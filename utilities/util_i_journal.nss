// -----------------------------------------------------------------------------
//    File: util_i_journal.nss
//  System: Journal
// -----------------------------------------------------------------------------
// Description:
//  Universal journal functions
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

//#include "core_i_database"
#include "util_i_data"

// The bHideFinishedQuests boolean variable controls if
// completed quests are loaded into the journal when a
// player logs back in.  If set to TRUE, journal entries
// will not be added.  Otherwise, they will be loaded.
const int bHideFinishedQuests = FALSE;

//:://////////////////////////////////////////////
//::     Method:  dhAddJournalQuestEntry
//:: Created By:  Dauvis
//:: Created On:  6/29/03
//::
//:: This method is a replacement for the AddJournalQuestEntry
//:: standard function.  It operates identically to the standard
//:: function except that it will perform actions necessary
//:: to give a persistant store to the journal entries.
//:: The bMarkAsFinished arguments, which is not standard, is a
//:: flag to indicate that the quest is finished.  If there is
//:: a way to figure this out from the module, I would like to know.
//:://////////////////////////////////////////////

void dhAddJournalQuestEntry(string strCategoryTag, int iEntryId, object oCreature,
        int bAllPartyMembers = TRUE, int bAllPlayers = FALSE, int bAllowOverrideHigher = FALSE,
        int bMarkAsFinished = FALSE);
void dhAddJournalQuestEntry(string strCategoryTag, int iEntryId, object oCreature,
        int bAllPartyMembers = TRUE, int bAllPlayers = FALSE, int bAllowOverrideHigher = FALSE,
        int bMarkAsFinished = FALSE)
{
    object oPlayer;

    // if bAllPlayers is true, make a call for each player
    if (bAllPlayers) 
    {
        oPlayer = GetFirstPC();
        while (GetIsObjectValid(oPlayer)) 
        {
            dhAddJournalQuestEntry(strCategoryTag, iEntryId, oPlayer, FALSE, FALSE, bAllowOverrideHigher, bMarkAsFinished);
            oPlayer = GetNextPC();
        }
        return;
    }

    // if bAllPartyMembers is true, make a call for each player in the party
    if (bAllPartyMembers) 
    {
        oPlayer = GetFirstFactionMember(oCreature, TRUE);
        while (GetIsObjectValid(oPlayer)) 
        {
            dhAddJournalQuestEntry(strCategoryTag, iEntryId, oPlayer, FALSE, FALSE, bAllowOverrideHigher, bMarkAsFinished);
            oPlayer = GetNextFactionMember(oCreature, TRUE);
        }
        return;
    }

    // perform the standard function call
    AddJournalQuestEntry(strCategoryTag, iEntryId, oCreature, FALSE, FALSE, bAllowOverrideHigher);

    // setup processing
    int iMaxIndex = GetLocalInt(oCreature, "iJournalMaxIndex");
    int bQuestFound = FALSE;
    int idx;
    string strTag;
    string strSerialized = "";
    int iState;

    // loop through all of the quests loaded on the player
    // to find out if this is a new quest. build the
    // serialized string as we go.
    for (idx = 0; idx < iMaxIndex; idx++) 
    {
        strTag = "strQuestTag" + IntToString(idx);
        strTag = GetLocalString(oCreature, strTag);

        if (strTag == "")
            continue;

        if (strTag == strCategoryTag) 
        {
            bQuestFound = TRUE;

            // if marked as finished, clear the array element and do
            // not put it in the serialized string.
            if (bHideFinishedQuests && bMarkAsFinished) {
                strTag = "strQuestTag"+IntToString(idx);
                SetLocalString(oCreature, strTag, "");
                continue;
            }
        }
        iState = GetLocalInt(oCreature, "NW_JOURNAL_ENTRY"+strTag);

        strSerialized += strTag;
        strSerialized += ".";
        strSerialized += IntToString(iState);
        strSerialized += ".";
    }

    // if quest wasn't found, add it to the serialized string
    // and record it on the PC.  if marked as finished don't do
    // this
    if (!bQuestFound && (!bHideFinishedQuests || !bMarkAsFinished)) 
    {
        strTag = "strQuestTag" + IntToString(iMaxIndex);
        SetLocalInt(oCreature, "iJournalMaxIndex", iMaxIndex+1);
        SetLocalString(oCreature, strTag, strCategoryTag);

        iState = GetLocalInt(oCreature, "NW_JOURNAL_ENTRY"+strCategoryTag);
        strSerialized += strCategoryTag;
        strSerialized += ".";
        strSerialized += IntToString(iState);
        strSerialized += ".";
    }

    // if marked as finished, set a flag in the database and add it to the
    // list of "completed" quests
    if (bMarkAsFinished) 
    {
        strTag = "bQuestFinished_" + strCategoryTag;
        //DeleteDatabaseVariable(strTag, oCreature);
        //SetDatabaseInt(strTag, TRUE, oCreature);

        //strTag = GetDatabaseString("strCompletedQuests", oCreature);

        //strTag += (strCategoryTag + ".");
        //DeleteDatabaseVariable("strCompletedQuests", oCreature);
        //SetDatabaseString("strCompletedQuests", strTag, oCreature);
    }

    // store the serialized string
    //DeleteDatabaseVariable("strCompletedQuests", oCreature);
    //SetDatabaseString("strQuestStates", strSerialized, oCreature);
}

