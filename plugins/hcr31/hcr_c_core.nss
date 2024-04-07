/// ----------------------------------------------------------------------------
/// @file:  hcr_c_core.nss
/// @brief: HCR2 System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                         HCR2 Configuration Options
// -----------------------------------------------------------------------------

/// This value controls the number of slots on the server available for player characters.
///  Setting this number to a value greater than 0 and a value less that the maximum
///  allowed players on the server (nwserver) will allow "always available" DM slots.
///  If a player logs in and this value is exceeded, that player will be booted.  A value
///  of 0 means there are no reserved DM slots.  DM PCs do not count against this total.
const int H2_MAXIMUM_PLAYERS = 0;

/// Set this value to the time interval in real-world seconds between each location save
/// for a player character. Set to 0.0 to prevent periodically saving character locations.
const float H2_SAVE_PC_LOCATION_TIMER_INTERVAL = 180.0;

/// Set this value to the time in real-world seconds to desired delay between a client
/// entering the server and the associated player character being transported to their
/// last saved location.
const float H2_CLIENT_ENTER_JUMP_DELAY = 1.0;

/// Set this value to TRUE to strip a player characters of all inventory items on their
/// first server login.
const int H2_STRIP_ON_FIRST_LOGIN = FALSE;

/// Set this value to the time interval in real-world seconds between exporting characters.
/// This feature is only useful on servers that use server vaults.  Set this value to 0.0
/// to prevent automated character exporting.
const float H2_EXPORT_CHARACTERS_INTERVAL = 0.0;

/// Set this value to the maximum number of registered characters (dead or alive) that
/// any on player is allowed to have on the server.  When a player opts to retire a
/// character, that character becomes unregistered and can no longer be played.
/// Characters created above the maximum number will be automatically booted upon login.
/// Retired characters will be automatically booted upon login.  Set this value to
/// zero to allow unlimited characters.
const int H2_REGISTERED_CHARACTERS_ALLOWED = 0;

/// Set this value to TRUE to force the game clock to update on every module heartbeat
/// event.
const int H2_FORCE_CLOCK_UPDATE = FALSE;

/// Set this value to TRUE to display a login message that shows the current game date
/// and time to the entering player in DD/MM/YYY HH:MM instead of MM/DD/YYYY HH:MM.
const int H2_SHOW_DAY_BEFORE_MONTH_IN_LOGIN = FALSE;

// TODO Can this be removed to the rest plugin?  Not yet.

// The basic rest system includes a small, configurable dialog.  Without any builder intervention, it has
//  two options:  rest or don't rest.  If you want the PC to confirm they want to rest before the rest
//  event occurs, set this to TRUE.  If you don't care or don't plan on adding additiona options, set this 
//  to FALSE.
const int H2_USE_REST_DIALOG = FALSE;

// -----------------------------------------------------------------------------
//                            HCR2 Translatable Text
// -----------------------------------------------------------------------------
/// @warning If modifying these values to use languages that are encoded using
///     other than Windows-1252, the file must be saved and compiled with the
///     appropriate encoding.

/// @note To use tlk entries for these values, you can modify the construction
///     using the following example:
/// string H2_TEXT_SEND_TO_SAVED_LOC = GetStringByStrRef(###);

const string H2_TEXT_SEND_TO_SAVED_LOC = "Sending you to your last saved location.";
const string H2_TEXT_RETIRED_PC_BOOT = "This character has been retired from play. Please log in with a different one after being booted.";
const string H2_TEXT_TOO_MANY_CHARS_BOOT = "This is not one of your registered characters. Please log in with a registered character after being booted.";
const string H2_TEXT_CHAR_REGISTERED = "This character is now registered.";
const string H2_TEXT_TOTAL_REGISTERED_CHARS = "Total number of registered characters: ";
const string H2_TEXT_MAX_REGISTERED_CHARS = " Maximum registered characters: ";
const string H2_TEXT_CURRENT_GAME_DATE_TIME = "Current Game Date and Time: ";
const string H2_TEXT_YOU_HAVE_DIED = "You have died.";
const string H2_TEXT_RECOVER_WITH_REST_IN = "You can recover spells and health by resting in: ";
const string H2_TEXT_HOURS = " hours.";
const string H2_TEXT_SETTINGS_NOT_READ = "The module builder has not read and customized the rule settings for this module.";
const string H2_TEXT_PCNAME_TOO_LONG = "Your PC's name is too long, recreate the character with a shorter name.";
const string H2_TEXT_YOU_ARE_BANNED = "You have been banned from the server.";
const string H2_TEXT_SERVER_IS_FULL = "The server is full, remaining space is resevered for DM logins. Try again later.";
const string H2_TEXT_MODULE_LOCKED = "The module is currently locked from player login. Try again later.";
const string H2_TEXT_PLAYER_NOT_ONLINE = "The player is not online.";
const string H2_TEXT_REST_NOT_ALLOWED_HERE = "You may not rest here.";

const string H2_TEXT_TARGET_ITEM_MUST_BE_IN_INVENTORY = "Target item must be in your inventory to do that.";
const string H2_TEXT_NOT_ENOUGH_GOLD = "You do not have enough gold for that.";
const string H2_TEXT_CANNOT_USE_ON_SELF = "You cannot use that on yourself.";
const string H2_TEXT_OFFLINE_PLAYER = "Offline player";
const string H2_TEXT_CANNOT_PLACE_THERE = "You cannot place that there.";
const string H2_TEXT_CANNOT_USE_ON_TARGET = "You cannot use that on that target.";

