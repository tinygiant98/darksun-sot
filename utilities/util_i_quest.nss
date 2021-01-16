// -----------------------------------------------------------------------------
//    File: util_i_quest.nss
//  System: Quest Control System
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Changelog:
//
// 20210112:
//      Initial Release

#include "util_i_datapoint"
#include "util_i_csvlists"
#include "util_i_varlists"
#include "util_i_data"
#include "util_i_time"
#include "util_i_libraries"
#include "nwnx_player"

// -----------------------------------------------------------------------------
//                          Configuration/Defaults
// -----------------------------------------------------------------------------

// Note:  Change these defaults to suit the needs or your module

// Generally, variables set on PC objects will persist through server resets,
// however, if you'd like to save PC quest states to the active database, set
// this to TRUE.  Setting this to TRUE is considered advanced usage since it may
// require modification of database functionality to match your server's
// implementation.
const int QUEST_SAVE_QUEST_STATE_TO_DATABASE = FALSE;

// TODO reward, preward, objective, etc. stucts for easy addition of steps to quests?


// -----------------------------------------------------------------------------
//                      LEAVE EVERYTHING BELOW HERE ALONE!
// -----------------------------------------------------------------------------

// Datapoint Object
object QUESTS = GetDatapoint("QUEST_DATA");

// Quest Identification Variable Names
const string QUEST_TAG = "QUEST_TAG";
const string QUEST_TITLE = "QUEST_TITLE";

// Quest Properties Variable Names
const string QUEST_ALLOW_RANDOM_ORDER = "QUEST_ALLOW_RANDOM_ORDER";
const string QUEST_ALLOW_PARTY_PREREQUISITES = "QUEST_ALLOW_PARTY_PREREQUISITES";
const string QUEST_ACTIVE = "QUEST_ACTIVE";
const string QUEST_REPETITIONS = "QUEST_REPETITIONS";
const string QUEST_ASSIGN_TO_PARTY = "QUEST_ASSIGN_TO_PARTY";
const string QUEST_SCRIPT_ON_ACCEPT = "QUEST_SCRIPT_ON_ACCEPT";
const string QUEST_SCRIPT_ON_ADVANCE = "QUEST_SCRIPT_ON_ADVANCE";
const string QUEST_SCRIPT_ON_COMPLETE = "QUEST_SCRIPT_ON_COMPLETE";
const string QUEST_DISPLAY_ON_COMPLETE = "QUEST_DISPLAY_ON_COMPLETE";

// Quest Data Variable Names (on PC Object)
const string QUEST_ASSIGNED = "QUEST_ASSIGNED";
const string QUEST_STATUS = "QUEST_STATUS";
const string QUEST_TIME_ASSIGNED = "QUEST_TIME_ASSIGNED";
const string QUEST_COMPLETION_COUNT = "QUEST_COMPLETION_COUNT";

// Quest Pseudo-Array List Names
const string QUEST_STEP = "QUEST_STEP";
const string QUEST_JOURNAL_ENTRY = "QUEST_JOURNAL_ENTRY";
const string QUEST_OBJECTIVE = "QUEST_OBJECTIVE";
const string QUEST_TIME_LIMIT = "QUEST_TIME_LIMIT";
const string QUEST_PARTY_COMPLETION = "QUEST_PARTY_COMPLETION";

const string QUEST_REWARD_TYPE = "QUEST_REWARD_TYPE";
const string QUEST_REWARD_KEY = "QUEST_REWARD_KEY";
const string QUEST_REWARD_VALUE = "QUEST_REWARD_VALUE";

const string QUEST_PREWARD_TYPE = "QUEST_PREWARD_TYPE";
const string QUEST_PREWARD_KEY = "QUEST_PREWARD_KEY";
const string QUEST_PREWARD_VALUE = "QUEST_PREWARD_VALUE";

const string QUEST_PREREQUISITE_TYPE = "QUEST_PREREQUISITE_TYPE";
const string QUEST_PREREQUISITE_KEY = "QUEST_PREREQUISITE_KEY";
const string QUEST_PREREQUISITE_VALUE = "QUEST_PREREQUISITE_VALUE";

// Quest Property and Value Types
const int QUEST_PROPERTY_TYPE_NONE = 0;
const int QUEST_PROPERTY_TYPE_PREREQUISITE = 1;
const int QUEST_PROPERTY_TYPE_REWARD = 2;
const int QUEST_PROPERTY_TYPE_PREWARD = 3;

const int QUEST_VALUE_TYPE_NONE = 0;
const int QUEST_VALUE_TYPE_ALIGNMENT = 1;
const int QUEST_VALUE_TYPE_CLASS = 2;
const int QUEST_VALUE_TYPE_ITEM = 3;
const int QUEST_VALUE_TYPE_QUEST = 4;
const int QUEST_VALUE_TYPE_RACE = 5;
const int QUEST_VALUE_TYPE_GOLD = 6;
const int QUEST_VALUE_TYPE_LEVEL_MAX = 7;
const int QUEST_VALUE_TYPE_LEVEL_MIN = 8;
const int QUEST_VALUE_TYPE_XP = 9;

// Quest Reward Bitmasks
const int AWARD_ALL = 0x00;
const int AWARD_GOLD = 0x01;
const int AWARD_XP = 0x02;
const int AWARD_ITEM = 0x04;
const int AWARD_ALIGNMENT = 0x08;

// Quest Reward Quantity Operations
const int QUEST_OPERATION_REPLACE = 0;
const int QUEST_OPERATION_ADD = 1;

// Quest Entry Validity
const string REQUEST_INVALID = "REQUEST_INVALID";
const int    OPERATION_INVALID = FALSE;

// Quest Objective Types
const int QUEST_OBJECTIVE_TYPE_GATHER = 1;
const int QUEST_OBJECTIVE_TYPE_KILL = 2;
const int QUEST_OBJECTIVE_TYPE_DELIVER = 3;
const int QUEST_OBJECTIVE_TYPE_ESCORT = 4;
const int QUEST_OBJECTIVE_TYPE_CAPTURE = 5;
const int QUEST_OBJECTIVE_TYPE_SPEAK = 6;

// Odds and Ends
const string PAIR_KEY = "PAIR_KEY";
const string PAIR_VALUE = "PAIR_VALUE";

// TODO structs necessary?
struct QUEST_Step_Objective
{
    int nType;
    string sTag1;
    int nQuantity;
    string sTag2;
    string sTime;
};

