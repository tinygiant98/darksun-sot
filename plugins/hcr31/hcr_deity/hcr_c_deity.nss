/// ----------------------------------------------------------------------------
/// @file:  hcr_c_deity.nss
/// @brief: HCR2 Deity System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 Deity Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the deity plugin is loaded or not. If you
/// want to control the deity system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the deity plugin will not be available to the module.
const int H2_DEITY_LOAD_PLUGIN = TRUE;

/// Set this value to the chance a player-character will be resurrected by their
/// chosen deity.  If the player does not have a chose deity, this value will
/// be ignored.  This value is clamped from 5-100.
const int H2_BASE_DEITY_REZ_CHANCE = 5;

/// Set this value to the additional chance (bonus) a player-character will
/// received per-level.  This value will be added to H2_BASE_DEITY_REZ_CHANCE to
/// determine a player-character's ultimate chance to be resurrected by their
/// chosen deity.  This value is clamped from 0-100.
const int H2_DEITY_REZ_CHANCE_PER_LEVEL = 0;

/// Set this value to the chance a player-character will be resurrected at the
/// location of their death.  This value is ignored if the player does not have
/// a chosen deity or fails the deity resurrection roll.  If the player fails
/// this check, the player will respawn at the specific or generic deity
/// resurrection waypoint.
const int H2_DEITY_REZ_AT_DEATH_LOCATION = 50;

/// Set this value to the generic deity waypoint a player-character will be
/// respawned at if they have a chosen deity, they pass the deity resurrection
/// check and the chosen deity does not have a specific deity resurrection
/// waypoint.
const string H2_GENERAL_DEITY_REZ_WAYPOINT = "H2_WP_DIETY_REZ";

// -----------------------------------------------------------------------------
//                         HCR2 Deity Translatable Text
// -----------------------------------------------------------------------------
/// @warning If modifying these values to use languages that are encoded using
///     other than Windows-1252, the file must be saved and compiled with the
///     appropriate encoding.

/// @note To use tlk entries for these values, you can modify the construction
///     using the following example:
/// string H2_TEXT_DEITY_REZZED = GetStringByStrRef(###);

const string H2_TEXT_DEITY_REZZED = "Your God has heard your prayers and ressurected you!";
const string H2_TEXT_DEITY_NO_REZ = "Your God has refused to hear your prayers.";
const string H2_TEXT_DM_DEITY_REZZED = /*GetName(oPC) + "_" + GetPCPlayerName(oPC) +*/
                                    " was ressurected by their deity: "; /* + GetDiety(oPC) */
