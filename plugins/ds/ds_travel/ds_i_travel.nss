// -----------------------------------------------------------------------------
//    File: unid_i_main.nss
//  System: UnID Item on Drop (core)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

#include "ds_c_travel"
#include "ds_i_const"
#include "util_i_data"
#include "core_i_constants"
#include "pw_i_corpse"
#include "pw_i_loot"
#include "pw_i_core"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// TODO clean up these constants

// ----- Custom Events
const string TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE = "tr_encounter_OnTimerExpire";
const string TRAVEL_ENCOUNTER_NEXT_ID  = "TRAVEL_ENCOUNTER_NEXT_ID";

// ----- Variable Names
// --- PC Variables
const string TRAVEL_ENCOUNTER_TIMER_ID  = "TRAVEL_ENCOUNTER_TIMER_ID";
const string TRAVEL_ENCOUNTER_ID        = "TRAVEL_ENCOUNTER_ID";
const string TRAVEL_MAX_ENCOUNTERS      = "TRAVEL_MAX_ENCOUNTERS";
const string TRAVEL_CURRENT_ENCOUNTERS  = "TRAVEL_CURRENT_ENCOUNTERS";
const string TRAVEL_CREATURE_LOCATION   = "TRAVEL_CREATURE_LOCATION";
const string TRAVEL_ENCOUNTER_CHASE     = "TRAVEL_ENCOUNTER_CHASE";

// --- Area Variables
const string TRAVEL_ENCOUNTER_AREAS        = "TRAVEL_ENCOUNTER_AREAS";
const string TRAVEL_ENCOUNTER_AREA_TAG     = "TRAVEL_ENCOUNTER_AREA_TAG";
const string TRAVEL_WAYPOINT_TYPE          = "TRAVEL_WAYPOINT_TYPE";
const string TRAVEL_WAYPOINT_TAG           = "TRAVEL_WAYPOINT_TAG";
const string TRAVEL_ENCOUNTER_AOE          = "TRAVEL_ENCOUNTER_AOE";
const string TRAVEL_ENCOUNTER_AOE_TAG      = "TRAVEL_ENCOUNTER_AOE_TAG";
const string TRAVEL_ENCOUNTER_PLAYER_DEATH = "TRAVEL_ENCOUNTER_PLAYER_DEATH";

// ----- Area Variable Values
// --- TRAVEL_WAYPOINT_TYPE
const string TRAVEL_WAYPOINT_TYPE_SPAWN = "spawn";
const string TRAVEL_WAYPOINT_TYPE_PRIMARY = "primary";
const string TRAVEL_WAYPOINT_TYPE_SECONDARY = "secondary";
const string TRAVEL_ENCOUNTER_AOE_SCRIPT = "tr_encounter_OnAOEEnter";

// ----- Encounter Data
const string ENCOUNTER_AREA = "ENCOUNTER_AREA";
const string ENCOUNTER_TRIGGERED_BY = "ENCOUNTER_TRIGGERED_BY";
const string ENCOUNTER_PRIMARY_WAYPOINT = "ENCOUNTER_PRIMARY_WAYPOINT";
const string ENCOUNTER_SECONDARY_WAYPOINTS = "ENCOUNTER_SECONDARY_WAYPOINTS";
const string ENCOUNTER_SPAWNPOINTS = "ENCOUNTER_SPAWNPOINTS";

struct TRAVEL_ENCOUNTER
{
    int nEncounterID;
    string sEncounterID;
    object oTriggeredBy;
    object oEncounterArea;
    string sPrimaryWaypoint;
    string sSecondaryWaypoints;
    string sSpawnPoints;
};




//const string TRAVEL_ENCOUNTER_ACTIVE = "TRAVEL_ENCOUNTER_ACTIVE";
const string TRAVEL_ENCOUNTER_AREA = "TRAVEL_ENCOUNTER_AREA";


// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< _setEncounterVariables >---
// Internal function for setting the required variables on any object travelling
//  to an encounter area.
void _setEncounterVariables(object oPC, int nEncounterID);

