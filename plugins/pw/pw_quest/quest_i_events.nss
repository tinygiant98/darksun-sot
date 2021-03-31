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
            }

            if (nQuestCount == 0)
            {
                string s = Indent(TRUE);
                Debug(ColorFail(s + "No quests loaded into module database"));
            }
        }
    }
}
