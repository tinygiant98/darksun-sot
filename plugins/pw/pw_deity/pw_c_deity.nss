/// ----------------------------------------------------------------------------
/// @file   pw_c_deity.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Deity Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the deity system.
const int DEITY_ACTIVE = FALSE;

/// @brief Set this value to the base percentage chance that a player character
///     will be resurrected by their chosen deity.
/// @note Value will be clamped to the range 0.0 - 100.0.
const float DEITY_REZ_CHANCE_BASE = 5.0;

/// @brief Set this value to the percentage per level that modifies
///     DEITY_REZ_CHANCE_BASE to determine the total percentage chance that
///     a player character will be resurrected by their chosen deity.
/// @note Value will be clamped to the range 0.0 - 100.0.
const float DEITY_REZ_CHANCE_PER_LEVEL = 0.0;

/// @brief Set this value to the percentage chance that the deity will resurrect
///     the player character at the location where the player character died.  If
///     the chance is missed, the player character will respawn at the deity's
///     specific resurrection point, or the generic point, if no deity is selected
///     or the selected deity does not have a specific resurrection point.
const int DEITY_REZ_AT_DEATH_LOCATION_CHANCE = 50;

/// @brief Set this value to the tag of the waypoint object that will be used as
///     a generic respawn/resurrection point for any player characters that have
///     not selected a deity or any deity that does not have a specified
///     respawn/resurrection point.
const string DEITY_REZ_GENERIC_WAYPOINT = "H2_WP_DIETY_REZ";
