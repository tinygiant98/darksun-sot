/// ----------------------------------------------------------------------------
/// @file   hcr_i_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed System (core)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Module Events
// -----------------------------------------------------------------------------

/// @brief H2_BLEED_EVENT_ON_TIMER_EXPIRE.  This event is triggered when a
///     running bleed timer expires after the interval defined the bleed system
///     configuration.
/// @param OBJECT_SELF The dying player character whose bleed time has expired.
/// @note Using a lower priority than the bleed systems OnTimerExpire event will
///     allow this system to fully process bleed actions and set the player state
///     before other event scripts are run.

#include "util_i_data"
#include "core_i_framework"
#include "hcr_c_bleed"
#include "hcr_i_core"

const string H2_BLEED_LAST_HIT_POINTS = "H2_BLEED_LAST_HIT_POINTS";
const string H2_BLEED_TIMER_ID = "H2_BLEED_TIMER_ID";
const string H2_BLEED_TIME_OF_LAST_BLEED_CHECK = "H2_BLEED_TIME_OF_LAST_BLEED_CHECK";
const string H2_BLEED_LONG_TERM_CARE = "H2_BLEED_LONG_TERM_CARE";
const string H2_BLEED_EVENT_ON_TIMER_EXPIRE = "H2_BLEED_EVENT_ON_TIMER_EXPIRE";

// -----------------------------------------------------------------------------
//                        System Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates and starts a timer to control a dying player's bleeding
///     process.
/// @param oPC The player character object to start the bleeding process for.
void h2_BeginPlayerBleeding(object oPC);

/// @brief Makes the player fully recover from a dying or stable state.
/// @param oPC The player character object to make fully recovered.
/// @note This brings oPC to 1 HP and sets their player state to H2_PLAYER_STATE_ALIVE.
void h2_MakePlayerFullyRecovered(object oPC);

/// @brief Sets the player's state to H2_PLAYER_STATE_STABLE or makes them fully
///     recovered if the player's state is H2_PLAYER_STATE_STABLE.
/// @param oPC The player character object to stabilize or make fully recovered.
/// @param bDoFullRecovery If TRUE, makes oPC fully recovered if they are stable.
void h2_StabilizePlayer(object oPC, int bDoFullRecovery = FALSE);

/// @brief Applies bleed damage to the player character.
/// @param oPC The player character object to apply bleed damage to.
void h2_DoBleedDamageToPC(object oPC);

/// @brief Checks to see if the player character can self-stabilize; if not,
///    applies bleed damage.
/// @param oPC The player character object to check for self-stabilization.
void h2_CheckForSelfStabilize(object oPC);

/// @brief Handle application of the heal widget on a creature object.
/// @param oTarget The target object the heal widget is being used on.
void h2_UseHealWidgetOnTarget(object oTarget);

// -----------------------------------------------------------------------------
//                        System Function Definitions
// -----------------------------------------------------------------------------

/// @private Ensures the user-provided self-stabilization chance configuration
///     value is within an acceptable range.
int _GetSelfStabilizeChance(object oPC)
{
    return clamp(h2_GetBleedSelfStabilizeChance(oPC), 0, 100);
}

/// @private Ensures the user-provided self-recovery chance configuration
///     value is within an acceptable range.
int _GetSelfRecoveryChance(object oPC)
{
    return clamp(h2_GetBleedSelfRecoveryChance(oPC), 0, 100);
}

/// @private Ensure the user-provided bleed HP loss configuration value is
///     at least 0HP.
int _GetHPLoss(object oPC)
{
    return max(h2_GetBleedHPLoss(oPC), 0);
}

/// @private Ensure the user-provided difficulty class for first-aid checks
///     is at least 0.
int _GetFirstAidDC(object oPC, object oHealer)
{
    return max(h2_GetBleedFirstAidDC(oPC, oHealer), 0);
}

/// @private Ensure the user-provided difficulty class for long-term care checks
///     is at least 0.
int _GetLongTermCareDC(object oPC, object oHealer)
{
    return max(h2_GetBleedLongTermCareDC(oPC, oHealer), 0);
}


void h2_BeginPlayerBleeding(object oPC)
{
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, H2_BLEED_LAST_HIT_POINTS, nCurrentHitPoints);
    
    int nTimer = CreateTimer(oPC, H2_BLEED_EVENT_ON_TIMER_EXPIRE, h2_GetBleedCheckInterval(oPC));
    SetLocalInt(oPC, H2_BLEED_TIMER_ID, nTimer);
    StartTimer(nTimer, FALSE);
}

