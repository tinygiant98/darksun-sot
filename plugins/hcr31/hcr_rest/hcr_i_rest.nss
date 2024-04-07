/// -----------------------------------------------------------------------------
/// @file:  hcr_i_rest.nss
/// @brief: HCR2 Rest System (core)
/// -----------------------------------------------------------------------------

#include "core_i_framework"
#include "hcr_c_rest"
#include "hcr_i_core"
#include "x2_inc_switches"

// -----------------------------------------------------------------------------
//                         Variable Name Constants
// -----------------------------------------------------------------------------

const string H2_REST_TRIGGER = "H2_REST_TRIGGER";
const string H2_LAST_PC_REST_TIME = "H2_LAST_PC_RESTTIME";
const string H2_IGNORE_MINIMUM_REST_TIME = "H2_IGNORE_MINIMUM_REST_TIME";
const string H2_REST_FEEDBACK = "H2_REST_FEEDBACK";
const string H2_CAMPFIRE_END_TIME = "H2_CAMPFIRE_END_TIME";

// Custom Events
const string REST_EVENT_ON_TRIGGER_CLICK = "Rest_OnTriggerClick";
const string REST_EVENT_ON_TRIGGER_ENTER = "Rest_OnTriggerEnter";
const string REST_EVENT_ON_TRIGGER_EXIT = "Rest_OnTriggerExit";
const string REST_EVENT_ON_TRIGGER_HEARTBEAT = "Rest_OnTriggerHeartbeat";
const string REST_EVENT_ON_TRIGGER_USERDEFINED = "Rest_OnTriggerUserDefined";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Saves a value derived from the time since the server was started
///     when oPC finishes a rest in which their spells and feats were allowed
///     to be recovered properly. This value is used in determining the elapsed
///     time since their last recovery rest when oPC next tries to rest.
/// @param oPC Resting player character.
void h2_SaveLastRecoveryRestTime(object oPC);

/// @brief Determines the amount of time in real seconds that are remaining
///     before recovery in rest is allowed according to
///     H2_MINIMUM_SPELL_RECOVERY_REST_TIME and the time elapsed since the
///     last time oPC recovered during rest.
/// @param oPC Resting player character.
int h2_RemainingTimeForRecoveryInRest(object oPC);

/// @brief Events script for module-level OnModuleLoad event.  Use this event
///     to set appropriate variables on triggers and other rest system
///     objects.
void rest_OnModuleLoad();

/// @brief Event script for local OnTriggerEnter event for trigger's associated
///     with areas a player can rest.
void rest_OnTriggerEnter();

/// @brief Event script for local OnTriggerExit event for trigger's associated
///     with areas a player can rest.
void rest_OnTriggerExit();

/// @brief Event script for module-level OnPlayerRestStarted event.  Ensures
///     the resting player character meets all prerequisites to rest.
void rest_OnPlayerRestStarted();

/// @brief Event script for module-level OnPlayerRestFinished event.  Restores
///     all spells/feats to the player character and sets up the next resting
///     period.
void rest_OnPlayerRestFinished();

/// @brief Event script for the module-level OnPlayerRestCancelled event.
///     Removes sleep/snoring effects and sets other resting properties.
void rest_OnPlayerRestCancelled();

/// Tag-based scripting function for using the rest system item h2_firewood.
void rest_firewood();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_InitializeRecoveryRestTime(object oPC)
{
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    string lastRest = GetModuleString(uniquePCID + H2_LAST_PC_REST_TIME);

    if (lastRest == "")
    {
        string sTime = GetSystemTime();
        sTime = SubtractSystemTimeElement(TIME_SECONDS, H2_MINIMUM_SPELL_RECOVERY_REST_TIME, sTime);
        SetModuleString(uniquePCID + H2_LAST_PC_REST_TIME, sTime);
    }
}

void h2_SaveLastRecoveryRestTime(object oPC)
{
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    SetModuleString(uniquePCID + H2_LAST_PC_REST_TIME, GetSystemTime());
}

int h2_RemainingTimeForRecoveryInRest(object oPC)
{
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    string lastRest = GetModuleString(uniquePCID + H2_LAST_PC_REST_TIME);
    int elapsedTime = FloatToInt(GetSystemTimeDifferenceIn(TIME_SECONDS, lastRest));
    
    if (lastRest != "" && elapsedTime < H2_MINIMUM_SPELL_RECOVERY_REST_TIME)
        return H2_MINIMUM_SPELL_RECOVERY_REST_TIME - elapsedTime;
    else
        return 0;
}

void h2_ApplySleepEffects(object oPC)
{
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBlindness(), oPC);
    if (GetRacialType(oPC) != RACIAL_TYPE_ELF && GetRacialType(oPC) != RACIAL_TYPE_HALFELF)
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLEEP), oPC);
}

void h2_CheckIfCampfireIsOut(object oCampfire)
{
    string endTime = GetLocalString(oCampfire, H2_CAMPFIRE_END_TIME);
    string currTime = GetGameTime();

    if (GetMaxGameTime(endTime, currTime) == currTime)
        DestroyObject(oCampfire);
    else
        DelayCommand(GetGameTimeDifferenceIn(TIME_SECONDS, endTime, currTime) + 1.0, h2_CheckIfCampfireIsOut(oCampfire));
}

