/// -----------------------------------------------------------------------------
/// @file:  hcr_i_torch.nss
/// @brief: HCR2 Torch System (core)
/// -----------------------------------------------------------------------------

#include "util_i_data"
#include "util_i_time"
#include "hcr_c_torch"
#include "hcr_i_core"
#include "x2_inc_switches"
#include "util_i_override"

// -----------------------------------------------------------------------------
//                         Variable Name Constants
// -----------------------------------------------------------------------------

const string H2_OLD_TORCH_TAGS = "NW_IT_TORCH001";
const string H2_LIGHT_TIMER = "h2_lighttimer";
const string H2_LIGHT_TIMERID = "H2_LIGHT_TIMERID";
const string H2_ELAPSED_BURN = "H2_ELAPSEDBURN";
const string H2_LIGHT_EQUIPPED = "H2_LIGHT_EQUIPPED";
const string H2_EQUIPPINGPC = "H2_EQUIPPINGPC";
const string H2_NEEDS_OIL = "H2_NEEDS_OIL";

const string H2_TORCH_ON_TIMER_EXPIRE = "H2_TORCH_ON_TIMER_EXPIRE";
const string TORCH_EVENT_ON_TIMER_EXPIRE = "Torch_OnTimerExpire";

const string H2_TORCH_EQUIPPED = "H2_TORCH_EQUIPPED";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event script for module-level OnSpellHook event.  Provides
///     a chance for failure to light an oil flask when used as a grenade.
void torch_OnSpellHook();

/// @brief Event script for module-level OnClientLeave event.  Ensures
///     players do not have lanterns or torches equipped when logging out.
void torch_OnClientLeave();

/// @brief Event script for module-level OnClientEnter event.  Destroys any
///     torches that are not tagged H2_TORCH and replaces them with hcr torches.
void torch_OnClientEnter();

/// @brief Tag-based script for oil flask items.  Refills an empty lantern.
void torch_oilflask();

/// @brief Tag-based script for torch items.  Adds/removes the light property
///     from the torch when equipped/unequipped.
void torch_torch();

/// @brief Timer expiration script for the lantern or torch object running out
///     of fuel (lantern) or burn time (torch).  Forces the player to either
///     replace the torch or refill the lantern.
void torch_OnTimerExpire();

/// @brief Remove ITEM_PROPERTY_LIGHT from oLantern, if it exists.
/// @param oLantern Lantern item to remove light property from.
void h2_RemoveLight(object oLantern);

/// @brief Adds ITEM_PROPERTY_LIGHT of normal brightness and color white to
///     oLantern.
/// @param oLantern Lantern item to add light property to.
void h2_AddLight(object oLantern);

/// @brief Determines whether a lantern/torch has enough fuel or burn time
///     to be used once equipped or use by a player character.
/// @param bLantern TRUE/FALSE, whether the equipped item is a lantern.
void h2_EquippedLightSource(int bLantern);

/// @brief Stops timers associated with lantern/torch use when the item
///     is unequipped or no longer being used.
/// @param bLantern TRUE/FALSE, whether the unequipped item is a lantern.
void h2_UnEquipLightSource(int bLantern);

/// @brief Removes the light source's ITEM_PROPERTY_LIGHT when it runs our of
///     fuel (lantern) or burn time (torch); the light source is either
///     unequipped (lantern) or destroyed (torch).
/// @param oLight Light source object (lantern/torch).
/// @param bLantern TRUE/FALSE, whether oLight is a lantern.
void h2_BurnOutLightSource(object oLight, int bLantern);

/// @brief Adds burn time to a lantern object and destroys the oil flask used
///     to provide fuel to the lantern.
/// @param oOilFlask Oil flask/fuel source object.
/// @param oLantern Lantern object to refuel.
void h2_FillLantern(object oOilFlask, object oLantern);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_RemoveLight(object oLantern)
{
    itemproperty ip = GetFirstItemProperty(oLantern);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_LIGHT)
            RemoveItemProperty(oLantern, ip);
        ip = GetNextItemProperty(oLantern);
    }
}

void h2_AddLight(object oLantern)
{
    itemproperty light = ItemPropertyLight(IP_CONST_LIGHTBRIGHTNESS_NORMAL, IP_CONST_LIGHTCOLOR_WHITE);
    AddItemProperty(DURATION_TYPE_PERMANENT, light, oLantern);
}

void h2_EquippedLightSource(int bLantern)
{
    object oLight = GetPCItemLastEquipped();
    object oPC = GetPCItemLastEquippedBy();
    int burncount = H2_TORCH_BURN_COUNT;

    if (bLantern)
    {
        if (GetLocalInt(oLight, H2_NEEDS_OIL))
        {
            SendMessageToPC(oPC, H2_TEXT_LANTERN_OUT);
            return;
        }
        burncount = H2_LANTERN_BURN_COUNT;
    }
    
    SetLocalString(oLight, H2_LIGHT_EQUIPPED, GetSystemTime());
    int elapsedBurn = GetLocalInt(oLight, H2_ELAPSED_BURN);
    int burnLeft = burncount - elapsedBurn;
    float percentRemaining = (IntToFloat(burnLeft) / IntToFloat(burncount)) * 100.0;
    SendMessageToPC(oPC, H2_TEXT_REMAINING_BURN + FloatToString(percentRemaining, 5, 1));
    
    int timerID = CreateTimer(oLight, TORCH_EVENT_ON_TIMER_EXPIRE, IntToFloat(burnLeft), 1, 0.0, CORE_HOOK_TIMERS);
    StartTimer(timerID, FALSE);
    SetLocalInt(oLight, H2_LIGHT_TIMERID, timerID);
    SetLocalObject(oLight, H2_EQUIPPINGPC, oPC);
    SetPlayerInt(oPC, H2_TORCH_EQUIPPED, TRUE);
}

