/// ----------------------------------------------------------------------------
/// @file   pw_e_loot.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Loot Library (events)
/// ----------------------------------------------------------------------------

#include "pw_i_loot"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for module-level OnPlayerDying event.  Creates the
///     loot placeable and transfers the player character's non-equipped item
///     inventory to the placeable inventory.
void loot_OnPlayerDying();

/// @brief Event handler for module-level OnPlayerDeath event.  Creates the
///     loot placeable and transfers the player character's inventory to the
///     placeable inventory.
void loot_OnPlayerDeath();

/// @brief Event handler for OnPlaceableClose event.  Destroys the loot
///     placeable once it's inventory is empty.
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
