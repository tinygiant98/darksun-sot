/// ----------------------------------------------------------------------------
/// @file   pw_i_unid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  UnID System (core).
/// ----------------------------------------------------------------------------

#include "util_i_data"
#include "pw_c_unid"

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

/// @private Sets an unacquired item as unidentifed, assuming the item has not been
//  acquired during the UnID delay (UNID_DELAY) set in pw_c_unid.
void unid_UnID(object oItem)
{
    if (GetItemPossessor(oItem) == OBJECT_INVALID)
        SetIdentified(oItem, FALSE);
}

/// @private Deploys a DelayCommand function to UnID the unacquired item if the items
//      meets minimuma value requirements as set on UNID_MINIMUM_VALUE in pw_c_unid.
void unid_UnIDOnDrop(object oItem)
{
    if (GetItemPossessor(oItem) == OBJECT_INVALID &&
        !GetLocalInt(oItem, UNID_NO_UNID) &&
        GetGoldPieceValue(oItem) > UNID_MINIMUM_VALUE)
    {
        DelayCommand(UNID_DELAY * 1f, unid_UnID(oItem));
    }
}

/// @private OnUnacquireItem event handler.
void unid_OnUnacquireItem()
{
    unid_UnIDOnDrop(GetModuleItemLost());
}
