/// ----------------------------------------------------------------------------
/// @file   pw_i_itemid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Item Identification Library (core)
/// ----------------------------------------------------------------------------

#include "util_i_data"

#include "pw_c_itemid"
#include "pw_k_itemid"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Sets an unacquired item as unidentified, assuming the item has not
///     been acquired during the unid delay (pw_k_itemid: PW_ITEMID_UNID_DELAY).
void itemid_UnID(object oItem);

/// @brief Deploys a DelayCommand function to unid the unacquired item if the
///     item meets minimum gold piece value requirement (pw_k_itemid:
///     PW_ITEMID_UNID_MINIMUM_VALUE).
void itemid_UnIDOnDrop(object oItem);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void itemid_UnID(object oItem)
{
    if (GetItemPossessor(oItem) == OBJECT_INVALID)
        SetIdentified(oItem, FALSE);
}

void itemid_UnIDOnDrop(object oItem)
{
    if (GetItemPossessor(oItem) == OBJECT_INVALID &&
        !GetLocalInt(oItem, ITEMID_NO_UNID) &&
        GetGoldPieceValue(oItem) > ITEMID_UNID_MINIMUM_VALUE)
    {
        DelayCommand(IntToFloat(ITEMID_UNID_DELAY), itemid_UnID(oItem));
    }
}