// -----------------------------------------------------------------------------
//                          Public Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddQuest >---
// Creates a new quest data item and sets default parameters; the quest cannot
// be used as-is after this function and other entries and properties must be set
int AddQuest(string sQuestTag, string sQuestTitle);

// ---< DeleteQuest >---
// Delete all data associated with sQuestTag
void DeleteQuest(string sQuestTag);

// ---< GetQuestActive >---
// Returns a boolean with sQuestTag's active state
int GetQuestActive(string sQuestTag);

// ---< SetQuest[Active|Inactive] >---
// Sets the current stats of sQuestTag to Active|Inactive
void SetQuestActive(string sQuestTag);
void SetQuestInactive(string sQuestTag);

// ---< [Get|Set]QuestRepetitions >---
// Get or Set the number of repititions allowed for sQuestTag
int GetQuestRepetitions(string sQuestTag);
void SetQuestRepetitions(string sQuestTag, int nRepetitions = 1);

// ---< GetQuestRewardItems >---  // TODO
// Gets a comma-delimited string of key:value pairs that represent
// quest reward items and quantities -> resref:qty[,resref:qty...]
string GetQuestRewardItemKeys(string sQuestTag, int nStep = 0);

// ---< GetQuestRewardItem >---  // TODO
// Gets a specific key:value pair that represents a single quest
// reward items at index nItemIndex.
string GetQuestRewardItemValues(string sQuestTag, int nStep = 0);

// ---< SetQuestRewardItem >---
// Sets a specified item and quantity as a reward for completing a quest or
// quest step.
void SetQuestRewardItem(string sQuestTag, string sResref, int nQuantity = 1, int nStep = 0);

// ---< SetQuestRewardItems >---
// Accepts a comma-delimited list of key:value pairs that define a set of item
// rewards and quantities to be awarded upon completion of a specific quest or
// quest step. This function is advanced usage.
void SetQuestRewardItems(string sQuestTag, string sResref, string sQuantity, int nStep = 0);

// ---< CountQuestRewardItems >----
// Returns the count of quest reward items
int CountQuestRewardItems(string sQuestTag, int nStep = 0);

// ---< GetQuestRewardItemResref >---
// Returns the resref of a specified item reward
string GetQuestRewardItemResref(string sQuestTag, int nIndex = 0, int nStep = 0);

// ---< GetQuestRewardItemQuantity >---
// Returns the quantity associated with a specified item reward
int GetQuestRewardItemQuantity(string sQuestTag, int nIndex = 0, int nStep = 0);

// ---< [Get|Set]QuestGoldReward >---
// Gets/Sets a gold reward for completing a quest or a quest step
int GetQuestRewardGold(string sQuestTag, int nStep = 0);
void SetQuestRewardGold(string sQuestTag, int nGold, int nStep = 0);

// ---< [Get|Set]QuestXPReward >---
// Gets/Sets an xp reward for completing a quest or a quest step
int GetQuestRewardXP(string sQuestTag, int nStep = 0);
void SetQuestRewardXP(string sQuestTag, int nXP, int nStep = 0);

// ---< [Get|Set]QuestJournalEntry >---
// Gets/Sets a journal entry for a quest or quest step
string GetQuestJournalEntry(string sQuestTag, int nStep = 0);
void SetQuestJournalEntry(string sQuestTag, string sJournalEntry, int nStep = 0);

// ---< GetQuestAlignmentReward[Axis|Shift] >---
// Returns the alignment reward axis (as an ALIGNMENT_* constant) or the amount of the
// alignment shift
int GetQuestRewardAlignmentAxis(string sQuestTag, int nStep = 0);
int GetQuestRewardAlignmentShift(string sQuestTag, int nStep = 0);

// ---< SetQuestAlignmentReward >---
// Sets an alignment reward for completing a quest or quest step
void SetQuestRewardAlignment(string sQuestTag, int nAxis, int nShift, int nStep = 0);

// ---< [Set|Get]QuestOn[Accept|Advance|Complete]Script >---
// Gets or sets a specified script that runs on the OnAccept/OnAdvance/OnComplete
// quest events
string GetQuestOnAcceptScript(string sQuestTag);
string GetQuestOnCompleteScript(string sQuestTag);
string GetQuestOnAdvanceScript(string sQuestTag);
void SetQuestOnAcceptScript(string sQuestTag, string sScript);
void SetQuestOnCompleteScript(string sQuestTag, string sScript);
void SetQuestOnAdvanceScript(string sQuestTag, string sScript);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

// ---< GetQuestDataItem >---
// Returns the dataitem object associated with sQuestTag
object GetQuestDataItem(string sQuestTag)
{
    object oQuest = GetDataItem(QUESTS, sQuestTag);

    if (!GetIsObjectValid(oQuest))
        oQuest = CreateDataItem(QUESTS, sQuestTag);

    return oQuest;
}

void DeleteQuestDataItem(string sQuestTag)
{
    object oQuest = GetDataItem(QUESTS, sQuestTag);
    DestroyObject(oQuest);
}

// ---< IncrementLocalInt >---
// Increments sVarName stored on oTarget by 1; returns the new value
int IncrementLocalInt(string sVarName, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID)
        oTarget = QUESTS;

    int nValue = GetLocalInt(oTarget, sVarName);
    SetLocalInt(oTarget, sVarName, ++nValue);
    
    return nValue;
}

// ---< DecrementLocalInt >---
// Decrements sVarName stored on oTarget by 1; returns the new value
int DecrementLocalInt(string sVarName, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID)
        oTarget = QUESTS;

    int nValue = GetLocalInt(oTarget, sVarName);
    SetLocalInt(oTarget, sVarName, --nValue);

    return nValue;
}

// ---< GetQuestStepIndex >---
// Quests steps could be put in out of order, for some reason,
// This function will get the index of the next step
int GetQuestStepIndex(string sQuestTag, int nStep = 0)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    return FindListInt(oQuest, nStep, QUEST_STEP);
}

// ---< SetQuestPropertyInt >---
// Sets variable sProperty with nValue on dataitem associated with sQuestTag
void SetQuestPropertyInt(string sQuestTag, string sProperty, int nValue)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    SetLocalInt(oQuest, sProperty, nValue);
}

// ---< GetQuestPropertyInt >---
// Gets variable sProperty from dataitem associated with sQuestTag
int GetQuestPropertyInt(string sQuestTag, string sProperty)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    return GetLocalInt(oQuest, sProperty);
}

// ---< SetQuestPropertyString >---
// Sets variable sProperty with sValue on dataitem associated with sQuestTag
void SetQuestPropertyString(string sQuestTag, string sProperty, string sValue)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    SetLocalString(oQuest, sProperty, sValue);
}

