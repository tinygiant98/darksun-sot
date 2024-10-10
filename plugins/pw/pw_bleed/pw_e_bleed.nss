/// ----------------------------------------------------------------------------
/// @file   pw_e_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed Library (events)
/// ----------------------------------------------------------------------------

#include "x2_inc_switches"

#include "pw_i_bleed"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for OnClientEnter.  Ensures each entering player has a
///    Heal Widget in their inventory.
void bleed_OnClientEnter();

/// @brief Handler for OnPlayerDeath.  Starts the bleed functions if the player
///     is not dead.
void bleed_OnPlayerDeath();

/// @brief Handler for OnPlayerRestStarted.  Sets the maximum amount of healing
///     a player character can recover during a rest period.
void bleed_OnPlayerRestStarted();

/// @brief Handler for OnPlayerDying.  Marks the player character as dying and
///     starts the bleed functions.
void bleed_OnPlayerDying();

/// @brief Tag-bsed scripting handler for heal widget item.
void bleed_healwidget();

/// @brief Time expiration handler for bleed timer.  Applies additional damage,
///     checks for self-stabilization, or kills the PC, as required by the
///     bleed system and custom settings.
void bleed_OnTimerExpire();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void bleed_OnClientEnter()
{
    object oPC = GetEnteringObject();
    object oHealWidget = GetItemPossessedBy(oPC, H2_HEAL_WIDGET);
    if (!GetIsObjectValid(oHealWidget))
        CreateItemOnObject(H2_HEAL_WIDGET, oPC);
}

void bleed_OnPlayerRestStarted()
{
    object oPC = GetLastPCRested();
    if (GetPlayerInt(oPC, H2_LONG_TERM_CARE) && h2_GetPostRestHealAmount(oPC) > 0)
    {
        DeletePlayerInt(oPC, H2_LONG_TERM_CARE);
        int postRestHealAmt = h2_GetPostRestHealAmount(oPC) * 2;
        h2_SetPostRestHealAmount(oPC, postRestHealAmt);
    }
}

void bleed_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    int timerID = GetPlayerInt(oPC, H2_BLEED_TIMER_ID);

    if (timerID)
    {
        DeletePlayerInt(oPC, H2_BLEED_TIMER_ID);
        KillTimer(timerID);
    }
}

void bleed_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (GetPlayerInt(oPC, H2_PLAYER_STATE) == H2_PLAYER_STATE_DYING)
        h2_BeginPlayerBleeding(oPC);
}

void bleed_healwidget()
{
    int nEvent = GetUserDefinedItemEventNumber();

    // * This code runs when the Unique Power property of the item is used
    // * Note that this event fires PCs only
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oTarget = GetItemActivatedTarget();
        if (GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
            return;
            
        h2_UseHealWidgetOnTarget(oTarget);
    }
}

void bleed_OnTimerExpire()
{
    object oPC = OBJECT_SELF;
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    if (nPlayerState != H2_PLAYER_STATE_DYING && nPlayerState != H2_PLAYER_STATE_STABLE &&
        nPlayerState != H2_PLAYER_STATE_RECOVERING)
    {
        int nTimerID = GetLocalInt(oPC, H2_BLEED_TIMER_ID);
        DeletePlayerInt(oPC, H2_BLEED_TIMER_ID);
        DeletePlayerInt(oPC, H2_TIME_OF_LAST_BLEED_CHECK);
        KillTimer(nTimerID);
    }
    else
    {
        int nCurrHitPoints = GetCurrentHitPoints(oPC);
        if (nCurrHitPoints > 0)
        {
            h2_MakePlayerFullyRecovered(oPC);
            return;
        }

        int nLastHitPoints = GetPlayerInt(oPC, H2_LAST_HIT_POINTS);
        if (nCurrHitPoints > nLastHitPoints)
        {
            h2_StabilizePlayer(oPC);
            return;
        }

        if (nCurrHitPoints > -10)
            h2_CheckForSelfStabilize(oPC);
        else
        {
            SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_DEAD);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
        }
    }
}
