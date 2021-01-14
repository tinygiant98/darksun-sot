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



// -----------------------------------------------------------------------------
//                      LEAVE EVERYTHING BELOW HERE ALONE!
// -----------------------------------------------------------------------------

// Datapoint Object
object QUESTS = GetDatapoint("QUEST_DATA");

// Quest Identification Variable Names
const string QUEST_ID = "QUEST_ID";
const string NEXT_QUEST_ID = "NEXT_QUEST_ID";
const string QUEST_TAG = "QUEST_TAG";
const string QUEST_TITLE = "QUEST_TITLE";

// Quest Properties Variable Names
const string QUEST_ALLOW_RANDOM_ORDER = "QUEST_ALLOW_RANDOM_ORDER";
const string QUEST_ACTIVE = "QUEST_ACTIVE";
const string QUEST_REPETITIONS = "QUEST_REPITITIONS";
const string QUEST_OBJECTIVE_TYPE = "QUEST_OBJECTIVE_TYPE";
const string SCRIPT_ON_ACCEPT = "SCRIPT_ON_ACCEPT";
const string SCRIPT_ON_ADVANCE = "SCRIPT_ON_ADVANCE";
const string SCRIPT_ON_COMPLETE = "SCRIPT_ON_COMPLETE";

// Quest Data Variable Names (on PC Object)
const string QUESTS_ASSIGNED = "QUESTS_ASSIGNED";
const string QUEST_STATE = "QUEST_STATE";

// Quest Pseudo-Array List Names
const string QUEST_STEP = "QUEST_STEP";
const string QUEST_JOURNAL_ENTRY = "QUEST_JOURNAL_ENTRY";
const string REWARD_TYPE_GOLD = "REWARD_TYPE_GOLD";
const string REWARD_TYPE_XP = "REWARD_TYPE_XP";
const string REWARD_TYPE_ITEM = "REWARD_TYPE_ITEM";
const string REWARD_TYPE_ALIGNMENT = "REWARD_TYPE_ALIGNMENT";

// Quest Reward Bitmasks
const int REWARD_ALL = 0x00;
const int REWARD_GOLD = 0x01;
const int REWARD_XP = 0x02;
const int REWARD_ITEM = 0x04;
const int REWARD_ALIGNMENT = 0x08;

// Quest Reward Quantity Operations
const int QUEST_OPERATION_REPLACE = 0;
const int QUEST_OPERATION_ADD = 1;

// Quest Entry Validity
const string QUANTITY_INVALID = "QUANTITY_INVALID";
const string QUEST_INVALID = "QUEST_INVALID";

// Quest Objective Types
const int QUEST_OBJECTIVE_GATHER = 1;
const int QUEST_OBJECTIVE_KILL = 2;
const int QUEST_OBJECTIVE_DELIVER = 3;
const int QUEST_OBJECTIVE_ESCORT = 4;
const int QUEST_OBJECTIVE_CAPTURE = 5;
const int QUEST_OBJECTIVE_SPEAK = 6;

// Quest Status
const int QUEST_ASSIGNED = 0;
const int QUEST_COMPLETE = -1;
const int QUEST_NOT_ASSIGNED = -2;
//const int nQUEST_INVALID = -3

// Quest Prerequisite Types
const int QUEST_PREREQUISITE_RACE = 1;
const int QUEST_PREREQUISITE_LEVEL_MIN = 2;
const int QUEST_PREREQUISITE_CLASS = 3;
const int QUEST_PREREQUISITE_GOLD = 4;
const int QUEST_PREREQUISITE_ALIGNMENT = 5;
const int QUEST_PREREQUISITE_QUEST = 6;
const int QUEST_PREREQUISITE_LEVEL_MAX = 7;
const int QUEST_PREREQUISITE_ITEM = 8;

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

// ---< GetQuestRewardItems >---
// Gets a comma-delimited string of key:value pairs that represent
// quest reward items and quantities -> resref:qty[,resref:qty...]
string GetQuestRewardItems(string sQuestTag, int nStep = 0);

