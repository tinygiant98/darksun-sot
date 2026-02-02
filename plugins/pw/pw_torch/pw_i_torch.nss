/// ----------------------------------------------------------------------------
/// @file   pw_i_torch.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Torch System (core).
/// ----------------------------------------------------------------------------

#include "util_i_data"
#include "util_i_time"
#include "pw_c_torch"
#include "pw_i_core"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string TORCH_TIMERID = "TORCH_TIMERID";
const string TORCH_ELAPSED_BURN = "TORCH_ELAPSED_BURN";
const string TORCH_LIGHT_EQUIPPED = "TORCH_LIGHT_EQUIPPED";
const string TORCH_EQUIPPING_PC = "TORCH_EQUIPPING_PC";
const string TORCH_EQUIPPED = "TORCH_EQUIPPED";
const string TORCH_NEEDS_OIL = "TORCH_NEEDS_OIL";
const string TORCH_IP_LIGHT = "TORCH_IP_LIGHT";
const string TORCH_LOCAL_VARIABLES = "TORCH_LOCAL_VARIABLES";

const string TORCH_ON_TIMER_EXPIRE = "TORCH_ON_TIMER_EXPIRE";
const string TORCH_EVENT_ON_TIMER_EXPIRE = "Torch_OnTimerExpire";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Remove tagged light item property.
/// @param oLantern Object to remove light item property from.
void torch_RemoveLight(object oLantern);

/// @brief Add tagged light item property.
/// @param oLantern Object to add light item property to.
void torch_AddLight(object oLantern);

/// @brief Calculate and start burn timer when equipping a light source.
/// @param bLantern TRUE if the light source is a lantern, FALSE if torch.
void torch_EquipLightSource(int bLantern);

/// @brief Calculate elapsed burn time and stop timer when unequipping a
///     light source.
/// @param bLantern TRUE if the light source is a lantern, FALSE if torch.
void torch_UnequipLightSource(int bLantern);

/// @brief Extinguish a light source when its burn duration has elapsed.
/// @param oLight Light source object to extinguish.
/// @param bLantern TRUE if the light source is a lantern, FALSE if torch.
void torch_ExtinguishLightSource(object oLight, int bLantern);

/// @brief Add burn time to a light source using an oil flask object.
/// @param oOilFlask Oil flask object used to refuel the light source.
/// @param oLantern Light source to refuel.
/// @note oOilFlask will be destroyed after use.
void torch_RefuelLightSource(object oOilFlask, object oLantern);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

json torch_GetLocalVariables(object oObject)
{
    json jVariables = GetLocalJson(oObject, TORCH_LOCAL_VARIABLES);
    if (JsonGetType(jVariables) == JSON_TYPE_NULL)
    {
        jVariables = JsonParse(r"
            {
                equipped_time: null,
                equipped_pc: null,
                timer_id: null,
                elapsed_burn: 0,
                needs_oil: 0
            }
        ");
    }

    SetLocalJson(oObject, TORCH_LOCAL_VARIABLES, jVariables);
    return jVariables;
}

/// @todo Not sure if this will work with inplace functions.
void torch_SetLocalInt(object oObject, string sVar, int nValue)
{
    json jVariables = GetLocalJson(oObject, TORCH_LOCAL_VARIABLES);

    jVariables = JsonObjectSet(jVariables, sVarName, JsonInt(nValue));
    SetLocalJson(oObject, TORCH_LOCAL_VARIABLES, jVariables);
}

void torch_RemoveLight(object oLantern)
{
    itemproperty ip = GetFirstItemProperty(oLantern);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyTag(ip) == TORCH_IP_LIGHT)
            RemoveItemProperty(oLantern, ip);
        ip = GetNextItemProperty(oLantern);
    }
}

void torch_AddLight(object oLantern)
{
    itemproperty ip = ItemPropertyLight(IP_CONST_LIGHTBRIGHTNESS_NORMAL, IP_CONST_LIGHTCOLOR_WHITE);
    AddItemProperty(DURATION_TYPE_PERMANENT, TagItemProperty(ip, TORCH_IP_LIGHT), oLantern);
}

void torch_EquipLightSource(int bLantern)
{
    object oLight = GetPCItemLastEquipped();
    object oPC = GetPCItemLastEquippedBy();
    int nDuration = TORCH_TORCH_DURATION;

    if (bLantern)
    {
        if (GetLocalInt(oLight, TORCH_NEEDS_OIL))
        {
            SendMessageToPC(oPC, TORCH_TEXT_LANTERN_OUT);
            return;
        }
        nDuration = TORCH_LANTERN_DURATION;
    }
    
    SetLocalString(oLight, TORCH_LIGHT_EQUIPPED, GetSystemTime());
    int nRemaining = nDuration - GetLocalInt(oLight, TORCH_ELAPSED_BURN);
    float fRemaining = (IntToFloat(nRemaining) / IntToFloat(nDuration)) * 100.0;
    SendMessageToPC(oPC, TORCH_TEXT_REMAINING_BURN + FloatToString(fRemaining, 5, 1));
    
    int nTimerID = CreateTimer(oLight, TORCH_EVENT_ON_TIMER_EXPIRE, IntToFloat(nRemaining), 1, 0.0);
    StartTimer(nTimerID, FALSE);
    SetLocalInt(oLight, TORCH_TIMERID, nTimerID);
    SetLocalObject(oLight, TORCH_EQUIPPING_PC, oPC);
    SetPlayerInt(oPC, TORCH_EQUIPPED, TRUE);
}

