// -----------------------------------------------------------------------------
//    File: ds_qst_i_main.nss
//  System: Quest Persistent World Subsystem
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "core_i_framework"
#include "quest_i_main"

void define_quest_demo_discover()
{
    AddQuest("quest_demo_discover");
    SetQuestPrerequisiteLevelMin(1);
    SetQuestPrerequisiteLevelMax(10);
    SetQuestRepetitions(0);
    SetQuestVersion(1);
    SetQuestVersionActionDelete();
    DeleteQuestJournalEntriesOnCompletion();
    SetQuestDeleteOnComplete();

    SetQuestScriptOnAll("quest_demo_discover");

    AddQuestStep();
    SetQuestStepPrewardMessage("Thanks for agreeing to help find my lost pet. " +
        "I don't know where he could be.");
    SetQuestStepObjectiveDiscover("quest_trigger_1");

    AddQuestStep();
    SetQuestStepPrewardMessage("You found Spot!  Go back and let Johnny know!");
    SetQuestStepObjectiveSpeak("quest_giver");

    AddQuestResolutionSuccess();
    SetQuestStepRewardXP(150);
    SetQuestStepRewardGold(50);
}