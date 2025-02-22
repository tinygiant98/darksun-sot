/// ----------------------------------------------------------------------------
/// @file   ds_l_item.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_data"

/*
void item_tag()
{
    int nEvent = GetUserDefinedItemEventNumber();
    object oPC, oItem;

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
        oItem = GetModuleItemAcquired();`
        oPC = GetModuleItemAcquiredBy();

    }
    else if (nEvent == X2_ITEM_EVENT_UNACQUIRE)
    {
        oItem = GetModuleItemLost();
        oPC = GetModuleItemLostBy();      

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    int n;
    // RegisterLibraryScript("item_tag", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            //if      (nEntry == n++) item_tag();
            //else if (nEntry == n++) something_else();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_item.nss");
    }
}