void h2_UseFirewood(object oPC, object oFirewood)
{
    object oTarget = GetItemActivatedTarget();
    if (GetIsObjectValid(oTarget))
    {
        if (GetTag(oTarget) == H2_CAMPFIRE)
        {
            string endTime = GetLocalString(oTarget, H2_CAMPFIRE_END_TIME);
            endTime = AddGameTimeElement(TIME_HOURS, H2_CAMPFIRE_BURN_TIME, endTime);
            SetLocalString(oTarget, H2_CAMPFIRE_END_TIME, endTime);
            AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, 3.0));
            DestroyObject(oFirewood);
        }
        else
            SendMessageToPC(oPC, H2_TEXT_CANNOT_USE_ON_TARGET);
    }
    else
    {
        location loc = GetItemActivatedTargetLocation();
        object oCampfire = CreateObject(OBJECT_TYPE_PLACEABLE, H2_CAMPFIRE, loc);
        SetLocalString(oCampfire, H2_CAMPFIRE_END_TIME, AddGameTimeElement(TIME_HOURS, H2_CAMPFIRE_BURN_TIME, GetGameTime()));
        DelayCommand(HoursToSeconds(H2_CAMPFIRE_BURN_TIME) + 5.0, h2_CheckIfCampfireIsOut(oCampfire));
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, 3.0));
        DestroyObject(oFirewood);
    }
}

void rest_OnModuleLoad()
{
    object oTrigger = GetObjectByTag(H2_REST_TRIGGER);
    int n; while (GetIsObjectValid(oTrigger))
    {
        SetLocalString(oTrigger, TRIGGER_EVENT_ON_ENTER, "rest_OnTriggerEnter:only");
        SetLocalString(oTrigger, TRIGGER_EVENT_ON_EXIT, "rest_OnTriggerExit:only");
        SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER, CORE_HOOK_NWN);
        SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT, CORE_HOOK_NWN);
        oTrigger = GetObjectByTag(H2_REST_TRIGGER, ++n);
    }
}

void rest_OnClientEnter()
{
    object oPC = GetEnteringObject();
    if (!_GetIsPC(oPC))
        return;

    h2_InitializeRecoveryRestTime(oPC);
}

void rest_OnPlayerRestStarted()
{
    object oPC = GetLastPCRested();

    if (!h2_GetAllowRest(oPC))
        return;

    int skipDialog, nRemainingTime = h2_RemainingTimeForRecoveryInRest(oPC);
    if (!H2_USE_REST_DIALOG)
        skipDialog = TRUE;
    else
        skipDialog = GetPlayerInt(oPC, H2_SKIP_REST_DIALOG);
    
    if (H2_REQUIRE_REST_TRIGGER_OR_CAMPFIRE)
    {
        object oRestTrigger = GetPlayerObject(oPC, H2_REST_TRIGGER);
        object oCampfire = GetNearestObjectByTag(H2_CAMPFIRE, oPC);
        if (GetIsObjectValid(oRestTrigger))
        {
            if (GetLocalInt(oRestTrigger, H2_IGNORE_MINIMUM_REST_TIME))
                nRemainingTime = 0;
            string feedback = GetLocalString(oRestTrigger, H2_REST_FEEDBACK);
            if (feedback != "" && skipDialog)
                SendMessageToPC(oPC, feedback);
        }
        else if (!GetIsObjectValid(oCampfire) || GetDistanceBetween(oPC, oCampfire) > 4.0)
        {
            h2_SetAllowRest(oPC, FALSE);
            return;
        }
    }

    if (nRemainingTime > 0)
    {
        if (!skipDialog)
        {
            string waittime = FloatToString(nRemainingTime / HoursToSeconds(1), 5, 2);
            string message = H2_TEXT_RECOVER_WITH_REST_IN + waittime + H2_TEXT_HOURS;
            SendMessageToPC(oPC, message);
        }
        h2_SetAllowSpellRecovery(oPC, FALSE);
        h2_SetAllowFeatRecovery(oPC, FALSE);
        h2_SetPostRestHealAmount(oPC, 0);
    }
    else
    {   
        if (skipDialog && H2_SLEEP_EFFECTS)
            h2_ApplySleepEffects(oPC);
        if (H2_HP_HEALED_PER_REST_PER_LEVEL > -1)
        {
            int postRestHealAmt = H2_HP_HEALED_PER_REST_PER_LEVEL * GetHitDice(oPC);
            h2_SetPostRestHealAmount(oPC, postRestHealAmt);
        }
    }
}

void rest_OnPlayerRestFinished()
{
    object oPC = GetLastPCRested();
    int bAllowSpellRecovery = h2_GetAllowSpellRecovery(oPC);
    if (!bAllowSpellRecovery)
        h2_SetAvailableSpellsToSavedValues(oPC);

    int bAllowFeatRecovery = h2_GetAllowFeatRecovery(oPC);
    if (!bAllowFeatRecovery)
        h2_SetAvailableSpellsToSavedValues(oPC);

    if (bAllowSpellRecovery && bAllowFeatRecovery)
        h2_SaveLastRecoveryRestTime(oPC);

    h2_LimitPostRestHeal(oPC, h2_GetPostRestHealAmount(oPC));
}

void rest_OnPlayerRestCancelled()
{
    object oPC = GetLastPCRested();
    h2_SetPlayerHitPointsToSavedValue(oPC);
    h2_SetAvailableSpellsToSavedValues(oPC);
    h2_SetAvailableFeatsToSavedValues(oPC);
    if (H2_SLEEP_EFFECTS)
        h2_RemoveEffectType(oPC, EFFECT_TYPE_BLINDNESS);
}

void rest_firewood()
{
    int nEvent = GetUserDefinedItemEventNumber();
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC   = GetItemActivator();
        object oItem = GetItemActivated();
        h2_UseFirewood(oPC, oItem);
    }
}

void rest_OnTriggerEnter()
{
    object oPC = GetEnteringObject();
    SetPlayerObject(oPC, H2_REST_TRIGGER, OBJECT_SELF);
}

void rest_OnTriggerExit()
{
    object oPC = GetExitingObject();
    DeletePlayerObject(oPC, H2_REST_TRIGGER);
}