void h2_UnEquipLightSource(int bLantern)
{
    object oPC = GetPCItemLastUnequippedBy();
    object oLight  = GetPCItemLastUnequipped();
    if (bLantern && GetLocalInt(oLight, H2_NEEDS_OIL))
        return;

    string timeEquipped = GetLocalString(oLight, H2_LIGHT_EQUIPPED);
    int elapsedBurn = GetLocalInt(oLight, H2_ELAPSED_BURN);
    elapsedBurn += FloatToInt(GetSystemTimeDifferenceIn(TIME_SECONDS, timeEquipped));
    SetLocalInt(oLight, H2_ELAPSED_BURN, elapsedBurn);
    
    int timerID = GetLocalInt(oLight, H2_LIGHT_TIMERID);
    KillTimer(timerID);
    DeletePlayerInt(oPC, H2_TORCH_EQUIPPED);
}

void h2_BurnOutLightSource(object oLight, int bLantern)
{
    int timerID = GetLocalInt(oLight, H2_LIGHT_TIMERID);
    KillTimer(timerID);

    object oPC = GetLocalObject(oLight, H2_EQUIPPINGPC);
    if (bLantern)
    {
        SendMessageToPC(oPC, H2_TEXT_LANTERN_OUT);
        h2_RemoveLight(oLight);
        SetLocalInt(oLight, H2_NEEDS_OIL, TRUE);
        AssignCommand(oPC, ActionUnequipItem(oLight));
    }
    else
    {
        SendMessageToPC(oPC, H2_TEXT_TORCH_BURNED_OUT);
        AssignCommand(oPC, ActionUnequipItem(oLight));
        DestroyObject(oLight);
    }
}

void h2_FillLantern(object oOilFlask, object oLantern)
{
    object oPC = GetItemActivator();
    if (oPC != GetItemPossessor(oLantern))
    {
        SendMessageToPC(oPC, H2_TEXT_TARGET_ITEM_MUST_BE_IN_INVENTORY);
        return;
    }
    if (!GetLocalInt(oLantern, H2_NEEDS_OIL))
    {
        SendMessageToPC(oPC, H2_TEXT_DOES_NOT_NEED_OIL);
        return;
    }
    if (GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC) == oLantern)
        AssignCommand(oPC, ActionUnequipItem(oLantern));
    h2_AddLight(oLantern);
    DeleteLocalInt(oLantern, H2_ELAPSED_BURN);
    DeleteLocalInt(oLantern, H2_NEEDS_OIL);
    DestroyObject(oOilFlask);
}

void torch_OnSpellHook()
{
    object oItem = GetSpellCastItem();
    int spellID = GetSpellId();
    if (GetTag(oItem) == H2_OILFLASK && GetSpellId() == SPELL_GRENADE_FIRE)
    {
        if (d2() == 1)
        {
            SendMessageToPC(OBJECT_SELF, H2_TEXT_OIL_FLASK_FAILED_TO_IGNITE);
            SetModuleOverrideSpellScriptFinished();
        }
    }
}

void torch_OnClientLeave()
{
    object oItem, oPC = GetExitingObject();
    string sItem;

    int i; for (i = INVENTORY_SLOT_RIGHTHAND; i <= INVENTORY_SLOT_LEFTHAND; i++)
    {
        oItem = GetItemInSlot(i, oPC);
        sItem = GetTag(oItem);
        if (sItem == H2_TORCH || sItem == H2_LANTERN)
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

    if (_GetIsPC(oPC))
    {
        object oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem))
        {
            if (HasListItem(H2_OLD_TORCH_TAGS, GetTag(oItem)))
            {
                DestroyObject(oItem);
                n++;
            }

            oItem = GetNextItemInInventory(oPC);
        }
    }

    DelayCommand(1.0, _CreateItemOnObject(H2_TORCH, oPC, n));
}

void torch_oilflask()
{
    int nEvent = GetUserDefinedItemEventNumber();
    // * This code runs when the Unique Power property of the item is used
    // * Note that this event fires PCs only
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC   = GetItemActivator();
        object oItem = GetItemActivated();
        object oTarget = GetItemActivatedTarget();
        if (GetIsObjectValid(oTarget))
        {
            if (GetTag(oTarget) == H2_LANTERN)
            {
                h2_FillLantern(oItem, oTarget);
                return;
            }
        }

        SendMessageToPC(oPC, H2_TEXT_CANNOT_USE_ON_TARGET);
    }
}

void torch_torch()
{
    int nEvent = GetUserDefinedItemEventNumber();

    if (nEvent ==  X2_ITEM_EVENT_EQUIP)
        h2_EquippedLightSource(GetTag(GetPCItemLastEquipped()) == H2_LANTERN);
    else if (nEvent == X2_ITEM_EVENT_UNEQUIP)
        h2_UnEquipLightSource(GetTag(GetPCItemLastUnequipped()) == H2_LANTERN);
}

void torch_OnTimerExpire()
{
    h2_BurnOutLightSource(OBJECT_SELF, GetTag(OBJECT_SELF) == H2_LANTERN);
}
