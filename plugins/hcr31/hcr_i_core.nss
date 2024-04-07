/// -----------------------------------------------------------------------------
/// @file:  hcr_i_core.nss
/// @brief: HCR2 System (core)
/// -----------------------------------------------------------------------------

#include "x3_inc_string"
#include "hcr_c_core"

#include "core_i_framework"
#include "util_i_data"
#include "util_i_time"

#include "dlg_i_dialogs"

// -----------------------------------------------------------------------------
//                         Variable Name Constants
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

const string H2_VARIABLE_TAG = "HCR2";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

//Returns the number of seconds elapsed since the server was started.
int h2_GetSecondsSinceServerStart();

//Returns TRUE or FALSE depending on if location loc is valid.
int h2_GetIsLocationValid(location loc);

//Returns a string consisting of the constant H2_TEXT_CURRENT_GAME_DATE_TIME (defined in h2_core_t)
//followed by a datetime format MM/DD/YYYY HH:MM (if bDayBeforeMonth is FALSE)
//or the format DD/MM/YYYY HH:MM (if bDayBeforeMonth is TRUE) (to support other cultural date formats)
//The default value of bDayBeforeMonth is FALSE.
string h2_GetCurrentGameTime(int bDayBeforeMonth = FALSE);

//This function copies an item equipped in slot invSlot (one of the INVENTORY_SLOT_* constants) of oPossessor,
//into the inventory of the object designated by oReceivingObject (if oReceivingObject is valid)
//Local variables on the equipped item are copied. The item equipped on oPossessor is then destroyed.
//If either oPossessor or no item is equipped in the given slot, this function does nothing.
void h2_MoveEquippedItem(object oPossessor, int invSlot, object oReceivingObject =  OBJECT_INVALID);

//This function copies all of the items in oPossessor's inventory into the inventory of oReceivingObject
//if oReceivingObject is valid. if bMoveGold is true, the gold is transfered as well.
//Local variables on items are also copied. The items in oPossessor's inventory are then destroyed.
//This function will NOT copy or destroy items that have been marked as cursed (not droppable) on their palette.
//If oPossessor is invalid, this function does nothing.
void h2_MovePossessorInventory(object oPossessor, int bMoveGold = FALSE, object oReceivingObject = OBJECT_INVALID);

//This function copies all equipped items from oPossessor into the inventory of oReceivingObject
//if oReceivingObject is valid.Local variables on the equipped items are copied.
//The items equipped on oPossessor are then destroyed.
//Item located in any of the creature slots are neither copied or destoyed.
//If oPossessor is invalid, this function does nothing.
void h2_MoveEquippedItems(object oPossessor, object oReceivingObject = OBJECT_INVALID);

//Destoys all items in oPossessor's inventory that have the Cursed (no drop) flag checked.
void h2_DestroyNonDroppableItemsInInventory(object oPossessor);

//This function boots the player oPC after the number of seconds indicated by delay has passed.
//If sMessage is not empty, the it will be send to the oPC prior to the boot.
//The PCPlayerName of oPC and sMessage are sent to the DM channel and written to the server logs.
//If oPC is invalid this function does nothing.
void h2_BootPlayer(object oPC, string sMessage = "", float delay = 0.0);

//This function bans a player by their public CDKey.
//It writes the ban information to the external database then boots the
//player with the "You are Banned" message.
void h2_BanPlayerByCDKey(object oPC);

//This function bans a player by their IP Address.
//It writes the ban information to the external database then boots the
//player with the "You are Banned" message.
void h2_BanPlayerByIPAddress(object oPC);

//This function removes all effects from oCreature. It does nothing if oCreature is invalid.
void h2_RemoveEffects(object oCreature);

//This function removes all effects of type nEffectType. It does nothing if oCreature is invalid.
void h2_RemoveEffectType(object oCreature, int nEffectType);

//This function lowers the value of oPC's current hitpoint to the value saved as H2_PLAYER_HP on oPC.
//This function does nothing if oPC is invalid or oPC's current hit points are less than or equal to the saved
//value.
void h2_SetPlayerHitPointsToSavedValue(object oPC);

//This function decrements remaining spell uses to values stored as H2_SPELL_TRACK on oPC.
//this function does nothing if oPC is invalid.
void h2_SetAvailableSpellsToSavedValues(object oPC);

//This function decrements remaining feat uses to values stored as H2_FEAT_TRACK on oPC.
//this function does nothing if oPC is invalid.
void h2_SetAvailableFeatsToSavedValues(object oPC);

//Saves oPCs hitpoints to a local variable H2_PLAYER_HP on oPC.
void h2_SavePCHitPoints(object oPC);

//Saves the values of the remaining uses of oPC's current spells to H2_SPELL_TRACK on oPC.
void h2_SavePCAvailableSpells(object oPC);

//Saves the values of the remaining uses of oPC's current feats to H2_FEAT_TRACK on oPC.
void h2_SavePCAvailableFeats(object oPC);

//Drops all henchman from oPC.
void h2_DropAllHenchmen(object oPC);

//Searchs the logged in PCs and returns the PC with the matching uniquePCID.
//Returns OBJECT_INVALID if not found.
object h2_FindPCWithGivenUniqueID(string uniquePCID);

//Rolls a standard skill check for nSkill for oUser.
//The return value is d20 + rank + modifiers.
//If nBroadCastLevel = 0, only the DM channel gets the results.
//If nBroadCastLevel = 1, the skill user gets the results as well.
//If nBroadCastLevel = 2, then in addtion to the above, all nearby PCs also get the result.
int h2_SkillCheck(int nSkill, object oUser, int nBroadCastLevel = 1);

//Saves the current in game month, day, year, hour and minute to the external database.
void h2_SaveCurrentCalendar();

//Saves the current location of oPC to oPC's data item, if oPC is not invalid.
void h2_SavePCLocation(object oPC);

//This sets the current game calendar and time to the data and time values last saved in the
//external database.
void h2_RestoreSavedCalendar();

//Call this after the game date and time has been restored with h2_RestoreSavedCalendar.
//This saved the current date and time as the server start time. Used in calculated the elapsed time
//passed for timers and various other effects.
void h2_SaveServerStartTime();

