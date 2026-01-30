/// ----------------------------------------------------------------------------
/// @file   hcr_i_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed System (core)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Module Events
// -----------------------------------------------------------------------------

/// @brief BLEED_EVENT_ON_TIMER_EXPIRE.  This event is triggered when a
///     running bleed timer expires after the interval defined the bleed system
///     configuration.
/// @param OBJECT_SELF The dying player character whose bleed timer has expired.
/// @note Using a lower priority than the bleed systems OnTimerExpire event will
///     allow this system to fully process bleed actions and set the player state
///     before other event scripts are run.

#include "util_i_data"
#include "core_i_framework"

#include "pw_c_bleed"
#include "pw_i_core"

const string BLEED_SYSTEM = "BLEED_SYSTEM";
const string BLEED_LAST_HIT_POINTS = "BLEED_LAST_HIT_POINTS";
const string BLEED_TIMER_ID = "BLEED_TIMER_ID";
const string BLEED_TIME_OF_LAST_BLEED_CHECK = "BLEED_TIME_OF_LAST_BLEED_CHECK";
const string BLEED_LONG_TERM_CARE = "BLEED_LONG_TERM_CARE";
const string BLEED_EVENT_ON_TIMER_EXPIRE = "BLEED_EVENT_ON_TIMER_EXPIRE";

// -----------------------------------------------------------------------------
//                        System Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates and starts a timer to control a dying player's bleeding
///     process.
/// @param oPC The player character object to start the bleeding process for.
void bleed_StartBleeding(object oPC);

/// @brief Makes the player fully recover from a dying or stable state.
/// @param oPC The player character object to make fully recovered.
/// @note This brings oPC to 1 HP and sets their player state to PW_CHARACTER_STATE_ALIVE.
void bleed_MakeFullyRecovered(object oPC);

/// @brief Sets the player's state to PW_CHARACTER_STATE_STABLE or makes them fully
///     recovered if the player's state is PW_CHARACTER_STATE_STABLE.
/// @param oPC The player character object to stabilize or make fully recovered.
/// @param bDoFullRecovery If TRUE, makes oPC fully recovered if they are stable.
void bleed_Stabilize(object oPC, int bDoFullRecovery = FALSE);

/// @brief Applies bleed damage to the player character.
/// @param oPC The player character object to apply bleed damage to.
void bleed_ApplyBleedDamage(object oPC);

/// @brief Checks to see if the player character can self-stabilize; if not,
///    applies bleed damage.
/// @param oPC The player character object to check for self-stabilization.
void bleed_SelfStabilizeCheck(object oPC);

/// @brief Handle application of the heal widget on a creature object.
/// @param oTarget The target object the heal widget is being used on.
void bleed_UseHealWidget(object oTarget);

// -----------------------------------------------------------------------------
//                        Private Function Definitions
// -----------------------------------------------------------------------------

/// @private Ensures the user-provided self-stabilization chance configuration
///     value is within an acceptable range.
int bleed_GetSelfStabilizeChance(object oPC)
{
    return clamp(bleed_GetBleedSelfStabilizeChance(oPC), 0, 100);
}

/// @private Ensures the user-provided self-recovery chance configuration
///     value is within an acceptable range.
int bleed_GetSelfRecoveryChance(object oPC)
{
    return clamp(bleed_GetBleedSelfRecoveryChance(oPC), 0, 100);
}

/// @private Ensure the user-provided bleed HP loss configuration value is
///     at least 0HP.
int bleed_GetHPLoss(object oPC)
{
    return max(bleed_GetBleedHPLoss(oPC), 0);
}

/// @private Ensure the user-provided difficulty class for first-aid checks
///     is at least 0.
int bleed_GetFirstAidDC(object oPC, object oHealer)
{
    return max(bleed_GetBleedFirstAidDC(oPC, oHealer), 0);
}

/// @private Ensure the user-provided difficulty class for long-term care checks
///     is at least 0.
int bleed_GetLongTermCareDC(object oPC, object oHealer)
{
    return max(bleed_GetBleedLongTermCareDC(oPC, oHealer), 0);
}

// -----------------------------------------------------------------------------
//                        System Function Definitions
// -----------------------------------------------------------------------------

void bleed_StartBleeding(object oPC)
{
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, BLEED_LAST_HIT_POINTS, nCurrentHitPoints);
    
    int nTimer = CreateTimer(oPC, BLEED_EVENT_ON_TIMER_EXPIRE, bleed_GetBleedCheckInterval(oPC));
    SetLocalInt(oPC, BLEED_TIMER_ID, nTimer);
    StartTimer(nTimer, FALSE);
}

