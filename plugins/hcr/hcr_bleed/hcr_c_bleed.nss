/// ----------------------------------------------------------------------------
/// @file   hcr_c_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed System (configuration)
/// ----------------------------------------------------------------------------

/// @section Translatable Text.  The following text values will be displayed
///     directly to the player.   These values can be modified or translated
///     as needed.

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

/// @section Configuration.  The following values should be modified to suit
///     the needs of the module.

/// @brief This setting determines whether the HCR bleed system is loaded
///     during the module load process.
///     TRUE: Enable the HCR bleed system.
///     FALSE: Disable the HCR bleed system.
const int H2_USE_BLEED_SYSTEM = TRUE;

/// @brief This setting defines the interval between bleed checks.  Once
///     initiated, the bleed system re-evaluate the player on this interval
///     to determine the next player state.
/// @note This value is seconds of real time, not game time.
const float H2_BLEED_INTERVAL = 6.0;

/// @brief This setting defines the interval between self-recovery checks.
///     Sine self-recovery is a more unlikely option, this setting can be
///     set to a longer interval than the bleed check interval to reduce
///     the chances of self-recovery occurring by reducing the number of
///     self-recovery checks performed.
/// @note This value is seconds of real time, not game time.
float H2_STABLE_INTERVAL = H2_BLEED_INTERVAL * 2.0;

/// @brief This setting defines the change a player charater will self-
///     stabilize and stop the bleeding process.
/// @note This value is a percentage change is clamped from [0..100].
const int H2_SELF_STABILIZE_CHANCE = 10;

/// @brief This setting defines the change a player character will begin
///     the recovery process after self-stabilizing.
/// @note This value is a percentage change is clamped from [0..100].
const int H2_SELF_RECOVERY_CHANCE = 10;

/// @brief This setting defines how many HP a player character will lose
///     if the system determines they are still bleeding.
/// @note This HP amount will be lost after each failed bleed check interval.
const int H2_BLEED_BLOOD_LOSS = 1;

/// @brief This setting defines the difficulty class a player character
///     must overcome to provide stabilizing first aid to a dying character.
const int H2_FIRST_AID_DC = 15;

/// @brief This setting defines the difficulty class a player character
///     must overcome to provide long-term care to a stabilized character.
const int H2_LONG_TERM_CARE_DC = 15;
