/// ----------------------------------------------------------------------------
/// @file   pw_i_loot.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Loot Library (core)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "pw_i_core"
#include "pw_c_loot"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Create the placeable object that will hold all items looted from
///     a dying or dead player character.
object h2_CreateLootBag(object oPC);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

object h2_CreateLootBag(object oPC)
{
    object oLootBag = GetLocalObject(oPC, LOOT_PLACEABLE);
    location lLootBag = GetLocation(oLootBag);
    location lPlayer = GetLocation(oPC);
    
    if (!GetIsObjectValid(oLootBag) || GetDistanceBetweenLocations(lPlayer, lLootBag) > 3.0 ||
        GetAreaFromLocation(lLootBag) != GetArea(oPC))
    {
        oLootBag = CreateObject(OBJECT_TYPE_PLACEABLE, LOOT_PLACEABLE, GetLocation(oPC));
        SetLocalObject(oPC, LOOT_PLACEABLE, oLootBag);
        HookObjectEvents(oLootBag, TRUE, FALSE);
        SetLocalString(oLootBag, PLACEABLE_EVENT_ON_CLOSE, "loot_OnPlaceableClose");
    }

    return oLootBag;
}