// ---< GetQuestPropertyString >---
// Gets variable sProperty from dataitem associated with sQuestTag
string GetQuestPropertyString(string sQuestTag, string sProperty)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    return GetLocalString(oQuest, sProperty);
}

// QUEST ENTRIES are essentially the same as properties above, but assigned to specific
// steps in a quest, so think of them as step properties, just wanted to keep the name shorter
void SetQuestEntry(string sQuestTag, string sEntryType, string sEntry, int nStep)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    int nIndex = FindListInt(oQuest, nStep, QUEST_STEP);

    if (nIndex == -1)
    {
        Error("Attempting to set a quest reward for a step that does not exist" +
              "\n  sQuestTag -> " + sQuestTag +
              "\n  sEntryType -> " + sEntryType +
              "\n  nStep -> " + IntToString(nStep));
        return;
    }

    string sCurrentEntry = GetListString(oQuest, nIndex, sEntryType);
    if (sCurrentEntry != "")
        Warning(sEntryType + " entry for quest " + sQuestTag + " at step " + 
                IntToString(nStep) + " is being overwritten" +
                "\n  Original value -> " + sCurrentEntry +
                "\n  New value -> " + sEntry);
    else if (sCurrentEntry == sEntry)
        Notice(sEntryType + " entry for quest " + sQuestTag + " is already set; no action taken" +
               "\n  Original value -> " + sCurrentEntry +
               "\n  New value -> " + sEntry);
    else
        SetListString(oQuest, nIndex, sEntry, sEntryType);
}

string GetQuestEntry(string sQuestTag, string sEntryType, int nStep = 0)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    int nIndex = FindListInt(oQuest, nStep, QUEST_STEP);    

    if (nIndex == -1)
    {
        Error("Attempting to get a quest reward for a step that does not exist" +
              "\n  sQuestTag -> " + sQuestTag +
              "\n  sEntryType -> " + sEntryType +
              "\n  nStep -> " + IntToString(nStep));
        return REQUEST_INVALID;
    }
    
    return GetListString(oQuest, nIndex, sEntryType);
}

int CountQuestSteps(string sQuestTag)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    return CountIntList(oQuest, QUEST_STEP);
}

// Adds a quest step to sQuestTag and 
int AddQuestStep(string sQuestTag, string sJournalEntry = "")
{
    object oQuest = GetQuestDataItem(sQuestTag);
    int nStep = CountQuestSteps(sQuestTag) + 1;

    if (AddListInt(oQuest, nStep, QUEST_STEP, TRUE))
    {
        AddListString(oQuest, sJournalEntry, QUEST_JOURNAL_ENTRY);
        AddListString(oQuest, "0,~,~,~", QUEST_OBJECTIVE);
        AddListString(oQuest, "", QUEST_TIME_LIMIT);
        AddListInt   (oQuest, 0, QUEST_PARTY_COMPLETION);
    }
    else
        Warning("Attempted to add step " + IntToString(nStep) + " to " + sQuestTag + "; " +
                "step already exists, no action taken");

    return nStep;
}

void SetQuestStepObjective(string sQuestTag, struct QUEST_Step_Objective qso, int nStep)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    int nIndex = GetQuestStepIndex(sQuestTag, nStep);
    
    string sObjective;
    sObjective = AddListItem(sObjective, IntToString(qso.nType));
    sObjective = AddListItem(sObjective, qso.sTag1);
    sObjective = AddListItem(sObjective, IntToString(qso.nQuantity));
    sObjective = AddListItem(sObjective, qso.sTag2);

    SetListString(oQuest, nIndex, sObjective, QUEST_OBJECTIVE);
}

// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

////// QUEST DATA ADMIN /////////////

int AddQuest(string sQuestTag, string sQuestTitle)
{
    if (sQuestTag == "")
    {
        Error("Unable to create quest; sQuestTag is an empty string");
        return FALSE;
    }

    // TODO see what datapoint already sets and use that
    object oQuest = GetQuestDataItem(sQuestTag);

    SetLocalString(oQuest, QUEST_TAG, sQuestTag);
    SetLocalString(oQuest, QUEST_TITLE, sQuestTitle);

    // Set default quest properties
    SetLocalInt(oQuest, QUEST_ACTIVE, TRUE);
    SetLocalInt(oQuest, QUEST_REPETITIONS, 1);
    SetLocalInt(oQuest, QUEST_ALLOW_RANDOM_ORDER, FALSE);
    SetLocalInt(oQuest, QUEST_ALLOW_PARTY_PREREQUISITES, FALSE);
    // TODO convenience functions to setting properties

    return TRUE;
}

void DeleteQuest(string sQuestTag)
{
    DeleteQuestDataItem(sQuestTag);
}

/////////// QUEST PROPERTIES //////////////
// APPLIES TO ENTIRE QUEST OBJECT ///////

int GetQuestActive(string sQuestTag)
{
    return GetQuestPropertyInt(sQuestTag, QUEST_ACTIVE);
}

void SetQuestActive(string sQuestTag)
{
    SetQuestPropertyInt(sQuestTag, QUEST_ACTIVE, TRUE);
}

void SetQuestInactive(string sQuestTag)
{
    SetQuestPropertyInt(sQuestTag, QUEST_ACTIVE, FALSE);
}

int GetQuestRepetitions(string sQuestTag)
{
    return GetQuestPropertyInt(sQuestTag, QUEST_REPETITIONS);
}

void SetQuestRepetitions(string sQuestTag, int nRepetitions = 1)
{
    SetQuestPropertyInt(sQuestTag, QUEST_REPETITIONS, nRepetitions);
}

string GetQuestOnAcceptScript(string sQuestTag)
{
    return GetQuestPropertyString(sQuestTag, QUEST_SCRIPT_ON_ACCEPT);
}

void SetQuestOnAcceptScript(string sQuestTag, string sScript)
{
    SetQuestPropertyString(sQuestTag, QUEST_SCRIPT_ON_ACCEPT, sScript);
}

string GetQuestOnCompleteScript(string sQuestTag)
{
    return GetQuestPropertyString(sQuestTag, QUEST_SCRIPT_ON_COMPLETE);
}

void SetQuestOnCompleteScript(string sQuestTag, string sScript)
{
    SetQuestPropertyString(sQuestTag, QUEST_SCRIPT_ON_COMPLETE, sScript);
}

string GetQuestOnAdvanceScript(string sQuestTag)
{
    return GetQuestPropertyString(sQuestTag, QUEST_SCRIPT_ON_ADVANCE);
}

