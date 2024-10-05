// -----------------------------------------------------------------------------
//    File: quest_i_events.nss
//  System: PC Corspe Loot (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "quest_i_main"
#include "util_i_chat"
#include "util_i_argstack"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

void quest_OnModuleLoad();
void quest_OnClientEnter();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void quest_OnModuleLoad()
{
    // put dialog into library load routine
       // LoadLibrary("quest_l_dialog");
    CreateModuleQuestTables(TRUE);
}

void quest_OnClientEnter()
{
    object oPC = GetEnteringObject();
    CreatePCQuestTables(oPC);
    UpdatePCQuestTables(oPC);
    CleanPCQuestTables(oPC);
    UpdateJournalQuestEntries(oPC);
}

void QUEST_GetQuestString()
{
    string sQuestTag = PopString(); //GetArgumentString();
    int nStep = PopInt(); //GetArgumentInt();

    string sMessage = GetQuestWebhookMessage(sQuestTag, nStep);
    //PushReturnValueString(sMessage);
    PushString(sMessage);
}

void QUEST_GetCurrentQuest()
{
    string sQuestTag = GetCurrentQuest();
    PushString(sQuestTag);
    //PushReturnValueString(sQuestTag);
}

void QUEST_GetCurrentQuestStep()
{
    int nStep = GetCurrentQuestStep();
    PushInt(nStep);
    //PushReturnValueInt(nStep);
}

void QUEST_GetCurrentQuestEvent()
{
    string sEvent = GetCurrentQuestEvent();
    PushString(sEvent);
    //PushReturnValueString(sEvent);
}

void QUEST_GetCurrentWebhookMessage()
{
    string sQuestTag = GetCurrentQuest();
    string sEvent = GetCurrentQuestEvent();
    int nStep, nQuestID = GetQuestID(sQuestTag);

    if (sEvent == QUEST_EVENT_ON_ASSIGN)
        nStep = 0;
    else if (sEvent == QUEST_EVENT_ON_ACCEPT)
        nStep = 0;
    else if (sEvent == QUEST_EVENT_ON_ADVANCE)
        nStep = GetCurrentQuestStep();
    else if (sEvent == QUEST_EVENT_ON_COMPLETE)
        nStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_SUCCESS);
    else if (sEvent == QUEST_EVENT_ON_FAIL)
        nStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_FAIL);

    string sMessage = GetQuestWebhookMessage(sQuestTag, nStep);
    PushString(sMessage);
    //PushReturnValueString(sMessage);
}

void quest_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    if (HasChatOption(oPC, "dump"))
    {
        string sQuery;
        int nQuestCount;

        string sQuestTag = GetChatArgument(oPC);
        
        if (HasChatOption(oPC, "pc"))
        {
            if (sQuestTag == "")
                sQuery = "SELECT quest_tag " +
                         "FROM quest_pc_data;";
            else
                sQuery = "SELECT quest_tag " +
                         "FROM quest_pc_data " +
                         "WHERE quest_tag = @sQuestTag;";

            sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
            if (sQuestTag != "")
                SqlBindString(sql, "@sQuestTag", sQuestTag);
            
            Debug(ColorTitle("Starting PC quest data dump..."));

            while (SqlStep(sql))
            {
                nQuestCount++;
                ResetIndent();
                sQuestTag = SqlGetString(sql, 0);
                DumpPCQuestData(oPC, sQuestTag);
                DumpPCQuestVariables(oPC, sQuestTag);
            }

            if (nQuestCount == 0)
            {
                string s = Indent(TRUE);
                Debug(ColorFail(s + "No quest data found on " + PCToString(oPC)));
            }
        }
        else
        {        
            if (sQuestTag == "")
                sQuery = "SELECT sTag " +
                        "FROM quest_quests;";
            else
                sQuery = "SELECT sTag " +
                        "FROM quest_quests " +
                        "WHERE sTag = @sQuestTag;";

            sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
            if (sQuestTag != "")
                SqlBindString(sql, "@sQuestTag", sQuestTag);

            Debug(ColorTitle("Starting quest data dump..."));

            while(SqlStep(sql))
            {
                nQuestCount++;
                ResetIndent();
                sQuestTag = SqlGetString(sql, 0);
                DumpQuestData(sQuestTag);
                DumpQuestVariables(sQuestTag);
            }

            if (nQuestCount == 0)
            {
                string s = Indent(TRUE);
                Debug(ColorFail(s + "No quests loaded into module database"));
            }
        }

        return;
    }

    if (HasChatOption(oPC, "reset"))
    {
        if (HasChatOption(oPC, "pc"))
        {
            CreatePCQuestTables(oPC, TRUE);
            SendChatResult("Quest tables for " + PCToString(oPC) + " have been reset", oPC);
        }
        else
        {
            CreateModuleQuestTables(TRUE);
            RunLibraryScript("ds_quest_OnModuleLoad");
            SendChatResult("Module quest tables have been reset", oPC);
        }

        return;
    }
}