//This creates a menu item in the conversation that is opened when the 'Player Info and Action Item'
//is activated by the PC. sMenuText is the text you want to appear to the user for that menu choice.
//sConvResRef is the resref of a conversation file that will be opened as a result
//of the PC choosing that menu. Note that all of the conversations are opened as if the PC
//is conversing with themselves, private conversation is true, and play hello is false.
//If sMenuText is an empty string nothing will be added.
//Only a maximum of 20 menu items can be added, if you exceed this amount the menu item
//is not added, instead a log file is generated stating that the maximim number of items was exceeded.
//This function should only be called from a module load hook-in script.
void h2_AddPlayerDataMenuItem(string sMenuText, string sConvResRef);

//This creats the player data item which can hold persistant info pertaining to that oPC
//which will survive server resets.
void h2_CreatePlayerDataItem(object oPC);

//Retrieves the next unused Unique Identifier ID for assignment to oPC.
//The unique ID is the hexstring conversion (making it a string of length 10) of a uniquely assigned integer
//(which even only counting positive integer values, allows for 2147483647 unique PCs over the life of your mod)
string h2_GetNewUniquePCID(object oPC);

//Sends oPC to their last saved location.
//Does nothing if oPC is invalid.
void h2_SendPCToSavedLocation(object oPC);

//Registers the PCs. by incrementing the players registered character count
//and sending appropraite feedback.
void h2_RegisterPC(object oPC);

//Performs important set up activity on oPC's first login
//including getting and setting the unique player ID and other player persistant
//information.
void h2_InitializePC(object oPC);

//Strips oPC of all items on their first login then sets the flag H2_STRIPPED to TRUE
//so subsequent logins will not strip this PC.
//This function is only ran if H2_STRIP_ON_FIRST_LOGIN = TRUE.
void h2_StripOnFirstLogin(object oPC);

//Checks if oPC has been assigned a uniquePCID (a hexstring based on a unique interger value)
//If oPC does not have one, a new one is obtained and assigned.
void h2_SetPlayerID(object oPC);

//Returns TRUE if the number of non-DM PCs currently online equal the value set to H2_MAXIMUM_PLAYERS
//This function is used in determining if enough slots remain open for the DM Reserve amount.
int h2_MaximumPlayersReached();

//Saves various Persistent PC data. This function is ran during the client leave event.
void h2_SavePersistentPCData(object oPC);

//Returns a TRUE or FALSE value that says whether or not rest should be allowed (TRUE)
//or not allowed (FALSE) for oPC.
int h2_GetAllowRest(object oPC);

//bAllowRest should be TRUE or FALSE.
//This sets a variable than when read by h2_GetAllowRest, returns the value of bAllowRest.
//This should be set to FALSE if oPC should not be allowed to rest on their next rest action.
void h2_SetAllowRest(object oPC, int bAllowRest);

//Returns a TRUE or FALSE value indicating whether or not Spells should allowed to be
//properly recovered after the oPC's next rest if finished.
int h2_GetAllowSpellRecovery(object oPC);

//Returns a TRUE or FALSE value indicating whether or not Feats should allowed to be
//properly recovered after the oPC's next rest if finished.
int h2_GetAllowFeatRecovery(object oPC);

//bAllowRecovery should be TRUE or FALSE
//This set a variable than when read by h2_GetAllowSpellRecovery, returns the value of bAllowRecovery.
//This should be set to FALSE if oPC should not be allowed to recover spells after their
//next rest action is finished.
void h2_SetAllowSpellRecovery(object oPC, int bAllowRecovery);

//bAllowRecovery should be TRUE or FALSE
//This set a variable than when read by h2_GetAllowFeatRecovery, returns the value of bAllowRecovery.
//This should be set to FALSE if oPC should not be allowed to recover feats after their
//next rest action is finished.
void h2_SetAllowFeatRecovery(object oPC, int bAllowRecovery);

//Returns an integer that indiated that amount of HitPoints oPC should be allowed to regain
//after their next rest action is finished.
int h2_GetPostRestHealAmount(object oPC);

//This sets the amount of HitPoints oPC will be allowed to regain
//after their next rest action is finished.
void h2_SetPostRestHealAmount(object oPC, int amount);

//This function opens the rest dialog for the PC if h2_GetAllowRest returns TRUE.
void h2_OpenRestDialog(object oPC);

//This makes oPC actually rest. It will not open the rest dialog
//when the rest occurs. Run this from a node that allows rest in the rest
//conversation dialogue.
void h2_MakePCRest(object oPC);

//Sets up a Rest Menu Item that will be displayed in the rest conversation dialogue for oPC.
//oPC is the player that is about to rest.
//sMenuText is the text of the option and sActionScript is the name of the script
//that will get executed if the option is selected.
//The OBJECT_SELF for the action script is oPC.
//If sMenuText is empty the rest menu option will not be added.
//A maximum of 10 menu items can be added, and one of those is added by default, leaving only 9 additional
//ones available to customize. Attempting to add more will have no effect, beyond a log entry being made.
//This should only be called from rest started event hook-in scripts.
void h2_AddRestMenuItem(object oPC, string sMenuText, string sActionScript = H2_REST_MENU_DEFAULT_ACTION_SCRIPT);

//This function uses the value from h2_GetPostRestHealAmount to restricted
//the amount of HitPoints gained after oPC's rest is finished.
//It should be called from rest event finished script hook-ins.
void h2_LimitPostRestHeal(object oPC, int postRestHealAmt);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

//This function saves the server start time before it is modified by any other functions.  It is called
//  on module load before any other functions.  Calling this function after the server time has been
//  modified by any other function will result in erroreous results for any calculation that uses
//  the server epoch.  The following five functions are not original to HCR2.
void h2_SaveServerEpoch()
{
    SetModuleString(H2_EPOCH, GetSystemTime());
}

string h2_GetServerEpoch()
{
    return GetModuleString(H2_EPOCH);
}

string h2_GetTimeSinceServerStart()
{
    string sTime = GetModuleString(H2_SERVER_START_TIME);
    return GetSystemTimeDifference(sTime);
}

int h2_GetIsLocationValid(location loc)
{
    object oArea = GetAreaFromLocation(loc);
    vector v = GetPositionFromLocation(loc);

    if (GetIsObjectValid(oArea) == FALSE || v.x < 0.0 || v.y < 0.0)
        return FALSE;

    return TRUE;
}

void h2_MoveEquippedItem(object oPossessor, int invSlot, object oReceivingObject =  OBJECT_INVALID)
{
    if (!GetIsObjectValid(oPossessor))
        return;

    object oItem = GetItemInSlot(invSlot, oPossessor);
    if (GetIsObjectValid(oItem))
    {
        if (GetIsObjectValid(oReceivingObject) && !GetItemCursedFlag(oItem))
            CopyItem(oItem, oReceivingObject, TRUE);

        if (!GetItemCursedFlag(oItem))
            DestroyObject(oItem);
    }
}

