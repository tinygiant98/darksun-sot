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

void AssignQuestToPC(object oPC)
{
    if (GetIsQuestAssignable(oPC, "myFirstQuest"))
    {
        Notice(HexColorString("Quest is assignable", COLOR_GREEN_LIGHT));
        AssignQuest(oPC, "myFirstQuest");
    }
    else
        Notice(HexColorString("Quest is NOT assignable", COLOR_RED_LIGHT));
}

void DefineQuests()
{
    int nQuestID, nStep;

    nQuestID = AddQuest("myFirstQuest", "Super duper journal title");
    //SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_GOOD);
    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_WIZARD, 1);
    SetQuestPrerequisiteGold(nQuestID, 50);
    //SetQuestPrerequisiteItem(nQuestID, "nw_maarcl015", 1);
    SetQuestPrerequisiteLevelMax(nQuestID, 1);
    SetQuestPrerequisiteLevelMin(nQuestID, 1);
    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_ELF, TRUE);
    
    SetQuestActive(nQuestID);
    SetQuestRepetitions(nQuestID, 2);
    //SetQuestTimeLimit(nQuestID, CreateDifferenceVector(0,0,0,1,0,0));
    SetQuestScriptOnAdvance(nQuestID, "quest_OnAdvance");
    SetQuestScriptOnAccept(nQuestID, "");
    SetQuestScriptOnComplete(nQuestID, "");
    SetQuestScriptOnFail(nQuestID, "");
    //SetQuestCooldown(nQuestID, CreateDifferenceVector(0,0,1,0,0,0));

    nStep = AddQuestStep(nQuestID, "");
    SetQuestStepObjectiveKill(nQuestID, nStep, "nw_goblina", 1);
    SetQuestStepPrewardGold(nQuestID, nStep, 150);
    SetQuestStepPrewardXP(nQuestID, nStep, 100);

    nStep = AddQuestResolutionSuccess(nQuestID);
    SetQuestStepRewardMessage(nQuestID, nStep, "Thanks for your help!");
    SetQuestStepRewardItem(nQuestID, nStep, "nw_maarcl015", 2);
    SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_GOOD, 20);
    SetQuestStepRewardXP(nQuestID, nStep, 100);
    SetQuestStepRewardGold(nQuestID, nStep, 100);
}
