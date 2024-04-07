/// ----------------------------------------------------------------------------
/// @file:  hcr_c_fugue.nss
/// @brief: HCR2 Fugue System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 Fugue Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the fugue plugin is loaded or not. If you
/// want to control the fugue system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the fugue plugin will not be available to the module.
const int H2_FUGUE_LOAD_PLUGIN = TRUE;

/// Set this value to the tag of the area that will be used as the fugue plane.
const string H2_FUGUE_PLANE = "h2_fugueplane";

/// Set this value to the tag of the waypoint within the fugue plane (set above
/// in H2_FUGUE_PLANE) to send the player-character to upon death.
const string H2_WP_FUGUE = "H2_FUGUE";