void h2_MovePossessorInventory(object oPossessor, int bMoveGold = FALSE, object oReceivingObject = OBJECT_INVALID)
{
    if (!GetIsObjectValid(oPossessor))
        return;

    if (GetLocalInt(oPossessor, H2_MOVING_ITEMS))
        return;

    SetLocalInt(oPossessor, H2_MOVING_ITEMS, 1);
    if (bMoveGold)
    {
        int nGold = GetGold(oPossessor);
        if (nGold)
        {
            if (GetIsObjectValid(oReceivingObject))
                AssignCommand(oReceivingObject, TakeGoldFromCreature(nGold, oPossessor));
            else
                AssignCommand(oPossessor, TakeGoldFromCreature(nGold, oPossessor, TRUE));
        }
    }

    object oItem = GetFirstItemInInventory(oPossessor);
    while (GetIsObjectValid(oItem))
    {
        if (!GetItemCursedFlag(oItem))
        {
            if (GetIsObjectValid(oReceivingObject))
                CopyItem(oItem, oReceivingObject, TRUE);
            DestroyObject(oItem);
        }
        oItem = GetNextItemInInventory(oPossessor);
    }

    DeleteLocalInt(oPossessor, H2_MOVING_ITEMS);
}

void h2_MoveEquippedItems(object oPossessor, object oReceivingObject = OBJECT_INVALID)
{
    if (!GetIsObjectValid(oPossessor))
        return;

    int i; while (i <= 13)
        h2_MoveEquippedItem(oPossessor, i++, oReceivingObject);
}

void h2_DestroyNonDroppableItemsInInventory(object oPossessor)
{
    object oItem = GetFirstItemInInventory(oPossessor);
    while (GetIsObjectValid(oItem))
    {
        if (GetItemCursedFlag(oItem))
            DestroyObject(oItem);
        oItem = GetNextItemInInventory(oPossessor);
    }
}

void h2_BootPlayer(object oPC, string sMessage = "", float delay = 0.0)
{
    if (!GetIsObjectValid(oPC))
        return;

    if (sMessage != "")
        SendMessageToPC(oPC, sMessage);

    string sAdminMessage = GetPCPlayerName(oPC) + " BOOTED: " + sMessage;
    SendMessageToAllDMs(sAdminMessage);
    Debug(sAdminMessage);
    DelayCommand(delay, BootPC(oPC, sMessage));
    SetEventState(EVENT_STATE_DENIED);
}

void h2_BanPlayerByCDKey(object oPC)
{
    string sMessage = GetName(oPC) + "_" + GetPCPlayerName(oPC) + " banned by: " + GetName(OBJECT_SELF) + "_" + GetPCPlayerName(OBJECT_SELF);

    SetPersistentString(H2_BANNED_PREFIX + GetPCPublicCDKey(oPC), sMessage, H2_VARIABLE_TAG);
    SendMessageToAllDMs(sMessage);
    Debug(sMessage);
    h2_BootPlayer(oPC, H2_TEXT_YOU_ARE_BANNED);
}

void h2_BanPlayerByIPAddress(object oPC)
{
    string sMessage = GetName(oPC) + "_" + GetPCPlayerName(oPC) + " banned by: " + GetName(OBJECT_SELF) + "_" + GetPCPlayerName(OBJECT_SELF);
    SetPersistentString(H2_BANNED_PREFIX + GetPCIPAddress(oPC), sMessage, H2_VARIABLE_TAG);
    SendMessageToAllDMs(sMessage);
    Debug(sMessage);
    h2_BootPlayer(oPC, H2_TEXT_YOU_ARE_BANNED);
}

void h2_RemoveEffects(object oCreature)
{
    if (!GetIsObjectValid(oCreature))
        return;

    effect e = GetFirstEffect(oCreature);
    while (GetEffectType(e) != EFFECT_TYPE_INVALIDEFFECT)
    {
        RemoveEffect(oCreature, e);
        e = GetNextEffect(oCreature);
    }
}

void h2_RemoveEffectType(object oCreature, int nEffectType)
{
    if (!GetIsObjectValid(oCreature))
        return;
    effect e = GetFirstEffect(oCreature);
    while (GetEffectType(e) != EFFECT_TYPE_INVALIDEFFECT)
    {
        if (GetEffectType(e) == nEffectType)
            RemoveEffect(oCreature, e);
        e = GetNextEffect(oCreature);
    }
}

void h2_SetPlayerHitPointsToSavedValue(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;
    int currHP = GetCurrentHitPoints(oPC);
    int savedHP = GetPlayerInt(oPC, H2_PLAYER_HP);
    int damage = currHP - savedHP;
    if (damage < currHP && damage > 0)
    {
        effect eDam = EffectDamage(damage);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oPC);
    }
}

int h2_GetFeatUsesRemaining(object oPC, int nFeat, int nMaxUses)
{
    int i, nCount = 0;

    for (i = 0; i <= nMaxUses; i++)
    {
        int bHasFeat = GetHasFeat(nFeat, oPC);
        if (bHasFeat)
        {
            nCount++;
            DecrementRemainingFeatUses(oPC, nFeat);
        }
        else
            break;
    }
    
    if (nCount == ++nMaxUses)
        nCount = -1;

    for (i = 0; i < nCount; i++)
        IncrementRemainingFeatUses(oPC, nFeat);

    return nCount;
}

void h2_SetFeatsRemaining(object oPC, int nFeat, int nUses)
{
    int i;
    for (i = 0; i < 50; i++)
    {
        int bHasFeat = GetHasFeat(nFeat, oPC);
        if (bHasFeat)
            DecrementRemainingFeatUses(oPC, nFeat);
        else
            break;
    }
    if (i < 50)
    {
        for (i = 0; i < nUses; i++)
            IncrementRemainingFeatUses(oPC, nFeat);
    }
}

// Modified to use CSVs.
// GOTO go thorugh feat/spell saving and check they're g2g.
void h2_SetAvailableFeatsToSavedValues(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    string sFeats = GetPlayerString(oPC, H2_FEAT_TRACK_FEATS);
    string sUses  = GetPlayerString(oPC, H2_FEAT_TRACK_USES);

    int i, nCount, nFeat, nUse;

    if (!(nCount = CountList(sFeats)))
        return;

    for (i = 0; i < nCount; i++)
    {
        nFeat = StringToInt(GetListItem(sFeats, i));
        nUse = StringToInt(GetListItem(sUses, i));

        h2_SetFeatsRemaining(oPC, nFeat, nUse);
    }
}