//:://////////////////////////////////////////////
//::     Method:  dhRemoveJournalQuestEntry
//:: Created By:  Dauvis
//:: Created On:  6/29/03
//::
//:: This method is a replacement for the RemoveJournalQuestEntry
//:: standard function.  It operates identically to the standard
//:: function except that it will perform actions necessary
//:: to give a persistant store to the journal entries.
//:: The bRemoveIfFinished argument, which is not standard, indicates
//:: if the quest should be removed even if it was flagged as
//:: finish.  By default, finished quests will not be removed.
//:://////////////////////////////////////////////

void dhRemoveJournalQuestEntry(string strPlotId, object oCreature, int bAllPartyMembers = TRUE,
        int bAllPlayers = FALSE, int bRemoveIfFinished = FALSE);
void dhRemoveJournalQuestEntry(string strPlotId, object oCreature, int bAllPartyMembers = TRUE,
        int bAllPlayers = FALSE, int bRemoveIfFinished = FALSE)
{
    object oPlayer;

    // if bAllPlayers is true, make a call for each player
    if (bAllPlayers) 
    {
        oPlayer = GetFirstPC();
        while (GetIsObjectValid(oPlayer)) 
        {
            dhRemoveJournalQuestEntry(strPlotId, oCreature, FALSE, FALSE, bRemoveIfFinished);
            oPlayer = GetNextPC();
        }
        return;
    }

    // if bAllPartyMembers is true, make a call for each player in the party
    if (bAllPartyMembers) 
    {
        oPlayer = GetFirstFactionMember(oCreature, TRUE);
        while (GetIsObjectValid(oPlayer)) 
        {
            dhRemoveJournalQuestEntry(strPlotId, oCreature, FALSE, FALSE, bRemoveIfFinished);
            oPlayer = GetNextFactionMember(oCreature, TRUE);
        }
        return;
    }

    // perform the standard function call
    RemoveJournalQuestEntry(strPlotId, oCreature, FALSE, FALSE);

    // setup processing
    int iMaxIndex = GetLocalInt(oCreature, "iJournalMaxIndex");
    int idx;
    string strTag;
    string strSerialized = "";
    int iState;

    // loop through all of the quests loaded on the player
    // to find this quest and remove it. build the
    // serialized string as we go.
    for (idx = 0; idx < iMaxIndex; idx++) {
        strTag = "strQuestTag" + IntToString(idx);
        strTag = GetLocalString(oCreature, strTag);

        if (strTag == "")
            continue;

        if (strTag == strPlotId) 
        {
            strTag = "strQuestTag"+IntToString(idx);
            SetLocalString(oCreature, strTag, "");
            continue;
        }
        iState = GetLocalInt(oCreature, "NW_JOURNAL_ENTRY"+strTag);

        strSerialized += strTag;
        strSerialized += ".";
        strSerialized += IntToString(iState);
        strSerialized += ".";
    }

    // if the remove if finished flag is set, see if the quest has been
    // marked as finished and unset it if it is (Don't just set the flag
    // because it will create an unnecessary database entry).
    if (bRemoveIfFinished) {
        strTag = "bQuestFinished_" + strPlotId;
        //iState = GetDatabaseInt(strTag, oCreature);
        //if (iState) 
        //{
        //    DeleteDatabaseVariable(strTag, oCreature);
        //    SetDatabaseInt(strTag, FALSE, oCreature);
        //}
    }

    // store the serialized string
    //DeleteDatabaseVariable("strCompletedQuests", oCreature);
    //SetDatabaseString("strQuestStates", strSerialized, oCreature);
}

