// -----------------------------------------------------------------------------
//    File: pw_i_deity.nss
//  System: Deity (core)
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

#include "util_i_data"
#include "pw_i_core"
#include "pw_c_deity"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< h2_DeityRez >---
// If a PC is ressurected by his deity, this function resets all approriate
//  PC variables and sends the PC to the deity ressurection waypoint.
void h2_DeityRez(object oPC);

// ---< h2_CheckForDeityRez >---
// This function will determine whether the PC will be resurrected by their
//  diety.
int h2_CheckForDeityRez(object oPC);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_DeityRez(object oPC)
{
    string deity = GetDeity(oPC);
    effect eRes = EffectResurrection();
    effect eHeal = EffectHeal(GetMaxHitPoints(oPC));

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eRes, oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oPC);
    SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    RunEvent(H2_EVENT_ON_PLAYER_LIVES, oPC, oPC);
    SendMessageToPC(oPC, H2_TEXT_DEITY_REZZED);
    
    string deityRez = GetName(oPC) + "_" + GetPCPlayerName(oPC) + H2_TEXT_DM_DEITY_REZZED + GetDeity(oPC);
    Debug(deityRez);
    SendMessageToAllDMs(deityRez);
    object deitywp = GetObjectByTag("WP_" + deity);
    if (GetIsObjectValid(deitywp))
    {
        AssignCommand(oPC, JumpToLocation(GetLocation(deitywp)));
        return;
    }

    deitywp = GetObjectByTag(H2_GENERAL_DEITY_REZ_WAYPOINT);
    if (GetIsObjectValid(deitywp))
    {
        AssignCommand(oPC, JumpToLocation(GetLocation(deitywp)));
        return;
    }

    location loc = GetPlayerLocation(oPC, H2_LOCATION_LAST_DIED);
    AssignCommand(oPC, JumpToLocation(loc));
}

int h2_CheckForDeityRez(object oPC)
{
    string deity = GetDeity(oPC);
    if (deity == "" || deity == "NONE")
        return FALSE;

    float totalpercent  = (H2_BASE_DEITY_REZ_CHANCE + (GetHitDice(oPC) * H2_DEITY_REZ_CHANCE_PER_LEVEL));
    totalpercent = totalpercent * 10.0;
    int random = Random(1000);
    SendMessageToPC(oPC, IntToString(FloatToInt(totalpercent)) + " " + IntToString(random));
    
    if (FloatToInt(totalpercent) > Random(1000))
        return TRUE;
    
    SendMessageToPC(oPC, H2_TEXT_DEITY_NO_REZ);
    return FALSE;
}

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< deity_OnPlayerDeath >---
// This is a framework-registerd script that fires on the module-level
//  OnPlayerDeath event to determine whether a PC will be resurrected
//  by their deity.
void deity_OnPlayerDeath();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void deity_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();

    //if some other death subsystem set the player state back to alive before this one, no need to continue
    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

    if (h2_CheckForDeityRez(oPC))
        h2_DeityRez(oPC);
}
