// -----------------------------------------------------------------------------
//    File: bus_i_const.nss
//  System: Business and NPC Operations
// -----------------------------------------------------------------------------
// Description:
//  Constants
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

const string BUSINESS_DATAPOINT = "BUSINESS_DATAPOINT";
object       BUSINESS           = GetDatapoint(BUSINESS_DATAPOINT);

const int BUSINESS_HOURS_OPEN = 25;
const int BUSINESS_HOURS_CLOSED = -1;
const int BUSINESS_HOURS_DEFAULT = -3;
const int BUSINESS_HOURS_ALWAYS_OPEN = 26;
const int BUSINESS_HOURS_ALWAYS_CLOSED = -2;

const string BUSINESS_STATE_SET = "BUSINESS_STATE_SET";

const string BUSINESS_ACTION = "BUSINESS_ACTION";
const int BUSINESS_ACTION_DEFAULT = -1;
const int BUSINESS_ACTION_OPEN = 0;
const int BUSINESS_ACTION_CLOSE = 1;

const int BUSINESS_RESOURCE_TYPE_NPC = 1;
const int BUSINESS_RESOURCE_TYPE_PROFILE = 2;
const int BUSINESS_RESOURCE_TYPE_DOOR = 3;

const string BUSINESS_PROFILE_CRAFT = "BUSINESS_PROFILE_CRAFT";
const string BUSINESS_PROFILE_TRADE = "BUSINESS_PROFILE_TRADE";
const string BUSINESS_PROFILE_MILL = "BUSINESS_PROFILE_MILL";
const string BUSINESS_PROFILE_TEMPLE = "BUSINESS_PROFILE_TEMPLE";
const string BUSINESS_PROFILE_OPEN = "BUSINESS_PROFILE_OPEN";
const string BUSINESS_PROFILE_CLOSED = "BUSINESS_PROFILE_CLOSED";

const string BUS_LIST_BUSINESS = "BUS_LIST_BUSINESS";

const string BUS_LIST_PROFILE = "BUS_LIST_PROFILE";
const string BUS_LIST_PROFILE_DAY = "BUS_LIST_PROFILE_DAY";
const string BUS_LIST_PROFILE_OPEN = "BUS_LIST_PROFILE_OPEN";
const string BUS_LIST_PROFILE_CLOSE = "BUS_LIST_PROFILE_CLOSE";

const string BUS_LIST_WORKER_BUSINESS = "BUS_LIST_WORKER_BUSINESS";
const string BUS_LIST_WORKER_NPC = "BUS_LIST_WORKER_NPC";

const string BUS_LIST_PROFILE_BUSINESS = "BUS_LIST_PROFILE_BUSINESS";
const string BUS_LIST_PROFILE_PROFILE = "BUS_LIST_PROFILE_PROFILE";

const string BUS_LIST_DOOR_BUSINESS = "BUS_LIST_DOOR_BUSINESS";
const string BUS_LIST_DOOR_DOOR = "BUS_LIST_DOOR_DOOR";

const string BUS_LIST_HOLIDAY = "BUS_LIST_HOLIDAY";

