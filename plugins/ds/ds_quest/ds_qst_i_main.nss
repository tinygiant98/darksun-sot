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

    AddQuestStep();
    SetQuestStepPrewardMessage("Thanks for agreeing to help find my lost pet. " +
        "I don't know where he could be.");
    SetQuestStepObjectiveDiscover("quest_trigger_1");
    SetQuestStepRewardMessage("The step you just accomplished was a demonstration of a discover quest. " +
        "You fulfilled this step's requirement by entering the trigger that surrounds Bandit.");

    AddQuestStep();
    SetQuestStepPrewardMessage("You found Spot!  Go back and let Jonny know!");
    SetQuestStepObjectiveSpeak("quest_jonny");
    SetQuestStepRewardMessage("The step you just accomplished was a demonstration of a speak quest. " +
        "You fulfilled this step's requirement by returning to Jonny to let him know you found Bandit.");

    AddQuestResolutionSuccess();
    SetQuestStepRewardXP(150);
    SetQuestStepRewardGold(50);
}

void define_quest_demo_kill()
{
    AddQuest("quest_demo_kill");
    SetQuestRepetitions(0);
    SetQuestVersion(1);
    SetQuestVersionActionDelete();
    
    AddQuestStep();
    SetQuestStepPrewardFloatingText("They're coming right for us!");
    SetQuestStepObjectiveKill("nw_goblina", 5);
    SetQuestStepRewardMessage("The quest you just accomplished was a demonstration of a KILL quest. " +
        "Each goblin you killed was tallied and when you reach five goblins killed, the quest step was " +
        "fulfilled.  There was only one step in this quest, so the quest was marked complete immediately.");

    AddQuestResolutionSuccess();
    SetQuestStepRewardXP(200);
    SetQuestStepRewardGold(25);
}

void define_quest_demo_protect()
{
    AddQuest("quest_demo_protect");
    SetQuestRepetitions(0);
    SetQuestVersion(1);
    SetQuestVersionActionDelete();

    AddQuestStep();
    SetQuestStepObjectiveKill("nw_golina", 5);
    SetQuestStepObjectiveKill("old_man", 0);

    AddQuestResolutionSuccess();
    SetQuestStepRewardGold(20);
    SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 5);
    SetQuestStepRewardAlignment(ALIGNMENT_LAWFUL, 5);

    AddQuestResolutionFail();
    SetQuestStepRewardXP(-10);
    SetQuestStepRewardAlignment(ALIGNMENT_CHAOTIC, 10);
}

/*
    string sGather = "quest_demo_gather";
    string sDeliver = "quest_demo_deliver";
    string sSpeak = "quest_demo_speak";
*/