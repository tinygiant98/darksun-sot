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
const string H2_PLAYER_STATE = "H2_PLAYERSTATE";
const int H2_PLAYER_STATE_ALIVE = 0;
const int H2_PLAYER_STATE_DYING = 1;
const int H2_PLAYER_STATE_DEAD = 2;
const int H2_PLAYER_STATE_STABLE = 3;
const int H2_PLAYER_STATE_RECOVERING = 4;
const int H2_PLAYER_STATE_RETIRED = 5;

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

const string MODULE_EVENT_ON_CHARACTER_REGISTRATION = "OnCharacterRegistration";

const string PC_IP_ADDRESS = "PC_IP_ADDRESS";