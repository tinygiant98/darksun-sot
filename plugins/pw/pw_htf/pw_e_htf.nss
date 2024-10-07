// -----------------------------------------------------------------------------
//    File: pw_e_htf.nss
//  System: Hunger, Thirst, Fatigue (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "x2_inc_switches"
#include "pw_i_htf"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Module Events -----

void hungerthirst_OnClientEnter()
{
    object oPC = GetEnteringObject();
    if (!_GetIsDM(oPC))
        h2_InitHungerThirstCheck(oPC);
}

void fatigue_OnClientEnter()
{
    object oPC = GetEnteringObject();
    if (!_GetIsDM(oPC))
        h2_InitFatigueCheck(oPC);
}

void hungerthirst_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    DeletePlayerFloat(oPC, H2_HT_CURR_THIRST);
    DeletePlayerFloat(oPC, H2_HT_CURR_HUNGER);
    DeletePlayerFloat(oPC, H2_HT_CURR_ALCOHOL);
    int timerID = GetLocalInt(oPC, H2_HT_DRUNK_TIMERID);
    KillTimer(timerID);
    DeletePlayerInt(oPC, H2_HT_DRUNK_TIMERID);
    DeletePlayerInt(oPC, H2_HT_IS_DEHYDRATED);
    DeletePlayerInt(oPC, H2_HT_IS_STARVING);
    DeletePlayerInt(oPC, H2_HT_HUNGER_NONLETHAL_DAMAGE);
    DeletePlayerInt(oPC, H2_HT_THIRST_NONLETHAL_DAMAGE);
}

void hungerthirst_OnPlayerRestFinished()
{
    object oPC = GetLastPCRested();
    DeletePlayerFloat(oPC, H2_HT_CURR_ALCOHOL);
    int timerID = GetLocalInt(oPC, H2_HT_DRUNK_TIMERID);
    KillTimer(timerID);
    DeletePlayerInt(oPC, H2_HT_DRUNK_TIMERID);
}

void fatigue_OnPlayerRestFinished()
{
    object oPC = GetLastPCRested();
    SetLocalFloat(oPC, H2_CURR_FATIGUE, 1.0);
    DeletePlayerInt(oPC, H2_IS_FATIGUED);
    DeletePlayerInt(oPC, H2_FATIGUE_SAVE_COUNT);
}

//This script should be placed in the on used event
//of a placeable that acts as a source of food or drink.

//Make this placeable a useable, non-container and assign variables to it
//in the same way that you would assign variables to an h2_fooditem.
void htf_OnPlaceableUsed()
{
    object oPC = GetLastUsedBy();
    SendMessageToPC(oPC, H2_TEXT_TAKE_A_DRINK);
    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK));
    h2_ConsumeFoodItem(oPC, OBJECT_SELF);
}

void hungerthirst_OnTriggerEnter()
{
    object oPC = GetEnteringObject();
    SetLocalObject(oPC, H2_HT_TRIGGER, OBJECT_SELF);
}

void hungerthirst_OnTriggerExit()
{
    object oPC = GetExitingObject();
    DeleteLocalObject(oPC, H2_HT_TRIGGER);
}

// ----- Tag-based Scripting -----

void htf_canteen()
{
    int nEvent = GetUserDefinedItemEventNumber();
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC   = GetItemActivator();
        object oItem = GetItemActivated();
        h2_UseCanteen(oPC, oItem);
    }
}

void htf_fooditem()
{
    int nEvent = GetUserDefinedItemEventNumber();
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC   = GetItemActivator();
        object oItem = GetItemActivated();
        h2_ConsumeFoodItem(oPC, oItem);
    }
}

// ----- Timer Events -----

void htf_drunk_OnTimerExpire()
{
    h2_DoDrunkenAntics(OBJECT_SELF);
}

void htf_ht_OnTimerExpire()
{
    h2_PerformHungerThirstCheck(OBJECT_SELF);
}

void htf_f_OnTimerExpire()
{
    h2_PerformFatigueCheck(OBJECT_SELF);
}
