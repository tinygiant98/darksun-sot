// -----------------------------------------------------------------------------
//    File: pw_e_crowd.nss
//  System: Simulated Population (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------


#include "pw_i_crowd"
#include "util_i_data"
#include "util_i_map"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< crowd_OnModuleLoad >---
// Library and event registered function to initialize crowd/simulated population
//  variables based on custom crowd initializer items.
void crowd_OnModuleLoad();

// ---< crowd_OnAreaEnter >---
// Library and event registered function that will start a timer to check for
//  updating any assigned crowds if there are PCs in the area.
void crowd_OnAreaEnter();

// ---< crowd_OnAreaExit >---
// Library and event registered function that will stop a running crowd timer
//  and clear the area of any crowds that have been spawned.
void crowd_OnAreaExit();

// ---< crowd_OnTimerExpire >---
// Library and event registered function that will check if a PC is in the area
//  and, if so, check on the area-assigned crowds to see if any NPCs need to
//  to be spawn/despawned.
void crowd_OnTimerExpire();

// ---< crowd_OnCreatureDeath >---
// Event handler for crowd member death.  This procedure ensures the crowd
//  member is removed from the crowd roster for the specified crowd.
void crowd_OnCreatureDeath();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void crowd_OnModuleLoad()
{
    dbg = sDebugPlugin + "crowd_OnModuleLoad:: ";
    Debug(dbg);

    if (!GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        InitializeSystem(CROWDS, CROWD_ITEM_INVENTORY, CROWD_ITEM_LOADED_CSV,
                         CROWD_ITEM_PREFIX, CROWD_ITEM_OBJECT_LIST,
                         CROWD_ITEM_INITIALIZED, FALSE);
}

void crowd_OnAreaEnter()
{
    dbg = sDebugPlugin + "crowd_OnAreaEnter:: ";
    Debug(dbg);

    object oPC = GetEnteringObject();
    object oArea = OBJECT_SELF;

    if (!_GetIsPC(oPC))
    {
        Notice(dbg + "Entering object is not player controlled.");
        return;
    }

    if (!GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        crowd_OnModuleLoad();
    
    string sCrowds = GetLocalString(oArea, CROWD_CSV);

    if (sCrowds == "")
    {
        Error(dbg + "Crowd variable is blank on " + GetName(oArea));
        return;
    }

    if (!GetLocalInt(oArea, AREA_CROWD_ITEM_INITIALIZED))
        InitializeCrowds(oArea);
    else
        SpawnCrowds(oArea);
}

void crowd_OnAreaExit()
{
    dbg = sDebugPlugin + "crowd_OnAreaExit:: ";
    Debug(dbg);

    if (!GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        return;

    object oPC = GetExitingObject();
    if (!_GetIsPC(oPC))
    {
        Notice(dbg + "Exiting object is not player controlled.");
        return;
    }

    if (!CountObjectList(OBJECT_SELF, AREA_ROSTER))
        ClearCrowds(OBJECT_SELF);
}

void crowd_OnTimerExpired()
{
    dbg = sDebugPlugin + "crowd_OnTimerExpired:: ";
    Debug(dbg);

    UpdateCrowds(OBJECT_SELF);
}

void crowd_OnCreatureDeath()
{
    dbg = sDebugPlugin + "crowd_OnCreatureDeath:: ";
    Debug(dbg);

    object oCreature = OBJECT_SELF;
    object oArea = GetArea(oCreature);
    RemoveListObject(oArea, oCreature, CROWD_ROSTER + GetLocalString(oCreature, CROWD_ITEM));
}