// ---< GetQuestRewardItem >---
// Gets a specific key:value pair that represents a single quest
// reward items at index nItemIndex.
string GetQuestRewardItem(string sQuestTag, int nItemIndex, int nStep = 0);

// ---< SetQuestRewardItem >---
// Sets a specified item and quantity as a reward for completing a quest or
// quest step.
void SetQuestRewardItem(string sQuestTag, string sResref, int nQuantity = 1, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE);

// ---< SetQuestRewardItems >---
// Accepts a comma-delimited list of key:value pairs that define a set of item
// rewards and quantities to be awarded upon completion of a specific quest or
// quest step. This function is advanced usage.
void SetQuestRewardItems(string sQuestTag, string sItemPairs, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE);

// ---< CountQuestRewardItems >----
// Returns the count of quest reward items
int CountQuestRewardItems(string sQuestTag, int nStep = 0);

// ---< GetQuestRewardItemResref >---
// Returns the resref of a specified item reward
string GetQuestRewardItemResref(string sQuestTag, int nItemIndex = 0, int nStep = 0);

// ---< GetQuestRewardItemQuantity >---
// Returns the quantity associated with a specified item reward
int GetQuestRewardItemQuantity(string sQuestTag, int nItemIndex = 0, int nStep = 0);

// ---< [Get|Set]QuestGoldReward >---
// Gets/Sets a gold reward for completing a quest or a quest step
int GetQuestGoldReward(string sQuestTag, int nStep = 0);
void SetQuestGoldReward(string sQuestTag, int nGold, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE);

// ---< [Get|Set]QuestXPReward >---
// Gets/Sets an xp reward for completing a quest or a quest step
int GetQuestXPReward(string sQuestTag, int nStep = 0);
void SetQuestXPReward(string sQuestTag, int nXP, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE);

// ---< [Get|Set]QuestJournalEntry >---
// Gets/Sets a journal entry for a quest or quest step
string GetQuestJournalEntry(string sQuestTag, int nStep = 0);
void SetQuestJournalEntry(string sQuestTag, string sJournalEntry, int nStep = 0);

// ---< GetQuestAlignmentReward[Axis|Shift] >---
// Returns the alignment reward axis (as an ALIGNMENT_* constant) or the amount of the
// alignment shift
int GetQuestAlignmentRewardAxis(string sQuestTag, int nStep = 0);
int GetQuestAlignmentRewardShift(string sQuestTag, int nStep = 0);

// ---< SetQuestAlignmentReward >---
// Sets an alignment reward for completing a quest or quest step
void SetQuestAlignmentReward(string sQuestTag, int nAxis, int nShift, int nStep = 0);

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

// ---< GetKey >---
// Returns the key portion of key:value pair sPair; if the sSeparator is
//  not found, returns sPair
string GetKey(string sPair, string sSeparator = ":")
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, sSeparator)) == -1)
        return sPair;
    else
        return GetSubString(sPair, 0, nIndex);
}

// ---< GetValue >---
// Returns the value portion of key:value pair sPair; if the sSeparator is
// not found, returns sDefault
string GetValue(string sPair, string sDefault = QUANTITY_INVALID, string sSeparator = ":")
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, sSeparator)) == -1)
        return sDefault;
    else
        return GetSubString(sPair, ++nIndex, GetStringLength(sPair));
}

// ---< GetNextQuestID >---
// Returns the next available quest ID
int GetNextQuestID()
{
    return IncrementLocalInt(NEXT_QUEST_ID);
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
        Error("Attempt to get a quest reward for a step that does not exist" +
              "\n  sQuestTag -> " + sQuestTag +
              "\n  sEntryType -> " + sEntryType +
              "\n  nStep -> " + IntToString(nStep));
        return QUEST_INVALID;
    }
    
    return GetListString(oQuest, nIndex, sEntryType);
}

