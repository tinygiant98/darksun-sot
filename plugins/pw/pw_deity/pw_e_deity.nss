/// ----------------------------------------------------------------------------
/// @file   pw_e_deity.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Deity Library (events)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "pw_i_deity"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for module-level OnPlayerDeath event.  If the dead
///     player character has a deity and successfuly passes the check for
///     deity resurrection, the player character is resurrected at the deity's
///     respawn/resurrection point without penalty.
/// @note Successful deity resurrection aborts OnPlayerDeath event processing.
void deity_OnPlayerDeath();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void deity_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

    if (h2_CheckForDeityRez(oPC))
    {
        h2_DeityRez(oPC);
        SetEventState(EVENT_STATE_ABORT);
    }
}