void SetQuestOnAdvanceScript(string sQuestTag, string sScript)
{
    SetQuestPropertyString(sQuestTag, QUEST_SCRIPT_ON_ADVANCE, sScript);
}

int GetQuestDisplayOnComplete(string sQuestTag)
{
    return GetQuestPropertyInt(sQuestTag, QUEST_DISPLAY_ON_COMPLETE);
}

void SetQuestDisplayOnComplete(string sQuestTag, int nDisplay = TRUE)
{
    SetQuestPropertyInt(sQuestTag, QUEST_DISPLAY_ON_COMPLETE, nDisplay);
}

//////////// HELPERS ///////////////

int GetIsQuestAssigned(object oPC, string sQuestTag)
{
    return FindListString(oPC, sQuestTag, QUEST_ASSIGNED) != -1;
}

int GetQuestIndex(object oPC, string sQuestTag)
{
    return FindListString(oPC, sQuestTag, QUEST_ASSIGNED);
}
   
int GetIsQuestComplete(object oPC, string sQuestTag, int nStep = 0)
{
    int nIndex = GetQuestIndex(oPC, sQuestTag);
    string sQuestStatus = GetListString(oPC, nIndex, QUEST_STATUS);

    int nQuestSteps = CountQuestSteps(sQuestTag);
    int nCompletedSteps = CountList(sQuestStatus);

    if (!nStep)
        return nCompletedSteps == nQuestSteps;
    else
        return HasListItem(sQuestStatus, IntToString(nStep));
}

// This will award reward or prewards, send the right argument to nPropertyType
// QUEST_PROPERTY_TYPE_REWARD
// QUEST_PROPERTY_TYPE_PREWARD
int AwardQuestAllotments(object oPC, string sQuestTag, int nPropertyType,
                        int nStep = 0, int nAwardType = AWARD_ALL, int bParty = FALSE)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    string sTypeList, sKeyList, sValueList, sStep = "_" + IntToString(nStep);

    if (nPropertyType == QUEST_PROPERTY_TYPE_REWARD)
    {
        sTypeList = QUEST_REWARD_TYPE + sStep;
        sKeyList = QUEST_REWARD_KEY + sStep;
        sValueList = QUEST_REWARD_VALUE + sStep;
    }
    else if (nPropertyType == QUEST_PROPERTY_TYPE_PREWARD)
    {
        sTypeList = QUEST_PREWARD_TYPE + sStep;
        sKeyList = QUEST_PREWARD_KEY + sStep;
        sValueList = QUEST_PREWARD_VALUE + sStep;
    }

    if (sTypeList == "" || sKeyList == "" || sValueList == "")
        return FALSE;

    string sKeys, sValues;
    int n, nType, nCount = CountIntList(oQuest, sTypeList);
    for (n = 0; n < nCount; n++)
    {
        nType = GetListInt(oQuest, n, sTypeList);
        sKeys = GetListString(oQuest, n, sKeyList);
        sValues = GetListString(oQuest, n, sValueList);

        if (nType == QUEST_VALUE_TYPE_GOLD)
        {
            if ((nAwardType && AWARD_GOLD) || nAwardType == AWARD_ALL)
            {
                int nGold = StringToInt(sValues);
                if (bParty) 
                    Error(""); // TODO GiveGoldToAll(oPC, nGold);
                else        
                    GiveGoldToCreature(oPC, nGold);
            }
            continue;
        }
        
        if (nType == QUEST_VALUE_TYPE_XP)
        {
            if ((nAwardType && AWARD_XP) || nAwardType == AWARD_ALL)
            {
                int nXP = StringToInt(sValues);
                if (bParty)
                    Error(""); // TODO GiveXPToAll(oPC, nXP);
                else
                    GiveXPToCreature(oPC, nXP);
            }
            continue;
        }
        
        if (nType == QUEST_VALUE_TYPE_ALIGNMENT)
        {
            if ((nAwardType && AWARD_ALIGNMENT) || nAwardType == AWARD_ALL)
            {
                int n, nAxis, nShift, nCount = CountList(sKeys);
                for (n = 0; n < nCount; n++)
                {
                    nAxis = StringToInt(GetListItem(sKeys, n));
                    nShift = StringToInt(GetListItem(sValues, n));

                    if (bParty)
                        Error("");  // TODO AdjustAlignmentOnAll(oPC, nAxis, nShift);
                    else
                        AdjustAlignment(oPC, nAxis, nShift, FALSE);
                }
            }
            continue;
        }        
        
        if (nType == QUEST_VALUE_TYPE_ITEM)
        {
            if ((nAwardType && AWARD_ITEM) || nAwardType == AWARD_ALL)
            {
                int n, nQuantity, nCount = CountList(sKeys);
                string sResref;
            
                for (n = 0; n < nCount; n++)
                {
                    sResref = GetListItem(sKeys, n);
                    nQuantity = StringToInt(GetListItem(sValues, n));

                    if (bParty)
                    {
                        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
                        while (GetIsObjectValid(oPartyMember))
                        {
                            CreateItemOnObject(sResref, oPartyMember, nQuantity);
                            oPartyMember = GetNextFactionMember(oPC, TRUE);
                        }
                    }
                    else
                        CreateItemOnObject(sResref, oPC, nQuantity);
                }
            }
        }
    }

    return TRUE;
}

int HasMinimumItemCount(object oPC, string sItemTag, int nMinQuantity = 1, int bIncludeParty = FALSE)
{
    int nItemCount = 0;
    object oItem = GetItemPossessedBy(oPC, sItemTag);
    if (GetIsObjectValid(oItem))
    {
        oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem))
        {
            if (GetTag(oItem) == sItemTag)
                nItemCount += GetNumStackedItems(oItem);

            if (nItemCount >= nMinQuantity)
                return TRUE;

            oItem = GetNextItemInInventory(oPC);
        }
    }

    if (bIncludeParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            oItem = GetItemPossessedBy(oPC, sItemTag);
            if (GetIsObjectValid(oItem))
            {
                oItem = GetFirstItemInInventory(oPartyMember);
                while (GetIsObjectValid(oItem))
                {
                    if (GetTag(oItem) == sItemTag)
                        nItemCount += GetNumberStackedItems(oItem);
                    
                    if (nItemCount >= nMinQuantity)
                        return TRUE;

                    oItem = GetNextItemInInventory(oPartyMember);
                }
            }

            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }

    return FALSE;
}