void AddQuestStep(string sQuestTag, int nStep = 0)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    
    if (AddListInt(oQuest, nStep, QUEST_STEP, TRUE))
    {
        AddListInt   (oQuest, 0, QUEST_OBJECTIVE_TYPE, 0);
        AddListString(oQuest, "", QUEST_JOURNAL_ENTRY);
        AddListString(oQuest, "", REWARD_TYPE_GOLD);
        AddListString(oQuest, "", REWARD_TYPE_XP);
        AddListString(oQuest, "", REWARD_TYPE_ITEM);
        AddListString(oQuest, "", REWARD_TYPE_ALIGNMENT);
    }
    else
        Warning("Attempted to add step " + IntToString(nStep) + " to " + sQuestTag + "; " +
                "step already exists, no action taken");
}

// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

int AddQuest(string sQuestTag, string sQuestTitle)
{
    if (sQuestTag == "")
    {
        Error("Unable to create quest; sQuestTag is an empty string");
        return FALSE;
    }

    // TODO see what datapoint already sets and use that
    object oQuest = GetQuestDataItem(sQuestTag);
    int nNextID = GetNextQuestID();

    SetLocalInt(oQuest, QUEST_ID, nNextID);
    SetLocalString(oQuest, QUEST_TAG, sQuestTag);
    SetLocalString(oQuest, QUEST_TITLE, sQuestTitle);

    // Set default quest properties
    SetLocalInt(oQuest, QUEST_ACTIVE, TRUE);
    SetLocalInt(oQuest, QUEST_REPETITIONS, 1);
    SetLocalInt(oQuest, QUEST_ALLOW_RANDOM_ORDER, FALSE);

    return nNextID;
}

void DeleteQuest(string sQuestTag)
{
    DeleteQuestDataItem(sQuestTag);
}

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

string GetQuestRewardItems(string sQuestTag, int nStep = 0)
{
    return GetQuestEntry(sQuestTag, REWARD_TYPE_ITEM, nStep);
}

string GetQuestRewardItem(string sQuestTag, int nItemIndex, int nStep = 0)
{
    string sItems = GetQuestRewardItems(sQuestTag, nStep);
    return GetListItem(sItems, nItemIndex);
}

void SetQuestRewardItem(string sQuestTag, string sResref, int nQuantity = 1, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE)
{
    string sRewards, sReward = sResref + ":" + IntToString(nQuantity);

    if (nOperation == QUEST_OPERATION_ADD)
    {
        sRewards = GetQuestRewardItems(sQuestTag, nStep);
        sRewards = AddListItem(sRewards, sReward);
    }
    else
        sRewards = sReward;

    SetQuestEntry(sQuestTag, REWARD_TYPE_ITEM, sRewards, nStep);
}

void SetQuestRewardItems(string sQuestTag, string sItemPairs, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE)
{
    string sRewards;

    if (nOperation = QUEST_OPERATION_ADD)
    {
        sRewards = GetQuestRewardItems(sQuestTag, nStep);
        sRewards = MergeLists(sRewards, sItemPairs);
    }
    else
        sRewards = sItemPairs;

    SetQuestEntry(sQuestTag, REWARD_TYPE_ITEM, sRewards, nStep = 0);
}

int CountQuestRewardItems(string sQuestTag, int nStep = 0)
{
    return CountList(GetQuestRewardItems(sQuestTag, nStep));
}

string GetQuestRewardItemResref(string sQuestTag, int nItemIndex = 0, int nStep = 0)
{
    string sItemPair = GetQuestRewardItem(sQuestTag, nItemIndex, nStep);
    return GetKey(sItemPair);
}

int GetQuestRewardItemQuantity(string sQuestTag, int nItemIndex = 0, int nStep = 0)
{
    string sItemPair = GetQuestRewardItem(sQuestTag, nItemIndex, nStep);
    string sValue = GetValue(sItemPair, QUANTITY_INVALID);
    
    if (sValue == QUANTITY_INVALID)
        return 1;
    else
        return StringToInt(sValue);
}

