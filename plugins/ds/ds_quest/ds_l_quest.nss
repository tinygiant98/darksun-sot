// -----------------------------------------------------------------------------
//    File: quest_l_plugin.nss
//  System: Quest Persistent World Subsystem
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "quest_i_main"

void ds_quest_OnModuleLoad()
{
    // Sample discovery quest (random)
    // Levels 1-3
    // Step 1: Find and enter quest_trigger_1
    //         Find and enter quest_trigger_2
    //         Find and enter quest_trigger_3
    
    AddQuest("quest_discovery_random");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(3);
    SetQuestPrerequisiteGold(500, LESS_THAN_OR_EQUAL_TO);
    SetQuestRepetitions(0);
    SetQuestVersion(1);
    SetQuestVersionActionDelete();
    DeleteQuestJournalEntriesOnCompletion();
    //SetQuestJournalHandler(QUEST_JOURNAL_NONE);
    
    SetQuestScriptOnAccept("script_OnAccept");

    AddQuestStep();
    SetQuestStepPrewardMessage("You've been assigned the Random Discovery Quest.");
    
    SetQuestStepObjectiveDiscover("quest_trigger_2");
    SetQuestStepObjectiveDescriptor("Quest Discovery Trigger 2");
    SetQuestStepObjectiveDescription("and skip around it");
    
    SetQuestStepObjectiveDiscover("quest_trigger_3");
    SetQuestStepObjectiveDescriptor("Quest Discovery Trigger 3");

    SetQuestStepObjectiveDiscover("quest_trigger_1");
    SetQuestStepObjectiveDescriptor("Quest Discovery Trigger 1");
    
    SetQuestStepObjectiveRandom(2);
    SetQuestStepObjectiveMinimum(1);

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Congratulations, you've completed the Random Discovery sample quest");
    SetQuestStepRewardGold(50);
    SetQuestStepRewardXP(50);

}



// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("ds");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "ds_quest_OnModuleLoad", 3.0);

    // ----- Module Events -----
    RegisterLibraryScript("ds_quest_OnModuleLoad", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  ds_quest_OnModuleLoad(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