// ---< tr_CreateEncounter >---
// Sets up all required objects for an encounter to occur.  Returns the encounter
//  ID.  Once this encounter has been created, the encounter ID can be used to 
//  start the encounter and kill the encounter.  The encounter cannot be killed
//  if there is a PC in the area.
int tr_CreateEncounter(object oPC);

// ---< tr_KillEncounter >---
// Deletes all variables associated with nEncounterID, if passed.  If not passed,
//  it is assumed the function is being called from the OnAreaEmpty event.  Will
//  check for PCs in the area and abort if found.  Destroys the encounter area.
void tr_KillEncounter(int nEncounterID = 0);

// ---< tr_StartEncounter >---
// Starts the encounter nEncounterID.  This should never be called if
//  tr_CreateEncounter did not return a valid encounter ID.  
void tr_StartEncounter(int nEncoutnerID);

// ---< tr_CheckForEncounter >---
// This is the executed script with the custom timer event for the overland travel
//  system expires.  This function checks to see if the party will have an
//  encounter during their overland travel and, if so, sends them there.
void tr_CheckForEncounter();

// ---< tr_EncounterExit >---
// This function sends the PC back to where they came from after the conclusion
//  of an encounter.
void tr_EncounterExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void _setEncounterVariables(object oPC, int nEncounterID)
{
    int nEncounters = GetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    
    SetLocalInt(oPC, TRAVEL_ENCOUNTER_ID, nEncounterID);
    SetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS, ++nEncounters);
    SetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION, GetLocation(oPC));
}

struct TRAVEL_ENCOUNTER tr_GetEncounterData(int nEncounterID)
{
    struct TRAVEL_ENCOUNTER te;

    te.nEncounterID = nEncounterID;
    te.sEncounterID = IntToString(nEncounterID);
    te.oEncounterArea = GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + te.sEncounterID);
    te.oTriggeredBy = GetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY + te.sEncounterID);
    te.sPrimaryWaypoint = GetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT + te.sEncounterID);
    te.sSecondaryWaypoints = GetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + te.sEncounterID);
    te.sSpawnPoints = GetLocalString(ENCOUNTERS, ENCOUNTER_SPAWNPOINTS + te.sEncounterID);

    return te;
}

