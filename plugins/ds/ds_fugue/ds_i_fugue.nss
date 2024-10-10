/// ----------------------------------------------------------------------------
/// @file   ds_i_fugue.nss
/// @author Anthony Sovaca (Jacyn)
/// @brief  Fugue System (core)
/// ----------------------------------------------------------------------------

#include "pw_i_core"

#include "ds_k_core"
#include "pw_i_fugue"
#include "ds_c_fugue"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Send a dead player character to the angel plane.
/// @param oPC The dead player character.
void SendPlayerToAngel(object oPC);

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------
void SendPlayerToAngel(object oPC)
{
    object oAngelWP = GetObjectByTag(WP_ANGEL);
    SendMessageToPC(oPC, H2_TEXT_YOU_HAVE_DIED);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);

    h2_RemoveEffects(oPC);
    ClearAllActions();
    AssignCommand(oPC, JumpToObject(oAngelWP));
}
