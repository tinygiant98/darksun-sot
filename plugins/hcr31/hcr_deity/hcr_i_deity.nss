/// -----------------------------------------------------------------------------
/// @file:  hcr_i_deity.nss
/// @brief: HCR2 Deity System (core)
/// -----------------------------------------------------------------------------

#include "util_i_data"
#include "core_i_framework"
#include "hcr_c_deity"
#include "hcr_i_core"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief If a player-character is resurrected by their chosen deity, this
///     function resets all appropriate variables and send the player to the
///     resurrection waypoint.
/// @param oPC Player-character being resurrected.
void h2_DeityRez(object oPC);

/// @brief Determines whether a player-character will be resurrected by their
///     chose deity.  Always fails if the player does not have a chosen deity.
/// @param oPC Player-character being resurrected.
/// @returns Whether the player-character will be deity-resurrected.
int h2_CheckForDeityRez(object oPC);

/// @brief Event script for module-level OnPlayerDeath event.  This function
///     determines whether or not a player will be resurrected by their
///     chosen deity.
void deity_OnPlayerDeath();

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

    float totalpercent = (clamp(H2_BASE_DEITY_REZ_CHANCE, 0, 100) + (GetHitDice(oPC) * clamp(H2_DEITY_REZ_CHANCE_PER_LEVEL, 0, 100))) * 10.0;
    int random = Random(1000);
    SendMessageToPC(oPC, IntToString(FloatToInt(totalpercent)) + " " + IntToString(random));
    
    if (FloatToInt(totalpercent) > Random(1000))
        return TRUE;
    
    SendMessageToPC(oPC, H2_TEXT_DEITY_NO_REZ);
    return FALSE;
}

void deity_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

    if (h2_CheckForDeityRez(oPC))
        h2_DeityRez(oPC);
}