/*
void h2_SetAvailableFeatsToSavedValues(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;
    string sFeatTrack = _GetLocalString(oPC, H2_FEAT_TRACK);
    if (sFeatTrack == "")
        return;
    sFeatTrack = GetStringRight(sFeatTrack, GetStringLength(sFeatTrack) - 1);
    while (sFeatTrack != "")
    {
        int nDivIndex = FindSubString(sFeatTrack, "|");
        int nValIndex = FindSubString(sFeatTrack, ":");
        int nFeat = StringToInt(GetStringLeft(sFeatTrack, nValIndex));
        int nUses = StringToInt(GetSubString(sFeatTrack,  nValIndex + 1, nDivIndex - nValIndex - 1));
        h2_SetFeatsRemaining(oPC, nFeat, nUses);
        sFeatTrack = GetStringRight(sFeatTrack, GetStringLength(sFeatTrack) - nDivIndex - 1);
    }
}
*/

// Modified to use CSVs.
void h2_SetAvailableSpellsToSavedValues(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    string sSpells = GetPlayerString(oPC, H2_SPELL_TRACK_SPELLS);
    string sUses = GetPlayerString(oPC, H2_SPELL_TRACK_USES);

    if (!CountList(sSpells))
        return;

    int nSpellID, nSpellsRemaining;
    for (nSpellID = 0; nSpellID < 550; nSpellID++)
    {
        if (nSpellsRemaining = GetHasSpell(nSpellID, oPC))
        {
            int nIndex = FindListItem(sSpells, IntToString(nSpellID));
            if (nIndex > -1)
                nSpellsRemaining -= StringToInt(GetListItem(sUses, nIndex));
                
            while (nSpellsRemaining)
            {
                DecrementRemainingSpellUses(oPC, nSpellID);
                nSpellsRemaining--;
            }
        }
    }
}

/*
void h2_SetAvailableSpellsToSavedValues(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    string sSpelltrack = _GetLocalString(oPC, H2_SPELL_TRACK);
    if (sSpelltrack == "")
        return;

    int nSpellID;
    for(nSpellID = 0; nSpellID < 550; nSpellID++) {
        int nSpellsRemaining = GetHasSpell(nSpellID, oPC);
        if (nSpellsRemaining > 0)
        {
            int nIndex = FindSubString(sSpelltrack, IntToString(nSpellID)+":");
            if (nIndex == -1)
            {
                //decrement spells that the player has, but were not known to have been set on
                //their last log out.
                while (nSpellsRemaining > 0) {
                    DecrementRemainingSpellUses(oPC, nSpellID);
                    nSpellsRemaining--;
                }
            }
            else //the PC has a spell that is being tracked.
            {   //get the saved remaining spells, and decrement them to the correct value.
                string sSavedSpellsRemaining = GetSubString(sSpelltrack, nIndex + GetStringLength(IntToString(nSpellID)) + 1, 1);
                int nSpellsToDecrement = nSpellsRemaining - StringToInt(sSavedSpellsRemaining);
                while (nSpellsToDecrement > 0) {
                    DecrementRemainingSpellUses(oPC, nSpellID);
                    nSpellsToDecrement--;
                }
            }
        }
    }
}
*/

//TODO save these values to the database?
void h2_SavePCHitPoints(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    int hp = GetCurrentHitPoints(oPC);
    SetPlayerInt(oPC, H2_PLAYER_HP, hp);
}

// Modified to use CSVs.
void h2_AppendToFeatTrack(object oPC, int nFeat, int nMaxUses)
{
    string sFeats = GetPlayerString(oPC, H2_FEAT_TRACK_FEATS);
    string sUses = GetPlayerString(oPC, H2_FEAT_TRACK_USES);
    string sFeat = IntToString(nFeat);

    int nIndex = FindListItem(sFeats, sFeat);
    int nUse = h2_GetFeatUsesRemaining(oPC, nFeat, nMaxUses);

    if (nIndex != -1)
    {
        sFeats = DeleteListItem(sFeats, nIndex);
        sUses = DeleteListItem(sUses, nIndex);
    }

    if (nUse > -1)
    {
        sFeats = AddListItem(sFeats, sFeat);
        sUses = AddListItem(sUses, IntToString(nUse));
        SetPlayerString(oPC, H2_FEAT_TRACK_FEATS, sFeats);
        SetPlayerString(oPC, H2_FEAT_TRACK_USES, sUses);
    }
}