int tf_CreateEncounter(object oPC)
{
    object oEncounterArea, oTravelArea = GetArea(oPC);
    string sSecondaryWaypoints, sWaypointTag, sWaypoints, sTriggers, sSpawnPoints, sEncounterArea;
    string sWaypointType, sEncounterAreas = GetLocalString(oTravelArea, TRAVEL_ENCOUNTER_AREAS);
    int nArea, nEncounterID, nCount = CountList(sEncounterAreas);
    int i = 2;

    if (!nCount)
    {
        Debug("Unable to create encounter, no encounter areas defined on oTravelArea's ENCOUNTER_AREA variable.");
        return 0;
    }
    
    nEncounterID = GetLocalInt(ENCOUNTERS, TRAVEL_ENCOUNTER_NEXT_ID);
    
    if (!nEncounterID)
        nEncounterID = 1;

    string sEncounterID = IntToString(nEncounterID);
    
    Debug("Creating encounter ID " + sEncounterID + " for " + GetName(oPC));

    sEncounterArea = GetListItem(sEncounterAreas, Random(nCount));

    Debug("Attempting to create new area from resref " + sEncounterArea +
        "\n  nCount " + IntToString(nCount) +
        "\n  sEncounterAreas " + sEncounterAreas +
        "\n  sEncounterArea " + sEncounterArea);
    oEncounterArea = CreateArea(sEncounterArea, TRAVEL_ENCOUNTER_AREA_TAG + IntToString(nEncounterID), "Encounter");

    object oAreaObject = GetFirstObjectInArea(oEncounterArea);

    while (GetIsObjectValid(oAreaObject))
    {
        if (GetObjectType(oAreaObject) == OBJECT_TYPE_WAYPOINT)
        {
            Debug("  Encounter area object:  " + GetTag(oAreaObject));
            sWaypointType = GetStringLowerCase(GetLocalString(oAreaObject, TRAVEL_WAYPOINT_TYPE));
            if (sWaypointType == TRAVEL_WAYPOINT_TYPE_PRIMARY)
                SetTag(oAreaObject, TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(1));
            else if (sWaypointType == TRAVEL_WAYPOINT_TYPE_SECONDARY)
            {
                sWaypointTag = TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(i++);
                SetTag(oAreaObject, sWaypointTag);
                sSecondaryWaypoints = AddListItem(sSecondaryWaypoints, sWaypointTag);
            }
            else if (sWaypointType == TRAVEL_WAYPOINT_TYPE_SPAWN)
            {
                sWaypointTag = TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(i++);
                SetTag(oAreaObject, sWaypointTag);
                sSpawnPoints = AddListItem(sSpawnPoints, sWaypointTag);
            }
        }

        oAreaObject = GetNextObjectInArea(oEncounterArea);
    }

    //Save encounter variables
    SetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID, TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(1));
    SetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID, sSecondaryWaypoints);
    SetLocalString(ENCOUNTERS, ENCOUNTER_SPAWNPOINTS         + sEncounterID, sSpawnPoints);
    SetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID, oPC);
    SetLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID, oEncounterArea);
    SetLocalInt   (ENCOUNTERS, TRAVEL_ENCOUNTER_NEXT_ID                    , nEncounterID + 1);

    //Set area events.
    SetLocalString(oEncounterArea, AREA_EVENT_ON_EXIT, "tr_encounter_OnAreaExit:only");
    SetLocalString(oEncounterArea, MODULE_EVENT_ON_PLAYER_DEATH, "tr_encounter_OnPlayerDeath");

    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);

    Debug("Successfully created encounter with ID " + sEncounterID + 
                "\n  Triggered by " + GetName(te.oTriggeredBy) +
                "\n  Occuring in " + GetName(te.oEncounterArea) +
                "\n  Primary " + te.sPrimaryWaypoint +
                "\n  Secondary " + te.sSecondaryWaypoints +
                "\n  Spawn " + te.sSpawnPoints);
    return nEncounterID;
}