//GetName(oPC) + "_" + GetPCPlayerName(oPC) + H2_TEXT_LOG_PLAYER_HAS_DIED +
//GetName(GetLastHostileActor(oPC)) + H2_TEXT_LOG_PLAYER_HAS_DIED2 + GetName(GetGetArea(oPC))
const string H2_TEXT_LOG_PLAYER_HAS_DIED = " was killed by ";
const string H2_TEXT_LOG_PLAYER_HAS_DIED2 = "in area ";

//Skill check message construction:
//GetName(oSkillUser) + " " + H2_TEXT_SKILL_* + H2_TEXT_SKILL_CHECK + rollresult + " + " + modifier + " = " + total
//"JimBob Heal skill check. Roll: 10 + 4 = 14"
const string H2_TEXT_SKILL_CHECK = " skill check. Roll: ";
const string H2_TEXT_SKILL_ANIMAL_EMPATHY = "Animal Empathy";
const string H2_TEXT_SKILL_APPRAISE = "Appraise";
const string H2_TEXT_SKILL_BLUFF = "Bluff";
const string H2_TEXT_SKILL_CONCENTRATION = "Concentration";
const string H2_TEXT_SKILL_CRAFT_ARMOR = "Craft Armor";
const string H2_TEXT_SKILL_CRAFT_TRAP = "Craft Trap";
const string H2_TEXT_SKILL_CRAFT_WEAPON = "Craft Weapon";
const string H2_TEXT_SKILL_DISABLE_TRAP = "Disable Trap";
const string H2_TEXT_SKILL_DISCIPLINE = "Discipline";
const string H2_TEXT_SKILL_HEAL = "Heal";
const string H2_TEXT_SKILL_HIDE = "Hide";
const string H2_TEXT_SKILL_INTIMIDATE = "Intimidate";
const string H2_TEXT_SKILL_LISTEN = "Listen";
const string H2_TEXT_SKILL_LORE = "Lore";
const string H2_TEXT_SKILL_MOVE_SILENTLY = "Move Silently";
const string H2_TEXT_SKILL_OPEN_LOCK = "Open Lock";
const string H2_TEXT_SKILL_PARRY = "Parry";
const string H2_TEXT_SKILL_PERFORM = "Perform";
const string H2_TEXT_SKILL_PERSUADE = "Persuade";
const string H2_TEXT_SKILL_PICK_POCKET = "Pick Pocket";
const string H2_TEXT_SKILL_SEARCH = "Search";
const string H2_TEXT_SKILL_SET_TRAP = "Set Trap";
const string H2_TEXT_SKILL_SPELLCRAFT = "Spellcraft";
const string H2_TEXT_SKILL_SPOT = "Spot";
const string H2_TEXT_SKILL_TAUNT = "Taunt";
const string H2_TEXT_SKILL_TUMBLE = "Tumble";
const string H2_TEXT_SKILL_USE_MAGIC_DEVICE = "Use Magic Device";

//Player Data Item conversation node texts:
//-H2_TEXT_PLAYER_DATA_ITEM_CONV_ROOT_NODE
//      -(custom action nodes) (pc options)
//      -H2_TEXT_RETIRE_PC_MENU_OPTION
//      -H2_TEXT_PLAYER_DATA_MENU_NOTHING
const string H2_TEXT_PLAYER_DATA_ITEM_CONV_ROOT_NODE = "What action would you like to perform?";
const string H2_TEXT_RETIRE_PC_MENU_OPTION = "Retire this character.";
const string H2_TEXT_PLAYER_DATA_MENU_NOTHING = "Nothing.";

//Retire PC conversation node texts:
//-H2_TEXT_RETIRE_PC_CONV_ROOT_NODE
//      -H2_TEXT_RETIRE_PC_CONV_NEVERMIND [END DIALOGUE]   (pc option)
//      -H2_TEXT_RETIRE_PC_CONV_RETIRE_OPTION              (pc option)
//          -H2_TEXT_RETIRE_PC_CONV_CONFIRM_MESSAGE
//              -H2_TEXT_RETIRE_PC_CONV_NEVERMIND [END DIALOGUE]     (pc option)
//              -H2_TEXT_RETIRE_PC_CONV_RETIRE_OPTION [End DIALOGUE] (pc option)
const string H2_TEXT_RETIRE_PC_CONV_ROOT_NODE = "Selecting to retire your character will cause this character to become unregistered, thus freeing a registration slot for a new character, but it also means you cannot play this character any longer.";
const string H2_TEXT_RETIRE_PC_CONV_NEVERMIND = "Nevermind, I don't want to do this.";
const string H2_TEXT_RETIRE_PC_CONV_RETIRE_OPTION = "Yes, retire my character.";
const string H2_TEXT_RETIRE_PC_CONV_CONFIRM_MESSAGE = "This character will be retired forever, and will not be playable again. You will then be booted and upon login you will need to make a new character. Are you sure you want to do this?";

//PC Rest conversation node texts:
//-H2_TEXT_PC_REST_CONV_ROOT_NODE
//      -(custom rest nodes) (pc options)
//      -H2_TEXT_PC_REST_CONV_DONT_REST [END DIALOGUE] (pc option)
const string H2_TEXT_PC_REST_CONV_ROOT_NODE = "Getting Sleepy...";
const string H2_TEXT_PC_REST_CONV_DONT_REST = "Don't Rest.";
const string H2_REST_MENU_DEFAULT_TEXT = "Rest.";
