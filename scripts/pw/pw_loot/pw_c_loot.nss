/// ----------------------------------------------------------------------------
/// @file   pw_c_loot.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Loot Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the loot system.
const int LOOT_ACTIVE = FALSE;

/// @brief Set this value to the resref of the placeable object that will be
///     used to hold all items that are looted from the player character
///     corpse when the player character is dying or dead.
const string LOOT_PLACEABLE = "h2_lootbag";