// Modified to use CSVs.
void h2_SavePCAvailableFeats(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    int i;

    for (i = 1; i <= 3; i++)
    {
        int nClass = GetClassByPosition(i, oPC);
        if (nClass == CLASS_TYPE_INVALID)
            continue;

        switch (nClass)
        {
            case CLASS_TYPE_BARBARIAN:
                h2_AppendToFeatTrack(oPC, FEAT_BARBARIAN_RAGE, 11);
                break;
            case CLASS_TYPE_BARD:
                h2_AppendToFeatTrack(oPC, FEAT_BARD_SONGS, 44);
                break;
            case CLASS_TYPE_CLERIC:
            {
                h2_AppendToFeatTrack(oPC, FEAT_TURN_UNDEAD, 24);
                h2_AppendToFeatTrack(oPC, FEAT_DEATH_DOMAIN_POWER, 1);
                h2_AppendToFeatTrack(oPC, FEAT_PROTECTION_DOMAIN_POWER, 1);
                h2_AppendToFeatTrack(oPC, FEAT_STRENGTH_DOMAIN_POWER, 1);
                h2_AppendToFeatTrack(oPC, FEAT_TRICKERY_DOMAIN_POWER, 1);
                break;
            }
            case CLASS_TYPE_DRUID:
                h2_AppendToFeatTrack(oPC, FEAT_ANIMAL_COMPANION, 1);
                h2_AppendToFeatTrack(oPC, FEAT_WILD_SHAPE, 6);
                h2_AppendToFeatTrack(oPC, FEAT_ELEMENTAL_SHAPE, 4);
                h2_AppendToFeatTrack(oPC, FEAT_EPIC_WILD_SHAPE_DRAGON, 3);
                break;
            case CLASS_TYPE_MONK:
                h2_AppendToFeatTrack(oPC, FEAT_STUNNING_FIST, 43);
                h2_AppendToFeatTrack(oPC, FEAT_EMPTY_BODY, 2);
                h2_AppendToFeatTrack(oPC, FEAT_QUIVERING_PALM, 1);
                h2_AppendToFeatTrack(oPC, FEAT_WHOLENESS_OF_BODY, 1);
                break;
            case CLASS_TYPE_PALADIN:
                h2_AppendToFeatTrack(oPC, FEAT_TURN_UNDEAD, 24);
                h2_AppendToFeatTrack(oPC, FEAT_LAY_ON_HANDS, 1);
                h2_AppendToFeatTrack(oPC, FEAT_REMOVE_DISEASE, 1);
                h2_AppendToFeatTrack(oPC, FEAT_SMITE_EVIL, 3);
                break;
            case CLASS_TYPE_RANGER:
                h2_AppendToFeatTrack(oPC, FEAT_ANIMAL_COMPANION, 1);
                break;
            case CLASS_TYPE_ROGUE:
                h2_AppendToFeatTrack(oPC, FEAT_DEFENSIVE_ROLL, 1);
                break;
            case CLASS_TYPE_SORCERER:
                h2_AppendToFeatTrack(oPC, FEAT_SUMMON_FAMILIAR, 1);
                break;
            case CLASS_TYPE_WIZARD:
                h2_AppendToFeatTrack(oPC, FEAT_SUMMON_FAMILIAR, 1);
                break;
            case CLASS_TYPE_ARCANE_ARCHER:
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_IMBUE_ARROW, 3);
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_HAIL_OF_ARROWS, 1);
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_ARROW_OF_DEATH, 1);
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_SEEKER_ARROW_1, 2);
                break;
            case CLASS_TYPE_ASSASSIN:
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_SPELL_GHOSTLY_VISAGE, 1);
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_DARKNESS, 1);
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_INVISIBILITY_1, 1);
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_INVISIBILITY_2, 1);
                break;
            case CLASS_TYPE_BLACKGUARD:
                h2_AppendToFeatTrack(oPC, FEAT_TURN_UNDEAD, 24);
                h2_AppendToFeatTrack(oPC, FEAT_SMITE_GOOD, 3);
                h2_AppendToFeatTrack(oPC, FEAT_PRESTIGE_DARK_BLESSING, 1);
                h2_AppendToFeatTrack(oPC, FEAT_BULLS_STRENGTH, 1);
                h2_AppendToFeatTrack(oPC, FEAT_INFLICT_SERIOUS_WOUNDS, 1);
                h2_AppendToFeatTrack(oPC, FEAT_INFLICT_CRITICAL_WOUNDS, 1);
                h2_AppendToFeatTrack(oPC, FEAT_CONTAGION, 1);
                h2_AppendToFeatTrack(oPC, FEAT_INFLICT_LIGHT_WOUNDS, 1);
                h2_AppendToFeatTrack(oPC, FEAT_INFLICT_MODERATE_WOUNDS, 1);
                break;
            case CLASS_TYPE_HARPER:
                h2_AppendToFeatTrack(oPC, FEAT_HARPER_CATS_GRACE, 1);
                h2_AppendToFeatTrack(oPC, FEAT_HARPER_EAGLES_SPLENDOR, 1);
                h2_AppendToFeatTrack(oPC, FEAT_HARPER_INVISIBILITY, 1);
                h2_AppendToFeatTrack(oPC, FEAT_HARPER_SLEEP, 1);
                h2_AppendToFeatTrack(oPC, FEAT_CRAFT_HARPER_ITEM, 1);
                h2_AppendToFeatTrack(oPC, FEAT_TYMORAS_SMILE, 1);
                break;
            case CLASS_TYPE_SHADOWDANCER:
                h2_AppendToFeatTrack(oPC, FEAT_SUMMON_SHADOW, 1);
                h2_AppendToFeatTrack(oPC, FEAT_SHADOW_DAZE, 1);
                h2_AppendToFeatTrack(oPC, FEAT_SHADOW_EVADE, 3);
                h2_AppendToFeatTrack(oPC, FEAT_DEFENSIVE_ROLL, 1);
                break;
            case CLASS_TYPE_PALEMASTER:
                h2_AppendToFeatTrack(oPC, FEAT_ANIMATE_DEAD, 1);
                h2_AppendToFeatTrack(oPC, FEAT_SUMMON_UNDEAD, 1);
                h2_AppendToFeatTrack(oPC, FEAT_UNDEAD_GRAFT_1, 9);
                h2_AppendToFeatTrack(oPC, FEAT_SUMMON_GREATER_UNDEAD, 1);
                h2_AppendToFeatTrack(oPC, FEAT_DEATHLESS_MASTER_TOUCH, 3);
                break;
            case CLASS_TYPE_DRAGON_DISCIPLE:
                h2_AppendToFeatTrack(oPC, FEAT_DRAGON_DIS_BREATH, 1);
                break;
            case CLASS_TYPE_SHIFTER:
                h2_AppendToFeatTrack(oPC, FEAT_GREATER_WILDSHAPE_1, 3);
                h2_AppendToFeatTrack(oPC, FEAT_GREATER_WILDSHAPE_2, 3);
                h2_AppendToFeatTrack(oPC, FEAT_GREATER_WILDSHAPE_3, 3);
                h2_AppendToFeatTrack(oPC, FEAT_GREATER_WILDSHAPE_4, 3);
                h2_AppendToFeatTrack(oPC, FEAT_HUMANOID_SHAPE, 3);
                h2_AppendToFeatTrack(oPC, FEAT_EPIC_CONSTRUCT_SHAPE, 3);
                h2_AppendToFeatTrack(oPC, FEAT_EPIC_OUTSIDER_SHAPE, 3);
                h2_AppendToFeatTrack(oPC, FEAT_EPIC_WILD_SHAPE_UNDEAD, 3);
                break;
            case CLASS_TYPE_DIVINE_CHAMPION:
                h2_AppendToFeatTrack(oPC, FEAT_LAY_ON_HANDS, 1);
                h2_AppendToFeatTrack(oPC, FEAT_SMITE_EVIL, 3);
                h2_AppendToFeatTrack(oPC, FEAT_DIVINE_WRATH, 1);
                break;
            case CLASS_TYPE_WEAPON_MASTER:
                h2_AppendToFeatTrack(oPC, FEAT_KI_DAMAGE, 30);
                break;
            case CLASS_TYPE_DWARVEN_DEFENDER:
                h2_AppendToFeatTrack(oPC, FEAT_DWARVEN_DEFENDER_DEFENSIVE_STANCE, 20);
                break;
        }
    }

    if (GetHitDice(oPC) > 20)
    {
        h2_AppendToFeatTrack(oPC, FEAT_EPIC_SPELL_DRAGON_KNIGHT, 1);
        h2_AppendToFeatTrack(oPC, FEAT_EPIC_SPELL_HELLBALL, 1);
        h2_AppendToFeatTrack(oPC, FEAT_EPIC_SPELL_MAGE_ARMOUR, 1);
        h2_AppendToFeatTrack(oPC, FEAT_EPIC_SPELL_MUMMY_DUST, 1);
        h2_AppendToFeatTrack(oPC, FEAT_EPIC_SPELL_RUIN, 1);
        h2_AppendToFeatTrack(oPC, FEAT_EPIC_SPELL_EPIC_WARDING, 1);
        h2_AppendToFeatTrack(oPC, FEAT_EPIC_BLINDING_SPEED, 1);
    }
}

