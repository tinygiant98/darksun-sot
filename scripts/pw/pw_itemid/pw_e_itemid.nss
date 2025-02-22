/// ----------------------------------------------------------------------------
/// @file   pw_e_itemid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Item Identification Library (events)
/// ----------------------------------------------------------------------------

#include "pw_i_itemid"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for module-level OnUnacquireItem event.
void itemid_OnUnacquireItem();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void itemid_OnUnacquireItem()
{
    itemid_UnIDOnDrop(GetModuleItemLost());
}
