/// ----------------------------------------------------------------------------
/// @file:  hcr_c_bleed.nss
/// @brief: HCR2 Bleed System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 Bleed Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the bleed plugin is loaded or not. If you
/// want to control the bleed system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the bleed plugin will not be available to the module.
const int H2_BLEED_LOAD_PLUGIN = TRUE;

/// Set this value to the amount of time, in seconds, between bleed checks while
/// a player character is dying.  This is real time, not game time.  Normally,
/// this value would be set to 6.0, which is the length of a standard NWN turn
/// and the length of object heartbeats. 
const float H2_BLEED_INTERVAL = 6.0;

/// Set this value to the amount of time, in seconds, between stable checks while
/// a player character is dying.  This is real time, not game time.
float H2_STABLE_INTERVAL = H2_BLEED_INTERVAL * 2.0;

/// Set this value to the percentage chance a player character has to stabilize and
/// stop bleeding, without outside intervention.  This value is clamped from
/// 0-100.
const int H2_SELF_STABILIZE_CHANCE = 10;

/// Set this value to the percentage chance a player character has to regain
/// consicousness and begin recovery after self-stabilizing.  This value is clamped
/// from 0-100.
const int H2_SELF_RECOVERY_CHANCE = 10;

/// Set this value to the number of HP lost each time the bleed system cycles,
/// based on H2_BLEED_INTERVAL, set above.  HP will not be lost if the player-character
/// successfully self-stabilizes.  This value should be positive.  If this value is
/// negative, this plugin will use the absolute value.
const int H2_BLEED_HP_LOSS = 1;

/// Set this value to the base difficuly class (DC) a player-character must exceed
/// to successfully provide first aid and stabilize a player-character that is bleeding.
const int H2_FIRST_AID_DC = 15;

/// Set this value to the base difficulty class (DC) a player-character must exceed
/// to successfully provide long term care for a player-character that is bleeding.
const int H2_LONG_TERM_CARE_DC = 15;

// -----------------------------------------------------------------------------
//                         HCR2 Bleed Translatable Text
// -----------------------------------------------------------------------------
/// @warning If modifying these values to use languages that are encoded using
///     other than Windows-1252, the file must be saved and compiled with the
///     appropriate encoding.

/// @note To use tlk entries for these values, you can modify the construction
///     using the following example:
/// string H2_TEXT_RECOVERED_FROM_DYING = GetStringByStrRef(###);

const string H2_TEXT_RECOVERED_FROM_DYING = "You have become revived and are no longer in danger of bleeding to death.";
const string H2_TEXT_PLAYER_STABLIZED = "Your wounds have stopped bleeding, and you are stable, but still unconcious.";
const string H2_TEXT_WOUNDS_BLEED = "Your wounds continue to bleed. You get ever closer to death.";
const string H2_TEXT_FIRST_AID_SUCCESS = "You have sucessfully rendered aid.";
const string H2_TEXT_FIRST_AID_FAILED = "You have failed to render aid.";
const string H2_TEXT_ALREADY_TENDED = "This person has already been tended to.";
const string H2_TEXT_CANNOT_RENDER_AID = "It is too late to render any aid for this person.";
const string H2_TEXT_DOES_NOT_NEED_AID = "This person is not in need of any aid.";
const string H2_TEXT_ATTEMPT_LONG_TERM_CARE = "You have attempted to provide long-term care to this person.";
const string H2_TEXT_RECEIVE_LONG_TERM_CARE = "An attempt to provide you with long-term care has been made.";
