/// -----------------------------------------------------------------------------
/// @file:  hcr_i_loot.nss
/// @brief: HCR2 Loot System (core)
/// -----------------------------------------------------------------------------

#include "util_i_data"
#include "core_i_framework"
#include "hcr_c_loot"
#include "hcr_i_core"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event script for module-level OnPlayerDying event.  Creates the
///     dying character's lootbag and fills it with non-equipped items.
void loot_OnPlayerDying();

/// @brief Event script for module-level OnPlayerDeath event.  Creates the
///     dead character's lootbag and fills it with all items in their inventory.
void loot_OnPlayerDeath();

/// @brief Event script for local OnPlaceableClose event for the lootbag. Destroys
///     the lootbag placeable when no inventory remains.
void loot_OnPlaceableClose();

/// @brief Creates a placeable to hold a dying/dead character's inventory items.
/// @param oPC Dying/dead character.
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
        SetLocalString(oLootBag, PLACEABLE_EVENT_ON_CLOSE, "loot_OnPlaceableClose:only");
        SetLocalObject(oPC, H2_LOOT_BAG, oLootBag);
    }

    return oLootBag;
}

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