int GetQuestGoldReward(string sQuestTag, int nStep = 0)
{
    string sGold = GetQuestEntry(sQuestTag, REWARD_TYPE_GOLD, nStep);
    return StringToInt(sGold);
}

void SetQuestGoldReward(string sQuestTag, int nGold, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE)
{   
    if (nOperation == QUEST_OPERATION_ADD)
        nGold += GetQuestGoldReward(sQuestTag, nStep);

    SetQuestEntry(sQuestTag, REWARD_TYPE_GOLD, IntToString(nGold), nStep);
}

int GetQuestXPReward(string sQuestTag, int nStep = 0)
{
    string sXP = GetQuestEntry(sQuestTag, REWARD_TYPE_XP, nStep);
    return StringToInt(sXP);
}

void SetQuestXPReward(string sQuestTag, int nXP, int nStep = 0, int nOperation = QUEST_OPERATION_REPLACE)
{
    if (nOperation == QUEST_OPERATION_ADD)
        nXP += GetQuestXPReward(sQuestTag, nStep);

    SetQuestEntry(sQuestTag, REWARD_TYPE_XP, IntToString(nXP), nStep);
}

string GetQuestJournalEntry(string sQuestTag, int nStep = 0)
{
    return GetQuestEntry(sQuestTag, QUEST_JOURNAL_ENTRY, nStep);
}

void SetQuestJournalEntry(string sQuestTag, string sJournalEntry, int nStep = 0)
{
    SetQuestEntry(sQuestTag, QUEST_JOURNAL_ENTRY, sJournalEntry, nStep);
}

int GetQuestAlignmentRewardAxis(string sQuestTag, int nStep = 0)
{
    string sEntry = GetQuestEntry(sQuestTag, REWARD_TYPE_ALIGNMENT, nStep);
    return StringToInt(GetKey(sEntry));
}

int GetQuestAlignmentRewardShift(string sQuestTag, int nStep = 0)
{
    string sEntry = GetQuestEntry(sQuestTag, REWARD_TYPE_ALIGNMENT, nStep);
    return StringToInt(GetValue(sEntry));
}

void SetQuestAlignmentReward(string sQuestTag, int nAxis, int nShift, int nStep = 0)
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

        nAxis = abs(nAxis);
    }

    string sEntry = IntToString(nAxis) + ":" + IntToString(nShift);
    SetQuestEntry(sQuestTag, REWARD_TYPE_ALIGNMENT, sEntry, nStep);
}

string GetQuestOnAcceptScript(string sQuestTag)
{
    return GetQuestPropertyString(sQuestTag, SCRIPT_ON_ACCEPT);
}

void SetQuestOnAcceptScript(string sQuestTag, string sScript)
{
    SetQuestPropertyString(sQuestTag, SCRIPT_ON_ACCEPT, sScript);
}

string GetQuestOnCompleteScript(string sQuestTag)
{
    return GetQuestPropertyString(sQuestTag, SCRIPT_ON_COMPLETE);
}

void SetQuestOnCompleteScript(string sQuestTag, string sScript)
{
    SetQuestPropertyString(sQuestTag, SCRIPT_ON_COMPLETE, sScript);
}

string GetQuestOnAdvanceScript(string sQuestTag)
{
    return GetQuestPropertyString(sQuestTag, SCRIPT_ON_ADVANCE);
}

void SetQuestOnAdvanceScript(string sQuestTag, string sScript)
{
    SetQuestPropertyString(sQuestTag, SCRIPT_ON_ADVANCE, sScript);
}

int FindQuestPrerequisite(string sQuestTag, int nPrerequisiteType)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    return FindListInt(oQuest, nPrerequisiteType, "QUEST_PREREQ_TYPE");
}


int GetIsQuestAssigned(object oPC, string sQuestTag)
{
    return FindListString(oPC, sQuestTag, QUESTS_ASSIGNED) != -1;
}