void h2_SavePCAvailableSpells(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;
 
    string sSpells, sUses;
    int nSpellID;

    for (nSpellID = 0; nSpellID < 550; nSpellID++)
    {
        int nSpellsRemaining = GetHasSpell(nSpellID, oPC);
        if (nSpellsRemaining)
        {
            sSpells = AddListItem(sSpells, IntToString(nSpellID));
            sUses = AddListItem(sUses, IntToString(nSpellsRemaining));
        }
    }

    SetPlayerString(oPC, H2_SPELL_TRACK_SPELLS, sSpells);
    SetPlayerString(oPC, H2_SPELL_TRACK_USES, sUses);
}

void h2_DropAllHenchmen(object oPC)
{
    object oHenchman = GetHenchman(oPC);
    while (GetIsObjectValid(oHenchman))
    {
        RemoveHenchman(oPC, oHenchman);
        oHenchman = GetHenchman(oPC);
    }
}

object h2_FindPCWithGivenUniqueID(string uniquePCID)
{
    return GetObjectByUUID(uniquePCID);
}

int h2_SkillCheck(int nSkill, object oUser, int nBroadCastLevel = 1)
{
    int nRank = GetSkillRank(nSkill, oUser);
    int nRoll = d20();
    string sSkill;
    switch (nSkill)
    {
        case SKILL_ANIMAL_EMPATHY:   sSkill = H2_TEXT_SKILL_ANIMAL_EMPATHY;     break;
        case SKILL_APPRAISE:         sSkill = H2_TEXT_SKILL_APPRAISE;           break;
        case SKILL_BLUFF:            sSkill = H2_TEXT_SKILL_BLUFF;              break;
        case SKILL_CONCENTRATION:    sSkill = H2_TEXT_SKILL_CONCENTRATION;      break;
        case SKILL_CRAFT_ARMOR:      sSkill = H2_TEXT_SKILL_CRAFT_ARMOR;        break;
        case SKILL_CRAFT_TRAP:       sSkill = H2_TEXT_SKILL_CRAFT_TRAP;         break;
        case SKILL_CRAFT_WEAPON:     sSkill = H2_TEXT_SKILL_CRAFT_WEAPON;       break;
        case SKILL_DISABLE_TRAP:     sSkill = H2_TEXT_SKILL_DISABLE_TRAP;       break;
        case SKILL_DISCIPLINE:       sSkill = H2_TEXT_SKILL_DISCIPLINE;         break;
        case SKILL_HEAL:             sSkill = H2_TEXT_SKILL_HEAL;               break;
        case SKILL_HIDE:             sSkill = H2_TEXT_SKILL_HIDE;               break;
        case SKILL_INTIMIDATE:       sSkill = H2_TEXT_SKILL_INTIMIDATE;         break;
        case SKILL_LISTEN:           sSkill = H2_TEXT_SKILL_LISTEN;             break;
        case SKILL_LORE:             sSkill = H2_TEXT_SKILL_LORE;               break;
        case SKILL_MOVE_SILENTLY:    sSkill = H2_TEXT_SKILL_MOVE_SILENTLY;      break;
        case SKILL_OPEN_LOCK:        sSkill = H2_TEXT_SKILL_OPEN_LOCK;          break;
        case SKILL_PARRY:            sSkill = H2_TEXT_SKILL_PARRY;              break;
        case SKILL_PERFORM:          sSkill = H2_TEXT_SKILL_PERFORM;            break;
        case SKILL_PERSUADE:         sSkill = H2_TEXT_SKILL_PERSUADE;           break;
        case SKILL_PICK_POCKET:      sSkill = H2_TEXT_SKILL_PICK_POCKET;        break;
        case SKILL_SEARCH:           sSkill = H2_TEXT_SKILL_SEARCH;             break;
        case SKILL_SET_TRAP:         sSkill = H2_TEXT_SKILL_SET_TRAP;           break;
        case SKILL_SPELLCRAFT:       sSkill = H2_TEXT_SKILL_SPELLCRAFT;         break;
        case SKILL_SPOT:             sSkill = H2_TEXT_SKILL_SPOT;               break;
        case SKILL_TAUNT:            sSkill = H2_TEXT_SKILL_TAUNT;              break;
        case SKILL_TUMBLE:           sSkill = H2_TEXT_SKILL_TUMBLE;             break;
        case SKILL_USE_MAGIC_DEVICE: sSkill = H2_TEXT_SKILL_USE_MAGIC_DEVICE;   break;
    }

    string sMessage = GetName(oUser) + " " + sSkill + H2_TEXT_SKILL_CHECK + IntToString(nRoll) +
                        " + " + IntToString(nRank) + " = " + IntToString(nRoll + nRank);
    SendMessageToAllDMs(sMessage);
    
    if (nBroadCastLevel == 1)
        SendMessageToPC(oUser, sMessage);
    else if (nBroadCastLevel == 2)
        FloatingTextStringOnCreature(sMessage, oUser);

    return nRank + nRoll;
}

void h2_SaveCurrentCalendar()
{
    SetPersistentString(H2_SERVER_TIME, GetSystemTime(), H2_VARIABLE_TAG);
}

void h2_SavePCLocation(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    SetPlayerLocation(oPC, H2_PC_SAVED_LOC, GetLocation(oPC));
}

void h2_RestoreSavedCalendar()
{
    string sTime = GetPersistentString(H2_SERVER_TIME, H2_VARIABLE_TAG);

    if (sTime != "")
        _SetCalendar(sTime, TRUE, TRUE);
}

void h2_SaveServerStartTime()
{
    SetModuleString(H2_SERVER_START_TIME, GetSystemTime());
}

