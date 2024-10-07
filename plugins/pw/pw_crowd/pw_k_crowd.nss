// -----------------------------------------------------------------------------
//    File: pw_k_crowd.nss
//  System: Simulated Population (constants)
// -----------------------------------------------------------------------------
// Description:
//  Constants for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

#include "util_i_datapoint"

const string sDebugPlugin = "::Crowd System|";
string dbg;

// CROWDS datapoint contains copies of all the crowd initializer items
const string CROWD_DATA = "CROWD_DATA";
object CROWDS = GetDatapoint(CROWD_DATA);

// TODO This is in test to see if using OBJECT_SELF in this global
//  manner will work.  Current assumption is that any procedure
//  using this datapoint will be called by the area itself (as in
//  from an area event).  It compiles, but will it work?!?
const string AREA_CROWD_DATA = "AREA_CROWD_DATA";
object AREA_CROWDS = GetDatapoint(AREA_CROWD_DATA, OBJECT_SELF);

// List variables for use by crowd initializer items (globally accessed)
const string CROWD_ITEM_LOADED_CSV  = "CROWD_ITEM_LOADED_CSV";
const string CROWD_ITEM_OBJECT_LIST = "CROWD_ITEM_OBJECT_LIST";
const string CROWD_ITEM_INITIALIZED = "CROWD_ITEM_INITIALIZED";

// List variables for local crowd initializers
const string AREA_CROWD_ITEM_LOADED_CSV    = "AREA_CROW_ITEM_LOADED_CSV";
const string AREA_CROWD_ITEM_OBJECT_LIST   = "AREA_CROWD_ITEM_OBJECT_LIST";
const string AREA_CROWD_ITEM_INITIALIZED   = "AREA_CROWD_ITEM_INITIALIZED";

// Event variables
const string CROWD_EVENT_ON_TIMER_EXPIRED = "crowd_OnTimerExpired";
const string CROWD_CHECK_TIMER            = "CROWD_CHECK_TIMER";
const string CROWD_CSV                    = "*Crowds";

const string CROWD_DESTINATION            = "CROWD_DESTINATION";
const string CROWD_ROSTER                 = "CROWD_ROSTER";
const string CROWD_ITEM                   = "CROWD_ITEM";
const string CROWD_QUEUE                  = "CROWD_QUEUE";
const string CROWD_DEFAULT_CONVERSATION   = "CrowdDefaultDialog";

const string CROWD_CREATURE_DEATH_SCRIPT  = "crowd_OnCreatureDeath";

// Other variables
const string CROWD_WP_COUNT               = "CROWD_WP_COUNT";
const string CROWD_OWNER                  = "CROWD_OWNER";

// CommonerSettings struct variables
const string CROWD_CONVERSATION       = "*Dialog";
const string CROWD_CLOTHING_RANDOM    = "ClothingRandom";
const string CROWD_CLOTHING_RESREF    = "ClothingResref";
const string CROWD_MEMBER_NAME        = "MemberName";
const string CROWD_MEMBER_RESREF      = "MemberResref";
const string CROWD_MEMBER_TAG         = "MemberTag";
const string CROWD_POPULATION_DAY     = "PopulationDay";
const string CROWD_POPULATION_NIGHT   = "PopulationNight";
const string CROWD_POPULATION_WEATHER = "PopulationWeather";
const string CROWD_SPAWN_DELAY_MIN    = "SpawnDelayMin";
const string CROWD_SPAWN_DELAY_MAX    = "SpawnDelayMax";
const string CROWD_STATIONARY         = "Stationary";
const string CROWD_UPDATE_INTERVAL    = "UpdateInterval";
const string CROWD_WALKTIME_LIMIT     = "WalkTimeLimit";
const string CROWD_WAYPOINT_TAG       = "WaypointTag";
