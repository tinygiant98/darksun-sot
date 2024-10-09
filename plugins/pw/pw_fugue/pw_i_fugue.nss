/// ----------------------------------------------------------------------------
/// @file   pw_i_fugue.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Fugue Library (core)
/// ----------------------------------------------------------------------------

#include "pw_i_core"
#include "pw_c_fugue"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Send the player to the fugue plane and resurrect.
void h2_SendPlayerToFugue(object oPC);

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

void h2_SendPlayerToFugue(object oPC)
{
    object oFugueWP = GetObjectByTag(FUGUE_WP);
    SendMessageToPC(oPC, H2_TEXT_YOU_HAVE_DIED);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);

    h2_RemoveEffects(oPC);
    ClearAllActions();
    AssignCommand(oPC, JumpToObject(oFugueWP));
}
