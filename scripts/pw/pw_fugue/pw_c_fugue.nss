/// ----------------------------------------------------------------------------
/// @file   pw_c_fugue.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Fugue Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the fugue system.
const int FUGUE_ACTIVE = TRUE;

/// @brief Set this value to the object tag of the area object that will be
///     used as the fugue plane.
const string FUGUE_PLANE = "h2_fugueplane";

/// @brief Set this value to the object tag of the waypoint object in this
///     fugue plane (FUGUE_PLANE above) that the PC will be sent to upon death.
const string FUGUE_WP = "H2_FUGUE";
