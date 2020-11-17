// -----------------------------------------------------------------------------
//    File: loot_i_events.nss
//  System: PC Corspe Loot (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "loot_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< loot_OnPlayerDying >---
// Registered as a library and event script in loot_l_plugin.  This function
//  will execute on the module-level OnPlayerDying event.  This function creates
//  the PC's lootbag and fills it with non-equipped items.
void loot_OnPlayerDying();

// ---< loot_OnPlayerDeath >---
// Registered as a library and event script in loot_l_plugin.  This function
//  will execute on the module-level OnPlayerDeath event.  This function creates
//  the PC's lootbag and fills it will all items in PC's inventory.
void loot_OnPlayerDeath();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void loot_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (_GetLocalInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DYING)
        return;

    object oLootBag = h2_CreateLootBag(oPC);
    h2_MovePossessorInventory(oPC, TRUE, oLootBag);
}

void loot_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    if (_GetLocalInt(oPC, H2_LOGIN_DEATH))
        return;

    if (_GetLocalInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

    object oLootBag = h2_CreateLootBag(oPC);
    h2_MovePossessorInventory(oPC, TRUE, oLootBag);
    h2_MoveEquippedItems(oPC, oLootBag);
}
