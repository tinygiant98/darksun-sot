/// -----------------------------------------------------------------------------
/// @file:  hcr_i_fugue.nss
/// @brief: HCR2 Fugue System (core)
/// -----------------------------------------------------------------------------

#include "util_i_data"
#include "core_i_framework"
#include "hcr_c_fugue"
#include "hcr_i_core"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Resurrects the dead player-character in the fugue plane.
/// @param oPC Player-character to be sent to the fugue plane.
void h2_SendPlayerToFugue(object oPC);

/// @brief Event script for module-level OnModuleLoad event.  Sets the
///     OnAreaExit event handler for the fugue plane area object.
void fugue_OnModuleLoad();

/// @brief Event script for module-level OnClientEnter event.  Sends the
///     player to the appropriate location if they are dead and not in the
///     fugue plane or at their chosen deity's resurrection waypoint.
void fugue_OnClientEnter();

/// @brief Event script for module-level OnPlayerDeath event.  Drops all
///     henchment and sends the player-character to the fugue plane.
void fugue_OnPlayerDeath();

/// @brief Event script for module-level OnPlayerDying event.  Resurrects
///     the player-character if they are dying while in the fugue plane.
void fugue_OnPlayerDying();

/// @brief Events cript for the area-level OnAreaExit event.  Marks the
///     player-character as alive, regardless of how they depart the fugue plane.
void fugue_OnAreaExit();

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

void fugue_OnModuleLoad()
{
    SetLocalString(GetObjectByTag(H2_FUGUE_PLANE), AREA_EVENT_ON_EXIT, "fugue_OnAreaExit:only");
}

void fugue_OnClientEnter()
{
    object oPC = GetEnteringObject();
    int playerstate = GetPlayerInt(oPC, H2_PLAYER_STATE);
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    location l = GetPersistentLocation(uniquePCID + H2_RESS_LOCATION, H2_VARIABLE_TAG);
    if (GetTag(GetArea(oPC)) != H2_FUGUE_PLANE && playerstate == H2_PLAYER_STATE_DEAD && !h2_GetIsLocationValid(l))
        DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, h2_SendPlayerToFugue(oPC));
}

void fugue_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

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

void fugue_OnAreaExit()
{
    object oPC = GetExitingObject();
    if (GetTag(OBJECT_SELF) == H2_FUGUE_PLANE)
    {
        DeletePlayerInt(oPC, H2_LOGIN_DEATH);
        SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
        RunEvent(H2_EVENT_ON_PLAYER_LIVES, OBJECT_INVALID, oPC);
    }
}
