// -----------------------------------------------------------------------------
//    File: ds_fug_i_events.nss
//  System: Fugue Death and Resurrection (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for DS Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
#include "ds_fug_i_main"
#include "util_i_data"
#include "core_i_framework"
#include "util_i_math"
//
// ---< ds_fug_OnPlayerDeath >---
// Upon death, drop all henchmen, generate a random number between 0 and 100
// If it is 50 or less, the PC goes to the Fugue
// If it is 51 or greater the PC goes to the Angel's Home
// TODO -   Develop a real rule based on many other things including recency
//          of last death, etc.         
void ds_fug_OnPlayerDeath();

void ds_fug_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (_GetLocalInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;  //PC ain't dead.  Return.

    //Generate a Random Number for Now
    int iRnd = d100();
    int iChance = clamp(DS_FUGUE_ANGEL_CHANCE, 0, 100);

    Notice("ds_fug_OnPlayerDeath: " +
            "\n  iChance = " + IntToString(iChance) +
            "\n  iRnd   = " + IntToString(iRnd));

    if (iRnd < (100-iChance))
        Notice("Sending " + GetName(oPC) + " to the Fugue");
    else
    {
        if (GetTag(GetArea(oPC)) == H2_ANGEL_PLANE)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
            return;
        }
        else
        {
            Notice("Sending " + GetName(oPC) + " to the Angel");
            h2_DropAllHenchmen(oPC);
            h2_SendPlayerToAngel(oPC);   
        }
        SetEventState(EVENT_STATE_ABORT);
    }
}