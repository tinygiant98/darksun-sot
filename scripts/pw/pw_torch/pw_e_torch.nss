/// ----------------------------------------------------------------------------
/// @file   pw_e_torch.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Torch Library (events)
/// ----------------------------------------------------------------------------

#include "x2_inc_switches"

#include "util_i_override"
#include "util_i_csvlists"

#include "pw_i_torch"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for OnSpellHook. Provides a chance of failure for
///     lighting an oil flask.
void torch_OnSpellHook();

/// @brief Event handler for oilflask tag-based scriptin.  Refills an empty
///     lantern.
void torch_oilflask();

/// @brief Event handler for torch tag-based scripting.  Adds or removes light
///     sourch from the torch when equipped/unequipped.
void torch_torch();

/// @brief Event handler for torch timer expiration.  Turns off the equipped
///     light source permanentl, forcing the player character to either
///     replace the torch or refill the lantern.
void torch_OnTimerExpire();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void torch_OnSpellHook()
{
    object oItem = GetSpellCastItem();
    int spellID = GetSpellId();
    if (HasListItem(OILFLASK_TAG, GetTag(oItem)) && GetSpellId() == SPELL_GRENADE_FIRE)
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
        if (HasListItem(TORCH_TAG, sItem) || HasListItem(LANTERN_TAG, sItem))
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

    DelayCommand(1.0, _CreateItemOnObject(GetListItem(TORCH_TAG), oPC, n));
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
            if (HasListItem(LANTERN_TAG, GetTag(oTarget)))
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
        h2_EquippedLightSource(HasListItem(LANTERN_TAG, GetTag(GetPCItemLastEquipped())));
    else if (nEvent == X2_ITEM_EVENT_UNEQUIP)
        h2_UnEquipLightSource(HasListItem(LANTERN_TAG, GetTag(GetPCItemLastUnequipped())));
}

void torch_OnTimerExpire()
{
    h2_BurnOutLightSource(OBJECT_SELF, HasListItem(LANTERN_TAG, GetTag(OBJECT_SELF)));
}
