// -----------------------------------------------------------------------------
//    File: fugue_i_main.nss
//  System: Fugue Death and Resurrection (core)
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// There are no constants associated with this system.

// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "hcr_i_core"
#include "hcr_c_fugue"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< _SendPlayerToFugue >---
// Upon player death, send the PC to the fugue plane and resurrect.
void h2_SendPlayerToFugue(object oPC);

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

void h2_SendPlayerToFugue(object oPC)
{
    object oFugueWP = GetObjectByTag(H2_WP_FUGUE);
    SendMessageToPC(oPC, H2_TEXT_YOU_HAVE_DIED);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);

    h2_RemoveEffects(oPC);
    ClearAllActions();
    AssignCommand(oPC, JumpToObject(oFugueWP));
}

#include "chat_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< fugue_OnClientEnter >---
// If the player is dead, but is not in the fugue or at his deity's ressurection 
//  location, send them to the fugue.
void fugue_OnClientEnter();

// ---< fugue_OnPlayerDeath >---
// Upon death, drop all henchmen and send PC to the fugue plane.
void fugue_OnPlayerDeath();

// ---< fugue_OnPlayerDying >---
// When a PC is dying, and already in the fugue plane, resurrect.
void fugue_OnPlayerDying();

// ---< fugue_OnPlayerExit >---
// No matter how a player exits the fugue plane, mark PC as alive.
void fugue_OnPlayerExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void fugue_OnClientEnter()
{
    // TODO
    /*
    object oPC = GetEnteringObject();
    int playerstate = pw_GetPlayerState(oPC);
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    location ressLoc = GetDatabaseLocation(uniquePCID + H2_RESS_LOCATION);
    if (GetTag(GetArea(oPC)) != H2_FUGUE_PLANE && playerstate == H2_PLAYER_STATE_DEAD && !h2_GetIsLocationValid(ressLoc))
        DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, h2_SendPlayerToFugue(oPC));
    */
}

void fugue_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (pw_GetPlayerState(oPC) != H2_PLAYER_STATE_DEAD)
        return;  //<-- Use core-framework cancellation function?

    if (GetTag(GetArea(oPC)) == H2_FUGUE_PLANE)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        return;
    }
    else
    {
        h2_DropAllHenchmen(oPC);
        h2_SendPlayerToFugue(oPC);
    }
}

void fugue_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (GetTag(GetArea(oPC)) == H2_FUGUE_PLANE)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        return;
    }
}

void fugue_OnPlayerExit()  // TODO is this for the area exit?
{
    object oPC = GetExitingObject();
    DeletePlayerInt(oPC, H2_LOGIN_DEATH);
    pw_SetPlayerState(oPC, H2_PLAYER_STATE_ALIVE);
}

void fugue_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;
    
    string sCommand = GetChatCommand(oPC);
    if (sCommand == "die")
    {
        int iHP = GetCurrentHitPoints(oPC) + 11;
        effect eDam = EffectDamage(iHP);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
        SendChatResult("You killed " + GetName(oTarget) + ".  You murderer!", oPC);
    }
    else if (sCommand == "dying")
    {
        int iHP = GetCurrentHitPoints(oPC) + 5;
        effect eDam = EffectDamage(iHP);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
        SendChatResult("Oh no!  " + GetName(oTarget) + " is dying. :)", oPC);
    }
}