void tr_StartEncounter(int nEncounterID)
{
    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);
    int nWaypointCount = CountList(te.sSecondaryWaypoints);
    object oEncounterAOE, oTarget, oPartyMember = GetFirstFactionMember(te.oTriggeredBy);    
    location lEncounterAOE = GetLocation(te.oTriggeredBy);    
    float fDistance;
    
    if (!GetIsObjectValid(te.oTriggeredBy) || !_GetIsPC(te.oTriggeredBy))
    {
        tr_KillEncounter(nEncounterID);
        Debug("Could not start encounter ID " + IntToString(nEncounterID) + "\nTriggering object is invalid.");
        return;
    }

    Debug("Encounter " + te.sEncounterID + " started; triggered by " + GetName(te.oTriggeredBy));

    while (GetIsObjectValid(oPartyMember))
    {
        if (te.oTriggeredBy != oPartyMember && (fDistance = GetDistanceBetween(te.oTriggeredBy, oPartyMember)) == 0.0)
        {
            oPartyMember = GetNextFactionMember(te.oTriggeredBy);
            continue;
        }

        Debug("Distance between " + GetName(te.oTriggeredBy) + " and " + GetName(oPartyMember) + " is " + FloatToString(fDistance) + "m");

        if (fDistance <= TRAVEL_ENCOUNTER_WAYPOINT_INCLUDE)
            oTarget = GetWaypointByTag(te.sPrimaryWaypoint);
        else if (fDistance > TRAVEL_ENCOUNTER_WAYPOINT_INCLUDE && fDistance <= TRAVEL_ENCOUNTER_PARTY_INCLUDE)
            oTarget = GetWaypointByTag(GetListItem(te.sSecondaryWaypoints, Random(nWaypointCount) + 1));

        //TODO need to check for resting.  You can have an encoutner while you're resting, but you shouldn't port?  Or
        //  port and cancel rest?

        if (GetIsObjectValid(oTarget))
        {
            _setEncounterVariables(oPartyMember, nEncounterID);
            AssignCommand(oPartyMember, ClearAllActions());
            AssignCommand(oPartyMember, JumpToObject(oTarget));
            Debug(GetName(oPartyMember) + " send to encounter " + te.sEncounterID);
        }
        else
        {
            Debug("Could not find valid waypoint for encounter " + te.sEncounterID);
        }

        oPartyMember = GetNextFactionMember(te.oTriggeredBy);
    }

    if (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY)
    {
        effect eEncounterAOE = EffectAreaOfEffect(AOE_PER_CUSTOM_AOE, TRAVEL_ENCOUNTER_AOE_SCRIPT, "", "");
        ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eEncounterAOE, lEncounterAOE);
        oEncounterAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lEncounterAOE);
        SetTag(oEncounterAOE, TRAVEL_ENCOUNTER_AOE_TAG + te.sEncounterID);
        
        SetLocalInt(oEncounterAOE, TRAVEL_ENCOUNTER_ID, nEncounterID);
        SetLocalObject(ENCOUNTERS, TRAVEL_ENCOUNTER_AOE + te.sEncounterID, oEncounterAOE);
        
        //TODO increase the AOE radius and add a visual effect so we know there's an encounter there
        //Don't let the AOE be dispelled or destroyed
        SetLocalInt(oEncounterAOE, "X1_L_IMMUNE_TO_DISPEL", 10);
        AssignCommand(oEncounterAOE, SetIsDestroyable(FALSE));

        Debug("Encounter AOE for encounter " + te.sEncounterID + " created.");
    }
}

void tr_KillEncounter(int nEncounterID = 0)
{
    string sEncounterID = IntToString(nEncounterID);
    object oEncounterArea = nEncounterID ? GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + sEncounterID) : OBJECT_SELF;

    //TODO check why area_roster shows a PC when DestroyArea does not.
    /*if (!CountObjectList(oEncounterArea, AREA_ROSTER))
        {
            Debug("Cannot kill encounter " + sEncounterID + "; PCs detected in encounter area.");
            //TODO delaycommand to recall this procedures?
            return;
        }*/

    if (GetLocalInt(oEncounterArea, TRAVEL_ENCOUNTER_PLAYER_DEATH))
    {
        //Search for dead bodies and bring them back.
        object oNewCorpse, oObject = GetFirstObjectInArea(oEncounterArea);
        while (GetIsObjectValid(oObject))
        {
            string sObjectTag = GetTag(oObject);

            if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE
                && GetStringLeft(sObjectTag, GetStringLength(H2_CORPSE)) == H2_CORPSE)
            {
                //TODO figure out a more efficient way to do this.
                object oCorpseToken = GetItemPossessedBy(oObject, H2_PC_CORPSE_ITEM);
                string uniquePCID = GetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID);
                object oPC = h2_FindPCWithGivenUniqueID(uniquePCID);
                if (GetIsObjectValid(oPC))
                {
                    location lDestination = GetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION);
                    SetLocalLocation(oCorpseToken, H2_LAST_DROP_LOCATION, lDestination);
                    oNewCorpse = CopyObject(oObject, lDestination);
                    object oLootBag = GetLocalObject(oPC, LOOT_BAG_RESREF);
                    object oNewLootBag = loot_CreateLootBag(oNewCorpse);
                    h2_MovePossessorInventory(oLootBag, TRUE, oNewLootBag);
                    SetLocalObject(oPC, LOOT_BAG_RESREF, oNewLootBag);

                    /*  TODO ALTERNATE METHOD, IF IT WORKS
                    AssignCommand(oObject, ClearAllActions());
                    AssignCommand(oObject, JumpToObject(lDestination))
                    AssignCommand(oLootBag, ClearAllActions());
                    AssignCommand(oLootBag, JumpToObject(lDestination));
                    */   
                }
                else
                    oNewCorpse = CopyObject(oObject, GetLocation(GetObjectByTag(H2_WP_DEATH_CORPSE)));

                AssignCommand(oObject, SetIsDestroyable(TRUE, FALSE));
                DestroyObject(oObject);
            }
        }
    }

    //Get rid of the AOE portal
    if (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY)
    {
        object oEncounterAOE = GetLocalObject(ENCOUNTERS, TRAVEL_ENCOUNTER_AOE + sEncounterID);
        DeleteLocalObject(ENCOUNTERS, TRAVEL_ENCOUNTER_AOE + sEncounterID);
        AssignCommand(oEncounterAOE, SetIsDestroyable(TRUE));
        DestroyObject(oEncounterAOE);
    }

    //TODO chased by enemies that are still alive?
    // Idea:  If the spawn hasn't been depeleted, make a decision based on spawn strength
    //  whether the spawn will "give chase".  If so, on next timer expire, the party is
    //  guaranteed to re-encounter that spawn.  So, when returning, instead of killing
    //  everything, setup the auto-encounter to the same area.
    int nDestroy = DestroyArea(oEncounterArea);

    if (nDestroy < 1)
    {
        Debug("Cannot kill encounter " + sEncounterID + "; failure id " + IntToString(nDestroy));
        return;
    }
    else
        Debug("Encounter area for encounter " + sEncounterID + " destroyed.");

    DeleteLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID);
    DeleteLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID);
    DeleteLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID);
    DeleteLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID);
    DeleteLocalString(ENCOUNTERS, ENCOUNTER_SPAWNPOINTS         + sEncounterID);
}

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< tr_OnAreaEnter >---
// Local OnAreaEnter event function for overland travel maps.  This function
//  initiates the encounter variables for the current travel map and starts
//  the encounter check timer for each PC.
void tr_OnAreaEnter();