void h2_MakePlayerFullyRecovered(object oPC)
{
    int nCurrHitPoints = GetCurrentHitPoints(oPC);
    if (nCurrHitPoints <= 0)
    {
        effect eHeal = EffectHeal(1 - nCurrHitPoints);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oPC);
    }

    SendMessageToPC(oPC, H2_TEXT_RECOVERED_FROM_DYING);
    DeleteLocalString(oPC, H2_BLEED_TIME_OF_LAST_BLEED_CHECK);
    SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    //TODO: make monsters go hostile to PC again?
}

void h2_StabilizePlayer(object oPC, int bNaturalHeal = FALSE)
{
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, H2_BLEED_LAST_HIT_POINTS, nCurrentHitPoints);
    if (nPlayerState == H2_PLAYER_STATE_DYING)
    {
        SendMessageToPC(oPC, H2_TEXT_PLAYER_STABLIZED);
        if (bNaturalHeal)
            SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_STABLE);
        else
            SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_RECOVERING);
        
        SetPlayerString(oPC, H2_BLEED_TIME_OF_LAST_BLEED_CHECK, GetSystemTime());
    }
    else if (bNaturalHeal)
        h2_MakePlayerFullyRecovered(oPC);
    else
        SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_RECOVERING);
}

void h2_DoBleedDamageToPC(object oPC)
{
    SetPlayerString(oPC, H2_BLEED_TIME_OF_LAST_BLEED_CHECK, GetSystemTime());
    SetPlayerInt(oPC, H2_BLEED_LAST_HIT_POINTS, GetCurrentHitPoints(oPC));
    
    if (GetPlayerInt(oPC, H2_PLAYER_STATE) == H2_PLAYER_STATE_RECOVERING)
        return;

    switch(d6())
    {
        case 1: PlayVoiceChat(VOICE_CHAT_HELP, oPC); break;
        case 2: PlayVoiceChat(VOICE_CHAT_PAIN1, oPC); break;
        case 3: PlayVoiceChat(VOICE_CHAT_PAIN2, oPC); break;
        case 4: PlayVoiceChat(VOICE_CHAT_PAIN3, oPC); break;
        case 5: PlayVoiceChat(VOICE_CHAT_HEALME, oPC); break;
        case 6: PlayVoiceChat(VOICE_CHAT_NEARDEATH, oPC); break;
    }

    SendMessageToPC(oPC, H2_TEXT_WOUNDS_BLEED);

    effect eBloodloss = EffectDamage(_GetHPLoss(oPC), DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eBloodloss, oPC);
}

void h2_CheckForSelfStabilize(object oPC)
{
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    int nStabilizeChance = _GetSelfStabilizeChance(oPC);
    
    if (nPlayerState == H2_PLAYER_STATE_STABLE || nPlayerState == H2_PLAYER_STATE_RECOVERING)
        nStabilizeChance = _GetSelfRecoveryChance(oPC);

    string sLastBleedCheck = GetPlayerString(oPC, H2_BLEED_TIME_OF_LAST_BLEED_CHECK);
    float fSecondsSinceLastBleedCheck = GetSystemTimeDifferenceIn(TIME_SECONDS, sLastBleedCheck);

    if (nPlayerState == H2_PLAYER_STATE_DYING || fSecondsSinceLastBleedCheck >= h2_GetBleedStableInterval(oPC))
    {
        if (d100() <= nStabilizeChance)
            h2_StabilizePlayer(oPC, TRUE);
        else
            h2_DoBleedDamageToPC(oPC);
    }
}

