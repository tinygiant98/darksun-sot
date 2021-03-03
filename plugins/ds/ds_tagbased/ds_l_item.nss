// -----------------------------------------------------------------------------
//    File: ds_l_item.nss
//  System: Event Mangament
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"

/* Example
void item_tag()
{
    int nEvent = GetUserDefinedItemEventNumber();
    object oPC, oItem;

    if (nEvent == X2_ITEM_EVENT_ONHITCAST)
    {
        oItem = GetSpellCastItem();
        oPC = OBJECT_SELF;          // Same as Spell Origin
        object oSpellTarget = GetSpellTargetObject();


    }
    else if (nEvent == X2_ITEM_EVENT_ACTIVATE)
    {
        oItem = GetItemActivated();
        oPC = GetItemActivator();

    }
    else if (nEvent == X2_ITEM_EVENT_EQUIP)
    {
        oItem = GetPCItemLastEquipped();
        oPC = GetPCItemLastEquippedBy();

    }
    else if (nEvent == X2_ITEM_EVENT_UNEQUIP)
    {
        oItem = GetPCItemLastUnequipped();
        oPC = GetPCItemLastUnequippedBy();

    }
    else if (nEvent == X2_ITEM_EVENT_ACQUIRE)
    {
        oItem = GetModuleItemAcquired();
        oPC = GetModuleItemAcquiredBy();

    }
    else if (nEvent == X2_ITEM_EVENT_UNACQUIRE)
    {
        oItem = GetModuleItemLost();
        oPC = GetModuleItemLostBy();      

    }
    else if (nEvent == X2_ITEM_EVENT_SPELLCAST_AT)
    {
        oItem = GetSpellTargetObject();
        oPC = OBJECT_SELF;
        int nSpellID = GetSpellId();

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // RegisterLibraryScript("item_tag", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  item_tag();           break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
