/// ----------------------------------------------------------------------------
/// @file   pw_i_deity.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Deity Library (core)
/// ----------------------------------------------------------------------------

#include "pw_i_core"
#include "pw_c_deity"
#include "pw_k_deity"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief If a player character is resurrected by their chosen deity, reset
///     all appropriate variables and send the player character to the diety's
///     specific respawn/resurrection waypoint, if it exists.
/// @param oPC The player character to resurrect.
void h2_DeityRez(object oPC);

/// @brief Determine whether a player character will be resurrected by their
///     chosen deity.
/// @param oPC The player character to check for deity resurrection.
/// @returns TRUE if the player character will be resurrected by their deity.
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

    deitywp = GetObjectByTag(DEITY_REZ_GENERIC_WAYPOINT);
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

    float totalpercent = DEITY_REZ_CHANCE_BASE + (GetHitDice(oPC) * DEITY_REZ_CHANCE_PER_LEVEL) * 10.0;
    int random = Random(1000);
    
    if (totalpercent > random * 1.0)
        return TRUE;
    
    SendMessageToPC(oPC, H2_TEXT_DEITY_NO_REZ);
    return FALSE;
}
