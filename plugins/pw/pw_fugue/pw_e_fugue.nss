/// ----------------------------------------------------------------------------
/// @file   pw_e_fugue.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Fugue Library (events)
/// ----------------------------------------------------------------------------

#include "util_i_chat"
#include "util_i_csvlists"

#include "core_i_constants"

#include "pw_i_fugue"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for module-level OnModuleLoad event.  Ensure the fugue
///     plane area object is setup correctly for the fugue plane.
void fugue_OnModuleLoad();

/// @brief Event handler for module-level OnClientEnter event.  If the entering
///     player character is marked as dead, but the player object is not
///     in the fugue plane or at the resurrection location, send the player to
///     the fugue plane. 
void fugue_OnClientEnter();

/// @brief Event handler for module-level OnPlayerDeath event.  Upon death,
///     drop all henchmen and send the player character to the fugue plane.
void fugue_OnPlayerDeath();

/// @brief Event handler for module-level OnPlayerDying event.  If a player
///     character is dying, but is already located in the fugue plane, resurrect
///     the player character.
void fugue_OnPlayerDying();

/// @brief Event handler for module-level OnClientExit event.  Ensure a player
///     character that departs the fugue plane is marked as alive.
void fugue_OnAreaExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void fugue_OnModuleLoad()
{
    AddLocalListItem(GetObjectByTag(FUGUE_PLANE), AREA_EVENT_ON_EXIT, "fugue_OnAreaExit", TRUE);
}

void fugue_OnClientEnter()
{
    object oPC = GetEnteringObject();
    int playerstate = GetPlayerInt(oPC, H2_PLAYER_STATE);
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    location ressLoc = GetPersistentLocation(uniquePCID + H2_RESS_LOCATION);
    if (GetTag(GetArea(oPC)) != FUGUE_PLANE && playerstate == H2_PLAYER_STATE_DEAD && !h2_GetIsLocationValid(ressLoc))
        DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, h2_SendPlayerToFugue(oPC));
}

void fugue_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;  //<-- Use core-framework cancellation function?

    if (GetTag(GetArea(oPC)) == FUGUE_PLANE)
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
    if (GetTag(GetArea(oPC)) == FUGUE_PLANE)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        return;
    }
}

void fugue_OnAreaExit()
{
    object oPC = GetExitingObject();
    DeletePlayerInt(oPC, H2_LOGIN_DEATH);
    SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    RunEvent(H2_EVENT_ON_PLAYER_LIVES, OBJECT_INVALID, oPC);
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
