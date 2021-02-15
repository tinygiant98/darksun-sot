// -----------------------------------------------------------------------------
//    File: quest_i_main.nss
//  System: Quest Persistent World Subsystem (core)
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "pw_i_core"
#include "quest_i_const"
#include "quest_i_config"
#include "quest_i_text"
#include "util_i_quest"
#include "util_i_chat"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void DefineQuests()
{
    string sJournalTitle = "This is the quest title.";
    string sTag = "qTestQuest";
    AddQuest("qTestQuest", sJournalTitle);

    SetQuestPrerequisiteAlignment(sTag, ALIGNMENT_GOOD);
    SetQuestPrerequisiteClass(sTag, RACIAL_TYPE_HUMAN, FALSE);
    SetQuestPrerequisiteLevelMin(sTag, 3);

    int nStep = AddQuestStep(sTag);
    SetQuestStepJournalEntry(sTag, nStep, "You're working on Step 1.");
    SetQuestStepRewardItem(sTag, nStep, "itemtag", 2);
    SetQuestStepRewardAlignment(sTag, nStep, ALIGNMENT_GOOD, 20);
    SetQuestStepRewardXP(sTag, nStep, 100);
    SetQuestStepRewardGold(sTag, nStep, 100);

    SetQuestStepObjectiveKill(sTag, nStep, "thistag", 1);

    nStep = AddQuestStep(sTag, "You're working on Step 2.");
    SetQuestStepPrewardAlignment(sTag, nStep, ALIGNMENT_EVIL, 10);
    SetQuestStepPrewardGold(sTag, nStep, 300);
    SetQuestStepPrewardItem(sTag, nStep, "thisitem", 2);
    SetQuestStepPrewardXP(sTag, nStep, 100);

}
