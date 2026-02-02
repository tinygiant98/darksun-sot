/// ----------------------------------------------------------------------------
/// @file   pw_i_loot.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Loot System (core).
/// ----------------------------------------------------------------------------

#include "util_i_data"
#include "pw_i_core"
#include "pw_c_loot"

// -----------------------------------------------------------------------------
//                          Public Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates a placeable to hold the inventory items of a character while
///     they are dead or dying.
/// @param oPC The player character object.
object loot_CreateLootBag(object oPC);

// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

object loot_CreateLootBag(object oPC)
{
    object oLootBag = GetLocalObject(oPC, LOOT_BAG_RESREF);
    location lLootBag = GetLocation(oLootBag);
    location lPlayer = GetLocation(oPC);
    
    if (!GetIsObjectValid(oLootBag) || GetDistanceBetweenLocations(lPlayer, lLootBag) > 3.0 ||
        GetAreaFromLocation(lLootBag) != GetArea(oPC))
    {
        oLootBag = CreateObject(OBJECT_TYPE_PLACEABLE, LOOT_BAG_RESREF, GetLocation(oPC));
        SetLocalObject(oPC, LOOT_BAG_RESREF, oLootBag);
    }

    return oLootBag;
}

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

void loot_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (pw_GetCharacterState(oPC) != PW_CHARACTER_STATE_DYING)
        return;

    object oLootBag = loot_CreateLootBag(oPC);
    h2_MovePossessorInventory(oPC, TRUE, oLootBag);
}

void loot_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    if (GetPlayerInt(oPC, H2_LOGIN_DEATH))
        return;

    if (pw_GetCharacterState(oPC) != PW_CHARACTER_STATE_DEAD)
        return;

    object oLootBag = loot_CreateLootBag(oPC);
    h2_MovePossessorInventory(oPC, TRUE, oLootBag);
    h2_MoveEquippedItems(oPC, oLootBag);
}

void loot_OnPlaceableClose()
{
    if (!GetIsObjectValid(GetFirstItemInInventory(OBJECT_SELF)))
        DestroyObject(OBJECT_SELF);
}
