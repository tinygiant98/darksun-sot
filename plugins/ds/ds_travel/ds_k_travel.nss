// -----------------------------------------------------------------------------
//    File: ds_k_travel.nss
//  System: Travel (constants)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Constants for PW Subsystem.
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
