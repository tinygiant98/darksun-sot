/// -----------------------------------------------------------------------------
/// @file:  hcr_i_bleed.nss
/// @brief: HCR2 Bleed System (core)
/// -----------------------------------------------------------------------------

#include "util_i_data"
#include "core_i_framework"
#include "hcr_c_bleed"
#include "hcr_i_core"
#include "x2_inc_switches"

// -----------------------------------------------------------------------------
//                         Variable Name Constants
// -----------------------------------------------------------------------------

const string H2_LAST_HIT_POINTS = "H2_LASTHITPOINTS";
const string H2_BLEED_TIMER_ID = "H2_BLEEDTIMERID";
const string H2_TIME_OF_LAST_BLEED_CHECK = "H2_TIME_OF_LAST_BLEED_CHECK";
const string H2_LONG_TERM_CARE = "H2_LONG_TERM_CARE";
const string H2_HEAL_WIDGET = "h2_healwidget";
const string BLEED_ON_TIMER_EXPIRE = "bleed_OnTimerExpire";
const string BLEED_EVENT_ON_TIMER_EXPIRE = "BLEED_EVENT_ON_TIMER_EXPIRE";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates and starts the bleed timer for oPC.
/// @param oPC Player-character to start the bleed timer for.
void h2_BeginPlayerBleeding(object oPC);

/// @brief Forces oPC to fully recover from a dying or stable state.  oPC
///     will have 1HP and their player state will be set to H2_PLAYER_STATE_ALIVE.
/// @param oPC Player-character to recover.
void h2_MakePlayerFullyRecovered(object oPC);

/// @brief Sets oPC's player state to H2_PLAYER_STATE_STABLE if oPC's previous
///     state was H2_PLAYER_STATE_DYING.  If the player's previous state was
///     H2_PLAYER_STATE_STABLE and bDoFullRecovery is TRUE, oPC will be fully
///     recovered.
/// @param oPC Player-character to stabilize.
/// @param bDoFullRecovery TRUE to fully recover oPC.
void h2_StabilizePlayer(object oPC, int bDoFullRecovery = FALSE);

/// @brief Provides bleed damage for oPC.
/// @param oPC Player-character to provide bleed damage for.
void h2_DoBleedDamageToPC(object oPC);

/// @brief Checks if oPC can self-stabilize.  If not, bleed damage is done.
/// @param oPC Player-character to check for self-stabilization.
void h2_CheckForSelfStabilize(object oPC);

/// @brief Handles the use of the healing skill widget.
/// @param oTarget Player-character the hel widget is being used on.
void h2_UseHealWidgetOnTarget(object oTarget);

/// @brief Event script for module-level OnClientEnter event.  Provides
///     a heal-widget for each player.
void bleed_OnClientEnter();

/// @brief Event script for module-level OnPlayerDeath event.  Starts bleed
///     function if player is not considered dead.
void bleed_OnPlayerDeath();

/// @brief Event script for module-level OnPlayerRestStarted event.  Sets
///     the maximum healing a player-character is capable of.
void bleed_OnPlayerRestStarted();

/// @brief Event script for module-level OnPlayerDying event.  Sets the
///     dying PC's state and starts the bleed system.
void bleed_OnPlayerDying();

/// @brief Event script for local OnTimerExpire event for bleed system timer.
///     This function runs on every bleed interval as set by H2_BLEED_INTERVAL
///     in hcr_c_bleed.
/// @note OnTimerExpire is not a framework event.
void bleed_OnTimerExpire();

/// @brief Tag-based script for heal widget activation.
void bleed_healwidget();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_BeginPlayerBleeding(object oPC)
{
    SetPlayerInt(oPC, H2_LAST_HIT_POINTS, GetCurrentHitPoints(oPC));
    
    int nTimer = CreateTimer(oPC, BLEED_EVENT_ON_TIMER_EXPIRE, H2_BLEED_INTERVAL, 0, 0.0, CORE_HOOK_TIMERS);
    SetLocalInt(oPC, H2_BLEED_TIMER_ID, nTimer);
    StartTimer(nTimer, FALSE);
}

void h2_MakePlayerFullyRecovered(object oPC)
{
    int nCurrHitPoints = GetCurrentHitPoints(oPC);
    if (nCurrHitPoints <= 0)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(1 - nCurrHitPoints), oPC);

    SendMessageToPC(oPC,  H2_TEXT_RECOVERED_FROM_DYING);
    DeleteLocalString(oPC, H2_TIME_OF_LAST_BLEED_CHECK);
    SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    //TODO: make monsters go hostile to PC again?
}

