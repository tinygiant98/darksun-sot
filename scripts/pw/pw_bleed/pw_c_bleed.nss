/// ----------------------------------------------------------------------------
/// @file   pw_c_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the bleed system.
const int BLEED_ACTIVE = TRUE;

/// @brief Set this value to amount of time in real-world seconds between bleed
///     checks for a dying player character.
/// @note 6.0 seconds = 1 heartbeat/combat round
const float BLEED_CHECK_DELAY = 6.0;

/// @brief Set this value to the amount of time in real-world seconds that elapses
///     before a stable player character nexts checks to see if they begin to
///     recover.
float BLEED_STABLE_DELAY = BLEED_CHECK_DELAY * 2.0;

/// @brief Set this value to the percentage chance that a player character will self-
///     stabilize and stop bleeding when dying.
/// @note This value will be clamped from 0 - 100.
const int BLEED_SELF_STABILIZE_CHANCE = 10;

/// @brief Set this value to the percentage chance that a player character will
///     regain consciousness and begin recovery after self-stabilizing.
/// @note This value will be clamped from 0 - 100.
/// @note This value will only be checked if the player character self-stabilizes.
const int BLEED_SELF_RECOVERY_CHANCE = 10;

/// @brief Set this value to the number of hit points a player character loses each
///     time they fail a bleed check.
const int BLEED_HP_LOSS = 1;

/// @brief Set this value to the difficulty class (DC) of the heal check for a player
///     attempting to use their heal skill to stabilize a dying player character.
const int BLEED_FIRST_AID_DC = 15;

/// @brief Set this value to the difficulty class (DC) of the heal check for a player
///     attempting to provide long-term care to a recovering player character.
const int BLEED_LONG_TERM_CARE_DC = 15;
