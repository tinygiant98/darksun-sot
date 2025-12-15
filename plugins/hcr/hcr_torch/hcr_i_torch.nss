// -----------------------------------------------------------------------------
//    File: pw_i_torch.nss
//  System: Torch and Lantern (core)
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "util_i_time"
#include "hcr_c_torch"
#include "pw_i_core"

// -----------------------------------------------------------------------------
//                                   Constants
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

// -----------------------------------------------------------------------------
//                              Primary Functions
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< h2_RemoveLight >---
// Removes ITEM_PROPERTY_LIGHT from the passed object, if it exists.
void h2_RemoveLight(object oLantern);

// ---< h2_AddLigt >---
// Adds ItemPropertyLight of normal brightness and color white to the passed
//  object.
void h2_AddLight(object oLantern);

// ---< h2_EquippedLightSource >---
// When a PC uses a light source (torch/lantern), this function determines if it
//  has the necessary fuel (if required) and how much burn time is remaining.
void h2_EquippedLightSource(int isLantern);

// ---< h2_UnEquipLightSource >---
// When a PC stops using a light source, this function sets the appropriate
//  time variables and kills the associted timer.
void h2_UnEquipLightSource(int isLantern);

// ---< h2_BurnOutLightSource >---
// When a light source can no longer function (fuel/time), this function removes
//  the light source itemproperty and either unequips or destroys the light
//  source, depending on the type (lantern = unequip, torch = destroy)
void h2_BurnOutLightSource(object oLight, int isLantern);

// ---< h2_FillLantern >---
// When a lantern requires oil, this function will add burn time to the lantern
//  and destroy the oil flask used to fill it.  
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

void h2_EquippedLightSource(int isLantern)
{
    object oLight = GetPCItemLastEquipped();
    object oPC = GetPCItemLastEquippedBy();
    int burncount = H2_TORCH_BURN_COUNT;

    if (isLantern)
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
    
    int timerID = CreateTimer(oLight, TORCH_EVENT_ON_TIMER_EXPIRE, IntToFloat(burnLeft), 1, 0.0);
    StartTimer(timerID, FALSE);
    SetLocalInt(oLight, H2_LIGHT_TIMERID, timerID);
    SetLocalObject(oLight, H2_EQUIPPINGPC, oPC);
    SetPlayerInt(oPC, "TORCH_EQUIPPED", TRUE);
}

void h2_UnEquipLightSource(int isLantern)
{
    object oPC = GetPCItemLastUnequippedBy();
    object oLight  = GetPCItemLastUnequipped();
    if (isLantern && GetLocalInt(oLight, H2_NEEDS_OIL))
        return;

    string timeEquipped = GetLocalString(oLight, H2_LIGHT_EQUIPPED);
    int elapsedBurn = GetLocalInt(oLight, H2_ELAPSED_BURN);
    elapsedBurn += FloatToInt(GetSystemTimeDifferenceIn(TIME_SECONDS, timeEquipped));
    SetLocalInt(oLight, H2_ELAPSED_BURN, elapsedBurn);
    
    int timerID = GetLocalInt(oLight, H2_LIGHT_TIMERID);
    KillTimer(timerID);
    DeletePlayerInt(oPC, "TORCH_EQUIPPED");
}

void h2_BurnOutLightSource(object oLight, int isLantern)
{
    int timerID = GetLocalInt(oLight, H2_LIGHT_TIMERID);
    KillTimer(timerID);

    object oPC = GetLocalObject(oLight, H2_EQUIPPINGPC);
    if (isLantern)
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

// -----------------------------------------------------------------------------
//                              Event Management
// -----------------------------------------------------------------------------

#include "x2_inc_switches"
#include "util_i_override"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< torch_OnSpellHook >---
// This function is a library and event registered script for the module
//  level event OnSpellHook.  This function provides a chance of failure for
//  lighting an oil flask.
void torch_OnSpellHook();

// ---< torch_oilflask >---
// This function is tag-based scripting used to refill an empty lantern
void torch_oilflask();

// ---< torch_torch >---
// This function is tag-based scripting used to add or remove light from the
//  torch when it is equipped/unequipped.
void torch_torch();

// ---< torch_OnTimerExpire >---
// This function turns off the equipped light source permanently, forcing the
// PC to either replace the torch or refill the lantern.

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Module Events -----

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

// ----- Tag-based Scripting -----

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

// ----- Timer Events -----

void torch_OnTimerExpire()
{
    h2_BurnOutLightSource(OBJECT_SELF, GetTag(OBJECT_SELF) == H2_LANTERN);
}