//TODO the whole menu/convo thing.  Get rid of and replace with dynamic dialog.
void h2_AddPlayerDataMenuItem(string sMenuText, string sConvResRef)
{
     if (sMenuText == "")
        return;

    int index = GetModuleInt(H2_PLAYER_DATA_MENU_INDEX) + 1;
    if (index <=20)
    {
        SetModuleInt(H2_PLAYER_DATA_MENU_INDEX, index);
        SetModuleString(H2_PLAYER_DATA_MENU_ITEM_TEXT + IntToString(index), sMenuText);
        SetModuleString(H2_CONVERSATION_RESREF + IntToString(index), sConvResRef);
    }
    else
        Debug("Player Data Menu Item: " + sMenuText + " exceeded maximum allowed.");
}

void h2_StartCharExportTimer()
{
    if (H2_EXPORT_CHARACTERS_INTERVAL > 0.0)
    {
        int nTimerID = CreateTimer(MODULE, H2_EXPORT_CHAR_ON_TIMER_EXPIRE, H2_EXPORT_CHARACTERS_INTERVAL, 0, 0.0, CORE_HOOK_TIMERS);
        SetModuleInt(H2_EXPORT_CHAR_TIMER_ID, nTimerID);
        StartTimer(nTimerID, TRUE);
    }
}

void h2_StartSavePCLocationTimer()
{
    if (H2_SAVE_PC_LOCATION_TIMER_INTERVAL > 0.0)
    {
        int nTimerID = CreateTimer(MODULE, H2_SAVE_LOCATION_ON_TIMER_EXPIRE, H2_SAVE_PC_LOCATION_TIMER_INTERVAL, 0, 0.0, CORE_HOOK_TIMERS);
        SetModuleInt(H2_SAVE_LOCATION_TIMER_ID, nTimerID);
        StartTimer(nTimerID, TRUE);
    }
}

// TODO swap to sm database
string h2_GetNewUniquePCID(object oPC)
{
    return GetObjectUUID(oPC);
}

void h2_SendPCToSavedLocation(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    int hasLoggedInThisReset = GetModuleInt(uniquePCID + H2_INITIAL_LOGIN);
    if (!hasLoggedInThisReset && H2_SAVE_PC_LOCATION_TIMER_INTERVAL > 0.0)
    {
        location savedLocation = GetPlayerLocation(oPC, H2_PC_SAVED_LOC);
        if (h2_GetIsLocationValid(savedLocation))
        {
            SendMessageToPC(oPC, H2_TEXT_SEND_TO_SAVED_LOC);
            DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, AssignCommand(oPC, ActionJumpToLocation(savedLocation)));
        }
    }
}

void h2_SetPlayerID(object oPC)
{
    string uniquepcid = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    string fullpcname = GetName(oPC) + "_" + GetPCPlayerName(oPC);
    if (uniquepcid == "")
    {
        uniquepcid = h2_GetNewUniquePCID(oPC);
        SetPlayerString(oPC, H2_UNIQUE_PC_ID, uniquepcid);
        SetPersistentString(uniquepcid, fullpcname, H2_VARIABLE_TAG);
    }
    else
    {
        string storedName = GetPersistentString(uniquepcid, H2_VARIABLE_TAG);
        if (storedName != fullpcname)
        {
            string sMessage = fullpcname + H2_WARNING_INVALID_PLAYERID + storedName + H2_WARNING_ASSIGNED_NEW_PLAYERID;
            Debug(sMessage);
            SendMessageToAllDMs(sMessage);
            uniquepcid = h2_GetNewUniquePCID(oPC);
            SetPlayerString(oPC, H2_UNIQUE_PC_ID, uniquepcid);
            SetPersistentString(uniquepcid, fullpcname, H2_VARIABLE_TAG);
        }
    }
}

void h2_RegisterPC(object oPC)
{
    int registeredCharCount = GetPersistentInt(GetPCPlayerName(oPC) + H2_REGISTERED_CHAR_SUFFIX, H2_VARIABLE_TAG);
    SetPlayerInt(oPC, H2_REGISTERED, TRUE);
    SetPlayerInt(oPC, H2_INITIAL_LOGIN, TRUE); //TODO why'd I put this here again?
    SetPersistentInt(GetPCPlayerName(oPC) + H2_REGISTERED_CHAR_SUFFIX, registeredCharCount + 1, H2_VARIABLE_TAG);
    SendMessageToPC(oPC, H2_TEXT_CHAR_REGISTERED);
    SendMessageToPC(oPC, H2_TEXT_MAX_REGISTERED_CHARS + IntToString(H2_REGISTERED_CHARACTERS_ALLOWED));

    RunEvent(MODULE_EVENT_ON_CHARACTER_REGISTRATION, oPC);
}

void h2_InitializePC(object oPC)
{
    SetPlotFlag(oPC, FALSE);
    SetImmortal(oPC, FALSE);

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_ALIVE)
    {
        SetPlayerInt(oPC, H2_LOGIN_DEATH, TRUE);
        h2_MovePossessorInventory(oPC, TRUE);
        h2_MoveEquippedItems(oPC);
        DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC));
        return;
    }

    if (H2_STRIP_ON_FIRST_LOGIN)
        h2_StripOnFirstLogin(oPC);

    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    int savedHP = GetModuleInt(uniquePCID + H2_PLAYER_HP);
    if (savedHP < GetMaxHitPoints(oPC) && savedHP > 0)
    {
        DeleteModuleInt(uniquePCID + H2_PLAYER_HP);
        SetPlayerInt(oPC, H2_PLAYER_HP, savedHP);
        h2_SetPlayerHitPointsToSavedValue(oPC);
    }

    string spelltrack = GetModuleString(uniquePCID + H2_SPELL_TRACK_SPELLS);
    string spelluses = GetModuleString(uniquePCID + H2_SPELL_TRACK_USES);
    string feattrack = GetModuleString(uniquePCID + H2_FEAT_TRACK_FEATS);
    string featuses = GetModuleString(uniquePCID + H2_FEAT_TRACK_USES);

    if (GetRacialType(oPC) > 6)
    {   //If racial type is above 6, then the PC is polymorphed.
        effect e = GetFirstEffect(oPC);
        while (GetEffectType(e) != EFFECT_TYPE_INVALIDEFFECT)
        {   //some polymorphs add temporary hitpoints.
            if (GetEffectType(e) == EFFECT_TYPE_POLYMORPH || GetEffectType(e) == EFFECT_TYPE_TEMPORARY_HITPOINTS)
                RemoveEffect(oPC, e);
            e = GetNextEffect(oPC);
        }
    }

    if (spelltrack != "")
    {
        DeleteModuleString(uniquePCID + H2_SPELL_TRACK_SPELLS);
        DeleteModuleString(uniquePCID + H2_SPELL_TRACK_USES);
        SetPlayerString(oPC, H2_SPELL_TRACK_SPELLS, spelltrack);
        SetPlayerString(oPC, H2_SPELL_TRACK_USES, spelluses);
        DelayCommand(1.0, h2_SetAvailableSpellsToSavedValues(oPC));
    }

    if (feattrack != "")
    {
        DeleteModuleString(uniquePCID + H2_FEAT_TRACK_FEATS);
        DeleteModuleString(uniquePCID + H2_FEAT_TRACK_USES);
        SetPlayerString(oPC, H2_FEAT_TRACK_FEATS, feattrack);
        SetPlayerString(oPC, H2_FEAT_TRACK_USES, featuses);
        DelayCommand(1.0, h2_SetAvailableFeatsToSavedValues(oPC));
    }

    h2_SendPCToSavedLocation(oPC);
    SetModuleInt(uniquePCID + H2_INITIAL_LOGIN, TRUE);

    int isRegistered = GetPlayerInt(oPC, H2_REGISTERED);
    if (!isRegistered && H2_REGISTERED_CHARACTERS_ALLOWED > 0)
        h2_RegisterPC(oPC);
}