// ---< tr_OnAreaEnter >---
// Local OnAreaExit event function for overland travel maps.  This function
//  cleans up the variables set when the PC entered the map.
void tr_OnAreaExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void tr_OnAreaEnter()
{
    object oPC = GetEnteringObject();

    if (!_GetIsPC(oPC))
        return;

    if (!CountList(GetLocalString(OBJECT_SELF, TRAVEL_ENCOUNTER_AREAS)))
        return;

    int nTimerID, nReturning = GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);

    if (!nReturning)    //Entering area from another area, not from an encounter
    {
        SetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS, TRAVEL_ENCOUNTER_LIMIT + (-1 + Random(3)) * Random(TRAVEL_ENCOUNTER_LIMIT_JITTER));
        DeleteLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);

        Debug("Maximum encounters for this PC is " + IntToString(GetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS)));

        nTimerID = CreateTimer(oPC, TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE, TRAVEL_ENCOUNTER_TIMER_INTERVAL, 0, TRAVEL_ENCOUNTER_TIMER_JITTER);
        SetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID, nTimerID);
        StartTimer(nTimerID, FALSE);
    }
    else
    {
        nTimerID = GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
        StartTimer(nTimerID, FALSE);
        DelayCommand(5.0f, DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_ID));
    }

    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5f);
}

void tr_OnAreaExit()
{
    object oPC = GetExitingObject();

    if (!_GetIsPC(oPC))
        return;

    if (!CountList(GetLocalString(OBJECT_SELF, TRAVEL_ENCOUNTER_AREAS)))
        return;

    int nEncounterID = GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
    int nTimerID = GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
    
    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 1.0f);

    if (!nEncounterID)
    {
        KillTimer(nTimerID);

        DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
        DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
        DeleteLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS);
        DeleteLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
        DeleteLocalLocation(oPC, TRAVEL_CREATURE_LOCATION);

        /*TODO Chase implementation
        if (_GetLocalInt(oPC,TRAVEL_ENCOUNTER_CHASE ))
        {
            _DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_CHASE);
            tr_KillEncounter(nEncounterID)
        }*/
    }
    else
        StopTimer(nTimerID);
}