void h2_UseHealWidgetOnTarget(object oTarget)
{
    object oUser = GetItemActivator();
    
    if (_GetIsPC(oTarget))
    {
        if (oTarget == oUser)
        {
            SendMessageToPC(oUser, H2_TEXT_CANNOT_USE_ON_SELF);
            return;
        }

        int nPlayerState = GetPlayerInt(oTarget, H2_PLAYER_STATE);
        switch (nPlayerState)
        {
            case H2_PLAYER_STATE_DEAD:
                SendMessageToPC(oUser, H2_TEXT_CANNOT_RENDER_AID);
                break;
            case H2_PLAYER_STATE_DYING:
            case H2_PLAYER_STATE_STABLE:
                if (h2_SkillCheck(SKILL_HEAL, oUser) >= _GetFirstAidDC(oTarget, oUser))
                {
                    SetPlayerInt(oTarget, H2_PLAYER_STATE, H2_PLAYER_STATE_RECOVERING);
                    SendMessageToPC(oTarget, H2_TEXT_PLAYER_STABLIZED);
                    SendMessageToPC(oUser, H2_TEXT_FIRST_AID_SUCCESS);
                }
                else
                    SendMessageToPC(oUser, H2_TEXT_FIRST_AID_FAILED);
                break;
            case H2_PLAYER_STATE_RECOVERING:
                SendMessageToPC(oUser, H2_TEXT_ALREADY_TENDED);
                break;
            case H2_PLAYER_STATE_ALIVE:
                if (GetCurrentHitPoints(oTarget) >= GetMaxHitPoints(oTarget))
                {
                    SendMessageToPC(oUser, H2_TEXT_DOES_NOT_NEED_AID);
                    return;
                }

                if (h2_SkillCheck(SKILL_HEAL, oUser, 0) >= _GetLongTermCareDC(oTarget, oUser))
                    SetLocalInt(oTarget, H2_BLEED_LONG_TERM_CARE, 1);
                    
                SendMessageToPC(oUser, H2_TEXT_ATTEMPT_LONG_TERM_CARE);
                SendMessageToPC(oTarget, H2_TEXT_RECEIVE_LONG_TERM_CARE);
                break;
        }
    }
    else //Target was not a PC, just Roll result and let DM decide what happens
        h2_SkillCheck(SKILL_HEAL, oUser);
}

// -----------------------------------------------------------------------------
//  EVENT MANAGEMENT
// -----------------------------------------------------------------------------

/// @todo get rid of this .... need to make changes in the framework engine here...
#include "x2_inc_switches"

// -----------------------------------------------------------------------------
//                        Event Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Ensure entering players have the required inventory items for using
///     the bleed system.
void bleed_OnClientEnter();

/// @brief If a character dies, stop the bleed system timer and remove the
///     any variables set by the bleed system.
void bleed_OnPlayerDeath();

/// @brief Determines the maximum amount of healing a player can do after resting
///    based on their current player state.
void bleed_OnPlayerRestStarted();

/// @brief Starts the bleeding process for a dying player character.
void bleed_OnPlayerDying();

/// @brief Tag-based scripting for the heal widget item.
void bleed_healwidget();

/// @brief Perform bleed system interval checks to determine the next state of
///    a dying player character.
void bleed_OnTimerExpire();

// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

/// @private Clear bleed system variables.
void bleed_ClearVariables(object oPC)
{
    int nTimerID = GetPlayerInt(oPC, H2_BLEED_TIMER_ID);
    if (nTimerID)
    {
        DeletePlayerInt(oPC, H2_BLEED_TIMER_ID);
        KillTimer(nTimerID);
    }

    DeletePlayerInt(oPC, H2_BLEED_LAST_HIT_POINTS);
    DeletePlayerString(oPC, H2_BLEED_TIME_OF_LAST_BLEED_CHECK);
    DeletePlayerInt(oPC, H2_BLEED_LONG_TERM_CARE);
}

void bleed_OnClientEnter()
{
    object oPC = GetEnteringObject();
    object oHealWidget = GetItemPossessedBy(oPC, H2_BLEED_HEAL_WIDGET);
    if (!GetIsObjectValid(oHealWidget))
        CreateItemOnObject(H2_BLEED_HEAL_WIDGET, oPC);
}

void bleed_OnPlayerDeath()
{
    bleed_ClearVariables(GetLastPlayerDied());
}

void bleed_OnPlayerRestStarted()
{
    object oPC = GetLastPCRested();
    if (GetPlayerInt(oPC, H2_BLEED_LONG_TERM_CARE) && h2_GetPostRestHealAmount(oPC) > 0)
    {
        DeletePlayerInt(oPC, H2_BLEED_LONG_TERM_CARE);
        h2_SetPostRestHealAmount(oPC, h2_GetPostRestHealAmount(oPC) * 2);
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
    if (nEvent == X2_ITEM_EVENT_ACTIVATE)
        h2_UseHealWidgetOnTarget(GetItemActivatedTarget());
}

void bleed_OnTimerExpire()
{
    object oPC = OBJECT_SELF;
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    if (nPlayerState != H2_PLAYER_STATE_DYING && nPlayerState != H2_PLAYER_STATE_STABLE &&
        nPlayerState != H2_PLAYER_STATE_RECOVERING)
    {
        bleed_ClearVariables(oPC);
    }
    else
    {
        int nCurrHitPoints = GetCurrentHitPoints(oPC);
        if (nCurrHitPoints > 0)
        {
            h2_MakePlayerFullyRecovered(oPC);
            return;
        }

        int nLastHitPoints = GetPlayerInt(oPC, H2_BLEED_LAST_HIT_POINTS);
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
