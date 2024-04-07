/// -----------------------------------------------------------------------------
/// @file:  hcr_i_unid.nss
/// @brief: HCR2 UnID System (core)
/// -----------------------------------------------------------------------------

#include "util_i_data"
#include "hcr_c_unid"

// -----------------------------------------------------------------------------
//                         Variable Name Constants
// -----------------------------------------------------------------------------

const string H2_NO_UNID = "H2_DO_NOT_UNID";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event script for module-level OnUnacquireItem event.
void unid_OnUacquireItem();

/// @brief Sets an unacquired item as unidentified, assuming the items has
///     not be re-acquired during the UnID delay (H2_UNID_DELAY) set in
///     hcr_c_unid.nss.
/// @param oItem Unacquired item.
void h2_UnID(object oItem);

/// @brief Creates a delayed UnID command for any unacquired item if the item's
///     minimum value exceeds H2_UNID_MINIMUM_VALUE set in hcr_c_unid.nss and
///     the item does not have the override variable set.
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

void unid_OnUnacquireItem()
{
    h2_UnIDOnDrop(GetModuleItemLost());
}