string GetQuestProperty(string sQuestTag, int nPropertyType, int nValueType,
                        string nComponent = PAIR_VALUE, int nStep = 0)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    string sTypeList, sKeyList, sValueList, sStep = "_" + IntToString(nStep);

    if (nPropertyType == QUEST_PROPERTY_TYPE_PREREQUISITE)
    {
        sStep = "_0";

        sTypeList = QUEST_PREREQUISITE_TYPE + sStep;
        sKeyList = QUEST_PREREQUISITE_KEY + sStep;
        sValueList = QUEST_PREREQUISITE_VALUE + sStep;
    }
    else if (nPropertyType == QUEST_PROPERTY_TYPE_REWARD)
    {
        sTypeList = QUEST_REWARD_TYPE + sStep;
        sKeyList = QUEST_REWARD_KEY + sStep;
        sValueList = QUEST_REWARD_VALUE + sStep;
    }
    else if (nPropertyType == QUEST_PROPERTY_TYPE_PREWARD)
    {
        sTypeList = QUEST_PREWARD_TYPE + sStep;
        sKeyList = QUEST_PREWARD_KEY + sStep;
        sValueList = QUEST_PREWARD_VALUE + sStep;
    }
    
    if (sTypeList == "" || sKeyList == "" || sValueList == "")
        return REQUEST_INVALID;

    int nIndex = FindListInt(oQuest, nValueType, sTypeList);
    if (nIndex == -1)
        return REQUEST_INVALID;

    switch (nValueType)
    {
        case QUEST_VALUE_TYPE_ALIGNMENT:
        case QUEST_VALUE_TYPE_CLASS:
        case QUEST_VALUE_TYPE_ITEM:
        case QUEST_VALUE_TYPE_QUEST:
        case QUEST_VALUE_TYPE_RACE:
            return GetListString(oQuest, nIndex, (nComponent == PAIR_KEY ? sKeyList : sValueList));
            break;
        case QUEST_VALUE_TYPE_GOLD:
        case QUEST_VALUE_TYPE_LEVEL_MAX:
        case QUEST_VALUE_TYPE_LEVEL_MIN:
            return GetListString(oQuest, nIndex, sValueList);
            break;
    }

    return REQUEST_INVALID;
}

int SetQuestProperty(string sQuestTag, int nPropertyType, int nValueType, 
                     string sKey, string sValue, int nStep = 0)
{
    if (nPropertyType == QUEST_PROPERTY_TYPE_PREREQUISITE)
        nStep = 0;

    object oQuest = GetQuestDataItem(sQuestTag);
    string sTypeList, sKeyList, sValueList, sStep = "_" + IntToString(nStep);

    if (nPropertyType == QUEST_PROPERTY_TYPE_PREREQUISITE)
    {
        sTypeList = QUEST_PREREQUISITE_TYPE + sStep;
        sKeyList = QUEST_PREREQUISITE_KEY + sStep;
        sValueList = QUEST_PREREQUISITE_VALUE + sStep;
    }
    else if (nPropertyType == QUEST_PROPERTY_TYPE_REWARD)
    {
        sTypeList = QUEST_REWARD_TYPE + sStep;
        sKeyList = QUEST_REWARD_KEY + sStep;
        sValueList = QUEST_REWARD_VALUE + sStep;
    }
    else if (nPropertyType == QUEST_PROPERTY_TYPE_PREWARD)
    {
        sTypeList = QUEST_PREWARD_TYPE + sStep;
        sKeyList = QUEST_PREWARD_KEY + sStep;
        sValueList = QUEST_PREWARD_VALUE + sStep;
    }

    if (sTypeList == "" || sKeyList == "" || sValueList == "")
        return FALSE;

    int nIndex = FindListInt(oQuest, nValueType, sTypeList);
    
    switch (nValueType)
    {
        case QUEST_VALUE_TYPE_ALIGNMENT:
        case QUEST_VALUE_TYPE_CLASS:
        case QUEST_VALUE_TYPE_ITEM:
        case QUEST_VALUE_TYPE_QUEST:
        case QUEST_VALUE_TYPE_RACE:
        {
            string sKeys, sValues;
            if (nIndex != -1)
            {
                sKeys = GetListString(oQuest, nIndex, sKeyList);
                sValues = GetListString(oQuest, nIndex, sValueList);
            }
        
            if (CountList(sKey) == CountList(sValue))
            {
                sKeys = MergeLists(sKeys, sKey);
                sValues = MergeLists(sValues, sValue);
            }
            else
                return FALSE;

            if (nIndex != -1)
            {
                SetListString(oQuest, nIndex, sKeys, sKeyList);
                SetListString(oQuest, nIndex, sValues, sValueList);
            }
            else
            {
                AddListInt   (oQuest, nValueType, sTypeList);
                AddListString(oQuest, sKeys, sKeyList);
                AddListString(oQuest, sValues, sValueList);
            }
            break;
        }
        case QUEST_VALUE_TYPE_GOLD:
        case QUEST_VALUE_TYPE_LEVEL_MAX:
        case QUEST_VALUE_TYPE_LEVEL_MIN:
        case QUEST_VALUE_TYPE_XP:
        {
            if (nIndex != -1)
                SetListString(oQuest, nIndex, sValue, sValueList);
            else
            {
                AddListInt   (oQuest, nValueType, sTypeList);
                AddListString(oQuest, sKey, sKeyList);
                AddListString(oQuest, sValue, sValueList);
            }
            break;
        }
    }

    return TRUE;
}