int CountQuestSteps(string sQuestTag)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    return CountIntList(oQuest, QUEST_STEP);
}

int GetQuestIndex(object oPC, string sQuestTag)
{
    return FindListString(oPC, sQuestTag, QUESTS_ASSIGNED);
}
   
int GetIsQuestComplete(object oPC, string sQuestTag, int nStep = 0)
{
    int nIndex = GetQuestIndex(oPC, sQuestTag);
    string sQuestStatus = GetListString(oPC, nIndex, QUEST_STATE);

    int nQuestSteps = CountQuestSteps(sQuestTag);
    int nCompletedSteps = CountList(sQuestStatus);

    if (!nStep)
        return nCompletedSteps == nQuestSteps;
    else
        return HasListItem(sQuestStatus, IntToString(nStep));
}

// Prerequisite Stuff
void SetQuestPrerequisite(string sQuestTag, int nPrerequisiteType, string sKey, string sValue)
{
    object oQuest = GetQuestDataItem(sQuestTag);
    int nIndex = FindQuestPrerequisite(sQuestTag, nPrerequisiteType);

    // TODO, do this by type to add csv lists?
    switch (nPrerequisiteType)
    {
        case QUEST_PREREQUISITE_ALIGNMENT:
        case QUEST_PREREQUISITE_CLASS:
        case QUEST_PREREQUISITE_ITEM:
        case QUEST_PREREQUISITE_QUEST:
        case QUEST_PREREQUISITE_RACE:
        {
            string sKeys, sValues;
            if (nIndex != -1)
            {
                // Type already exists add it?
                sKeys = GetListString(oQuest, nIndex, "QUEST_PREREQ_KEY");
                sValues = GetListString(oQuest, nIndex, "QUEST_PREREQ_VALUE");
            }
        
            sKeys = MergeLists(sKeys, sKey);
            sValues = MergeLists(sValues, sValue);

            if (nIndex != -1)
            {
                SetListString(oQuest, nIndex, sKeys, "QUEST_PREREQ_KEY");
                SetListString(oQuest, nIndex, sValues, "QUEST_PREREQ_VALUE");
            }
            else
            {
                AddListInt   (oQuest, nPrerequisiteType, "QUEST_PREREQ_TYPE");
                AddListString(oQuest, sKeys, "QUEST_PREREQ_KEY");
                AddListString(oQuest, sValues, "QUEST_PREREQ_VALUE");
            }
            break;
        }
        case QUEST_PREREQUISITE_GOLD:
        case QUEST_PREREQUISITE_LEVEL_MAX:
        case QUEST_PREREQUISITE_LEVEL_MIN:
        {
            if (nIndex != -1)
                SetListString(oQuest, nIndex, sValue, "QUEST_PREREQ_VALUE");
            else
            {
                AddListInt   (oQuest, nPrerequisiteType, "QUEST_PREREQ_TYPE");
                AddListString(oQuest, sKey, "QUEST_PREREQ_KEY");
                AddListString(oQuest, sValue, "QUEST_PREREQ_VALUE");
            }
            break;
        }
    }
}

