/// ----------------------------------------------------------------------------
/// @file   pw_e_crowd.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Crowd Library (events)
/// ----------------------------------------------------------------------------

#include "util_i_data"
#include "util_i_map"

#include "pw_i_crowd"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Event handler for OnModuleLoad event.  Initializes the crowd/
///     simulated population variables based on custom crown initializer objects.
void crowd_OnModuleLoad();

/// @brief Event handler for OnAreaEnter event.  Starts a timer to check for
///     updating any assigned crowds if there are PCs in the area.
void crowd_OnAreaEnter();

/// @brief Event handler for OnAreaExit event.  Stops any running crowd timers
///     and clears the area of any crowd objects that have been spawned.
void crowd_OnAreaExit();

/// @brief Event handler for OnTimerExpire for the area crowd check timer.  Checks
///     if a player character is in the area and, if so, checks the area-assigned
///     crowds to see if any crowd members need to be spawned or despawned.
void crowd_OnTimerExpire();

/// @brief Event handler for OnCreatureDeath for crowd objects.  Removes dead
///     crowd members from the area's crowd roster.
void crowd_OnCreatureDeath();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void crowd_OnModuleLoad()
{
    if (!GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        InitializeSystem(CROWDS, CROWD_ITEM_INVENTORY, CROWD_ITEM_LOADED_CSV,
                         CROWD_ITEM_PREFIX, CROWD_ITEM_OBJECT_LIST,
                         CROWD_ITEM_INITIALIZED, FALSE);
}

void crowd_OnAreaEnter()
{
    object oPC = GetEnteringObject();
    object oArea = OBJECT_SELF;

    if (!_GetIsPC(oPC))
        return;

    if (!GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        crowd_OnModuleLoad();
    
    string sCrowds = GetLocalString(oArea, CROWD_CSV);
    if (sCrowds == "")
        return;

    if (!GetLocalInt(oArea, AREA_CROWD_ITEM_INITIALIZED))
        InitializeCrowds(oArea);
    else
        SpawnCrowds(oArea);
}

void crowd_OnAreaExit()
{
    if (!GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        return;

    object oPC = GetExitingObject();
    if (!_GetIsPC(oPC))
        return;

    if (!CountObjectList(OBJECT_SELF, AREA_ROSTER))
        ClearCrowds(OBJECT_SELF);
}

void crowd_OnTimerExpired()
{
    UpdateCrowds(OBJECT_SELF);
}

void crowd_OnCreatureDeath()
{
    RemoveListObject(GetArea(OBJECT_SELF), OBJECT_SELF, CROWD_ROSTER + GetLocalString(OBJECT_SELF, CROWD_ITEM));
}
