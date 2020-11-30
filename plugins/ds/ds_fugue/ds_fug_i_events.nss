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
//
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
        return;  //<-- Use core-framework cancellation function?

    //Generate a Random Number for Now
    int iRnd = Random(100);
    Notice("The generated random number is " + IntToString(iRnd));
    if (iRnd <= 50)
    {
        if (GetTag(GetArea(oPC)) == H2_FUGUE_PLANE)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
            return;
        }
        else
        {
            Notice("Sending " + GetName(oPC) + " to the Fugue");
            h2_DropAllHenchmen(oPC);
            h2_SendPlayerToFugue(oPC);
        }
    }
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
    }
}