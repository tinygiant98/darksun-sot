/// ----------------------------------------------------------------------------
/// @file   ds_c_fugue.nss
/// @author Anthony Sovaca (Jacyn)
/// @brief  Fugue System (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the angel system.
/// @note If the dead player is sent to the angel plane, all script
///     in pw_fugue will be aborted.
const int ANGEL_ACTIVE = FALSE;

/// @brief Set this value to the tag of the area that will act as the
///     angel's home.  This is the area the dead player will be sent if
///     they pass the chance check.
const string ANGEL_PLANE = "angelhome";

/// @brief Set this vvalue to the tag of the waypoint object in the
///     angel's home area that the dead player will be sent to.
const string WP_ANGEL = "ah_death";

/// @brief Set this value to the percentage change the dead player will
///     be sent to the angel plane.
/// @note This value will be clamped in the range 0 .. 100.
const int DS_FUGUE_ANGEL_CHANCE = 50;
