// -----------------------------------------------------------------------------
//    File: torch_i_events.nss
//  System: Torch and Lantern (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "x2_inc_switches"
#include "torch_i_main"
#include "util_i_override"
#include "util_i_csvlists"

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

    int i;
    for (i = INVENTORY_SLOT_RIGHTHAND; i <= INVENTORY_SLOT_LEFTHAND; i++)
    {
        oItem = GetItemInSlot(i, oPC);
        sItem = GetTag(oItem);
        if (sItem == H2_TORCH || sItem == H2_LANTERN)
        {
            AssignCommand(oPC, ActionUnequipItem(oItem));
            Notice("Torch/Lantern Unequipped");
            Notice("  Variable --> " + (_GetLocalInt(oPC, "TORCH_EQUIPPED") ? "TRUE":"FALSE"));
            return;
        }
    }
}

void torch_OnClientEnter()
{
    object oPC = GetEnteringObject();
    int i;

    if (_GetIsPC(oPC))
    {
        object oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem))
        {
            if (HasListItem(H2_OLD_TORCH_TAGS, GetTag(oItem)))
            {
                DestroyObject(oItem);
                i++;
            }

            oItem = GetNextItemInInventory(oPC);
        }
    }

    DelayCommand(1.0, _CreateItemOnObject(H2_TORCH, oPC, i));
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
