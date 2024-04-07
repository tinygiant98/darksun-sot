/// ----------------------------------------------------------------------------
/// @file:  hcr_c_rest.nss
/// @brief: HCR2 Rest System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 Rest Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the bleed plugin is loaded or not. If you
/// want to control the bleed system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the bleed plugin will not be available to the module.
const int H2_REST_LOAD_PLUGIN = TRUE;

/// Set this value to the minimum time in real-world seconds that must elapse
/// since the last time a player character has rested and recovered spells, feats,
/// and health, for the same player to recover those properties again when they
/// rest.  Set this value to 0 to eliminate a minimum elapsed time between rests.
const int H2_MINIMUM_SPELL_RECOVERY_REST_TIME = 0;

/// Set this value to the number of hit points per level that are healed when
/// a player character rests.  This value is ignored if the time set in
/// H2_MINIMUM_SPELL_RECOVERY_REST_TIME above has not elapsed.  Set to -1 to allow
/// player characters to heal to maximum hit points.
const int H2_HP_HEALED_PER_REST_PER_LEVEL = -1;

/// Set this value to TRUE to create a blindness effect and snoring visual effect
/// on resting player characters.
const int H2_SLEEP_EFFECTS = TRUE;

/// Set this value to TRUE to require player characters to only rest within
/// designated resting triggers or within four (4) meters or a campfire.
const int H2_REQUIRE_REST_TRIGGER_OR_CAMPFIRE = FALSE;

/// Set this value to the maximum time in game-hours a campfire will burn once
/// it's lit.  Using firewood on an existing campfire will add this amount of
/// burn time to the campfire.
const int H2_CAMPFIRE_BURN_TIME = 3;

// If H2_REQUIRE_REST_TRIGGER_OR_CAMPFIRE (rest_i_config) is set to TRUE, the item
//  associated with H2_CAMPFIRE will be used to determine rest allowance/distance.
const string H2_CAMPFIRE = "h2_campfire";
const string H2_FIREWOOD = "h2_firewood";