void h2_StripOnFirstLogin(object oPC)
{
    if (!GetPlayerInt(oPC, H2_STRIPPED))
    {
        h2_MovePossessorInventory(oPC, TRUE);
        h2_MoveEquippedItems(oPC);
        SetPlayerInt(oPC, H2_STRIPPED, TRUE);
    }
}

int h2_MaximumPlayersReached()
{
    return (H2_MAXIMUM_PLAYERS > 0 && CountObjectList(GetModule(), PLAYER_ROSTER) >= H2_MAXIMUM_PLAYERS);
}

void h2_SavePersistentPCData(object oPC)
{
    int hp = GetCurrentHitPoints(oPC);
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    SetModuleInt(uniquePCID + H2_PLAYER_HP, hp);
    h2_SavePCAvailableSpells(oPC);
    h2_SavePCAvailableFeats(oPC);

    string spelltrack = GetPlayerString(oPC, H2_SPELL_TRACK_SPELLS);
    string spelluses = GetPlayerString(oPC, H2_SPELL_TRACK_USES);
    SetModuleString(uniquePCID + H2_SPELL_TRACK_SPELLS, spelltrack);
    SetModuleString(uniquePCID + H2_SPELL_TRACK_USES, spelluses);

    string feattrack = GetPlayerString(oPC, H2_FEAT_TRACK_FEATS);
    string featuses = GetPlayerString(oPC, H2_FEAT_TRACK_USES);
    SetModuleString(uniquePCID + H2_FEAT_TRACK_FEATS, feattrack);
    SetModuleString(uniquePCID + H2_FEAT_TRACK_USES, featuses);
}

int h2_GetAllowRest(object oPC)
{
    return GetLocalInt(oPC, H2_ALLOW_REST);
}

void h2_SetAllowRest(object oPC, int bAllowRest)
{
    SetLocalInt(oPC, H2_ALLOW_REST, bAllowRest);
}

int h2_GetAllowSpellRecovery(object oPC)
{
    return GetPlayerInt(oPC, H2_ALLOW_SPELL_RECOVERY);
}

int h2_GetAllowFeatRecovery(object oPC)
{
    return GetPlayerInt(oPC, H2_ALLOW_FEAT_RECOVERY);
}

void h2_SetAllowSpellRecovery(object oPC, int bAllowRecovery)
{
    SetPlayerInt(oPC, H2_ALLOW_SPELL_RECOVERY, bAllowRecovery);
}

void h2_SetAllowFeatRecovery(object oPC, int bAllowRecovery)
{
    SetPlayerInt(oPC, H2_ALLOW_FEAT_RECOVERY, bAllowRecovery);
}

int h2_GetPostRestHealAmount(object oPC)
{
    return GetPlayerInt(oPC, H2_POST_REST_HEAL_AMT);
}

void h2_SetPostRestHealAmount(object oPC, int amount)
{
    SetPlayerInt(oPC, H2_POST_REST_HEAL_AMT, amount);
}

void h2_OpenRestDialog(object oPC)
{
    SetPlayerInt(oPC, H2_SKIP_CANCEL_REST, TRUE);
    AssignCommand(oPC, ClearAllActions());
    StartDialog(oPC, oPC, "RestDialog", TRUE, TRUE, TRUE);
}

void h2_MakePCRest(object oPC)
{
    SetPlayerInt(oPC, H2_SKIP_REST_DIALOG, TRUE);
    h2_SavePCHitPoints(oPC);
    h2_SavePCAvailableSpells(oPC);
    h2_SavePCAvailableFeats(oPC);
    DelayCommand(1.0, AssignCommand(oPC, ActionRest(TRUE)));
}

void h2_LimitPostRestHeal(object oPC, int postRestHealAmt)
{
    int savedHP = GetPlayerInt(oPC, H2_PLAYER_HP);
    int currHP = GetCurrentHitPoints(oPC);
    if (savedHP + postRestHealAmt < currHP)
    {
        int nDam = currHP - (savedHP + postRestHealAmt);
        effect eDamage = EffectDamage(nDam, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oPC);
    }
}

string h2_debug_TranslateState(int n)
{
    return n == H2_PLAYER_STATE_ALIVE      ? "ALIVE"      :
           n == H2_PLAYER_STATE_DYING      ? "DYING"      :
           n == H2_PLAYER_STATE_DEAD       ? "DEAD"       :
           n == H2_PLAYER_STATE_STABLE     ? "STABLE"     :
           n == H2_PLAYER_STATE_RECOVERING ? "RECOVERING" :
           n == H2_PLAYER_STATE_RETIRED    ? "RETIRED"    :
                                             "UKNOWN";
}

int AssignRole(object oPC)
{
    DeletePlayerInt(oPC, IS_PC);
    DeletePlayerInt(oPC, IS_DM);
    DeletePlayerInt(oPC, IS_DEVELOPER);

    // Bypass for neirac

    if (GetIsDM(oPC))
        SetPlayerInt(oPC, IS_DM, TRUE);
    else
        SetPlayerInt(oPC, IS_PC, TRUE);


    return TRUE;
}