int GetIsQuestAssignable(object oPC, string sQuestTag)
{
    // Do the easy checks first:
    // If the quest is complete and repeatable, just send yes
    if (GetIsQuestComplete(oPC, sQuestTag) && GetQuestRepetitions(sQuestTag) > 1)
        return TRUE;

    // If the quest is already assigned, can't reassign
    if (GetIsQuestAssigned(oPC, sQuestTag))
        return FALSE;

    // Other types not met, check for prerequisites to meet quest assignment
    object oQuest = GetQuestDataItem(sQuestTag);
    int n, nCount = CountIntList(oQuest, "QUEST_PREREQ_TYPE");
    int bAssignable = FALSE;

    for (n = 0; n < nCount; n++)
    {
        int nPrerequisiteType = GetListInt(oQuest, n, "QUEST_PREREQ_TYPE");
        string sKeys = GetListString(oQuest, n, "QUEST_PREREQ_KEY");
        string sValues = GetListString(oQuest, n, "QUEST_PREREQ_VALUE");

        switch (nPrerequisiteType)
        {
            case QUEST_PREREQUISITE_ALIGNMENT:
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
            case QUEST_PREREQUISITE_CLASS:
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
            case QUEST_PREREQUISITE_GOLD:
            {   // Mandata, no meet = FALSE
                int nValue = StringToInt(sValues);
                if (GetGold(oPC) >= nValue)
                    bAssignable = TRUE;
                else
                    return FALSE;
                break;
            }
            case QUEST_PREREQUISITE_LEVEL_MIN:
            {   // Mandate, no meet = FALSE
                int nValue = StringToInt(sValues);
                if (GetHitDice(oPC) >= nValue)
                    bAssignable = TRUE;
                else
                    return FALSE;
                break;
            }
            case QUEST_PREREQUISITE_LEVEL_MAX:
            {   // Mandate, no meet = FALSE
                int nValue = StringToInt(sValues);
                if (GetHitDice(oPC) <= nValue)
                    bAssignable = TRUE;
                else
                    return FALSE;
                break;
            }
            case QUEST_PREREQUISITE_QUEST:
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
            case QUEST_PREREQUISITE_RACE:
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
            case QUEST_PREREQUISITE_ITEM:
            {
                int n, nCount = CountList(sKeys);
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
                        int nItemCount = 0;
                        object oItem = GetFirstItemInInventory(oPC);

                        while (GetIsObjectValid(oItem))
                        {
                            if (GetTag(oItem) == sKey)
                                nItemCount += GetNumStackedItems(oItem);

                            if (nItemCount >= nValue)
                            {
                                bAssignable = TRUE;
                                break;
                            }

                            oItem = GetNextItemInInventory(oPC);
                        }
                    }
                }

                break;
            }
        }
    }
    
    return bAssignable;
}

void SetQuestPrerequisiteRace(string sQuestTag, int nRace, int bInclude = TRUE)
{
    SetQuestPrerequisite(sQuestTag, QUEST_PREREQUISITE_RACE, IntToString(nRace), IntToString(bInclude));
}

void SetQuestPrerequisiteLevelMin(string sQuestTag, int nLevel)
{
    SetQuestPrerequisite(sQuestTag, QUEST_PREREQUISITE_LEVEL_MIN, "", IntToString(nLevel));
}

void SetQuestPrerequisiteLevelMax(string sQuestTag, int nLevel)
{
    SetQuestPrerequisite(sQuestTag, QUEST_PREREQUISITE_LEVEL_MAX, "", IntToString(nLevel));
}

void SetQuestPrerequisiteClass(string sQuestTag, int nClass, int nLevels = 1)
{
    string sClass = IntToString(nClass);
    SetQuestPrerequisite(sQuestTag, QUEST_PREREQUISITE_CLASS, sClass, IntToString(nLevels));
}

void SetQuestPrerequisiteGold(string sQuestTag, int nGold)
{
    SetQuestPrerequisite(sQuestTag, QUEST_PREREQUISITE_GOLD, "", IntToString(nGold));
}

void SetQuestPrerequisiteAlignment(string sQuestTag, int nAxis)
{
    string sAxis = IntToString(nAxis);
    SetQuestPrerequisite(sQuestTag, QUEST_PREREQUISITE_ALIGNMENT, sAxis, "");
}

void SetQuestPrerequisiteQuest(string sQuestTag, string sPrereqQuestTag, int nValue = 0)
{
    SetQuestPrerequisite(sQuestTag, QUEST_PREREQUISITE_QUEST, sPrereqQuestTag, "");
}