//:://////////////////////////////////////////////
//::     Method:  dhGetJournalQuestState
//:: Created By:  Dauvis
//:: Created On:  6/29/03
//::
//:: This function will return the current state of the specified
//:: quest.  If there isn't such a quest on the player's list,
//:: it will return 0.  If the quest is marked as finished,
//:: it will return -1.  Otherwise, it will return the quest's
//:: state.
//:://////////////////////////////////////////////
int dhGetJournalQuestState(string strPlotId, object oCreature);
int dhGetJournalQuestState(string strPlotId, object oCreature)
{
    // check the database to see if the flag is set.
    string strTag = "bQuestFinished_" + strPlotId;
    int bFlag = GetDatabaseInt(strTag, oCreature);
    if (bFlag) return -1;

    // return the state stored on the player
    strTag = "NW_JOURNAL_ENTRY" + strPlotId;
    int iState = GetLocalInt(oCreature, strTag);
    return iState;
}

//:://////////////////////////////////////////////
//::     Method:  dhNextToken
//:: Created By:  Dauvis
//:: Created On:  6/29/03
//::
//:: This function is used in the parsing of a string into
//:: tokens.
//:://////////////////////////////////////////////
string dhNextToken(string strSerialized, int iStart)
{
    int idx = 0;
    string strChar;

    if (GetStringLength(strSerialized) <= iStart) 
        return "";

    strChar = GetSubString(strSerialized, iStart+idx, 1);
    while (strChar != ".") 
    {
        idx++;
        strChar = GetSubString(strSerialized, iStart+idx, 1);
    }
    return GetSubString(strSerialized, iStart, idx);
}

//:://////////////////////////////////////////////
//::     Method:  dhClearJournal
//:: Created By:  Dauvis
//:: Created On:  6/29/03
//::
//:: This method clears the persistant information for
//:: the player's journal.  It is intended to be
//:: called for new characters so that a new character
//:: won't "inherit" values from a former character.
//::
//:: WARNING:  if a character is recreated from one
//:: that had a very large number of quests completed,
//:: there will be a moment of lag as the information
//:: is cleared.
//:://////////////////////////////////////////////
void dhClearJournal(object oPlayer);
void dhClearJournal(object oPlayer)
{
    string strCompleted;
    int iStart = 0;
    string strToken;
    string strTag;

//    strCompleted = GetDatabaseString("strCompletedQuests", oPlayer);
//    while (TRUE) 
//    {
//        strToken = dhNextToken(strCompleted, iStart);
//        iStart += (GetStringLength(strToken) + 1);
//
//        if (strToken == "") break;
//
//        strTag = "bQuestFinished_" + strToken;
//        DeleteDatabaseVariable(strTag, oPlayer);
//        SetDatabaseInt(strTag, FALSE, oPlayer);
//    }
//
//    // clear the pending quests and completed quests
//    DeleteDatabaseVariable("strCompletedQuests", oPlayer);
//    SetDatabaseString("strCompletedQuests", "", oPlayer);
//    DeleteDatabaseVariable("strQuestStates", oPlayer);
//    SetDatabaseString("strQuestStates", "", oPlayer);
}

//:://////////////////////////////////////////////
//::     Method:  dhLoadJournalQuestStates
//:: Created By:  Dauvis
//:: Created On:  6/29/03
//::
//:: This method will load the quest states from the database
//:: and store them on the player.
//:://////////////////////////////////////////////
void dhLoadJournalQuestStates(object oPlayer)
{
    string strSerialized;
    int idx, iMaxIndex = 0;
    int iStart = 0;
    string strToken1;
    string strToken2;
    string strTag;

    // error checking
    if (!GetIsPC(oPlayer))
        return;

    // check to make sure this is not a new character
    // because a player can recreate a character of the
    // same name
    if (!GetXP(oPlayer)) 
    {
        dhClearJournal(oPlayer);
        return;
    }

    // get serialized quest states
//    strSerialized = GetDatabaseString("strQuestStates", oPlayer);
//    while (TRUE) 
//    {
//        strToken1 = dhNextToken(strSerialized, iStart);
//        iStart += (GetStringLength(strToken1) + 1);
//        strToken2 = dhNextToken(strSerialized, iStart);
//        iStart += (GetStringLength(strToken2) + 1);
//
//        if (strToken1 == "" || strToken2 == "")
//            break;
//
//        AddJournalQuestEntry(strToken1, StringToInt(strToken2), oPlayer, FALSE);
//        strTag = "strQuestTag"+IntToString(iMaxIndex);
//        SetLocalString(oPlayer, strTag, strToken1);
//        iMaxIndex++;
//    }
//
//    SetLocalInt(oPlayer, "iJournalMaxIndex", iMaxIndex+1);
}