void torch_UnequipLightSource(int bLantern)
{
    object oPC = GetPCItemLastUnequippedBy();
    object oLight  = GetPCItemLastUnequipped();
    if (bLantern && GetLocalInt(oLight, TORCH_NEEDS_OIL))
        return;

    string timeEquipped = GetLocalString(oLight, TORCH_LIGHT_EQUIPPED);
    int elapsedBurn = GetLocalInt(oLight, TORCH_ELAPSED_BURN);
    elapsedBurn += FloatToInt(GetSystemTimeDifferenceIn(TIME_SECONDS, timeEquipped));
    SetLocalInt(oLight, TORCH_ELAPSED_BURN, elapsedBurn);
    
    KillTimer(GetLocalInt(oLight, TORCH_TIMERID));
    DeletePlayerInt(oPC, TORCH_EQUIPPED);
}

void torch_ExtinguishLightSource(object oLight, int bLantern)
{
    KillTimer(GetLocalInt(oLight, TORCH_TIMERID));

    object oPC = GetLocalObject(oLight, TORCH_EQUIPPING_PC);
    if (bLantern)
    {
        SendMessageToPC(oPC, TORCH_TEXT_LANTERN_OUT);
        torch_RemoveLight(oLight);
        SetLocalInt(oLight, TORCH_NEEDS_OIL, TRUE);
        AssignCommand(oPC, ActionUnequipItem(oLight));
    }
    else
    {
        SendMessageToPC(oPC, TORCH_TEXT_TORCH_BURNED_OUT);
        AssignCommand(oPC, ActionUnequipItem(oLight));
        DestroyObject(oLight);
    }
}

void torch_RefuelLightSource(object oOilFlask, object oLantern)
{
    object oPC = GetItemActivator();
    if (oPC != GetItemPossessor(oLantern))
    {
        SendMessageToPC(oPC, TORCH_TEXT_TARGET_ITEM_MUST_BE_IN_INVENTORY);
        return;
    }
    if (!GetLocalInt(oLantern, TORCH_NEEDS_OIL))
    {
        SendMessageToPC(oPC, TORCH_TEXT_DOES_NOT_NEED_OIL);
        return;
    }
    if (GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC) == oLantern)
        AssignCommand(oPC, ActionUnequipItem(oLantern));
    
    torch_AddLight(oLantern);
    DeleteLocalInt(oLantern, TORCH_ELAPSED_BURN);
    DeleteLocalInt(oLantern, TORCH_NEEDS_OIL);
    DestroyObject(oOilFlask);
}

#include "x2_inc_switches"
#include "util_i_override"

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void torch_OnSpellHook()
{
    if (GetTag(GetSpellCastItem()) == TORCH_OILFLASK_RESREF && GetSpellId() == SPELL_GRENADE_FIRE)
    {
        if (d2() == 1)
        {
            SendMessageToPC(OBJECT_SELF, TORCH_TEXT_OIL_FLASK_FAILED_TO_IGNITE);
            SetModuleOverrideSpellScriptFinished();
        }
    }
}

void torch_OnClientLeave()
{
    object oPC = GetExitingObject();

    int i; for (i = INVENTORY_SLOT_RIGHTHAND; i <= INVENTORY_SLOT_LEFTHAND; i++)
    {
        object oItem = GetItemInSlot(i, oPC);
        string sItem = GetTag(oItem);
        if (sItem == TORCH_TORCH_RESREF || sItem == TORCH_LANTERN_RESREF)
        {
            AssignCommand(oPC, ActionUnequipItem(oItem));
            return;
        }
    }
}

void torch_OnClientEnter()
{
    object oPC = GetEnteringObject();
    int n;

    string sResRefs = GetStringLowerCase(TORCH_INVALID_RESREFS);

    if (_GetIsPC(oPC))
    {
        object oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem))
        {
            if (HasListItem(sResRefs, GetStringLowerCase(GetTag(oItem))))
            {
                DestroyObject(oItem);
                n++;
            }

            oItem = GetNextItemInInventory(oPC);
        }
    }

    DelayCommand(0.5, _CreateItemOnObject(TORCH_TORCH_RESREF, oPC, n));
}

void torch_oilflask()
{
    int nEvent = GetUserDefinedItemEventNumber();
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC   = GetItemActivator();
        object oItem = GetItemActivated();
        object oTarget = GetItemActivatedTarget();
        if (GetIsObjectValid(oTarget))
        {
            if (GetTag(oTarget) == TORCH_LANTERN_RESREF)
            {
                torch_RefuelLightSource(oItem, oTarget);
                return;
            }
        }

        SendMessageToPC(oPC, TORCH_TEXT_CANNOT_USE_ON_TARGET);
    }
}

void torch_torch()
{
    int nEvent = GetUserDefinedItemEventNumber();

    if (nEvent ==  X2_ITEM_EVENT_EQUIP)
        torch_EquipLightSource(GetTag(GetPCItemLastEquipped()) == TORCH_LANTERN_RESREF);
    else if (nEvent == X2_ITEM_EVENT_UNEQUIP)
        torch_UnequipLightSource(GetTag(GetPCItemLastUnequipped()) == TORCH_LANTERN_RESREF);
}

void torch_OnTimerExpire()
{
    torch_ExtinguishLightSource(OBJECT_SELF, GetTag(OBJECT_SELF) == TORCH_LANTERN_RESREF);
}