void SetQuestPrerequisiteItem(string sQuestTag, string sResRef, int nQuantity = 1)
{
    SetQuestPrerequisite(sQuestTag, sResref, IntToString(nQuantity));
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





void AssignQuest(object oPC, string sQuestTag)
{
    if (GetIsQuestAssignable(oPC, sQuestTag))
    {
        if (AddListString(oPC, sQuestTag, QUESTS_ASSIGNED, TRUE))
            AddListString(oPC, IntToString(QUEST_ASSIGNED), QUEST_STATUS);
        else
        {
            int nIndex = FindListString(oPC, sQuestTag, QUESTS_ASSIGNED);
            SetListString(oPC, IntToString(QUEST_ASSIGNED), QUEST_STATUS);
        }
    }
    else
        Warning("Doesn't meet prerequisites");
}

void DeleteQuest(object oPC, string sQuestTag)
{
    int nIndex = GetQuestIndex(oPC, sQuestTag);

    if (nIndex != -1)
    {
        DeleteListString(oPC, nIndex, QUESTS_ASSIGNED);
        DeleteListString(oPC, nIndex, QUEST_STATUS);
    }
}


int GetQuestState(object oPC, string sQuestTag)
{
    int bAssigned = GetIsQuestAssigned(oPC, sQuestTag);
    int bComplete = GetIsQuestComplete(oPC, sQuestTag);

    if (!bAssigned)
        return QUEST_NOT_ASSIGNED;
    else if (GetIsQuestComplete(oPC, sQuestTag))
        return QUEST_COMPLETE;
    else
    {
        int nIndex = GetQuestIndex(oPC, sQuestTag);
        string sQuestStatus = GetListString(oPC, nIndex, QUEST_STATUS);

        int nQuestSteps = CountQuestSteps(sQuestTag);
        int nCompletedSteps = CountList(sQuestStatus);

        if (GetQuestPropertyInt(sQuestTag, QUEST_ALLOW_RANDOM_ORDER))
            return nCompletedSteps;
        else
            return StringToInt(GetListItem(sQuestStatus, nCompletedSteps -1));
    }

    return QUEST_INVALID;
}

void GiveQuestRewards(object oPC, string sQuestTag, int nStep = 0, int nRewardType = REWARD_ALL, int bParty = FALSE)
{
    if ((nRewardType && REWARD_GOLD) || nRewardType == REWARD_ALL)
    {
        int nGold = GetQuestGoldReward(sQuestTag, nStep);
        if (bParty)
            GiveGoldToAll(oPC, nGold);
        else        
            GiveGoldToCreature(oPC, nGold);
    }

    if ((nRewardType && REWARD_XP) || nRewardType == REWARD_ALL)
    {
        int nXP = GetQuestXPReward(sQuestTag, nStep);
        if (bParty)
            GiveXPToAll(oPC, nXP);
        else
            GiveXPToCreature(oPC, StringToInt(sReward));
    }

    if ((nRewardType && REWARD_ALIGNMENT) || nRewardType == REWARD_ALL)
    {
        int nAxis = GetQuestAlignmentRewardAxis(sQuestTag, nStep);
        int nShift = GetQuestAlignmentRewardShift(sQuestTag, nStep);

        if (bParty)
            AdjustAlignmentOnAll(oPC, nAxis, nShift);
        else
            AdjustAlignment(oPC, nAxis, nShift, FALSE);
    }

    if ((nRewardType && REWARD_ITEM) || nRewardType == REWARD_ALL)
    {
        int n, nQuantity, nCount = CountQuestRewardItems(sQuestTag, nStep);
    
        for (n = 0; n < nCount; n++)
        {
            sItemResref = GetQuestRewardItemResref(sQuestTag, n, nStep);
            nItemQuantity = GetQuestRewardItemQuantity(sQuestTag, n, nStep);

            if (bParty)
            {
                object oParty = GetFirstFactionMember(oPC, TRUE);
                while (GetIsObjectValid(oParty))
                {
                    CreateItemOnObject(sItemResref, oParty, nItemQuantity);
                    oParty = GetNextFactionMember(oPC, TRUE);
                }
            }
            else
                CreateItemOnObject(sItemResref, oPC, nItemQuantity);
        }
    }

}

void main(){}