//:://////////////////////////////////////////////
//::     Method:  dhGiveQuestItem
//:: Created By:  Dauvis
//:: Created On:  7/3/03
//::
//:: This function is intended to be called in a death script for NPC but it can
//:: be useful in other situations.  When called, the function will check the
//:: specified player to see if he is a specific state in a quest.  If so,
//:: it will award the specified item to him.  This function return TRUE
//:: if an item was awarded.  It will return FALSE if the bAllParty flag is
//:: set to TRUE.
//::
//:: strPlotId - the category tag for the quest
//:: iReqState - the state at which the player must be at to receive the item
//:: oPlayer - the player on which the check will be made
//:: strResRef - the resource reference of the item to award
//:: iQty - the quantity of items to give to the player
//:: iNewState - the next state to which the quest will be changed.  If this is
//::        is set to -1, the quest's state will not be changed.
//:: bAllParty - a flag to indicate if everyone in the player's party
//::        should be checked and be awarded in addition to the player.
//:: bMarkAsFinished - a flag to indicate that the quest should be marked as
//::        finished if the quest state is changed by this function.
//:://////////////////////////////////////////////
int dhGiveQuestItem(string strPlotId, int iReqState, object oPlayer, string strResRef,
        int iQty = 1, int iNewState = -1, int bAllParty = FALSE, int bMarkAsFinished = FALSE);

int dhGiveQuestItem(string strPlotId, int iReqState, object oPlayer, string strResRef,
        int iQty = 1, int iNewState = -1, int bAllParty = FALSE, int bMarkAsFinished = FALSE)
{
    object oCreature;

    // if the bAllParty is true, apply this function to all players in
    // the party
    if (bAllParty) {
        oCreature = GetFirstFactionMember(oPlayer, TRUE);
        while (GetIsObjectValid(oCreature)) 
        {
            dhGiveQuestItem(strPlotId, iReqState, oCreature, strResRef, iQty, iNewState);
            oCreature = GetNextFactionMember(oPlayer, TRUE);
        }
        return FALSE;
    }

    // check to see if we are at the required state
    int iCurState = dhGetJournalQuestState(strPlotId, oPlayer);
    if (iCurState != iReqState)
        return FALSE;

    // we are at the required state, award the item.
    CreateItemOnObject(strResRef, oPlayer, iQty);

    // update the state if necessary
    if (iNewState != -1)
        dhAddJournalQuestEntry(strPlotId, iNewState, oPlayer, FALSE, FALSE, FALSE, bMarkAsFinished);

    return TRUE;
}

//:://////////////////////////////////////////////
//::      Method:   dhHideJournalQuestEntry
//::  Created By:   Dauvis
//::  Created On:   7/13/03
//:: Modified By:   Dauvis
//:: Modified On:   7/13/03
//::
//:: This function will remove a quest from the player's journal
//:: if the quest has been marked as finished.  Its purpose is to
//:: provide a way to remove the journal entry from the journal if the
//:: bHideJournalQuests flag is set to FALSE.
//:://////////////////////////////////////////////
void dhHideJournalQuestEntry(object oPlayer, string strPlotId);
void dhHideJournalQuestEntry(object oPlayer, string strPlotId)
{
    int iMaxIndex = GetLocalInt(oPlayer, "iJournalMaxIndex");
    int idx;
    string strTag;
    string strSerialized = "";
    int iState;

    // make sure the quest is marked as finished
    strTag = "bQuestFinished_" + strPlotId;
    
//    if (!GetDatabaseInt(strTag, oPlayer));
//        return;
//
    // find the quest in the list and exclude from
    // serialize string
    for (idx = 0; idx < iMaxIndex; idx++) 
    {
        strTag = "strQuestTag" + IntToString(idx);
        strTag = GetLocalString(oPlayer, strTag);

        if (strTag == "")
            continue;

        if (strTag == strPlotId) 
        {
            // clear the array element and do not put it in the serialized string.
            strTag = "strQuestTag"+IntToString(idx);
            SetLocalString(oPlayer, strTag, "");
            continue;
        }
        iState = GetLocalInt(oPlayer, "NW_JOURNAL_ENTRY"+strTag);

        strSerialized += strTag;
        strSerialized += ".";
        strSerialized += IntToString(iState);
        strSerialized += ".";
    }

    // save the new serialized string
   //DeleteDatabaseVariable("strQuestStates", oPlayer);
   //SetDatabaseString("strQuestStates", strSerialized, oPlayer);

    // remove from journal for aestetic reasons
    RemoveJournalQuestEntry(strPlotId, oPlayer);
}
