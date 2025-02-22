/// ----------------------------------------------------------------------------
/// @file   pw_i_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed Library (core)
/// ----------------------------------------------------------------------------

#include "util_i_math"

#include "pw_i_core"
#include "pw_k_bleed"
#include "pw_c_bleed"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates and starts a timer to track player character bleeding.
void h2_BeginPlayerBleeding(object oPC);

/// @brief Makes the player oPC fully recover from a dying or stable state.
///     This brings oPC to 1 HP and sets their player state to H2_PLAYER_STATE_ALIVE.
/// @param oPC The player character to recover.
void h2_MakePlayerFullyRecovered(object oPC);

/// @brief Sets oPC's player state to H2_PLAYER_STATE_STABLE if oPC's player state
///     was H2_PLAYER_STATE_DYING or makes oPC fully recovered if the oPC's player
///     state was H2_PLAYER_STATE_STABLE and bDoFullRecovery is TRUE.
/// @param oPC The player character to stabilize.
/// @param bDoFullRecovery If TRUE, the player character will be fully recovered.
void h2_StabilizePlayer(object oPC, int bDoFullRecovery = FALSE);

/// @brief Apply bleed damage to oPC.
/// @param oPC The player character to apply bleed damage to.
void h2_DoBleedDamageToPC(object oPC);

/// @brief Checks to see if oPC was able to stabilize on their own, if not, bleed
///     damage is applied to oPC.
/// @param oPC The player character to check for self-stabilization.
void h2_CheckForSelfStabilize(object oPC);

/// @brief Handles using heal widget on a target.
/// @param oTarget The target to use the healing widget on.
void h2_UseHealWidgetOnTarget(object oTarget);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_BeginPlayerBleeding(object oPC)
{
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, H2_LAST_HIT_POINTS, nCurrentHitPoints);
    
    int timerID = CreateEventTimer(oPC, BLEED_EVENT_ON_TIMER_EXPIRE, BLEED_CHECK_DELAY);
    SetLocalInt(oPC, H2_BLEED_TIMER_ID, timerID);
    StartTimer(timerID, FALSE);
}

void h2_MakePlayerFullyRecovered(object oPC)
{
    int nCurrHitPoints = GetCurrentHitPoints(oPC);
    if (nCurrHitPoints <= 0)
    {
        effect eHeal = EffectHeal(1 - nCurrHitPoints);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oPC);
    }

    SendMessageToPC(oPC,  H2_TEXT_RECOVERED_FROM_DYING);
    DeleteLocalString(oPC, H2_TIME_OF_LAST_BLEED_CHECK);
    SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    //TODO: make monsters go hostile to PC again?
}

void h2_StabilizePlayer(object oPC, int bNaturalHeal = FALSE)
{
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, H2_LAST_HIT_POINTS, nCurrentHitPoints);
    if (nPlayerState == H2_PLAYER_STATE_DYING)
    {
        SendMessageToPC(oPC,  H2_TEXT_PLAYER_STABLIZED);
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
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, H2_LAST_HIT_POINTS, nCurrentHitPoints);
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    
    if (nPlayerState == H2_PLAYER_STATE_RECOVERING)
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
    effect eBloodloss = EffectDamage(BLEED_HP_LOSS, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eBloodloss, oPC);
}

void h2_CheckForSelfStabilize(object oPC)
{
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    int stabilizechance = max(BLEED_SELF_STABILIZE_CHANCE, 0);
    if (nPlayerState == H2_PLAYER_STATE_STABLE || nPlayerState == H2_PLAYER_STATE_RECOVERING)
        stabilizechance = max(BLEED_SELF_RECOVERY_CHANCE, 0);

    string lastCheck = GetPlayerString(oPC, H2_TIME_OF_LAST_BLEED_CHECK);
    float secondsSinceLastCheck = GetSystemTimeDifferenceIn(TIME_SECONDS, lastCheck);

    if (nPlayerState == H2_PLAYER_STATE_DYING || secondsSinceLastCheck >= BLEED_STABLE_DELAY)
    {
        if (d100() <= stabilizechance)
            h2_StabilizePlayer(oPC, TRUE);
        else
            h2_DoBleedDamageToPC(oPC);
    }
}

void h2_UseHealWidgetOnTarget(object oTarget)
{
    object oUser = GetItemActivator();
    int rollResult;
    
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
                rollResult = h2_SkillCheck(SKILL_HEAL, oUser);
                if (rollResult >= BLEED_FIRST_AID_DC)
                {
                    SetPlayerInt(oTarget, H2_PLAYER_STATE, H2_PLAYER_STATE_RECOVERING);
                    SendMessageToPC(oTarget,  H2_TEXT_PLAYER_STABLIZED);
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
                rollResult = h2_SkillCheck(SKILL_HEAL, oUser, 0);
                if (rollResult >= BLEED_LONG_TERM_CARE_DC)
                    SetLocalInt(oTarget, H2_LONG_TERM_CARE, 1);
                    
                SendMessageToPC(oUser, H2_TEXT_ATTEMPT_LONG_TERM_CARE);
                SendMessageToPC(oTarget, H2_TEXT_RECEIVE_LONG_TERM_CARE);
                break;
        }
    }
    else //Target was not a PC, just Roll result and let DM decide what happens
        h2_SkillCheck(SKILL_HEAL, oUser);
}