int GetIsQuestAssignable(object oPC, string sQuestTag)
{
    // Do the easy checks first:
    // If the quest is complete and repeatable, just send yes
    if (GetIsQuestComplete(oPC, sQuestTag) && GetQuestRepetitions(sQuestTag) > 1)
        return TRUE;

    // TODO store a quest completion count on the pc for checking against questrepitition count

    // If the quest is already assigned, can't reassign
    if (GetIsQuestAssigned(oPC, sQuestTag))
        return FALSE;

    // If there are no prerequisites for this quest, assign
    if (!CountStringList(oQuest, QUEST_PREREQUISITE_TYPE))
        return TRUE;

    // Other types not met, check for prerequisites to meet quest assignment
    object oQuest = GetQuestDataItem(sQuestTag);
    int n, nCount = CountIntList(oQuest, QUEST_PREREQUISITE_TYPE);
    int bAssignable = FALSE;
    int bPartyPrerequisites = GetLocalInt(oQuest, QUEST_ALLOW_PARTY_PREREQUISITES);

    for (n = 0; n < nCount; n++)
    {
        int nPrerequisiteType = GetListInt(oQuest, n, QUEST_PREREQUISITE_TYPE);
        string sKeys = GetListString(oQuest, n, QUEST_PREREQUISITE_KEY);
        string sValues = GetListString(oQuest, n, QUEST_PREREQUISITE_VALUE);

        switch (nPrerequisiteType)
        {
            case QUEST_VALUE_TYPE_ALIGNMENT:
            {
                int n, nAxis, nValue, nMeets, nCount = CountList(sKeys);
                int nAlignmentGE = GetAlignmentGoodEvil(oPC);
                int nAlignmentLC = GetAlignmentLawChaos(oPC);

                for (n = 0; n < nCount; n++)
                {
                    nAxis = StringToInt(GetListItem(sKeys, n));
                    nValue = StringToInt(GetListItem(sValues, n));
                    
                    if (nAlignmentGE == nAxis || nAlignmentLC == nAxis)
                        nMeets++;
                }

                if (nMeets == nCount)
                    bAssignable = TRUE;
                else
                    return FALSE;
                break;
            }
            case QUEST_VALUE_TYPE_CLASS:
            {
                int n, nKey, nValue, nCount = CountList(sKeys);
                int nClass1 = GetClassByPosition(1, oPC);
                int nClass2 = GetClassByPosition(2, oPC);
                int nClass3 = GetClassByPosition(3, oPC);
                int nLevels1 = GetLevelByClass(nClass1, oPC);
                int nLevels2 = GetLevelByClass(nClass2, oPC);
                int nLevels3 = GetLevelByClass(nClass3, oPC);
                
                for (n = 0; n < nCount; n++);
                {
                    nKey = StringToInt(GetListItem(sKeys, n));
                    nValue = StringToInt(GetListItem(sValues, n));

                    switch (nValue)
                    {
                        case -1:  // Any number of levels in specified class
                            if (nClass1 == nKey || nClass2 == nKey || nClass3 == nKey)
                                bAssignable = TRUE;
                            break;
                        case 0:   // No levels in specific class
                            if (nClass1 == nKey || nClass2 == nKey || nClass3 == nKey)
                                return FALSE;
                            break;
                        default:  // Specific number or more of levels in a specified class
                            if (nClass1 == nKey && nLevels1 >= nValue)
                                bAssignable == TRUE;
                            else if (nClass2 == nKey && nLevels2 >= nValue)
                                bAssignable == TRUE;
                            else if (nClass3 == nKey && nLevels3 >= nValue)
                                bAssignable == TRUE;
                            else
                                return FALSE;
                    }
                }
                break;
            }
            case QUEST_VALUE_TYPE_GOLD:
            {   // Mandata, no meet = FALSE
                int nValue = StringToInt(sValues);
                if (GetGold(oPC) >= nValue)
                    bAssignable = TRUE;
                else
                    return FALSE;
                break;
            }
            case QUEST_VALUE_TYPE_LEVEL_MIN:
            {   // Mandate, no meet = FALSE
                int nValue = StringToInt(sValues);
                if (GetHitDice(oPC) >= nValue)
                    bAssignable = TRUE;
                else
                    return FALSE;
                break;
            }
            case QUEST_VALUE_TYPE_LEVEL_MAX:
            {   // Mandate, no meet = FALSE
                int nValue = StringToInt(sValues);
                if (GetHitDice(oPC) <= nValue)
                    bAssignable = TRUE;
                else
                    return FALSE;
                break;
            }
            case QUEST_VALUE_TYPE_QUEST:
            {   // && must meet all
                int n, nCount = CountList(sValues);
                string sQuest;

                for (n = 0; n < nCount; n++)
                {
                    sQuest = GetListItem(sValues, n);
                    if (GetIsQuestComplete(oPC, sQuest))
                        bAssignable = TRUE;
                    else
                        return FALSE;
                }
                break;
            }
            case QUEST_VALUE_TYPE_RACE:
            {   // Since players are only one race, this is an OR || unless excluded
                int n, nPC, nRace, bInclude, nCount = CountList(sKeys);
                for (n = 0; n < nCount; n++)
                {
                    nPC = GetRacialType(oPC);
                    nRace = StringToInt(GetListItem(sKeys, n));
                    bInclude = StringToInt(GetListItem(sValues, n));

                    if (nPC == nRace)
                    {
                        if (bInclude)
                        {
                            bAssignable = TRUE;
                            break;
                        }
                        else
                            return FALSE;
                    }
                }
                break;
            }        
            case QUEST_VALUE_TYPE_ITEM:
            {
                string sItem;
                int n, nQuantity, nCount = CountList(sKeys);
                for (n = 0; n < nCount; n++)
                {
                    sItem = GetListItem(sKeys, n);
                    nQuantity = StringToInt(GetListItem(sValues, n));

                    if (nQuantity == 0)
                    {
                        if (GetIsObjectValid(GetItemPossessedBy(oPC, sItem)))
                            return FALSE;
                    }
                    else if (nQuantity == 1)
                    {
                        if (GetIsObjectValid(GetItemPossessedBy(oPC, sItem)))
                            bAssignable = TRUE;
                    }
                    else if (nQuantity > 1)
                    {
                        if (HasMinimumItemCount(oPC, sItem, nQuantity, bPartyPrerequisites)
                            bAssignable = TRUE;
                    }
                }

                break;
            }
        }
    }
    
    return bAssignable;
}

///////////////////////////// PREREQUISITE CONVENIENCE /////////////////////////////////

void SetQuestPrerequisiteRace(string sQuestTag, int nRace, int bInclude = TRUE)
{
    string sRace = IntToString(nRace);
    string sInclude = IntToString(bInclude);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_RACE, sRace, sInclude);
}

void SetQuestPrerequisiteLevelMin(string sQuestTag, int nLevel)
{
    string sLevel = IntToString(nLevel);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_LEVEL_MIN, "", sLevel);
}

void SetQuestPrerequisiteLevelMax(string sQuestTag, int nLevel)
{
    string sLevel = IntToString(nLevel);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_LEVEL_MAX, "", sLevel);
}

void SetQuestPrerequisiteClass(string sQuestTag, int nClass, int nLevels = 1)
{
    string sClass = IntToString(nClass);
    string sLevels = IntToString(nLevels);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_CLASS, sClass, sLevels);
}

void SetQuestPrerequisiteGold(string sQuestTag, int nGold)
{
    string sGold = IntToString(nGold);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_GOLD, "", sGold);
}

void SetQuestPrerequisiteAlignment(string sQuestTag, int nAxis)
{
    string sAxis = IntToString(nAxis);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_ALIGNMENT, sAxis, "");
}

