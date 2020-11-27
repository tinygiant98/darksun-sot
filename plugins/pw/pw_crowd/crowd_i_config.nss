// -----------------------------------------------------------------------------
//    File: crowd_i_config.nss
//  System: Simulated Population (configuration)
// -----------------------------------------------------------------------------
// Description:
//  Configuration File for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  Set the constants below as directed in the comments for each constant.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------

// Set this to false if you do not want to use the crowd system.
const int PW_USE_CROWD_SYSTEM = FALSE;

// The crowd/simulated population system uses custom game objects with specific
//  variables to initialize crowd objects.  CROWD_ITEM_PREFIX is the prefix
//  of the item being used to initialize the crowd object.  All initialization
//  objects must start with this prefix.  This CSV is a list of those crowd
//  objects that will be loaded on module load.  For example, if you wanted to
//  load a crowd object called `crowd_KlegGuard`, you would include `KlegGuard`
//  in the CROWD_ITEM_INVENTORY list and `crowd_` as the CROWD_ITEM_PREVIX
//  value.  The CROWD_ITEM_INVENTORY should list all possible crowds in the
//  entire module, even if they're not used in the area you're building.
string CROWD_ITEM_INVENTORY = "start,start2,start3";
const string CROWD_ITEM_PREFIX = "crowd_";

// The crowd system will re-check the simulated population every so often to
//  see if more NPCs need to be spawned or if they all need to be despawned.
//  This is the interval at which the system will make that check if an
//  interval is not defined on the initializer item.
const float CROWD_DEFAULT_INTERVAL = 45.0f;

// Crowd members can be set to walk to a location.  If they are unable to find
//  a path to their destination within the time specified on the initializer item,
//  this default value will be used.
const float CROWD_DEFAULT_WALK_TIME = 30.0f;

// The tag given to each spawned crowd member if the tag is not specified on the
//  intializer item.
const string CROWD_DEFAULT_TAG = "crowd_member";

// The name given to each spawned crowd member if the name is not specified on the
//  initializer item.
const string CROWD_DEFAULT_NAME = "Citizen";

// The default delay to use between spawning crowd members if the values in the settings
// are invalid. The values are considered invalid if both of them are zero or the max
// delay is less than the min delay.
const float CROWD_DEFAULT_MIN_SPAWN_DELAY = 2.0f;
const float CROWD_DEFAULT_MAX_SPAWN_DELAY = 30.0f;
