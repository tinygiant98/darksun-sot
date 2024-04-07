/// ----------------------------------------------------------------------------
/// @file:  hcr_c_unid.nss
/// @brief: HCR2 UnID System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 UnID Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the bleed plugin is loaded or not. If you
/// want to control the bleed system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the bleed plugin will not be available to the module.
const int H2_UNID_LOAD_PLUGIN = TRUE;

/// Set this value to the time in real-world seconds that an unacquired item
/// will become unidentified.  If the item contains and integer variable named
/// H2_NO_UNID set to TRUE/1 or the item's value is less than H2_UNID_MINIMUM_VALUE
/// set below, the item will remain identified.
const int H2_UNID_DELAY = 300;

/// Set this value to the toal gold piece value an item must exceed for the item
/// to become unidentified after it is unacquired and the interval set in
/// H2_UNID_DELAY above has elapsed.
const int H2_UNID_MINIMUM_VALUE = 5;