void SetQuestPrerequisiteQuest(string sQuestTag, string sPrereqQuestTag)
{
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_QUEST, sPrereqQuestTag, "");
}

void SetQuestPrerequisiteItem(string sQuestTag, string sResref, int nQuantity = 1)
{
    string sQuantity = IntToString(nQuantity);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_PREREQUISITE, QUEST_VALUE_TYPE_ITEM, sResref, sQuantity);
}

///////////////////////////// REWARD CONVENIENCE /////////////////////////////////
////// ITEM REWARD STUFF ////////
string GetQuestRewardItemKeys(string sQuestTag, int nStep = 0)
{
    return GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, PAIR_KEY, nStep);
}

string GetQuestRewardItemValues(string sQuestTag, int nStep = 0)
{
    return GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, PAIR_VALUE, nStep);
}

int CountQuestRewardItems(string sQuestTag, int nStep = 0)
{
    return CountList(GetQuestRewardItemKeys(sQuestTag, nStep));
}

string GetQuestRewardItemResref(string sQuestTag, int nIndex = 0, int nStep = 0)
{
    string sKeys = GetQuestRewardItemKeys(sQuestTag, nStep);
    return GetListItem(sKeys, nIndex);
}

int GetQuestRewardItemQuantity(string sQuestTag, int nIndex = 0, int nStep = 0)
{
    string sValues = GetQuestRewardItemValues(sQuestTag, nStep);
    return StringToInt(GetListItem(sValues, nIndex));
}

void SetQuestRewardItem(string sQuestTag, string sResref, int nQuantity = 1, int nStep = 0)
{
    string sQuantity = IntToString(nQuantity);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, sResref, sQuantity, nStep);
}

void SetQuestRewardItems(string sQuestTag, string sResref, string sQuantity, int nStep = 0)
{
    if (CountList(sResref) == CountList(sQuantity))
        SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, sResref, sQuantity, nStep);
}

//// GOLD REWARD STUFF ///////

int GetQuestRewardGold(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_GOLD, PAIR_VALUE, nStep));
}

void SetQuestRewardGold(string sQuestTag, int nGold, int nStep = 0)
{   
    string sGold = IntToString(nGold);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_GOLD, "", sGold, nStep);
}

////// XP REWARD STUFF //////

int GetQuestRewardXP(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_XP, PAIR_VALUE, nStep));
}

void SetQuestRewardXP(string sQuestTag, int nXP, int nStep = 0)
{
    string sXP = IntToString(nXP);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_XP, "", sXP, nStep);
}

//// ALIGNMENT REWARD STUFF /////
int GetQuestRewardAlignmentAxis(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ALIGNMENT, PAIR_KEY, nStep));
}

int GetQuestRewardAlignmentShift(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ALIGNMENT, PAIR_VALUE, nStep));
}

void SetQuestRewardAlignment(string sQuestTag, int nAxis, int nShift, int nStep = 0)
{
    if (nShift < 0)
    {
        switch (nAxis)
        {
            case ALIGNMENT_EVIL:
                nAxis = ALIGNMENT_GOOD;
                break;
            case ALIGNMENT_GOOD:
                nAxis = ALIGNMENT_EVIL;
                break;
            case ALIGNMENT_CHAOTIC:
                nAxis = ALIGNMENT_LAWFUL;
                break;
            case ALIGNMENT_LAWFUL:
                nAxis = ALIGNMENT_CHAOTIC;
                break;
        }

        nShift = abs(nShift);
    }

    string sAxis = IntToString(nAxis);
    string sShift = IntToString(nShift);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ALIGNMENT, sAxis, sShift, nStep);
}

///////////////////////////// PREWARD CONVENIENCE /////////////////////////////////
////// ITEM PREWARD STUFF ////////
string GetQuestPrewardItemKeys(string sQuestTag, int nStep = 0)
{
    return GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, PAIR_KEY, nStep);
}

string GetQuestPrewardItemValues(string sQuestTag, int nStep = 0)
{
    return GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, PAIR_VALUE, nStep);
}

int CountQuestPrewardItems(string sQuestTag, int nStep = 0)
{
    return CountList(GetQuestRewardItemKeys(sQuestTag, nStep));
}

string GetQuestPrewardItemResref(string sQuestTag, int nIndex = 0, int nStep = 0)
{
    string sKeys = GetQuestRewardItemKeys(sQuestTag, nStep);
    return GetListItem(sKeys, nIndex);
}

int GetQuestPrewardItemQuantity(string sQuestTag, int nIndex = 0, int nStep = 0)
{
    string sValues = GetQuestRewardItemValues(sQuestTag, nStep);
    return StringToInt(GetListItem(sValues, nIndex));
}

void SetQuestPrewardItem(string sQuestTag, string sResref, int nQuantity = 1, int nStep = 0)
{
    string sQuantity = IntToString(nQuantity);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, sResref, sQuantity, nStep);
}

void SetQuestPrewardItems(string sQuestTag, string sResref, string sQuantity, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE)
{
    if (CountList(sResref) == CountList(sQuantity))
        SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ITEM, sResref, sQuantity, nStep);
}

//// GOLD PREWARD STUFF ///////

int GetQuestPrewardGold(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_GOLD, PAIR_VALUE, nStep));
}

void SetQuestPrewardGold(string sQuestTag, int nGold, int nStep = 0)
{   
    string sGold = IntToString(nGold);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_GOLD, "", sGold, nStep);
}

////// XP PREWARD STUFF //////

int GetQuestPrewardXP(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_XP, PAIR_VALUE, nStep));
}

void SetQuestPrewardXP(string sQuestTag, int nXP, int nStep = 0)
{
    string sXP = IntToString(nXP);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_XP, "", sXP, nStep);
}

//// ALIGNMENT PREWARD STUFF /////
int GetQuestPrewardAlignmentAxis(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ALIGNMENT, PAIR_KEY, nStep));
}

int GetQuestPrewardAlignmentShift(string sQuestTag, int nStep = 0)
{
    return StringToInt(GetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ALIGNMENT, PAIR_VALUE, nStep));
}

