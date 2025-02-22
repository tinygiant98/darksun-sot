/// ----------------------------------------------------------------------------
/// @file   ds_e_fugue.nss
/// @author Anthony Sovaca (Jacyn)
/// @brief  Fugue System (events)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_data"
#include "util_i_time"

#include "ds_i_fugue"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Handler for OnPlayerDeath. Drop all henchment and determine if the
///     dead player will go to the angel plane.
void ds_fug_OnPlayerDeath();

/// @brief Handler for OnPlayerChat.
void ds_fug_OnPlayerChat();

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

void ds_fug_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

    // Generate a Random Number for Now
    // TODO -   Develop real rules based on many other things including recency of last death, alignment stray...
    int iRnd = d100();
    int iChance = clamp(DS_FUGUE_ANGEL_CHANCE, 0, 100);

    if (iRnd < (100 - iChance))
        return;

	if (GetTag(GetArea(oPC)) == ANGEL_PLANE)
    {
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        return;
    }
    else
    {
		h2_DropAllHenchmen(oPC);
        SendPlayerToAngel(oPC);   
    }

    SetEventState(EVENT_STATE_ABORT);
}