void tr_encounter_OnPlayerDeath()
{
    SetLocalInt(OBJECT_SELF, TRAVEL_ENCOUNTER_PLAYER_DEATH, TRUE);
}

void tr_encounter_OnTimerExpire()
{
    object oPC = OBJECT_SELF;
    int nTimerID, nGoing, nEncounters = GetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    int nEncounterID, nMaxEncounters = GetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS);

    if (!_GetIsPC(oPC))
        return;

    /* TODO Chase implementation
    - if being chased and variable set
    - guarantee the encounter to the previous id
    */
    
    if (nEncounters >= nMaxEncounters && TRAVEL_ENCOUNTER_LIMIT)
    {
        nTimerID = GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
        KillTimer(nTimerID);
        Debug("Max encounters reached, no more for this guys.");
        return;
    }
 
    if (GetIsDawn() || GetIsDay())
        nGoing = (Random(100) <= TRAVEL_ENCOUNTER_CHANCE_DAY);
    else
        nGoing = (Random(100) < TRAVEL_ENCOUNTER_CHANCE_NIGHT);

    if (nGoing)
    {
        if (nEncounterID = tf_CreateEncounter(oPC))
            tr_StartEncounter(nEncounterID);
    }
    else
        Debug("Encounter checked for " + GetName(oPC) + ".  Party is staying put for now.");
}

void tr_encounter_OnAreaExit()
{
    //This needs to be run after the module removes the player from the area_roster
    object oPC = GetExitingObject();
    location lPC = GetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION);
    int nEncounterID = GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);;

    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);

    if (!GetIsObjectValid(GetAreaFromLocation(lPC)))
    {
        //TODO Need a default destination here, in case of getting stucks and no DMs are online.
        return;
    }

    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, JumpToLocation(lPC));

    //big TODO make sure all required functions are exposed in the library script
    if (!CountObjectList(te.oEncounterArea, AREA_ROSTER))
    {
        /* TODO Chase implementation
        - if any enemies in area
            - decide if going to give chase
            - if yes, set variable to guarantee re-encounter after specific number of
            -   timer intervals
            -if not, kill encounter*/
    
        tr_KillEncounter(te.nEncounterID);
    }
}

void tr_encounter_OnAOEEnter()
{
    object oTarget, oEncounterAOE = OBJECT_SELF;
    object oPC = GetEnteringObject();
    int nEncounterID = GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
        
    if (nEncounterID)
        return;

    nEncounterID = GetLocalInt(oEncounterAOE, TRAVEL_ENCOUNTER_ID);
    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);
 
    int nWaypointCount = CountList(te.sSecondaryWaypoints);

    if ((TRAVEL_ENCOUNTER_ALLOW_STRANGERS) || (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY && _GetIsPartyMember(oPC, te.oTriggeredBy)))
    {
        if (GetIsObjectValid(te.oEncounterArea) && CountObjectList(te.oEncounterArea, AREA_ROSTER))
        {
            if (nWaypointCount)
                oTarget = GetWaypointByTag(GetListItem(te.sSecondaryWaypoints, Random(nWaypointCount) + 1));
            else
                oTarget = GetWaypointByTag(te.sPrimaryWaypoint);

            if (GetIsObjectValid(oTarget))
            {
                SetLocalInt(oPC, TRAVEL_ENCOUNTER_ID, nEncounterID);
                SetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION, GetLocation(oPC));
                AssignCommand(oPC, ClearAllActions());
                AssignCommand(oPC, JumpToObject(oTarget));

                Debug(GetName(oPC) + " has been sent to the encounter area for encounter " +
                    te.sEncounterID + " via the encounter AOE");
            }
            else
                Debug(GetName(oPC) + " is attempting to enter encounter " + te.sEncounterID +
                    "via an AOE entry, but a valid entry waypoint could not be found.");
        }
    }
}