void SetQuestPrewardAlignment(string sQuestTag, int nAxis, int nShift, int nStep = 0)
{
    if (nShift < 0)
    {
        switch (nAxis)
        {
            case ALIGNMENT_EVIL:
                nAxis = ALIGNMENT_GOOD;
                break;
            case ALIGNMENT_GOOD:
                nAxis = ALIGNMENT_EVIL;
                break;
            case ALIGNMENT_CHAOTIC:
                nAxis = ALIGNMENT_LAWFUL;
                break;
            case ALIGNMENT_LAWFUL:
                nAxis = ALIGNMENT_CHAOTIC;
                break;
        }

        nShift = abs(nShift);
    }

    string sAxis = IntToString(nAxis);
    string sShift = IntToString(nShift);
    SetQuestProperty(sQuestTag, QUEST_PROPERTY_TYPE_REWARD, QUEST_VALUE_TYPE_ALIGNMENT, sAxis, sShift, nStep);
}

////////////////// END PREWARD CONVENIENCE /////////////////

//////// JOURNAL ENTRY STUFF, where does this go? ////////
/// With step creation? ////////////

string GetQuestJournalEntry(string sQuestTag, int nStep = 0)
{
    string sJournalEntry = GetQuestEntry(sQuestTag, QUEST_JOURNAL_ENTRY, nStep);
    return sJournalEntry;
}


void SetQuestJournalEntry(string sQuestTag, string sJournalEntry, int nStep = 0)
{
    SetQuestEntry(sQuestTag, QUEST_JOURNAL_ENTRY, sJournalEntry, nStep);
}

struct NWNX_Player_JournalEntry CreateNWNXJournalEntryStruct(object oPC, string sQuestTag)
{
    struct NWNX_Player_JournalEntry je;

    je.sName = "";
    je.sText = "";
    je.sTag = "";
    je.nState = 0;
    je.nPriority = 0;
    je.nQuestCompleted = 0;
    je.nQuestDisplayed = 0;
    je.nUpdated = 0;
    je.nCalendarDay = 0;
    je.nTimeOfDay = 0;

    return je;
}

// Assigns a quest to a PC object
int AssignQuest(object oPC, string sQuestTag)
{
    if (GetIsQuestAssignable(oPC, sQuestTag))
    {
        if (AddListString(oPC, sQuestTag, QUEST_ASSIGNED, TRUE))
        {
            AddListString(oPC, "", QUEST_STATUS);
            AddListString(oPC, GetSystemTime(), QUEST_TIME_ASSIGNED);
            AddListInt   (oPC, 0, QUEST_COMPLETION_COUNT);
        }
        else
        {
            int nIndex = FindListString(oPC, sQuestTag, QUEST_ASSIGNED);
            SetListString(oPC, nIndex, "", QUEST_STATUS);
            SetListString(oPC, nIndex, GetSystemTime(), QUEST_TIME_ASSIGNED);
        }

        string sScript = GetQuestOnAcceptScript(sQuestTag);
        RunLibraryScript(sScript, oPC);

        return TRUE;

    }
    else
        return FALSE;
}

// Deletes quest from PC object
void UnassignQuest(object oPC, string sQuestTag)
{
    int nIndex = GetQuestIndex(oPC, sQuestTag);

    if (nIndex != -1)
    {
        DeleteListString(oPC, nIndex, QUEST_ASSIGNED);
        DeleteListString(oPC, nIndex, QUEST_STATUS);
        DeleteListString(oPC, nIndex, QUEST_TIME_ASSIGNED);
        DeleteListInt   (oPC, nIndex, QUEST_COMPLETION_COUNT);
    }
}

int GetCurrentStep(object oPC, string sQuestTag)
{
    int nIndex = GetQuestIndex(oPC, sQuestTag);

    if (nIndex != -1)
    {
        sStatus = GetListString(oPC, nIndex, QUEST_STATUS);
        return CountList(sStatus);
    }
    else
        return OPERATION_INVALID;

    return 0;
}

// TODO RestoreJournalEntries (after login)
void RestoreJournalEntries(object oPC)
{
    int n, nStep, nCount = CountStringList(oPC, QUEST_ASSIGNED);
    string sQuestTag, sJournalEntry;

    for (n = 0; n < nCount; n++)
    {
        sQuestTag = GetListString(oPC, n, QUEST_ASSIGNED);
        nStep = GetCurrentStep(oPC, sQuestTag);
        sJournalEntry = GetQuestJournalEntry(sQuestTag, nStep);
        // TODO etc.
    }

    // Loop each quest
    // Get state/journal entry for the current step of each quest
    // Set the correct journal entry
}

int HasKilledObjective(object oPC, object oKiller, int bAllowPartyCompletion = FALSE)
{
    if (oPC == oKiller)
        return TRUE;

    if (bAllowPartyCompletion)
    {  
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            if (oPartyMember == oKiller)
                return TRUE;

            oPartyMember = GetNextFactionMember(oPC, TRUE)
        }

        object oPartyMember = GetFirstFactionMember(oPC, FALSE);
        while (GetIsObjectValid(oPartyMember))
        {
            if (oPartyMember == oKiller)
                return TRUE;

            oPartyMember = GetNextFactionMember(oPC, FALSE);
        }
    }
    
    return FALSE;
}

// TODO advance the quest step, running the 
void AdvanceQuestStep(object oPC, string sQuestTag)
{
    // This function evaluates step completion based on step objective
    object oQuest = GetQuestDataItem(sQuestTag);
    int nStep = GetCurrentStep(oPC, sQuestTag);
    int nIndex = GetQuestStepIndex(sQuestTag, nStep);

    string sObjective = GetListString(oQuest, nIndex, QUEST_OBJECTIVE);
    int nObjectiveType = StringToInt(GetListItem(sObjective, 0));
    string sTag1 = GetListItem(sObjective, 1);
    int nQuantity = StringToInt(GetListItem(sObjective, 2));
    string sTag2 = GetListItem(sObjective, 3);

    int bAllowPartyCompletion = GetListInt(oQuest, nIndex, QUEST_PARTY_COMPLETION);

    if (nObjectiveType == QUEST_OBJECTIVE_TYPE_GATHER)
    {
        // Expected to be called from acquireitem event?
        if (HasMinimumItemCount(oPC, sTag1, nQuantity1, bAllowPartyCompletion))
            Error(""); // TODO yes, advance
    }
    else if (nObjectiveType == QUEST_OBJECTIVE_TYPE_DELIVER)
    {
        // Expected to be called from unacquire event?

    }
    else if (nObjectiveType = QUEST_OBJECTIVE_TYPE_KILL)
    {
        // Expected from oncreaturedeath event?
        object oKiller = GetLastKiller(OBJECT_SELF);
        
        if (HasKilledObjective(oPC, oKiller, bAllowPartyCompletion))
            Error(""); // check the number, and advance or complete

        

        // If partycompletion, loop members and if assigned quest and on
        // correct step, add kills.

    }



}

void main(){}
