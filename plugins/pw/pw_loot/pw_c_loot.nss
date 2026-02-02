/// ----------------------------------------------------------------------------
/// @file   pw_c_loot.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Loot System (configuration).
/// ----------------------------------------------------------------------------

/// @brief Set this value to FALSE to prevent the loot system plugin from
///     intializing.  If FALSE, no loot functionality will be available.
const int LOOT_SYSTEM_ENABLED = FALSE;

/// @brief Set this value to the resref of the placeable object that will
///     be created to hold a character's inventory items when they are
///     dead or dying.
const string LOOT_BAG_RESREF = "loot_lootbag";
