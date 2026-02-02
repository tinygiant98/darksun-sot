/// ----------------------------------------------------------------------------
/// @file   pw_c_core.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Persistent World System (configuration).
/// ----------------------------------------------------------------------------

/// @note Acknowledgement.  Configuration values here are based largely on Edward
///     Beck's HCR2 setup.  The names of the constants have been changed to
///     conform to the Persistent World naming conventions, but the values and
///     purpose remain the same as in HCR2.

/// @brief The maximum length for a player-controlled character's name.  This restriction
///     applies only to player-controlled characters, not dungeon masters.  Set this
///     value to the maximum allowed length for a PC's name, including both first and
///     last names.
/// @note This check is accomplished before OnClientEnter hook scripts are run.
///     If the name length exceeds this value, the player is booted.  If booted,
///     neither the OnClientEnter or OnClientLeave events are triggered.
const int PW_PC_MAX_NAME_LENGTH = 40;

/// @brief The maximum number of players allowed on the server, excluding DM PCs.
///     Setting this value to 0 means there is no limit beyond what the server
///     itself allows.
/// @note If this value is greater than 0, and the number of non-DM PCs exceeds
///     this value when a new player attempts to log in, that player will be
///     booted.
const int PW_MAX_PLAYERS = 0;

//This value controls whether a non-DM PC's location is periodically saved.
//Default value: TRUE
const int H2_SAVE_PC_LOCATION = TRUE;

//Time in real seconds, this is the delay between client enter and jumping the entering 
//  PC to their last saved location, or any other location, after login.  Adjust this 
//  value based on the size or lag of the server.
//Default value: 5.0
const float H2_CLIENT_ENTER_JUMP_DELAY = 1.0;

//Time interval in real-world seconds between each location save for a PC.
//Default value: 180.0
const float H2_SAVE_PC_LOCATION_TIMER_INTERVAL = 180.0;

//Set the below to true to remove all starting equipment from a newly created character.
//Default value: FALSE
const int H2_STRIP_ON_FIRST_LOGIN = FALSE;

/// @todo remove and use events instead...
//Set this value to the interval duration in seconds that you want to export all characters.
//You should only change this value if you are using a server vault.
//Recommended settings are from 30.0 (seconds) to 300.0 (five minutes)
//depending on your server performance.
//Individual player exports also occur if this value is above 0 whenever the player rests or levels up.
//The default value is 0.0.
const float H2_EXPORT_CHARACTERS_INTERVAL = 0.0;

//Set this to the number of registered characters (alive or dead) that you want the player
//to be allowed to play. When a player chooses to retire a character it becomes unregistered
//and they are no longer allowed to play that character. If a player created a character after
//they have already attained the maximum number of registered characters allowed, they
//will not be able to play that character and will be booted.
//If a player logs in with a retired character they will be booted.
//If the PC is booted both the client enter and client leave hook-in scripts will not run for that PC.
//A value of zero means there is no limit to the number of characters they can play.
//When this value is zero the option to retire a character doesn't display.
//The default value is 0.
const int H2_REGISTERED_CHARACTERS_ALLOWED = 0;

//Force the game clock to update itself each heartbeat (to fix clock update problem for large modules)
//Set this to true if your module has trouble with the clock updating to see if it helps.
//The default value is FALSE.
const int H2_FORCE_CLOCK_UPDATE = FALSE;

//Set this to TRUE if you want the login message that shows the current game date and time to the
//entering player to be in the format: DD/MM/YYYY HH:MM instead of MM/DD/YYYY HH:MM.
//The default value is FALSE.
const int H2_SHOW_DAY_BEFORE_MONTH_IN_LOGIN = FALSE;

// You can turn off Bioware's default events by setting this to false.  Generally, this should remain
//  TRUE since it can break the horse system, cause player death problems and create other hidden issues
//  if all default bioware events aren't handled by custom handlers.
const int H2_USE_DEFAULT_BIOWARE_EVENTS = TRUE;

// The basic rest system includes a small, configurable dialog.  Without any builder intervention, it has
//  two options:  rest or don't rest.  If you want the PC to confirm they want to rest before the rest
//  event occurs, set this to TRUE.  If you don't care or don't plan on adding additiona options, set this 
//  to FALSE.
const int H2_USE_REST_DIALOG = FALSE;

const string PW_CAMPAIGN_DB_NAME = "darksun_sot";
