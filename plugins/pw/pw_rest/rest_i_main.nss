// -----------------------------------------------------------------------------
//    File: rest_i_main.nss
//  System: Rest (core)
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "rest_i_config"
#include "rest_i_const"
#include "rest_i_text"
#include "pw_i_core"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

//This function saves a value derived from the time since the server was started
//when oPC finishes a rest in which their spells and feats were allowed to be recovered
//properly. This value is used in determining the elapsed time since their last recovery
//rest when oPC next tries to rest.
void h2_SaveLastRecoveryRestTime(object oPC);

//Returns the amount of time in real seconds that are remaining
//before recovery in rest is allowed according to H2_MINIMUM_SPELL_RECOVERY_REST_TIME
//and the time elapsed since the last time oPC recovered during rest.
int h2_RemainingTimeForRecoveryInRest(object oPC);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_InitializeRecoveryRestTime(object oPC)
{
    string uniquePCID = _GetLocalString(oPC, H2_UNIQUE_PC_ID);
    string lastRest = _GetLocalString(MODULE, uniquePCID + H2_LAST_PC_REST_TIME);

    if (lastRest == "")
    {
        string sTime = GetSystemTime();
        sTime = SubtractSystemTimeElement(TIME_SECONDS, H2_MINIMUM_SPELL_RECOVERY_REST_TIME, sTime);
        _SetLocalString(MODULE, uniquePCID + H2_LAST_PC_REST_TIME, sTime);
    }
}

void h2_SaveLastRecoveryRestTime(object oPC)
{
    string uniquePCID = _GetLocalString(oPC, H2_UNIQUE_PC_ID);
    _SetLocalString(MODULE, uniquePCID + H2_LAST_PC_REST_TIME, GetSystemTime());
}

int h2_RemainingTimeForRecoveryInRest(object oPC)
{
    string uniquePCID = _GetLocalString(oPC, H2_UNIQUE_PC_ID);
    string lastRest = _GetLocalString(MODULE, uniquePCID + H2_LAST_PC_REST_TIME);
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
            string endTime = _GetLocalString(oTarget, H2_CAMPFIRE_END_TIME);
            endTime = AddGameTimeElement(TIME_HOURS, H2_CAMPFIRE_BURN_TIME, endTime);
            _SetLocalString(oTarget, H2_CAMPFIRE_END_TIME, endTime);
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
        _SetLocalString(oCampfire, H2_CAMPFIRE_END_TIME, AddGameTimeElement(TIME_HOURS, H2_CAMPFIRE_BURN_TIME, GetGameTime()));
        DelayCommand(HoursToSeconds(H2_CAMPFIRE_BURN_TIME) + 5.0, h2_CheckIfCampfireIsOut(oCampfire));
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, 3.0));
        DestroyObject(oFirewood);
    }
}