void h2_StabilizePlayer(object oPC, int bNaturalHeal = FALSE)
{
    SetPlayerInt(oPC, H2_LAST_HIT_POINTS, GetCurrentHitPoints(oPC));

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) == H2_PLAYER_STATE_DYING)
    {
        SendMessageToPC(oPC, H2_TEXT_PLAYER_STABLIZED);
        if (bNaturalHeal)
            SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_STABLE);
        else
            SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_RECOVERING);
        
        SetPlayerString(oPC, H2_TIME_OF_LAST_BLEED_CHECK, GetSystemTime());
    }
    else if (bNaturalHeal)
        h2_MakePlayerFullyRecovered(oPC);
    else
        SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_RECOVERING);
}

void h2_DoBleedDamageToPC(object oPC)
{
    SetPlayerString(oPC, H2_TIME_OF_LAST_BLEED_CHECK, GetSystemTime());
    SetPlayerInt(oPC, H2_LAST_HIT_POINTS, GetCurrentHitPoints(oPC));
    
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

    effect e = EffectDamage(abs(H2_BLEED_HP_LOSS), DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, e, oPC);
}

void h2_CheckForSelfStabilize(object oPC)
{
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    int nChance = clamp(H2_SELF_STABILIZE_CHANCE, 0, 100);
    if (nPlayerState == H2_PLAYER_STATE_STABLE || nPlayerState == H2_PLAYER_STATE_RECOVERING)
        nChance = clamp(H2_SELF_RECOVERY_CHANCE, 0, 100);

    string lastCheck = GetPlayerString(oPC, H2_TIME_OF_LAST_BLEED_CHECK);
    float secondsSinceLastCheck = GetSystemTimeDifferenceIn(TIME_SECONDS, lastCheck);

    if (nPlayerState == H2_PLAYER_STATE_DYING || secondsSinceLastCheck >= H2_STABLE_INTERVAL)
    {
        if (d100() <= nChance)
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
                if (h2_SkillCheck(SKILL_HEAL, oUser) >= H2_FIRST_AID_DC)
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

                if (h2_SkillCheck(SKILL_HEAL, oUser, 0) >= H2_LONG_TERM_CARE_DC)
                    SetLocalInt(oTarget, H2_LONG_TERM_CARE, 1);
                    
                SendMessageToPC(oUser, H2_TEXT_ATTEMPT_LONG_TERM_CARE);
                SendMessageToPC(oTarget, H2_TEXT_RECEIVE_LONG_TERM_CARE);
                break;
        }
    }
    else //Target was not a PC, just Roll result and let DM decide what happens
        h2_SkillCheck(SKILL_HEAL, oUser);
}

void bleed_OnClientEnter()
{
    object oPC = GetEnteringObject();
    object oHealWidget = GetItemPossessedBy(oPC, H2_HEAL_WIDGET);
    if (!GetIsObjectValid(oHealWidget))
        CreateItemOnObject(H2_HEAL_WIDGET, oPC);
}

void bleed_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    int nTimer = GetPlayerInt(oPC, H2_BLEED_TIMER_ID);

    if (nTimer)
    {
        DeleteLocalInt(oPC, H2_BLEED_TIMER_ID);
        KillTimer(nTimer);
    }
}

void bleed_OnPlayerRestStarted()
{
    object oPC = GetLastPCRested();
    if (GetPlayerInt(oPC, H2_LONG_TERM_CARE) && h2_GetPostRestHealAmount(oPC) > 0)
    {
        DeletePlayerInt(oPC, H2_LONG_TERM_CARE);
        h2_SetPostRestHealAmount(oPC, h2_GetPostRestHealAmount(oPC) * 2);
    }
}

void bleed_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (GetPlayerInt(oPC, H2_PLAYER_STATE) == H2_PLAYER_STATE_DYING)
        h2_BeginPlayerBleeding(oPC);
}

void bleed_OnTimerExpire()
{
    object oPC = OBJECT_SELF;
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    if (nPlayerState != H2_PLAYER_STATE_DYING && nPlayerState != H2_PLAYER_STATE_STABLE &&
        nPlayerState != H2_PLAYER_STATE_RECOVERING)
    {
        KillTimer(GetLocalInt(oPC, H2_BLEED_TIMER_ID));
        DeletePlayerInt(oPC, H2_BLEED_TIMER_ID);
        DeletePlayerInt(oPC, H2_TIME_OF_LAST_BLEED_CHECK);
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

void bleed_healwidget()
{
    if (GetUserDefinedItemEventNumber() ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oTarget = GetItemActivatedTarget();
        if (GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
            return;
            
        h2_UseHealWidgetOnTarget(oTarget);
    }
}
