// -----------------------------------------------------------------------------
//    File: pw_i_text.nss
//  System: Persistent World Administration (text/language configuration script)

// -----------------------------------------------------------------------------
// Persistent world text constants.  This script contains user-definable text
//  constants that are used in-game for the base persistent world (pw)
//  administration system.
//
// This constants can be translated to other languages and still be used in the
//  base pw system.  If translated, save this script with a different name and
//  reference the new script as an include in pw_i_core.nss.
//  ---> Replace [#include pw_i_text] with [#include <your script name>]
// -----------------------------------------------------------------------------
// Acknowledgment:
// This script is a copy of Edward Becks HCR2 script h2_core_t modified and renamed
//  to work under Michael Sinclair's (Squatting Monk) core-framework system and
//  for use in the Dark Sun Persistent World.
// -----------------------------------------------------------------------------
// Revisions:
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
//    File: pw_i_const.nss
//  System: Administration
// -----------------------------------------------------------------------------
// Description:
//  Constant for PW Management
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

const string H2_PLAYER_HP = "H2_PLAYER_HP";
const string H2_FEAT_TRACK_FEATS = "H2_FEAT_TRACK_FEATS";
const string H2_FEAT_TRACK_USES = "H2_FEAT_TRACK_USES";
const string H2_SPELL_TRACK_SPELLS = "H2_SPELL_TRACK_SPELLS";
const string H2_SPELL_TRACK_USES = "H2_SPELL_TRACK_USES";
const string H2_PC_SAVED_LOC = "H2_PC_SAVED_LOC";
const string H2_PC_PLAYER_NAME = "H2_PC_PLAYER_NAME";
const string H2_PC_CD_KEY = "H2_PCCDKEY";
const string H2_UNIQUE_PC_ID = "H2_UNIQUEPCID";
const string H2_NEXT_UNIQUE_PC_ID = "H2_NEXTUNIQUEPCID";

const string H2_WARNING_INVALID_PLAYERID = /*GetName(oPC)+"_"+GetPCPlayerName(oPC)+*/
                                            " did not match database record: ";
                                            /*+*h2_GetExternalString(uniquePCID)*/
const string H2_WARNING_ASSIGNED_NEW_PLAYERID = ". Assigning new uniquePCID.";

const string H2_BANNED_PREFIX = "BANNED_";
const string H2_LOGIN_BOOT = "H2_LOGIN_BOOT";
const string H2_MODULE_LOCKED = "H2_MODULE_LOCKED";

const string H2_CURRENT_YEAR = "H2_CURRENTYEAR";
const string H2_CURRENT_MONTH = "H2_CURRENTMONTH";
const string H2_CURRENT_DAY = "H2_CURRENTDAY";
const string H2_CURRENT_HOUR = "H2_CURRENTHOUR";
const string H2_CURRENT_MIN = "H2_CURRENTMIN";

const string H2_REGISTERED_CHAR_SUFFIX = "_RC#";
const string H2_REGISTERED = "H2_REGISTERED";

const string H2_PLAYER_COUNT = "H2_PLAYER_COUNT";
const string PW_CHARACTER_STATE = "H2_PLAYERSTATE";


const string H2_CONVERSATION_RESREF = "ConversationResRef";
const string H2_PLAYER_DATA_ITEM = "util_playerdata";
const string H2_CURRENT_TOKEN_INDEX = "H2_CURRENT_TOKEN_INDEX";
const string H2_PLAYER_DATA_MENU_ITEM_TEXT = "H2_PLAYER_DATA_MENU_ITEM_TEXT";
const string H2_PLAYER_DATA_MENU_INDEX = "H2_PLAYER_DATA_MENU_INDEX";
const string H2_PLAYER_REST_MENU_ITEM_TEXT = "H2_PLAYER_REST_MENU_ITEM_TEXT";
const string H2_PLAYER_REST_MENU_ACTION_SCRIPT = "H2_PLAYER_REST_MENU_ACTION_SCRIPT";
const string H2_PLAYER_REST_MENU_INDEX = "H2_PLAYER_REST_MENU_INDEX";
const string H2_SAVE_LOCATION_TIMER_ID = "H2_SAVE_LOCATION_TIMER_ID";
const string H2_EXPORT_CHAR_TIMER_ID = "H2_EXPORT_CHAR_TIMER_ID";

const string H2_LOGIN_DEATH = "H2_LOGINDEATH";
const string H2_LOCATION_LAST_DIED = "H2_LOCATION_LAST_DIED";
const string H2_PLAYER_DATA_ITEM_TARGET_OBJECT = "H2_PLAYER_DATA_ITEM_TARGET_OBJECT";
const string H2_PLAYER_DATA_ITEM_TARGET_LOCATION = "H2_PLAYER_DATA_ITEM_TARGET_LOCATION";

const string H2_RESS_LOCATION = "H2_RESS_LOCATION";
const string H2_RESS_BY_DM = "H2_RESS_BY_DM";

const string H2_DO_NOT_CREATE_CORPSE_IN_AREA = "H2_DO_NOT_CREATE_CORPSE_IN_AREA";
const string H2_DO_NOT_MOVE = "H2_DO_NOT_MOVE";

const string H2_EXPORT_CHAR_ON_TIMER_EXPIRE = "ExportPC_OnTimerExpire";
const string H2_SAVE_LOCATION_ON_TIMER_EXPIRE = "SavePCLocation_OnTimerExpire";
const string H2_EXPORT_CHAR_TIMER_SCRIPT = "h2_exportchars";
const string H2_INITIAL_LOGIN = "H2_INITIALLOGIN";
const string H2_SAVE_LOCATION = "h2_savelocation"; //name of script to execute to save pc location
const string H2_STRIPPED = "H2_STRIPPED";
const string H2_MOVING_ITEMS = "H2_MOVINGITEMS";

const string H2_ALLOW_REST = "H2_ALLOW_REST";
const string H2_ALLOW_SPELL_RECOVERY = "H2_ALLOW_SPELL_RECOVERY";
const string H2_ALLOW_FEAT_RECOVERY = "H2_ALLOW_FEAT_RECOVERY";
const string H2_POST_REST_HEAL_AMT = "H2_POST_REST_HEAL_AMT";
const string H2_PC_REST_DIALOG = "h2_prestmenuconv";
const string H2_SKIP_REST_DIALOG = "H2_SKIP_REST_DIALOG";
const string H2_SKIP_CANCEL_REST = "H2_SKIP_CANCEL_REST";
const string H2_REST_MENU_DEFAULT_ACTION_SCRIPT = "h2_makepcrest";

const string H2_SERVER_START_YEAR = "H2_SERVER_START_YEAR";
const string H2_SERVER_START_MONTH = "H2_SERVER_START_MONTH";
const string H2_SERVER_START_DAY = "H2_SERVER_START_DAY";
const string H2_SERVER_START_HOUR = "H2_SERVER_START_HOUR";
const string H2_SERVER_START_MINUTE = "H2_SERVER_START_MINUTE";

const string H2_SERVER_TIME = "H2_SERVER_TIME";
const string H2_SERVER_START_TIME = "H2_SERVER_START_TIME";
const string H2_EPOCH = "H2_EPOCH";

const string H2_EVENT_ON_PLAYER_LIVES = "OnPlayerLives";

const string PW_EVENT_ON_CHARACTER_REGISTRATION = "OnCharacterRegistration";

const string PC_IP_ADDRESS = "PC_IP_ADDRESS";