void bleed_MakeFullyRecovered(object oPC)
{
    int nCurrHitPoints = GetCurrentHitPoints(oPC);
    if (nCurrHitPoints <= 0)
    {
        effect eHeal = EffectHeal(1 - nCurrHitPoints);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oPC);
    }

    SendMessageToPC(oPC, bleed_GetText(BLEED_TEXT_RECOVERED_FROM_DYING));
    DeleteLocalString(oPC, BLEED_TIME_OF_LAST_BLEED_CHECK);
    pw_SetCharacterState(oPC, PW_CHARACTER_STATE_ALIVE);
    //TODO: make monsters go hostile to PC again?
}

void bleed_Stabilize(object oPC, int bNaturalHeal = FALSE)
{
    int nPlayerState = pw_GetCharacterState(oPC);
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, BLEED_LAST_HIT_POINTS, nCurrentHitPoints);
    if (nPlayerState == PW_CHARACTER_STATE_DYING)
    {
        SendMessageToPC(oPC, bleed_GetText(BLEED_TEXT_PLAYER_STABILIZED));
        if (bNaturalHeal)
            pw_SetCharacterState(oPC, PW_CHARACTER_STATE_STABLE);
        else
            pw_SetCharacterState(oPC, PW_CHARACTER_STATE_RECOVERING);
        
        SetPlayerString(oPC, BLEED_TIME_OF_LAST_BLEED_CHECK, GetSystemTime());
    }
    else if (bNaturalHeal)
        bleed_MakeFullyRecovered(oPC);
    else
        pw_SetCharacterState(oPC, PW_CHARACTER_STATE_RECOVERING);
}

void bleed_ApplyBleedDamage(object oPC)
{
    SetPlayerString(oPC, BLEED_TIME_OF_LAST_BLEED_CHECK, GetSystemTime());
    SetPlayerInt(oPC, BLEED_LAST_HIT_POINTS, GetCurrentHitPoints(oPC));
    
    if (pw_GetCharacterState(oPC) == PW_CHARACTER_STATE_RECOVERING)
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

    SendMessageToPC(oPC, bleed_GetText(BLEED_TEXT_WOUNDS_BLEED));

    effect eBloodloss = EffectDamage(bleed_GetHPLoss(oPC), DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eBloodloss, oPC);
}

void bleed_SelfStabilizeCheck(object oPC)
{
    int nPlayerState = pw_GetCharacterState(oPC);
    int nStabilizeChance = bleed_GetSelfStabilizeChance(oPC);
    
    if (nPlayerState == PW_CHARACTER_STATE_STABLE || nPlayerState == PW_CHARACTER_STATE_RECOVERING)
        nStabilizeChance = bleed_GetSelfRecoveryChance(oPC);

    string sLastBleedCheck = GetPlayerString(oPC, BLEED_TIME_OF_LAST_BLEED_CHECK);
    float fSecondsSinceLastBleedCheck = GetSystemTimeDifferenceIn(TIME_SECONDS, sLastBleedCheck);

    if (nPlayerState == PW_CHARACTER_STATE_DYING || fSecondsSinceLastBleedCheck >= bleed_GetBleedStableInterval(oPC))
    {
        if (d100() <= nStabilizeChance)
            bleed_Stabilize(oPC, TRUE);
        else
            bleed_ApplyBleedDamage(oPC);
    }
}

