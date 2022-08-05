// -----------------------------------------------------------------------------
//    File: bleed_l_plugin.nss
//  System: Bleed Persistent World Subsystem (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//  CONSTANTS
// -----------------------------------------------------------------------------

const string H2_BLEED_TIMER_SCRIPT = "h2_bleedtimer";
const string H2_LAST_HIT_POINTS = "H2_LASTHITPOINTS";
const string H2_BLEED_TIMER_ID = "H2_BLEEDTIMERID";
const string H2_TIME_OF_LAST_BLEED_CHECK = "H2_TIME_OF_LAST_BLEED_CHECK";
const string H2_LONG_TERM_CARE = "H2_LONG_TERM_CARE";
const string H2_HEAL_WIDGET = "h2_healwidget";
const string BLEED_ON_TIMER_EXPIRE = "bleed_OnTimerExpire";
const string BLEED_EVENT_ON_TIMER_EXPIRE = "BLEED_EVENT_ON_TIMER_EXPIRE";



// -----------------------------------------------------------------------------
//  PRIMARY FUNCTIONS
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "core_i_framework"
#include "pw_c_bleed"
#include "pw_i_core"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

//Creates and starts a timer to track the bleeding of oPC.
void h2_BeginPlayerBleeding(object oPC);

//Makes the player oPC fully recover from a dying or stable state.
//This brings oPC to 1 HP and sets their player state to H2_PLAYER_STATE_ALIVE.
void h2_MakePlayerFullyRecovered(object oPC);

//Sets oPC's player state to H2_PLAYER_STATE_STABLE if oPC's player state was H2_PLAYER_STATE_DYING
//or makes oPC fully recovered if the oPC's player state was H2_PLAYER_STATE_STABLE
//and bDoFullRecovery is TRUE.
void h2_StabilizePlayer(object oPC, int bDoFullRecovery = FALSE);

//Causes bleed damage to oPC.
void h2_DoBleedDamageToPC(object oPC);

//Checks to see if oPC was able to stabilize on their own, if not
//bleed damage is done to oPC.
void h2_CheckForSelfStabilize(object oPC);

//Handles when the healing skill widget is used on a target.
void h2_UseHealWidgetOnTarget(object oTarget);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_BeginPlayerBleeding(object oPC)
{
    int nCurrentHitPoints = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, H2_LAST_HIT_POINTS, nCurrentHitPoints);
    
    int timerID = CreateTimer(oPC, BLEED_EVENT_ON_TIMER_EXPIRE, H2_BLEED_DELAY);
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
    effect eBloodloss = EffectDamage(H2_BLEED_BLOOD_LOSS, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_ENERGY);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eBloodloss, oPC);
}

void h2_CheckForSelfStabilize(object oPC)
{
    int nPlayerState = GetPlayerInt(oPC, H2_PLAYER_STATE);
    int stabilizechance = H2_SELF_STABILIZE_CHANCE;
    if (nPlayerState == H2_PLAYER_STATE_STABLE || nPlayerState == H2_PLAYER_STATE_RECOVERING)
        stabilizechance = H2_SELF_RECOVERY_CHANCE;

    string lastCheck = GetPlayerString(oPC, H2_TIME_OF_LAST_BLEED_CHECK);
    float secondsSinceLastCheck = GetSystemTimeDifferenceIn(TIME_SECONDS, lastCheck);

    if (nPlayerState == H2_PLAYER_STATE_DYING || secondsSinceLastCheck >= H2_STABLE_DELAY)
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
                if (rollResult >= H2_FIRST_AID_DC)
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
                if (rollResult >= H2_LONG_TERM_CARE_DC)
                    SetLocalInt(oTarget, H2_LONG_TERM_CARE, 1);
                    
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

#include "x2_inc_switches"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< bleed_OnClientEnter >---
// Library and event registered script for the module-level OnClientEnter
//  event.  This function ensures each entering player has a Heal Widget in
//  their inventory.
void bleed_OnClientEnter();

// ---< bleed_OnPlayerDeath >---
// Library and event registered script for the module-level OnPlayerDeath
//  event.  This function starts the bleed functions if the player is not dead.
void bleed_OnPlayerDeath();

// ---< bleed_OnPlayerRestStarted >---
// Library and event registered script for the module-level OnPlayerRestStarted
//  event.  This function sets the maximum amount of healing a PC can do.
void bleed_OnPlayerRestStarted();

// ---< bleed_OnPlayerDying >---
// Library and event registered script for the module-level OnPlayerDying
//  event.  This function marks the PC's state and starts the bleed system.
void bleed_OnPlayerDying();

// ---< bleed_healwidget >---
// Library registered script for tag-based sripting for the healwidget item.
void bleed_healwidget();

// ---< bleed_OnTimerExpire >---
// Event registered script that runs when the bleed timer expires.  This
//  function will apply additional damage, check for self-stabilization, or
//  kill the PC, as required by the bleen system and custom settings.
// Note: OnTimerExpire is not a framework event.
void bleed_OnTimerExpire();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Module Events -----

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

// ----- Tag-based Scripting -----

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

// ----- Timer Events -----

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
