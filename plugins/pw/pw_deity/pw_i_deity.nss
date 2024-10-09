/// ----------------------------------------------------------------------------
/// @file   pw_i_deity.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Deity Library (core)
/// ----------------------------------------------------------------------------

#include "util_i_math"

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

    float fChance = fclamp(DEITY_REZ_CHANCE_BASE, 0.0, 100.0);
    float fPerLevel = fclamp(DEITY_REZ_CHANCE_PER_LEVEL, 0.0, 100.0);

    float totalpercent = fChance + (GetHitDice(oPC) * fPerLevel) * 10.0;
    totalpercent = fclamp(totalpercent, 0.0, 1000.0);
    int random = Random(1000);
    
    if (totalpercent > random * 1.0)
        return TRUE;
    
    SendMessageToPC(oPC, H2_TEXT_DEITY_NO_REZ);
    return FALSE;
}