void bleed_UseHealWidget(object oTarget)
{
    object oUser = GetItemActivator();
    
    if (_GetIsPC(oTarget))
    {
        if (oTarget == oUser)
        {
            SendMessageToPC(oUser, bleed_GetText(BLEED_TEXT_CANNOT_USE_ON_SELF));
            return;
        }

        int nPlayerState = pw_GetCharacterState(oTarget);
        switch (nPlayerState)
        {
            case PW_CHARACTER_STATE_DEAD:
                SendMessageToPC(oUser, bleed_GetText(BLEED_TEXT_CANNOT_RENDER_AID));
                break;
            case PW_CHARACTER_STATE_DYING:
            case PW_CHARACTER_STATE_STABLE:
                if (h2_SkillCheck(SKILL_HEAL, oUser) >= bleed_GetFirstAidDC(oTarget, oUser))
                {
                    pw_SetCharacterState(oTarget, PW_CHARACTER_STATE_RECOVERING);
                    SendMessageToPC(oTarget, bleed_GetText(BLEED_TEXT_PLAYER_STABILIZED));
                    SendMessageToPC(oUser, bleed_GetText(BLEED_TEXT_FIRST_AID_SUCCESS));
                }
                else
                    SendMessageToPC(oUser, bleed_GetText(BLEED_TEXT_FIRST_AID_FAILED));
                break;
            case PW_CHARACTER_STATE_RECOVERING:
                SendMessageToPC(oUser, bleed_GetText(BLEED_TEXT_ALREADY_TENDED));
                break;
            case PW_CHARACTER_STATE_ALIVE:
                if (GetCurrentHitPoints(oTarget) >= GetMaxHitPoints(oTarget))
                {
                    SendMessageToPC(oUser, bleed_GetText(BLEED_TEXT_DOES_NOT_NEED_AID));
                    return;
                }

                if (h2_SkillCheck(SKILL_HEAL, oUser, 0) >= bleed_GetLongTermCareDC(oTarget, oUser))
                    SetLocalInt(oTarget, BLEED_LONG_TERM_CARE, 1);
                    
                SendMessageToPC(oUser, bleed_GetText(BLEED_TEXT_ATTEMPT_LONG_TERM_CARE));
                SendMessageToPC(oTarget, bleed_GetText(BLEED_TEXT_RECEIVE_LONG_TERM_CARE));
                break;
        }
    }
    else
        h2_SkillCheck(SKILL_HEAL, oUser);
}

// -----------------------------------------------------------------------------
//  EVENT MANAGEMENT
// -----------------------------------------------------------------------------

/// @todo get rid of this .... need to make changes in the framework engine here...
#include "x2_inc_switches"


// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

/// @todo make a json structure? or use variable tags for easy deletion?
/// @private Clear bleed system variables.
void bleed_ClearVariables(object oPC)
{
    int nTimerID = GetPlayerInt(oPC, BLEED_TIMER_ID);
    if (nTimerID)
    {
        DeletePlayerInt(oPC, BLEED_TIMER_ID);
        KillTimer(nTimerID);
    }

    DeletePlayerInt(oPC, BLEED_LAST_HIT_POINTS);
    DeletePlayerString(oPC, BLEED_TIME_OF_LAST_BLEED_CHECK);
    DeletePlayerInt(oPC, BLEED_LONG_TERM_CARE);
}

void bleed_OnClientEnter()
{
    object oPC = GetEnteringObject();
    object oHealWidget = GetItemPossessedBy(oPC, BLEED_HEAL_WIDGET_RESREF);
    if (!GetIsObjectValid(oHealWidget))
        CreateItemOnObject(BLEED_HEAL_WIDGET_RESREF, oPC);
}

void bleed_OnPlayerDeath()
{
    bleed_ClearVariables(GetLastPlayerDied());
}

void bleed_OnPlayerRestStarted()
{
    object oPC = GetLastPCRested();
    if (GetPlayerInt(oPC, BLEED_LONG_TERM_CARE) && h2_GetPostRestHealAmount(oPC) > 0)
    {
        DeletePlayerInt(oPC, BLEED_LONG_TERM_CARE);
        h2_SetPostRestHealAmount(oPC, h2_GetPostRestHealAmount(oPC) * 2);
    }
}

void bleed_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (pw_GetCharacterState(oPC) == PW_CHARACTER_STATE_DYING)
        bleed_StartBleeding(oPC);
}

void bleed_healwidget()
{
    int nEvent = GetUserDefinedItemEventNumber();
    if (nEvent == X2_ITEM_EVENT_ACTIVATE)
        bleed_UseHealWidget(GetItemActivatedTarget());
}

void bleed_OnTimerExpire()
{
    object oPC = OBJECT_SELF;
    int nPlayerState = pw_GetCharacterState(oPC);
    if (nPlayerState != PW_CHARACTER_STATE_DYING && nPlayerState != PW_CHARACTER_STATE_STABLE &&
        nPlayerState != PW_CHARACTER_STATE_RECOVERING)
    {
        bleed_ClearVariables(oPC);
    }
    else
    {
        int nCurrHitPoints = GetCurrentHitPoints(oPC);
        if (nCurrHitPoints > 0)
        {
            bleed_MakeFullyRecovered(oPC);
            return;
        }

        int nLastHitPoints = GetPlayerInt(oPC, BLEED_LAST_HIT_POINTS);
        if (nCurrHitPoints > nLastHitPoints)
        {
            bleed_Stabilize(oPC);
            return;
        }

        if (nCurrHitPoints > -10)
            bleed_SelfStabilizeCheck(oPC);
        else
        {
            pw_SetCharacterState(oPC, PW_CHARACTER_STATE_DEAD);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
        }
    }
}
