// -----------------------------------------------------------------------------
//    File: ds_e_fugue.nss
//  System: Fugue Death and Resurrection (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for DS Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "util_i_time"
#include "core_i_framework"
#include "ds_i_fugue"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< ds_fug_OnPlayerDeath >---
// Upon death, drop all henchmen, generate a random number between 0 and 100
// If it is below the Angel value, the PC goes to the Fugue
// If it is greater the PC goes to the Angel's Home
// TODO - Druids or Rangers who die cannot respawn their familiar until they clear a condition.
void ds_fug_OnPlayerDeath();

// ---< ds_fug_OnPlayerChat >---
// Used for testing.  When the PC types the command .die in chat, it kills the PC
void ds_fug_OnPlayerChat();

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

void ds_fug_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;  //PC ain't dead.  Return.

    // Generate a Random Number for Now
    // TODO -   Develop real rules based on many other things including recency of last death, alignment stray...
    int iRnd = d100();
    int iChance = clamp(DS_FUGUE_ANGEL_CHANCE, 0, 100);

    // Let the PW Fugue system take it from here.
    if (iRnd < (100 - iChance))
        return;

	if (GetTag(GetArea(oPC)) == ANGEL_PLANE)
    {
		//If you're already at the Angel, just make sure you're alive and healed.
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
