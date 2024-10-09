/// ----------------------------------------------------------------------------
/// @file   pw_e_htf.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Hunger, Thirst, Fatigue Library (events)
/// ----------------------------------------------------------------------------

#include "x2_inc_switches"

#include "pw_i_htf"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for module-level OnClientEnter event (ht).
void hungerthirst_OnClientEnter();

/// @brief Event handler for module-level OnClientEnter event (f).
void fatigue_OnClientEnter();

/// @brief Event handler for module-level OnPlayerDeath event.
void hungerthirst_OnPlayerDeath();

/// @brief Event handler for module-level OnPlayerRestFinished event (ht).
void hungerthirst_OnPlayerRestFinished();

/// @brief Event handler for module-level OnPlayerRestFinished event (f).
void fatigue_OnPlayerRestFinished();

/// @brief Event handler for OnPlaceableUsed event.
void htf_OnPlaceableUsed();

/// @brief Event handler for module-level OnTriggerEnter event.
void hungerthirst_OnTriggerEnter();

/// @brief Event handler for module-level OnTriggerExit event.
void hungerthirst_OnTriggerExit();

/// @brief Event handler for tag-based script (canteen).
void htf_canteen();

/// @brief Event handler for tag-based script (fooditem).
void htf_fooditem();

/// @brief Event handler for timer event (drunk).
void htf_drunk_OnTimerExpire();

/// @brief Event handler for timer event (ht expiration).
void htf_ht_OnTimerExpire();

/// @brief Event handler for timer event (f expiration).
void htf_f_OnTimerExpire();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void hungerthirst_OnClientEnter()
{
    object oPC = GetEnteringObject();
    if (!_GetIsDM(oPC))
        h2_InitHungerThirstCheck(oPC);
}

void hungerthirst_OnPlayerRestFinished()
{
    object oPC = GetLastPCRested();
    DeletePlayerFloat(oPC, H2_HT_CURR_ALCOHOL);
    DeletePlayerInt(oPC, H2_HT_DRUNK_TIMERID);

    KillTimer(GetLocalInt(oPC, H2_HT_DRUNK_TIMERID));
}

void hungerthirst_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    DeletePlayerFloat(oPC, H2_HT_CURR_THIRST);
    DeletePlayerFloat(oPC, H2_HT_CURR_HUNGER);
    DeletePlayerFloat(oPC, H2_HT_CURR_ALCOHOL);
    DeletePlayerInt(oPC, H2_HT_DRUNK_TIMERID);
    DeletePlayerInt(oPC, H2_HT_IS_DEHYDRATED);
    DeletePlayerInt(oPC, H2_HT_IS_STARVING);
    DeletePlayerInt(oPC, H2_HT_HUNGER_NONLETHAL_DAMAGE);
    DeletePlayerInt(oPC, H2_HT_THIRST_NONLETHAL_DAMAGE);

    KillTimer(GetLocalInt(oPC, H2_HT_DRUNK_TIMERID));
}

void hungerthirst_OnTriggerEnter()
{
    SetLocalObject(GetEnteringObject(), H2_HT_TRIGGER, OBJECT_SELF);
}

void hungerthirst_OnTriggerExit()
{
    DeleteLocalObject(GetExitingObject(), H2_HT_TRIGGER);
}

void fatigue_OnClientEnter()
{
    object oPC = GetEnteringObject();
    if (!_GetIsDM(oPC))
        h2_InitFatigueCheck(oPC);
}

void fatigue_OnPlayerRestFinished()
{
    object oPC = GetLastPCRested();
    SetLocalFloat(oPC, H2_CURR_FATIGUE, 1.0);
    DeletePlayerInt(oPC, H2_IS_FATIGUED);
    DeletePlayerInt(oPC, H2_FATIGUE_SAVE_COUNT);
}

void htf_OnPlaceableUsed()
{
    object oPC = GetLastUsedBy();
    SendMessageToPC(oPC, H2_TEXT_TAKE_A_DRINK);
    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK));
    h2_ConsumeFoodItem(oPC, OBJECT_SELF);
}

void htf_canteen()
{
    if (GetUserDefinedItemEventNumber() == X2_ITEM_EVENT_ACTIVATE)
        h2_UseCanteen(GetItemActivator(), GetItemActivated());
}

void htf_fooditem()
{
    if (GetUserDefinedItemEventNumber() == X2_ITEM_EVENT_ACTIVATE)
        h2_ConsumeFoodItem(GetItemActivator(), GetItemActivated());
}

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
