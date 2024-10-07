// -----------------------------------------------------------------------------
//    File: pw_e_deity.nss
//  System: Deity Resurrection (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

 #include "pw_i_deity"

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
