// -----------------------------------------------------------------------------
//    File: unid_i_main.nss
//  System: UnID Item on Drop (core)
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "pw_i_core"
#include "pw_c_loot"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// There are no constants associated with this system.

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< h2_CreateLootBag >---
//Creates an item to hold the items of oPC while they are dead or dying.
object h2_CreateLootBag(object oPC);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

object h2_CreateLootBag(object oPC)
{
    object oLootBag = GetLocalObject(oPC, H2_LOOT_BAG);
    location lLootBag = GetLocation(oLootBag);
    location lPlayer = GetLocation(oPC);
    
    if (!GetIsObjectValid(oLootBag) || GetDistanceBetweenLocations(lPlayer, lLootBag) > 3.0 ||
        GetAreaFromLocation(lLootBag) != GetArea(oPC))
    {
        oLootBag = CreateObject(OBJECT_TYPE_PLACEABLE, H2_LOOT_BAG, GetLocation(oPC));
        SetLocalObject(oPC, H2_LOOT_BAG, oLootBag);
    }

    return oLootBag;
}

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

// ---< loot_OnPlaceableClose >---
// Run from loot placeable to destroy the lootbag once it's empty.
void loot_OnPlaceableClose();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void loot_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DYING)
        return;

    object oLootBag = h2_CreateLootBag(oPC);
    h2_MovePossessorInventory(oPC, TRUE, oLootBag);
}

void loot_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    if (GetPlayerInt(oPC, H2_LOGIN_DEATH))
        return;

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

    object oLootBag = h2_CreateLootBag(oPC);
    h2_MovePossessorInventory(oPC, TRUE, oLootBag);
    h2_MoveEquippedItems(oPC, oLootBag);
}

void loot_OnPlaceableClose()
{
    if (!GetIsObjectValid(GetFirstItemInInventory(OBJECT_SELF)))
        DestroyObject(OBJECT_SELF);
}
