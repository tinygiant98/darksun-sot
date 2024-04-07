/// ----------------------------------------------------------------------------
/// @file:  hcr_c_loot.nss
/// @brief: HCR2 Loot System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 Loot Configuration Options
// ------------------------------------------------------------------------------

/// This value determines whether the loot plugin is loaded or not. If you
/// want to control the loot system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the loot plugin will not be available to the module.
const int H2_LOOT_LOAD_PLUGIN = FALSE;

/// This is the resref of the item that will be used to hold all items that are
/// looted from the PC corpse when the PC is dying or dead.
const string H2_LOOT_BAG = "h2_lootbag";
