// -----------------------------------------------------------------------------
//    File: pw_i_unid.nss
//  System: UnID Item on Drop
// -----------------------------------------------------------------------------
// Description:
//  Primary include for PW UnID system
// -----------------------------------------------------------------------------
// Builder Use:
//  Configuration options can be changed here
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "pw_c_unid"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

//This is the name of the integer variable to set on an item if the item is not
//  to be unidentified when it is unacquired.  If the variable is not set, or is
//  set to 0, the item will be unidentified when the time requirement is met.
//  If this variable is set to any integer value above 0 (normally 1), the item
//  will not be unidentified when unacquired.
const string H2_NO_UNID = "H2_DO_NOT_UNID";

// -----------------------------------------------------------------------------
//                               Primary Functions
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< h2_UnID >---
// Sets an unacquired item as unidentifed, assuming the item has not been
//  acquired during the UnID delay (H2_UNID_DELAY) set in unid_i_config.
void h2_UnID(object oItem);

// ---< h2_UnIDOnDrop >---
// Deploys a DelayCommand function to UnID the unacquired item if the items
//  meets minimuma value requirements as set on H2_UNID_MINIMUM_VALUE in
//  unid_i_config.
void h2_UnIDOnDrop(object oItem);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_UnID(object oItem)
{
    if (GetItemPossessor(oItem) == OBJECT_INVALID)
        SetIdentified(oItem, FALSE);
}

void h2_UnIDOnDrop(object oItem)
{
    if (GetItemPossessor(oItem) == OBJECT_INVALID &&
        !GetLocalInt(oItem, H2_NO_UNID) &&
        GetGoldPieceValue(oItem) > H2_UNID_MINIMUM_VALUE)
    {
        DelayCommand(IntToFloat(H2_UNID_DELAY), h2_UnID(oItem));
    }
}

// -----------------------------------------------------------------------------
//                               Event Management
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< unid_OnUacquireItem >---
// Wrapper function for module-level OnUnacquireItem event.  This function is
//  registered as a library function and an event function in pw_l_plugin.
void unid_OnUacquireItem();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void unid_OnUnacquireItem()
{
    h2_UnIDOnDrop(GetModuleItemLost());
}
