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
    SetQuestStepRewardMessage(HexColorString("The step you just accomplished was a demonstration of a discover quest. " +
        "You fulfilled this step's requirement by entering the trigger that surrounds Bandit.  When you return to tell " +
        "Jonny about Bandit's location, the conversation will demonstrate that you can retrieve quest data from the " +
        "system to use as conditionals for which pages and nodes to display.", COLOR_CYAN));

    AddQuestStep();
    SetQuestStepPrewardMessage("You found Spot!  Go back and let Jonny know!");
    SetQuestStepObjectiveSpeak("quest_jonny");
    SetQuestStepRewardMessage(HexColorString("The step you just accomplished was a demonstration of a speak quest. " +
        "You fulfilled this step's requirement by returning to Jonny to let him know you found Bandit. " +
        "Additionally you'll see that journal entries for this quest have been completely removed once " +
        "the quest was completed.", COLOR_CYAN));

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
    SetQuestStepObjectiveKill("nw_oldman", 0);

    AddQuestResolutionSuccess();
    SetQuestStepRewardGold(20);
    SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 5);
    SetQuestStepRewardAlignment(ALIGNMENT_LAWFUL, 5);

    AddQuestResolutionFail();
    SetQuestStepRewardXP(-10);
    SetQuestStepRewardAlignment(ALIGNMENT_CHAOTIC, 10);
    SetQuestStepRewardMessage(HexColorString("Booooo!  You suck!", COLOR_RED_LIGHT));
    SetQuestStepRewardMessage(HexColorString("This quest was designed to demonstrate a failure condition. " +
        "The old man was designated as a protected object, so when he died the quest automatically failed. " +
        "You can set a different journal quest entry for failures compared to successes.", COLOR_CYAN));
}

void define_quest_demo_gather()
{
    AddQuest("quest_demo_gather");
    SetQuestRepetitions(0);
    SetQuestVersion(1);
    SetQuestVersionActionDelete();

    AddQuestStep();
    SetQuestStepObjectiveGather("quest_gather_helmet", 3);
    SetQuestStepObjectiveGather("quest_gather_shield", 3);
    SetQuestStepObjectiveGather("quest_gather_armor", 3);

    AddQuestResolutionSuccess();
    SetQuestStepRewardAlignment(ALIGNMENT_GOOD, 2);
    SetQuestStepRewardMessage("Thanks for the help!");
}

void define_quest_demo_deliver()
{
    AddQuest("quest_demo_deliver");
    SetQuestRepetitions(0);
    SetQuestVersion(1);
    SetQuestVersionActionDelete();

    AddQuestStep();
    SetQuestStepPrewardMessage("Please collect all the armor you see strewn about");
    SetQuestStepObjectiveGather("quest_gather_helmet", 3);
    SetQuestStepObjectiveGather("quest_gather_shield", 3);
    SetQuestStepObjectiveGather("quest_gather_armor", 3);
    SetQuestStepRewardMessage(HexColorString("You've collected all the required gear.  This step demonstrates " +
        "that you can force a PC to collect a specified number of items before delivering them.  Although this " +
        "demo doesn't demonstrate it, you can also allow those items to be delivered as they are collected " +
        "instead of forcing seqential actions.  Non-sequential actions are demonstrated here by allowing the PC " +
        "to collect all the dropped items in any order.", COLOR_CYAN));

    AddQuestStep();
    SetQuestStepPrewardMessage("Wow, you're awesome.  Ok, can you put all that in the wagon, please?");
    SetQuestStepObjectiveDeliver("quest_deliver_wagon", "quest_gather_helmet", 3);
    SetQuestStepObjectiveDeliver("quest_deliver_wagon", "quest_gather_shield", 3);
    SetQuestStepObjectiveDeliver("quest_deliver_wagon", "quest_gather_armor", 3);
    SetQuestStepRewardMessage(HexColorString("This quest demonstration used a container with inventory to " +
        "act as the deliver location, however you can also use ground locations, such as triggers, NPCs " +
        "or really any other game object to act as a delivery location.", COLOR_CYAN));

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage("Thanks for cleaning up the mess!");
    SetQuestStepRewardGold(15);
}

void define_quest_demo_speak()
{
    AddQuest("quest_demo_speak");
    SetQuestRepetitions(0);
    SetQuestVersion(1);
    SetQuestVersionActionDelete();

    AddQuestStep();
    SetQuestStepPrewardMessage("Dr. Bannon would like to see you.");
    SetQuestStepObjectiveSpeak("quest_bannon");

    AddQuestResolutionSuccess();
    SetQuestStepRewardMessage(HexColorString("Although a very simple quest, this quest demonstrates " +
        "that a quest can be progressed when speaking to an NPC.", COLOR_CYAN));
    SetQuestStepRewardXP(1);
    SetQuestStepRewardGold(1);
}

location _GetRandomLocationAroundObject(object oTarget, float fRadius)
{
    // Get location data
    location lTarget = GetLocation(oTarget);
    vector vTarget = GetPositionFromLocation(lTarget);

    // Randomize the radius
    float fDistance = Random(FloatToInt(fRadius * 10) + 1) / 10.0;

    // Generate a random angle and facing
    float fAngle = IntToFloat(Random(360));
    float fFacing = IntToFloat(Random(360));

    vector vRandom;
    vRandom.x = vTarget.x + (fDistance * cos(fAngle));
    vRandom.y = vTarget.y + (fDistance * sin(fAngle));
    vRandom.z = vRandom.z;

    return Location(GetArea(oTarget), vRandom, fFacing);
}

void ResetGatherQuestArea(object oPC, int bCleanOnly = FALSE)
{
    string sTag, sTags = "quest_gather_helmet,quest_gather_shield,quest_gather_armor";
    string sResref, sResrefs = "nw_arhe001,nw_ashlw001,nw_aarcl001";
    int i, n, nCount = CountList(sTags);
    object oItem;

    // Clean up the PC
    oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (HasListItem(sTags, GetTag(oItem)))
            DestroyObject(oItem);

        oItem = GetNextItemInInventory(oPC);
    }

    //Clean the area
    object oWP = GetObjectByTag("quest_deliver_wp_1");

    for (n = 0; n < nCount; n++)
    {
        i = 0;
        
        sTag = GetListItem(sTags, n);
        oItem = GetNearestObjectByTag(sTag, oWP, i++);
        while (GetIsObjectValid(oItem))
        {
            DestroyObject(oItem);
            oItem = GetNearestObjectByTag(sTag, oWP, i++);
        }
    }

    //Create new stuff
    if (!bCleanOnly)
    {
        for (n = 0; n < nCount; n++)
        {
            i = 0;
            sTag = GetListItem(sTags, n);
            sResref = GetListItem(sResrefs, n);

            while (i++ < 3)
            {
                location l = _GetRandomLocationAroundObject(oWP, 3.0);
                CreateObject(OBJECT_TYPE_ITEM, sResref, l, FALSE, sTag);
            }
        }
    }
}
