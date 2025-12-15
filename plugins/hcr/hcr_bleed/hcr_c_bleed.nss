/// ----------------------------------------------------------------------------
/// @file   hcr_c_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed System (configuration).
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                           Translatable Text
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
//                         Configuration Settings
// -----------------------------------------------------------------------------

/// @brief This setting determines whether the HCR bleed system is loaded
///     during the module load process.
///     TRUE: Enable the HCR bleed system.
///     FALSE: Disable the HCR bleed system.
const int H2_BLEED_ENABLE_SYSTEM = TRUE;

/// @brief This setting defines the resref of the heal widget that will be
///     created in the player's inventory to allow them to attempt to heal
///     other players.
const string H2_BLEED_HEAL_WIDGET = "h2_healwidget";

// -----------------------------------------------------------------------------
//                         Configuration Functions
// -----------------------------------------------------------------------------

/// @brief This return value of this function defines the interval between
///     bleed checks.  Once initiated, the bleed system re-evaluates the
///     player on this interval to determine the next player state.
/// @param oPC The player character object to get the bleed check interval for.
/// @return The interval, in seconds of real time, between bleed checks.
float h2_GetBleedCheckInterval(object oPC)
{
    return 6.0;
}

/// @brief This return value of this function defines the interval between
///     self-recovery checks.  Since self-recovery is an unlikely event,
///     this setting can be set to a longer interval than the bleed check
///     interval to reduce the chances of self-recovery occurring by
///     reducing the number of self-recovery checks performed.
/// @param oPC The player character object to get the self-recovery check
///     interval for.
/// @return The interval, in seconds of real time, between self-recovery checks.
float h2_GetBleedStableInterval(object oPC)
{
    return h2_GetBleedCheckInterval(oPC) * 2.0;
}

/// @brief The return value of this function defines the chance a player
///     character will self-stabilize and stop the bleeding process.
/// @param oPC The player character object to get the self-stabilization
///     chance for.
/// @return The chance that a player character will self-stabilize [0..100].
/// @note This value will be internally clamped to [0..100].
int h2_GetBleedSelfStabilizeChance(object oPC)
{
    return 10;
}

/// @brief The return value of this function defines the chance a player
///     character will begin the recovery process after self-stabilizing.
/// @param oPC The player character object to get the self-recovery chance for.
/// @return The chance that a player character will begin recovery [0..100].
/// @note This value will be internally clamped to [0..100].
int h2_GetBleedSelfRecoveryChance(object oPC)
{
    return 10;
}

/// @brief The return value of this function defines the amount of hit points
///     a player character will lose if they have failed a bleed check.
/// @param oPC The player character object to get the bleed HP loss for.
/// @note This value will be internally minimized to at least 0HP.
int h2_GetBleedHPLoss(object oPC)
{
    return 1;
}

/// @brief The return value of this function defines the difficulty class
///     a player character must overcome to provide first aid to a dying
///     character.
/// @param oPC The dying player character object.
/// @param oHealer The player character object attempting to provide first aid.
/// @return The difficulty class to overcome to provide first aid.
/// @note This value will be internally minimized to at least DC 0.
int h2_GetBleedFirstAidDC(object oPC, object oHealer)
{
    return 15;
}

/// @brief The return value of this function defines the difficulty class
///     a player character must overcome to provide long-term care to
///     a stabilized character.
/// @param oPC The stabilized player character object.
/// @param oHealer The player character object attempting to provide
///     long-term care.
/// @return The difficulty class to overcome to provide long-term care.
/// @note This value will be internally minimized to at least DC 0.
int h2_GetBleedLongTermCareDC(object oPC, object oHealer)
{
    return 15;
}
