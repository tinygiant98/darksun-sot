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
// 20210118:
//      Initial Release

/*
Note: util_i_quest will not function without other utility includes from squattingmonk's
sm-utils.  These utilities can be obtained from
https://github.com/squattingmonk/nwn-core-framework/tree/master/src/utils.

Specificially, the following files are required:  util_i_color.nss, util_i_csvlists.nss,
util_i_datapoint.nss, util_i_debug.nss, util_i_math.nss, util_i_string.nss, util_dataitem.uti,
util_datapoint.utp

Description:
    This utility is designed to allow builders/scripters to fully define quests within script without
    the need for game journal editing.  The greatest use of this utility comes from pairing it
    with NWNX journal functions, which completely obviates the need for editing journal entries
    in the toolset.  Since there are many modules that cannot or will not use NWNX, I've included
    functionality for interfacing with the game's journal system.

NWN Journal vs. NWNX Journal Entries:
    This utility can be used with either the standard NWN or NWNX journal functions.  If you
    elect to use the standard NWN journal functions, you must build the quests within the
    game's journal editor and then enter the quest's properties into the build properties
    for each quest in the system.  Examples of how to do this, as well as use NWNX journal
    functions, are included below.

Reserved Words and Characters:
    - NONE

Usage Notes:
    This system makes extensive use of comma-delimited lists (csv lists) and variable lists (varlists).
    The vast majority of items in csv lists are string casts of integer values, so included commas
    are generally not an issue.  All text entries, such as journal titles and journal entries, are stored
    as varlists, which means there are no character limitations beyond the limitations of the game itself.
    
    The text entries in this system can store colorized text, however, there are no functions included in
    this utility to accomplish colorized text.  If you wish to have your journal titles or journal entries
    colored, the text must be pre-processed before storing the values on the quest or quest step.  The
    utility script util_i_color has several functions to accomplish this.

    This primary functionality of this utility resides in the ability to set various properties on quests
    and quest steps.  These properties include quest prerequisites, step rewards, step prewards and step
    objectives.  These properties are stored on quest dataitems in pseudo-arrays containing three columns.
    The first is the property id column, which stores the category and value type of the property.  The
    second is the Key column, which stores various string values depending on the property type.  The third
    is the Value column, which stores various string values depending on the property type.   Most properties
    can be "stacked" (more than one added).  Examples of this will follow.
    
    All data stored on quest dataitems is volatile and will be lost when the server is reset, unless saved
    to a database or other storage method.  All data saved to PC objects should be persistent across server
    resets if your server is using a servervault.

    TODO Move Warnings and Notes for Time Usage here.

Property Descriptions:

    Quest-Level Properties - each quest contains the following properties.  Not all properties are required.
        Active - Whether the quest is currently active.  If a quest is inactive, the quest cannot be
            assigned and PC's cannot progress in the quest.  TRUE by default, this value can be set to
            FALSE at any time.  This property allows builders to control, for example, when quests are
            available for assignment or redemption.
        Title - The quest title.  This is the text that will appear as the title of the quest in
            the player's journal.  If you are using NWNX, you can color this text.  If you are using
            the game's journal editor, you must abide by the editor's capabilities and limitations for
            displaying text.
        Repetitions - The number of times a PC can complete the quest.  Generally, quests are one-time or
            repeatable.  Setting this value to 0 (zero) allows the quest to be repeated an infinite number
            of times.  Setting this value to any positive integer will limit the number of times a PC
            can accomplish this quest.  The default value is 1.
        Scripts - Actions to run for quest events.  Quests have three primary event: OnAccept, OnAdvance, and
            OnComplete.  The script assigned to OnAccept will run when the quest is assigned to the player.
            The OnAdvance script will run when the player successfully completes a quest step.  The OnComplete
            script will run when the player successfully completes all steps in a given quest.  The QUESTS
            dataitem will contain appropriate values to allow the script to identify the quest and step.  The
            scripts will be run with the PC as OBJECT_SELF.
        Step Order - The order in which the steps must be accomplished.  Quests steps can be accomplished
            in sequential order or non-sequentially.  Sequential quests will allow the player to move from
            one step to the next only after completing the previous step.  Non-sequential quests allows the
            player to complete quests steps in any order.
        Time Limit - The total in-game time a PC has to complete a quest from the time the quest is assigned to
            the PC.  Failure to complete the quest within the required time will result in unassignment of the
            quest and removal of all prewards.  Rewards for completing steps will be kept by the PC.

            *** WARNING *** Timing functions require consistent server time.  If you are running a single player
                server or your persistent world time is not consistent across resets, timing functions will
                not work correctly and should be avoided.

            *** Note *** Timing functions use the util_i_time include, which stores all times as string.  If you
                use different time control and storage methods, you'll have to modify these functions to fit your
                methodologies.  To make this easier, the following functions have been included and are meant
                for custom methodologies:
            TODO

        Prerequisites - Requirements a PC must meet before a quest can be assigned.  You can add any number of
            prerequisites to each quest to narrow down which PCs can be assigned specific quests.  All
            prerequisites are checked when requested and the PC must pass all required checks before being
            assigned a quest.  Party Member characteristics cannot be used to satisfy quest prerequisites.

            ALIGNMENT:
                SetQuestPrerequisiteAlignment(string sTag, int nKey, int nValue = FALSE)
                    sTag   -> Quest Tag
                    nKey   -> ALIGNMENT_* Constant
                    nValue -> Neutrality Flag

                This property can be stacked.  There should be one call for each alignment.  The PC must meet ALL
                of the prerequisitve alignments in order to pass this check.  Since the ALIGNMENT_NEUTRAL constant
                cannot denote which axis it lies on (Good-Evil or Law-Chaos), you can set nValue to TRUE to denote
                a requirements for neutrality on the desired axis.

                This example shows prerequisites for lawful-good alignments:
                    SetQuestPrerequisiteAlignment("questTag", ALIGNMENT_GOOD);
                    SetQuestPrerequisiteAlignment("questTag", ALIGNMENT_LAWFUL);

                This example shows prerequisites for true neutral:
                    SetQuestPrerequisiteAlignment("questTag", ALIGNMENT_GOOD, TRUE);
                    SetQuestPrerequisiteAlignment("questTag", ALIGNMENT_LAWFUL, TRUE);

                This example shows a prerequisite for evil characters:
                    SetQuestPrerequisityAlignment("questTag", ALIGNMENT_EVIL);

            CLASS:
                SetQuestPrerequisiteClass(string sTag, int nKey, int nValue = 1)
                    sTag   -> Quest Tag
                    nKey   -> CLASS_TYPE_* Constant
                    nValue -> Class Levels Requirements

                This property can be stacked.  Class prerequisites are treated as OR, so the PC must meet
                AT LEAST ONE of the prerequisites, but does not have to meet all of them.  If a level-requirement
                is passed to nValue for the specified class, the PC must also meet the required number of levels
                in that class to pass this check.  Omitting the class level requirement assumes that any number
                of levels in that class satisfies the requirement.  Passing a class level requirement of 0 (zero)
                excludes any PCs that have any number of levels in that class to fail this check.

                This example shows a requirement for at least 8 levels of Druid OR any number of Fighter levels:
                    SetQuestPrerequisiteClass("questTag", CLASS_TYPE_DRUID, 8);
                    SetQuestPrerequisiteClass("questTag", CLASS_TYPE_FIGHTER);

                This example shows a requirement for at least 2 levels of Fighter, but any PC with any levels of
                Paladin are excluded:
                    SetQuestPrerequisiteClass("questTag", CLASS_TYPE_FIGHTER, 2);
                    SetQuestPrerequisiteClass("questTag", CLASS_TYPE_PALADIN, 0);

            GOLD:
                SetQuestPrerequisiteGold(string sTag, int nKey)
                    sTag -> Quest Tag
                    nKey -> Gold Amount

                This property cannot be stacked.  This check passes if the PC has the required amount of gold in their
                inventory and fails if they do not.

            ITEM:
                SetQuestPrerequisiteItem(string sTag, string sKey, int nValue = 1)
                    sTag   -> Quest Tag
                    sKey   -> Tag of Required Item
                    nValue -> Quantity of Required Item

                This property can be stacked.  Item prerequisites are treated as AND, so all item prerequisites must
                be met by the PC in order to pass this check.  nValues greater than 0 create an inclusive requirement and
                the PC must have the required number of each item to pass this check.  An nValue of 0 creates an exclusive
                requirement and any PC that has that refernced item in inventory will fail the check.

                This example shows a requirement to have 4 flowers and any number of vases in your inventory, but the PC
                cannot have any graveyard dirt:
                    SetQuestPrerequisiteItem("questTag", "item_flower", 4);
                    SetQuestPrerequisiteItem("questTag", "item vase");
                    SetQuestPrerequisiteItem("questTag", "item_gravedirt", 0);

            LEVEL_MAX:
                SetQuestPrerequisteLevelMax(string sTag, int nKey)
                    sTag -> Quest Tag
                    nKey -> Maximum Total Character Levels

                This property cannot be stacked.  This check passes if the PC total character levels are less than or equal
                to nKey, and fails otherwise.

            LEVEL_MIN:
                SetQuestPrerequisiteLevelMin(string sTag, int nKey)
                    sTag -> Quest Tag
                    nKey -> Minimum Total Character Levels

                This property cannot be stacked.  This check passes if the PC total character levels are more than or equal
                to nKey, and fails otherwise.

            QUEST:
                SetQuestPrerequisiteQuest(string sTag, string sKey, int nValue = 1)
                    sTag   -> Quest Tag
                    sKey   -> Quest Tag of Prerequisite Quest
                    nValue -> Number of Prerequisite Quest Completions

                This property can be stacked.  Quest prerequisites are treated as AND, so all quest prerequisites must
                be met by the PC in order to pass thic heck.  An nValue greater than 0 creates an inclusive requirement and
                the PC must have completed each quest at least that number of times to pass the check.  An nValue of 0 creates
                an exclusive requirement and any PC that has completed that quest will fail this check.

                This example shows a requirement to have completed the flower collection quest at least once, but to never
                have completed the rat-killing quest:
                    SetQuestPrerequisiteQuest("questTag", "questFlowers");
                    SetQuestPrerequisiteQuest("questTag", "questRats", 0);

            RACE:
                SetQuestPrerequisiteRace(string sTag, int nKey, int nValue = TRUE)
                    sTag   -> Quest Tag
                    nKey   -> RACIAL_TYPE_* Constant
                    nValue -> Inclusion/Exclusion Flag

                This property can be stacked.  Race prerequisites are treated as OR, so the PC must meet AT LEAST ONE
                of the prerequisites to pass this check.  An nValue of TRUE creates an inclusive requirement and the PC
                must be of at least one of the races listed.  An nvalue of FALSE cretes an exclusive requirement and the
                PC cannot be of any of the races listed.  Unlike other properties, combining inclusive and exclusive requirements
                on the same quest does not make sense and should be avoided as it could create undefined behavior.

                This example shows a requirement for either a dwarf, a human or a halfling:
                    SetQuestPrerequisiteRace("questTag", RACIAL_TYPE_DWARF);
                    SetQuestPrerequisiteRace("questTag", RACIAL_TYPE_HUMAN);
                    SetQuestPrerequisiteRace("questTag", RACIAL_TYPE_HALFLING);

                This examples show a requirement for any race except a human:
                    SetQuestPrerequisiteRace("questTag", RACIAL_TYPE_HUMAN, FALSE);

    Quest Step-Level Properties - each quest step contains the following properties.  Not all properties are required.
        Journal Entry - This is the text that will appear as the body of the quest journal entry in the player's
            in-game quest journal.  If you are using NWNX, you can color this text.  If you are using
            the game's journal editor, you must abide by the editor's capabilities and limitations for
            displaying text.
        Party Completion - This property allows party members to help complete quest steps.  In some cases, it
            may be necessary to allow someone other than the PC that holds the quest to complete a step.  For example,
            if a step's objective is to kill a target and the target is killed by a member of the player's party
            while the player is present, the player would normally be able to get quest credit for the kill.
        Time Limit - The total in-game time a PC has to complete a quest step from the time the previous step is
            successfully accomplished.  Failure to complete the quest step within  the required time will result
            in reversion of the quest to the previous step and removal of all prewards for the lost step.

            *** WARNING *** Timing functions require consistent server time.  If you are running a single player
                server or your persistent world time is not consistent across resets, timing functions will
                not work correctly and should be avoided.

        Prerequisites - Prerequisites cannot be assigned to invdividual steps.  It is assumed the the prerequisite
            for a sequential quest is the completion of all steps in-order.  For non-sequential quests, there are no
            step-level prerequisits and the PC can complete the steps in any order.
        Objectives - These properties define the purpose of each step in a quest.  A quest step with OBJECTIVE_TYPE_NONE
            will bea automatically completed by the PC and is useful for steps such as the last step in a quest that
            you'd like to use to display the completed quest journal entry.
        
            *** WARNING *** It is possible to assign more than one objective to a quest step, however, only one type
                of objective can be assigned.  For example, you can use SetQuestStepObjectiveKill() multiple times on a
                single step, but using SetQuestStepObjectiveKill() and SetQuestObjectiveGather() on the same quest
                step will result in the first objective type being evaluated and the second objective type being ignored.

                So ... this is ok:
                    SetQuestStepObjectiveKill("questTag", 1, "creature_orc", 7);
                    SetQuestStepObjectiveKill("questTag", 1, "creature_princess", 0);

                This ... is not:
                    SetQuestStepObjectiveKill("questTag", 1, "creature_orc", 7);
                    SetQuestStepObjectiveGather("questTag", 1, "orc_ears", 0);

                To ease the data storage burden, the methodology used to store quest objective quantities limits the number
                of quest objectives you can add to a single step; additionally, the greater the number of quest objectives
                on a single step, the lower the quantity number can be.  This is a limitation of the game's ability to
                process and store 32-bit integers.  If you assign more than 5 objectives to any one quest step, you are
                heading into undefined behavior territory.

            KILL:
                SetQuestStepObjectiveKill(string sTag, int nStep, string sKey, int nValue = 1)
                    sTag   -> Quest Tag
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object

                This property can be stacked.  Kill targets are treated as AND, so the PC must kill the required number
                of each assigned target object to fulfill this quest step.  A positive nValue creates an inclusive requirement
                and the PC must kill at least that many targets to fulfill the requirement.  An nValue of 0 creates an exclusive
                requirement and the PC cannot kill any of the specified target objects or the quest step will fail.

                This example shows a requirement to kill at least seven orcs, but to not kill the princess.  There is no
                penalty if a non-party member kills the target object.
                    SetQuestStepObjectiveKill("questTag", 1, "creature_orc", 7);
                    SetQuestStepObjectiveKill("questTag", 1, "creature_princess", 0);

            GATHER:
                SetQuestStepObjectiveGather(string sTag, int nStep, string sKey, int nValue = 1)
                    sTag   -> Quest Tag
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object

                This property can be stacked.  Gather targets are treated as AND, so the PC must gather the required number
                of each assigned target object to fulfill this quest step.  This property is inclusive only.

                This examples shows a requirement to gather at least seven flower bouquets and one vase:
                    SetQuestStepObjectiveGather("questTag", 1, "item_bouquet", 7);
                    SetQuestStepObjectiveGather("questTag", 1, "item_vase");

            DELIVER:
                SetQuestStepObjectiveDeliver(string sTag, int nStep, string sKey, int nValue = 1)
                
                TODO - NEED TO FLESH THIS REQUIREMENT OUT A BIT -> It might need more than sKey and nValue to work right.

            DISCOVER:
                SetQuestStepObjectiveDiscover(string sTag, int nStep, string sKey, int nValue = 1)
                    sTag   -> Quest Tag
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object
                
                This property can be stacked.  Discover targets are treated as AND, so the PC must discover the required number
                of each assigned target object to fulfill this quest step.  This property is inclusive only.  Generally, the
                target objects will be triggers or areas to allow for easy identification, but any object with an assigned event
                can be used.

                This example shows a requirement to discover two different locations:
                    SetQuestStepObjectiveDiscover("questTag", 1, "trigger_fishing");
                    SetQuestStepObjectiveDiscover("questTag", 1, "area_hollow");

            SPEAK:
                SetQuestStepObjectiveSpeak(string sTag, int nStep, string sKey)

                This property can be stacked.  Speak targets are treated as AND, so the PC must speak to each of the assigned target
                objects to fulfill this quest step.  This property is inclusive only.

                This example shows a requirement to converse with a store keep NPC:
                    SteQuestStepObjectiveSpeak("questTag", 1, "creature_StoreKeep");

        Prewards - these are game objects or characteristics that are given or assigned to a PC at the beginning of a quest
            step.  They can be used as a reward system for simply accepting a difficult quest (i.e. gold and xp to prepare
            a PC for a difficult journey), to give the PC an item to deliver to another NPC or as a method to modify PC
            characteristics (i.e. changing the PC's alignment when they accept an assassination quest).
        Reward - these are game objects or characteristics that are give or assigned to a PC at the end of a quest step.
            Rewards and prewards share the same types.  The primary difference between rewards and prewards is when they
            are allotted.  Any other minor differences are noted in the descriptions below.

            ALIGNMENT:
                SetQuestStepPrewardAlignment(string sTag, int nStep, int nKey, int nValue)
                SetQuestStepRewardAlignment(string sTag, int nStep, int nKey, int nValue)
                    sTag   -> Quest Tag
                    nStep  -> Quest Step Number
                    nKey   -> ALIGNMENT_* Constant
                    nValue -> Alignment Shift Value

                This property can be stacked.  There should be one call for each alignment.  The PC will be awarded all
                alignment shifts listed.  For details on how alignment shifts work, see the NWN Lexicon entry for
                AdjustAlignment().

                This example shows an alignment preward for accepting an assassination quest:
                    SetQuestStepPrewardAlignment("questTag", 1, ALIGNMENT_EVIL, 20);

                This example show an alignment reward for completing a quest step that protects the local farmer's stock:
                    SetQuestStepRewardAlignment("questTag", 2, ALIGNMENT_GOOD, 20);
                    SetQuestStepRewardAlignment("questTag", 2, ALIGNMENT_LAWFUL, 20);

            GOLD:
                SetQuestStepPrewardGold(string sTag, int nStep, int nKey)
                SetQuestStepRewardGold(string sTag, int nStep, int nKey)
                    sTag   -> Quest Tag
                    nStep  -> Quest Step Number
                    nKey   -> Gold Amount

                This property cannot be stacked.  An nKey greater than zero denotes that a PC will receive the specified
                amount of gold.  An nKey less than zero denotes that the PC will lose the specified amount of gold.

                This example shows the PC paying 5000 gold to gain access to specified quest:
                    SetQuestStepPrewardGold("questTag", 1, -5000);

            ITEM:
                SetQuestStepPrewardItem(string sTag, int nStep, string sKey, int nValue = 1)
                SetQuestStepRewardItem(string sTag, int nStep, string sKey, int nValue = 1)
                    sTag   -> Quest Tag
                    nStep  -> Quest Step Number
                    sKey   -> Tag of [P]reward Item
                    nValue -> Quantity of [P]reward Item

                This property can be stacked.  An nValue of greater than zero denotes that the PC will receive the designated
                number of items when the quest [p]rewards are allotted.  An nValue of less than zero denotes that the PC will
                lose the designated number of items.  Gained and lost items can be stacked.

                This example shows the PC receiving a reward of several items, but losing a prewarded item, upon completion of
                a quest step:
                    SetQuestStepRewardItem("questTag", 3, "item_cakes", 2);
                    SetQuestStepRewardItem("questTag", 3, "item_flour", -1);

            QUEST:
                SetQuestStepRewardQuest(string sTag, int nStep, string sKey, int nValue = TRUE)
                    sTag   -> Quest Tag
                    nStep  -> Quest Step Number
                    sKey   -> Reward Quest Tag
                    nValue -> Assignment Flag

                This property can be stacked.  An nValue of TRUE denotes that the quest should be assigned to the PC.  An nValue
                of FALSE denotes that the quest should be removed from the PC.  By adding a quest as a reward for completing a
                quest, quest chaining is implemented.

                This example show the PC receiving a reward of the next quest in the quest chain and having the current quest
                removed completely:
                    SetQuestStepRewardQuest("questTag", 4, "questTag2");
                    SetQuestStepRewardQuest("questTag", 4, "questTag", FALSE);

            XP:
                SetQuestStepPrewardXP(string sTag, int nStep, int nKey)
                SetquestStepRewardXP(string sTag, int nStep, int nKey)
                    sTag  -> Quest Tag
                    nStep -> Quest Step Number
                    nKey  -> XP Amount

                This property cannot be stacked.  An nValue greater than zero denotes that a PC will receive the specified
                amount of XP.  An nKey value less than zero denotes that the PC will lose the specified amount of XP.

Usage Example:

    Following is a complete usage example for creating a sequential three-step quest that:
        - Requires the PC to be a 3rd-level halfing rogue
        - Requires the PC to break into three houses
        - Requires the PC collect two maps
        - Limits the PC to 24 hours of game time
        - Proved the PC with a set of advanced lockpicks after the find the maps
        - Rewards the PC with Gold, XP and Alignment Shift upon completion
        - Requires the PC report back to the NPC that assigned the quest

    void DefineRogueQuest()
    {
        int nStep;
        string sTag, sJournalEntry;

        // Create the base quest dataitem and set prerequisites
        sTag = "questRogue";
        AddQuest(sTag, "The Rogue's Initiation Quest");

        SetQuestPrerequisiteRace(sTag, RACIAL_TYPE_HALFLING);
        SetQuestPrerequisiteClass(sTag, CLASS_TYPE_ROGUE, 3);
        SetQuestTimeLimit(sTag, CreateSystemTimeVector(0, 0, 0, 24, 0, 0));

        // Step 1 - Find Maps
        sJournalEntry = "The thieve's hideaway can only be found with maps. " +
                        "Find two of these maps to find your way through the " +
                        "maze of thick forest and unrelenting underbrush.";
        nStep = AddQuestStep(sTag, sJournalEntry);
        SetQuestObjectiveGather(sTag, nStep, "map_rogue1");
        SetQuestObjectiveGather(sTag, nStep, "map_rogue2");

        // Step 2 - Break into the houses
        sJournalEntry = "You've found the maps to the thieve's hideaways. " +
                        "Sneak into each of the hideaways and discover what " +
                        "treasures they've been keeping from the guild.";
        nStep = AddQuestStep(sTag, sJournalEntry);
        SetQuestStepObjectiveDiscover(sTag, nStep, "trigger_house1");
        SetQuestStepObjectiveDiscover(sTag, nStep, "trigger_house2");
        SetQuestStepObjectiveDiscover(sTag, nStep, "trigger_house3");
        SetQuestStepPrewardItem(sTag, nStep, "lockpicks_10", 3);

        // Step 3 - Go tell the guild
        sJournalEntry = "You've discovered the treasure horsed the thieves " +
                        "have been hiding from the guild.  Report back to the " +
                        "guild-master and let him know what's going on.";
        nStep = AddQuestStep(sTag, sJournalEntry);
        SetQuestStepObjectiveSpeak(sTag, nStep, "guild_master");
        SetQuestStepRewardGold(sTag, nStep, 1000);
        SetQuestStepRewardXP(sTag, nStep, 500);
        SetQuestStepRewardAlignment(sTag, nStep, ALIGNMENT_CHAOS, 10);
    }

    In order to make this quest work, an event of some type has to call the quest system to
    check if the PC correctly accomplished the steps.  In the Rogue Quest example above,
    it would be necessary to have checks for OnAcquireItem (for the maps), OnTriggerEnter
    (for breaking into the houses) and OnCreatureConversation (for speaking with the NPC);

    This is accomplished by sending a Quest Step Advance Request to the quest system through
    the RequestQuestStepAdvance() function.  If you want to do any pre-processing before calling
    this function, the events are the correct scripts to do that in.  For example, if you set
    a quest step objective to kill a creature, but you only want to count it if that creature is
    killed with a specific weapon or weapon type, you would check those custom prerequisites in
    your script before calling RequestQuestStepAdvance().

    This is a simple example of requesting a quest step advance from the quest system when a creature
    is killed:

    // In the OnCreatureDeath script
    void main()
    {
        string sQuestTag = GetLocalString(OBJECT_SELF, "*QuestTag");
        RequestQuestStepAdvance(GetLastKiller(), sQuestTag);
    }

    The quest system will then evaluate whether the PC has fulfilled the requirements to move forward
    in the quest.  If so, the quest is advanced.  If not, the kill is noted, but the quest does not
    advance.


*/

#include "util_i_datapoint"
#include "util_i_csvlists"
#include "util_i_varlists"
#include "util_i_libraries"
#include "util_i_debug"
#include "util_i_time"

const int QUEST_STEP_ORDER_SEQUENTIAL = 1;
const int QUEST_STEP_ORDER_RANDOM = 2;

// -----------------------------------------------------------------------------
//                          Configuration/Defaults
// -----------------------------------------------------------------------------

// Note:  Change these defaults to suit the needs or your module

// Quest Creation - these are default values only and can be modified for each
//  quest after the quest is created.

// When a new quest is created, the active property will be set to this.  If you
//  don't want new quests to be active immediately, set this to FALSE.
const int QUEST_CONFIG_QUEST_ACTIVE = TRUE;

// Quest Creation Defaults
// When a new quest is created, you can set how many times a PC can complete the
//  quest.  This is a default value only and can be changed for each quest.
const int QUEST_CONFIG_QUEST_REPETITIONS = 1;

// When a new quest is created, the step-order can be sequential or random.  Set
//  this to TRUE for sequential, FALSE for random.
const int QUEST_CONFIG_QUEST_STEP_ORDER = QUEST_STEP_ORDER_SEQUENTIAL;

// This system can be used with the standard game journal system or with the
// external functions made available through NWNX.  If you want to use NWNX
// functions, set this to TRUE;
const int QUEST_CONFIG_USE_NWNX = TRUE;

int GetIsQuestComplete(object oPC, string sTag, int nCompletions = 1);

// -----------------------------------------------------------------------------
//                      LEAVE EVERYTHING BELOW HERE ALONE!
// -----------------------------------------------------------------------------

// Datapoint Object
object QUESTS = GetDatapoint("QUEST_DATA");
const string QUEST_CURRENT_QUEST = "QUEST_CURRENT_QUEST";
const string QUEST_CURRENT_STEP = "QUEST_CURRENT_STEP";

// Quest DataItem Variable Names
const string QUEST_TAG = "QUEST_TAG";
const string QUEST_TITLE = "QUEST_TITLE";

const string QUEST_ACTIVE = "QUEST_ACTIVE";
const string QUEST_REPETITIONS = "QUEST_REPETITIONS";
const string QUEST_STEP_ORDER = "QUEST_STEP_ORDER";
const string QUEST_TIME_LIMIT = "QUEST_TIME_LIMIT";
const string QUEST_SCRIPT_ON_ACCEPT = "QUEST_SCRIPT_ON_ACCEPT";
const string QUEST_SCRIPT_ON_ADVANCE = "QUEST_SCRIPT_ON_ADVANCE";
const string QUEST_SCRIPT_ON_COMPLETE = "QUEST_SCRIPT_ON_COMPLETE";
const string QUEST_DATAITEM_COPY = "QUEST_DATAITEM_COPY";

// Quest DataItem List Names
const string QUEST_STEP = "QUEST_STEP";
const string QUEST_STEP_ID = "QUEST_STEP_ID";
const string QUEST_STEP_JOURNAL_ENTRY = "QUEST_STEP_JOURNAL_ENTRY";
const string QUEST_STEP_TIME_LIMIT = "QUEST_STEP_TIME_LIMIT";
const string QUEST_STEP_PARTY_COMPLETION = "QUEST_STEP_PARTY_COMPLETION";

// Quest PC Variable Names
const string QUEST_PC_QUEST = "QUEST_PC_LIST";
const string QUEST_PC_STATUS = "QUEST_PC_STATUS";
const string QUEST_PC_TIME = "QUEST_PC_TIME";
const string QUEST_PC_COMPLETIONS = "QUEST_PC_COMPLETIONS";

// Quest Categories and Values
const int QUEST_CATEGORY_PREREQUISITE = 0x0100;
const int QUEST_CATEGORY_OBJECTIVE = 0x0200;
const int QUEST_CATEGORY_PREWARD = 0x0300;
const int QUEST_CATEGORY_REWARD = 0x0400;

const int QUEST_VALUE_NONE = 0x00;
const int QUEST_VALUE_ALIGNMENT = 0x01;
const int QUEST_VALUE_CLASS = 0x02;
const int QUEST_VALUE_GOLD = 0x03;
const int QUEST_VALUE_ITEM = 0x04;
const int QUEST_VALUE_LEVEL_MAX = 0x05;
const int QUEST_VALUE_LEVEL_MIN = 0x06;
const int QUEST_VALUE_QUEST = 0x07;
const int QUEST_VALUE_RACE = 0x08;
const int QUEST_VALUE_XP = 0x09;
const int QUEST_VALUE_FACTION = 0x0A;

// Quest Objective Types
const int QUEST_OBJECTIVE_GATHER = 0x01;
const int QUEST_OBJECTIVE_KILL = 0x02;
const int QUEST_OBJECTIVE_DELIVER = 0x03;
const int QUEST_OBJECTIVE_SPEAK = 0x04;
const int QUEST_OBJECTIVE_DISCOVER = 0x05;

// Quest Award Bitmasks
const int AWARD_ALL = 0x00;
const int AWARD_GOLD = 0x01;
const int AWARD_XP = 0x02;
const int AWARD_ITEM = 0x03;
const int AWARD_ALIGNMENT = 0x04;
const int AWARD_QUEST = 0x05;

// Quest Script Types
const int QUEST_SCRIPT_TYPE_ON_ACCEPT = 1;
const int QUEST_SCRIPT_TYPE_ON_ADVANCE = 2;
const int QUEST_SCRIPT_TYPE_ON_COMPLETE = 3;

// Variable Validity
const string REQUEST_INVALID = "REQUEST_INVALID";

// Odds & Ends
const int QUEST_PAIR_KEYS = 1;
const int QUEST_PAIR_VALUES = 2;

string GetQuestTimeLimit(string sTag);
string GetQuestStepTimeLimit(string sTag, int nStep);

// -----------------------------------------------------------------------------
//                          Public Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddQuest >---
// Adds a new quest with tag sTag and Journal Entry Title sTitle.  sTag is required;
// the Journal Entry title can be added later with SetQuestTitle().
int AddQuest(string sTag, string sTitle = "JOURNAL TITLE NOT ASSIGNED");

// ---< DeleteQuest >---
// Deletes all data associated with quest sTag
void DeleteQuest(string sTag);

// ---< AddQuestStep >---
// Adds a new quest step to quest sTag with Journal Entry sJournalEntry.  The quest
//  step's journal entry can be added at a later time with SetQuestStepJournalEntry().
//  Returns the new quest step for use in assigning quest step variables.
int AddQuestStep(string sTag, string sJournalEntry = "JOURNAL ENTRY NOT ASSIGNED", int nID = -1);

// ---< AssignQuest >---
// Assigns quest sTag to player object oPC.  Does not check for quest elgibility. 
// GetIsQuestAssignable() should be run before calling this procedure to ensure the PC
// meets all prerequisites for quest assignment.
void AssignQuest(object oPC, string sTag);

// ---< CountQuestCompletions >---
// Returns the number of times oPC has copmleted quest sTag
int CountQuestCompletions(object oPC, string sTag);

// ---< GetStepQuantityRemaining >---
// Returns the remining quest step quanity oPC needs to complete nStep of quest sTag
int GetStepQuantityRemaining(object oPC, string sTag, int nStep);

// ---< AdvanceQuestStep >---
// Called from events associated with quest-related objects, will determine whether oPC
// has completed nStep of quest sTag.  The quest will be advanced by one step if the step
// is complete, otherwise the step quantity remaining will be reducedd by nQuantity.  If
// step and/or quest is complete, associated scripts will be run, rewards and prewards
// assigned.
void AdvanceQuestStep(object oPC, string sTag, int nStep, int nQuantity = 1, int bForce = FALSE);

// ---< CountQuestStepsCompleted >---
// Returns the numbers of quest steps oPC completed for quest sTag.
int CountQuestStepsCompleted(object oPC, string sTag);

// ---< GetIsQuestComplete >---
// Returns whether oPC has completed quest sTag at least nCompletions times.
int CountIsQuestComplete(object oPC, string sTag, int nCompletions = 1);
// TODO CountQuestCompletions?

// ---< GetIsQuestAssignable >---
// Returns whether oPC meets all prerequisites for quest sTag.  If nStep is passed,
// will evaluate reprequisites for a specific step.  Quest prerequisites can only
// be satisfied by the PC object, not party members.
int GetIsQuestAssignable(object oPC, string sTag, int nStep = 0);

// ---< AwardQuestStep[Prewards|Rewards] >---
// Awards all nStep prewards|rewards associated with quest sTag to oPC.  If bParty, prewards will
// also be assigned to all party members.  Prewards|Rewards will be limited to nAwardType.
void AwardQuestStepPrewards(object oPC, string sTag, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL);
void AwardQuestStepRewards(object oPC, string sTag, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL);

// ---< [Get|Set]QuestTitle >---
// Gets or sets the quest title shown for quest sTag in the player's journal
string GetQuestTitle(string sTag);
void SetQuestTitle(string sTag, string sTitle);

// ---< [Get|Set]Quest[Active|Inactive] >---
// Gets or sets the active status of quest sTag.
int GetQuestActive(string sTag);
void SetQuestActive(string sTag);
void SetQuestInactive(string sTag);

// ---< [Get|Set]QuestRepetitions >---
// Gets or sets the number of times a PC can complete quest sTag
int GetQuestRepetitions(string sTag);
void SetQuestRepetitions(string sTag, int nRepetitions = 1);

// ---< [Get|Set]QuestStepOrder >---
// Gets or sets the quest step order for quest sTag to nOrder.
// nOrder can be:
//  QUEST_STEP_ORDER_SEQUENTIAL
//  QUEST_STEP_ORDER_NONSEQUENTIAL
int GetQuestStepOrder(string sTag);
void SetQuestStepOrder(string sTag, int nOrder = QUEST_STEP_ORDER_SEQUENTIAL);

// ---< [Get|Set]QuestScriptOn[Accept|Advance|Complete] >---
// Gets or sets the script associated with quest events OnAccept|Advance|Complete for
//  quest sTag.
string GetQuestScriptOnAccept(string sTag);
string GetQuestScriptOnAdvance(string sTag);
string GetQuestScriptOnComplete(string sTag);
void SetQuestScriptOnAccept(string sTag, string sScript = "");
void SetQuestScriptOnAdvance(string sTag, string sScript = "");
void SetQuestScriptOnComplete(string sTag, string sScript = "");

// ---< [Get|Set]QuestStepJournalEntry >---
// Gets or sets the journal entry associated with nStep of quest sTag
string GetQuestStepJournalEntry(string sTag, int nStep);
void SetQuestStepJournalEntry(string sTag, int nStep, string sJournalEntry);

// ---< [Get|Set]QuestStepPartyCompletion >---
// Gets or sets the ability to allow party members to help complete quest steps
int GetQuestStepPartyCompletion(string sTag, int nStep);
void SetquestStepPartyCompletion(string sTag, int nStep, int nParty = FALSE);

// ---< SetQuestPrerequisite[Alignment|Class|Gold|Items|LevelMax|LevelMin|Quest|Race] >---
// Sets a prerequisite for a PC to be able to be assigned a quest.  Used by
//  GetIsQuestAssignable() to determine if a PC is eligible to be assigned quest sTag
void SetQuestPrerequisiteAlignment(string sTag, int nKey, int nValue = FALSE);
void SetQuestPrerequisiteClass(string sTag, int nKey, int nValue = -1);
void SetQuestPrerequisiteGold(string sTag, int nValue = 1);
void SetQuestPrerequisiteItem(string sTag, string sKey, int nValue);
void SetQuestPrerequisiteLevelMax(string sTag, int nValue);
void SetQuestPrerequisiteLevelMin(string sTag, int nValue);
void SetQuestPrerequisiteQuest(string sTag, string sKey, int nValue = 0);
void SetQuestPrerequisiteRace(string sTag, int nKey, int nValue = TRUE);

// ---< SetQuestStepObjective[Kill|Gather|Deliver|Discover|Speak] >---
// Sets the objective type for a specified quest step
void SetQuestStepObjectiveKill(string sTag, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveGather(string sTag, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveDeliver(string sTag, int nStep, string sKey, string sValue);
void SetQuestStepObjectiveDiscover(string sTag, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveSpeak(string sTag, int nStep, string sKey, int nValue = 1);

// ---< SetQuestStep[Preward|Reward][Alignment|Gold|Item|XP] >---
// Sets nStep's preward or reward
void SetQuestStepPrewardAlignment(string sTag, int nStep, int nKey, int nValue);
void SetQuestStepPrewardGold(string sTag, int nStep, int nKey, int nValue = FALSE);
void SetQuestStepPrewardItem(string sTag, int nStep, string sKey, int nValue = 1);
void SetQuestStepPrewardXP(string sTag, int nStep, int nKey, int nValue = 0);
void SetQuestStepRewardAlignment(string sTag, int nStep, int nKey, int nValue);
void SetQuestStepRewardGold(string sTag, int nStep, int nKey);
void SetQuestStepRewardItem(string sTag, int nStep, string sKey, int nValue = 1);
void SetQuestStepRewardXP(string sTag, int nStep, int nKey, int nValue = 0);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

// ---< _GetQuestDataItem >---
// Returns the dataitem object associated with sQuestTag; if the dataitem
//  doesn't exist, it will be created on the QUESTS datapoint.
object _GetQuestDataItem(string sQuestTag)
{
    object oQuest = GetDataItem(QUESTS, sQuestTag);

    if (!GetIsObjectValid(oQuest))
        oQuest = CreateDataItem(QUESTS, sQuestTag);

    return oQuest;
}

// ---< _DeleteQuestDataItem >---
// Deletes the dataitem related to sQuestTag; this will destroy all
//  data associated with sQuestTag.
void _DeleteQuestDataItem(string sTag)
{
    object oQuest = _GetQuestDataItem(sTag);
    DestroyObject(oQuest);
}

// Gets the index of quest sTag on oPC's quest listing
int _GetQuestIndex(object oPC, string sTag)
{
    return FindListString(oPC, sTag, QUEST_PC_QUEST);
}

// Get the index of nStep from the quest step listing for quest sTag
int _GetQuestStepIndex(string sTag, int nStep)
{
    object oQuest = _GetQuestDataItem(sTag);
    return FindListInt(oQuest, nStep, QUEST_STEP_ID);
}

// Gets the value of sProperty from sTag
string _GetQuestPropertyString(string sTag, string sProperty, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag);
    int nIndex;

    if (nStep <= 0)
        return GetLocalString(oQuest, sProperty);
    else
    {
        if ((nIndex = _GetQuestStepIndex(sTag, nStep)) == -1)
            return REQUEST_INVALID;
        
        return GetListString(oQuest, nIndex, sProperty);
    }

    return REQUEST_INVALID;
}

// Sets the value of sProperty on sTag to sValue
void _SetQuestPropertyString(string sTag, string sProperty, string sValue, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag);
    int nIndex;

    if (nStep <= 0)
        SetLocalString(oQuest, sProperty, sValue);
    else
    {
        if ((nIndex = _GetQuestStepIndex(sTag, nStep)) == -1)
            // TODO Should this be an add if it doesn't exist?
            return;

        SetListString(oQuest, nIndex, sValue, sProperty);
    }
}

void _DeleteQuestPropertyString(string sTag, string sProperty, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag):
    int nIndex;

    if (nStep <= 0)
        DeleteLocalString(oQuest, sProperty);
    else
    {
        if ((nIndex = _GetQuestStepIndex(sTag, nStep)) == -1)
            return;

        DeleteListString(oQuest, nIndex, sProperty);
    }
}

// Get the value of sProperty from sTag
int _GetQuestPropertyInt(string sTag, string sProperty, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag);
    int nIndex;

    if (nStep <= 0)
        return GetLocalInt(oQuest, sProperty);
    else
    {
        if ((nIndex = _GetQuestStepIndex(sTag, nStep)) == -1)
            return FALSE;
        
        return GetListInt(oQuest, nIndex, sProperty);
    }

    return FALSE;
}

// Sets the value of sProperty on sTag to nValue
void _SetQuestPropertyInt(string sTag, string sProperty, int nValue, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag);
    int nIndex;

    if (nStep <= 0)
        SetLocalInt(oQuest, sProperty, nValue);
    else
    {
        if ((nIndex = _GetQuestStepIndex(sTag, nStep)) == -1)
            return;
        
        SetListInt(oQuest, nIndex, nValue, sProperty);
    }
}

void _DeleteQuestPropertyInt(string sTag, string sProperty, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag):
    int nIndex;

    if (nStep <= 0)
        DeleteLocalInt(oQuest, sProperty);
    else
    {
        if ((nIndex = _GetQuestStepIndex(sTag, nStep)) == -1)
            return;

        DeleteListInt(oQuest, nIndex, sProperty);
    }
}

// Gets varlist data from the quest data item
string _GetQuestStepData(string sTag, int nCategory, int nPair = QUEST_PAIR_KEYS, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag);
    string sPrefix = QUEST_STEP + IntToString(nStep);

    string sCategoryList = sPrefix + "_CATEGORY";
    string sKeyList = sPrefix + "_KEYS";
    string sValueList = sPrefix + "_VALUES";

    int nIndex = FindListInt(oQuest, nCategory, sCategoryList);
    if (nIndex != -1)
    {
        string sList = (nPair == QUEST_PAIR_KEYS ? sKeyList : sValueList);
        return GetListString(oQuest, nIndex, sList);
    }
    
    return REQUEST_INVALID;
}

int _GetIsPropertyStackable(int nCategory)
{
    int nValueType = nCategory & 0x00ff;
    if (nValueType == QUEST_VALUE_GOLD ||
        nValueType == QUEST_VALUE_LEVEL_MAX ||
        nValueType == QUEST_VALUE_LEVEL_MIN ||
        nValueType == QUEST_VALUE_XP)
        return FALSE;
    else
        return TRUE;
}

int _GetEncodingShift(int nElements)
{
    return 32 / nElements - 1;
}

int _GetEncodedValue(int nValue, int nValueCount, int nIndex)
{
    int nShift = _GetEncodingShift(nValueCount);
    return (nValue >> nIndex * nShift) & ((1 << nShift) - 1);
}

int _AddEncodedValue(int nValue, int nValueCount, int nValueToAdd)
{
    if (nValueCount == 0)
        return nValueToAdd;

    int n, nElement, nResult, nShift;
    nShift = _GetEncodingShift(nValueCount + 1);

    for (n = 0; n < nValueCount; n++)
    {
        nElement = _GetEncodedValue(nValue, nValueCount, n);
        nResult |= nElement << n * nShift;
    }

    return nResult |= nValueToAdd << n * nShift;
}

int _RemoveEncodedValue(int nValue, int nValueCount, int nIndex)
{
    int n, nCount, nElement, nResult;
    int nCurrentShift = _GetEncodingShift(nValueCount);
    int nNewShift = _GetEncodingShift(nValueCount - 1);

    for (n = 0; n < nValueCount; n++)
    {
        nElement = (nValue >> n * nCurrentShift) & ((1 << nCurrentShift) - 1);
        if (n != nIndex)
            nResult |= nElement << nCount++ * nNewShift;
    }

    return nResult;
}

int _UpdateEncodedValue(int nValue, int nValueCount, int nIndex, int nNewValue)
{
    int nShift = _GetEncodingShift(nValueCount);
    int n, nElement, nResult;

    for (n = 0; n < nValueCount; n++)
    {
        nElement = (nValue >> n * nShift) & ((1 << nShift) - 1);
        nResult |= (n == nIndex ? nNewValue : nElement) << n * nShift;
    }

    return nResult;
}

int _IncrementEncodedValue(int nValue, int nValueCount, int nIndex, int nIncrement = 1)
{
    _UpdateEncodedValue(nValue, nValueCount, nIndex, _GetEncodedValue(nValue, nValueCount, nIndex) + nIncrement);
}

int _DecrementEncodedValue(int nValue, int nValueCount, int nIndex, int nDecrement = 1)
{
    _UpdateEncodedValue(nValue, nValueCount, nIndex, _GetEncodedValue(nValue, nValueCount, nIndex) - nDecrement);
}

// Sets varlist data on the quest data item
void _SetQuestStepData(string sTag, int nCategory, string sKey, string sValue, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag);
    int nVarIndex, nCSVIndex;
    string sKeys, sValues;

    string sPrefix = QUEST_STEP + IntToString(nStep);
    string sCategoryList = sPrefix + "_CATEGORY";
    string sKeyList = sPrefix + "_KEYS";
    string sValueList = sPrefix + "_VALUES";

    if ((nVarIndex = FindListInt(oQuest, nCategory, sCategoryList)) != -1)
    {
        if (_GetIsPropertyStackable(nCategory))
        {
            sKeys = _GetQuestStepData(sTag, nCategory, QUEST_PAIR_KEYS, nStep);
            sValues = _GetQuestStepData(sTag, nCategory, QUEST_PAIR_VALUES, nStep);

            if ((nCSVIndex = FindListItem(sKeys, sKey)) != -1)
            {
                sKeys = DeleteListItem(sKeys, nCSVIndex);
                sValues = DeleteListItem(sValues, nCSVIndex);
            }
        }
    }

    sKeys = AddListItem(sKeys, sKey);
    sValues = AddListItem(sValues, sValue);

    if (nVarIndex == -1)
    {
        AddListInt(oQuest, nCategory, sCategoryList);
        AddListString(oQuest, sKeys, sKeyList);
        AddListString(oQuest, sValues, sValueList);
    }
    else
    {
        SetListString(oQuest, nVarIndex, sKeys, sKeyList);
        SetListString(oQuest, nVarIndex, sValues, sValueList);
    }
}

void _DeleteQuestStepData(string sTag, int nCategory, int nStep = 0)
{
    object oQuest = _GetQuestDataItem(sTag);
        
    string sPrefix = QUEST_STEP + IntToString(nStep);
    string sCategoryList = sPrefix + "_CATEGORY";
    string sKeyList = sPrefix + "_KEYS";
    string sValueList = sPrefix + "_VALUES";

    int n, nProperty, nCount = CountIntList(oQuest, sCategoryList);

    for (n = 0; n < nCount; n++)
    {
        nProperty = GetListInt(oQuest, n, sCategoryList);
        if (nProperty & 0xff00 == nCategory)
        {
            DeleteListInt(oQuest, n, sCategoryList);
            DeleteListString(oQuest, n, sKeyList);
            DeleteListString(oQuest, n, sValueList);
            return;
        }
    }
}

// Counts the number of quest prerequisites for quest sTag
int _CountQuestPrerequisites(string sTag)
{
    object oQuest = _GetQuestDataItem(sTag);
    return CountIntList(oQuest, QUEST_STEP + "0_CATEGORY");
}

// Counts the number of steps in quest sTag
int _CountQuestSteps(string sTag)
{
    object oQuest = _GetQuestDataItem(sTag);
    return CountIntList(oQuest, QUEST_STEP_ID);
}

// Private accessor for setting quest prerequisites
void _SetQuestPrerequisite(string sTag, int nValueType, string sKey, string sValue)
{
    int nCategory = QUEST_CATEGORY_PREREQUISITE;
    _SetQuestStepData(sTag, nCategory + nValueType, sKey, sValue);
}

int _GetObjectiveTypesMatch(string sTag, int nStep, int nValueType)
{
    object oQuest = _GetQuestDataItem(sTag);
    string sPrefix = QUEST_STEP + IntToString(nStep);
    string sCategoryList = sPrefix + "_CATEGORY";

    int n, nCategory, nCount = CountIntList(oQuest, sCategoryList);
    for (n = 0; n < nCount; n++)
    {
        nCategory = GetListInt(oQuest, n, sCategoryList);
        if (nCategory & 0xff00 == QUEST_CATEGORY_OBJECTIVE)
            return nCategory & 0x00ff == nValueType;
    }

    // If we're here, no objective categories were found, so allow the add
    return TRUE;
}

// Private accessor for setting quest step objectives
void _SetQuestObjective(string sTag, int nValueType, string sKey, string sValue, int nStep)
{
    if (_GetObjectiveTypesMatch(sTag, nStep, nValueType))
    {
        int nCategory = QUEST_CATEGORY_OBJECTIVE;
        _SetQuestStepData(sTag, nCategory + nValueType, sKey, sValue, nStep);
    }
    else
    {
        if (_GetQuestPropertyInt(sTag, QUEST_DATAITEM_COPY))
        {
            _DeleteQuestPropertyInt(sTag, QUEST_DATAITEM_COPY));
            _DeleteQuestStepData(sTag, QUEST_CATEGORY_OBJECTIVE);
            _SetQuestObjective(sTag, nValueType, sKey, sValue, nStep);
        }
    }
}

// Private accessor for setting quest step prewards
void _SetQuestPreward(string sTag, int nValueType, string sKey, string sValue, int nStep)
{
    int nCategory = QUEST_CATEGORY_PREWARD;
    _SetQuestStepData(sTag, nCategory + nValueType, sKey, sValue, nStep);
}

// Private accessor for setting quest step rewards
void _SetQuestReward(string sTag, int nValueType, string sKey, string sValue, int nStep)
{
    int nCategory = QUEST_CATEGORY_REWARD;
    _SetQuestStepData(sTag, nCategory + nValueType, sKey, sValue, nStep);
}

// Sets the step quantities values for quest sTag onto oPC
void _SetPCStepQuantities(object oPC, string sTag, string sQuantities)
{
    int nIndex= _GetQuestIndex(oPC, sTag);
    SetListString(oPC, nIndex, sQuantities, QUEST_PC_STATUS);
}

// Gets the step quantities for quest sTag from oPC
string _GetPCStepQuantities(object oPC, string sTag)
{
    int nIndex = _GetQuestIndex(oPC, sTag);
    return GetListString(oPC, nIndex, QUEST_PC_STATUS);
}

// Aggregates the step quantities for each step of quest sTag to create a
// starting point for quest completion.

// TODO redo this with the new encoded int values
string _GetQuestStepQuantities(string sTag)
{
    string sQuantities;
    object oQuest = _GetQuestDataItem(sTag);

    int nStep, nSteps = _CountQuestSteps(sTag);
    for (nStep = 0; nStep < nSteps; nStep++)
    {
        string sPrefix = QUEST_STEP + IntToString(nStep);
        string sCategoryList = sPrefix + "_CATEGORY";
        string sKeyList = sPrefix + "_KEYS";
        string sValueList = sPrefix + "_VALUES";
        string sKeys, sValues;

        int n, nCategory, nCategories = CountIntList(oQuest, sCategoryList);
        for (n = 0; n < nCategories; n++)
        {
            nCategory = GetListInt(oQuest, n, sCategoryList);
            sKeys = GetListString(oQuest, n, sKeyList);
            sValues = GetListString(oQuest, n, sValueList);

            if (nCategory & 0xff00 == QUEST_CATEGORY_OBJECTIVE)
                sQuantities = AddListItem(sQuantities, sValues);
        }
    }

    return sQuantities;
}

// Checks to see if oPC or their party members have at least nMinQuantity of sItemTag
int _HasMinimumItemCount(object oPC, string sItemTag, int nMinQuantity = 1, int bIncludeParty = FALSE)
{
    int nItemCount = 0;
    object oItem = GetItemPossessedBy(oPC, sItemTag);
    if (GetIsObjectValid(oItem))
    {
        oItem = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oItem))
        {
            if (GetTag(oItem) == sItemTag)
                nItemCount += GetNumStackedItems(oItem);

            if (nItemCount >= nMinQuantity)
                return TRUE;

            oItem = GetNextItemInInventory(oPC);
        }
    }

    // We haven't met the minimum yet, so let's check the other party members.
    if (bIncludeParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            oItem = GetItemPossessedBy(oPC, sItemTag);
            if (GetIsObjectValid(oItem))
            {
                oItem = GetFirstItemInInventory(oPartyMember);
                while (GetIsObjectValid(oItem))
                {
                    if (GetTag(oItem) == sItemTag)
                        nItemCount += GetItemStackSize(oItem);
                    
                    if (nItemCount >= nMinQuantity)
                        return TRUE;

                    oItem = GetNextItemInInventory(oPartyMember);
                }
            }

            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }

    return FALSE;
}

// Awards gold to oPC and/or their party members
void _AwardGold(object oPC, int nGold, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            if (nGold < 0)
                TakeGoldFromCreature(abs(nGold), oPartyMember, TRUE);
            else
                GiveGoldToCreature(oPartyMember, nGold);
            
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        if (nGold < 0)
            TakeGoldFromCreature(abs(nGold), oPC, TRUE);
        else
            GiveGoldToCreature(oPC, nGold);
    }
}

// Awards XP to oPC and/or their party members
void _AwardXP(object oPC, int nXP, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            SetXP(oPartyMember, GetXP(oPartyMember) + nXP);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        SetXP(oPC, GetXP(oPC) + nXP);
}

int GetIsQuestAssigned(object o, string s)
{
    // see if the quest is on the list
    // if not, false
    // if so, see if quest is complete
    // if not complete, true, if complete false
    return TRUE;
}

void UnassignQuest(object o, string s)
{
    // Get index
    // Delete all data
}

void _AwardQuest(object oPC, string sQuest, int nFlag = TRUE, int bParty = FALSE)
{
    int nAssigned, nComplete;

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            nAssigned = GetIsQuestAssigned(oPartyMember, sQuest);
            nComplete = GetIsQuestComplete(oPartyMember, sQuest);

            if (nFlag)
            {
                if (!nAssigned || (nAssigned && nComplete))
                    AssignQuest(oPartyMember, sQuest);
            }
            else
                UnassignQuest(oPartyMember, sQuest);
            
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        nAssigned = GetIsQuestAssigned(oPC, sQuest);
        nComplete = GetIsQuestComplete(oPC, sQuest);

        if (nFlag)
        {
            if (!nAssigned || (nAssigned && nComplete))
                AssignQuest(oPC, sQuest);
        }
        else
            UnassignQuest(oPC, sQuest);
    }
}

// Awards item(s) to oPC and/or their party members
void _AwardItem(object oPC, string sResref, int nQuantity, int bParty = FALSE)
{
    int nCount;
    object oItem;

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);

        while (GetIsObjectValid(oPartyMember))
        {
            nCount = nQuantity;
            if (nCount < 0)
            {
                while (nCount < 0)
                {
                    oItem = GetItemPossessedBy(oPartyMember, sResref);
                    DestroyObject(oItem);
                    nCount++;
                }
            }
            else
                CreateItemOnObject(sResref, oPartyMember, nQuantity);

            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        nCount = nQuantity;
        if (nCount < 0)
        {
            while (nCount < 0)
            {
                oItem = GetItemPossessedBy(oPC, sResref);
                DestroyObject(oItem);
                nCount++;
            }
        }
        else
            CreateItemOnObject(sResref, oPC, nQuantity);
    }
}

// Awards alignment shift to oPC and/or their party members
void _AwardAlignment(object oPC, int nAxis, int nShift, int bParty = FALSE)
{
    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            AdjustAlignment(oPartyMember, nAxis, nShift, FALSE);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        AdjustAlignment(oPC, nAxis, nShift, FALSE);
}

// Sends a journal quest entry to either the nwn game or through nwnx
void _SendJournalEntry(object oPC, string sTag, int nStep)
{
    Notice ("Send Journal Entry");
    // Send journal entry via nwnx! ???

}

int _GetQuestExists(string sTag)
{
    object oQuest = _GetQuestDataItem(sTag);
    return GetIsObjectValid(oQuest);
}

// Awards quest sTag step nStep [p]rewards.  The awards type will be limited by nAwardType and can be
// provided to the entire party with bParty.  nCategoryType is a QUEST_CATEGORY_* constant.
void _AwardQuestStepAllotments(object oPC, string sTag, int nCategoryType, int nStep, int nAwardType, int bParty = FALSE)
{
    object oQuest = _GetQuestDataItem(sTag);
    
    string sPrefix = QUEST_STEP + IntToString(nStep);
    string sCategoryList = sPrefix + "_CATEGORY";
    string sKeyList = sPrefix + "_KEYS";
    string sValueList = sPrefix + "_VALUES";
    string sKeys, sValues;
    
    int n, nCategory, nCount = CountIntList(oQuest, sCategoryList);
    for (n = 0; n < nCount; n++)
    {
        nCategory = GetListInt(oQuest, n, sCategoryList);
        sKeys = GetListString(oQuest, n, sKeyList);
        sValues = GetListString(oQuest, n, sValueList);

        if (nCategory & 0xff00 == nCategoryType)
        {
            switch (nCategory & 0x00ff)
            {
                case QUEST_VALUE_GOLD:
                {
                    if ((nAwardType && AWARD_GOLD) || nAwardType == AWARD_ALL)
                    {
                        int nGold = StringToInt(sValues);
                        _AwardGold(oPC, nGold, bParty);
                    }
                    continue;
                }
                case QUEST_VALUE_XP:
                {
                    if ((nAwardType && AWARD_XP) || nAwardType == AWARD_ALL)
                    {
                        int nXP = StringToInt(sValues);
                        _AwardXP(oPC, nXP, bParty);
                    }
                    continue;
                }
                case QUEST_VALUE_ALIGNMENT:
                {
                    if ((nAwardType && AWARD_ALIGNMENT) || nAwardType == AWARD_ALL)
                    {
                        int n, nAxis, nShift, nCount = CountList(sKeys);
                        for (n = 0; n < nCount; n++)
                        {
                            nAxis = StringToInt(GetListItem(sKeys, n));
                            nShift = StringToInt(GetListItem(sValues, n));
                            _AwardAlignment(oPC, nAxis, nShift, bParty);
                        }
                    }
                    continue;
                }  
                case QUEST_VALUE_ITEM:
                {
                    if ((nAwardType && AWARD_ITEM) || nAwardType == AWARD_ALL)
                    {
                        int n, nQuantity, nCount = CountList(sKeys);
                        string sResref;
                    
                        for (n = 0; n < nCount; n++)
                        {
                            sResref = GetListItem(sKeys, n);
                            nQuantity = StringToInt(GetListItem(sValues, n));
                            _AwardItem(oPC, sResref, nQuantity, bParty);
                        }
                    }
                }
                case QUEST_VALUE_QUEST:
                {
                    if ((nAwardType && AWARD_QUEST) || nAwardType == AWARD_ALL)
                    {
                        int n, nFlag, nCount = CountList(sKeys);
                        string sTag;

                        for (n = 0; n < nCount; n++)
                        {
                            sTag = GetListItem(sKeys, n);
                            nFlag = StringToInt(GetListItem(sValues, n));
                            _AwardQuest(oPC, sTag, nFlag, bParty);
                        }
                    }
                }
            }
        }
    }
}

/*
void _AddJournalEntry(object oPC, string sTag, int nID = 1, int bParty = FALSE)
{
    // NWN game stuff uses a "category" to find the right quest, similar to sTag
    // Also uses an id to set the correct step, which is essentially the step id.

    AddJournalQuestEntry()




    void AddJournalQuestEntry(
    string sCategoryTag,
    int nEntryID,
    object oCreature,
    int bAllPartyMembers = TRUE,
    int bAllPlayers = FALSE,
    int bAllowOverrideHigher = FALSE
);

}*/


void dhAddJournalQuestEntry(string strCategoryTag, int iEntryId, object oCreature,
        int bAllPartyMembers = TRUE, int bAllPlayers = FALSE, int bAllowOverrideHigher = FALSE,
        int bMarkAsFinished = FALSE);


// Debug function to provide a human readable string to replace bitwise category integers
// in debug messages
string _GetStringFromCategory(int nCategory)
{
    string sResult;

    switch (nCategory & 0xff00)
    {
        case QUEST_CATEGORY_OBJECTIVE:
            sResult = "Objective";
            switch (nCategory & 0x00ff)
            {
                case QUEST_OBJECTIVE_GATHER:
                    return sResult += " (Gather)";
                case QUEST_OBJECTIVE_KILL:
                    return sResult += " (Kill)";
                case QUEST_OBJECTIVE_DELIVER:
                    return sResult += " (Deliver)";
                case QUEST_OBJECTIVE_SPEAK:
                    return sResult += " (Speak)";
                case QUEST_OBJECTIVE_DISCOVER:
                    return sResult += " (Discover)";
            }
        case QUEST_CATEGORY_PREREQUISITE:
            sResult = "Prerequisite";
            break;
        case QUEST_CATEGORY_PREWARD:
            sResult = "Preward";
            break;
        case QUEST_CATEGORY_REWARD:
            sResult = "Reward";
    }

    switch (nCategory & 0x00ff)
    {
        case QUEST_VALUE_ALIGNMENT:
            return sResult += " (Alignment)";
        case QUEST_VALUE_CLASS:
            return sResult += " (Class)";
        case QUEST_VALUE_GOLD:
            return sResult += " (Gold)";
        case QUEST_VALUE_ITEM:
            return sResult += " (Item)";
        case QUEST_VALUE_LEVEL_MAX:
            return sResult += " (Max Level)";
        case QUEST_VALUE_LEVEL_MIN:
            return sResult += " (Min Level)";
        case QUEST_VALUE_QUEST:
            return sResult += " (Quest)";
        case QUEST_VALUE_RACE:
            return sResult += " (Race)";
        case QUEST_VALUE_XP:
            return sResult += " (XP)";
        case QUEST_VALUE_FACTION:
            return sResult += " (Faction)";
            // TODO REPUATION instead of FACTION?
    }

    return REQUEST_INVALID;
}

// TODO Add meaningful error messages to all procedures

// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

string AddQuest(string sTag, string sTitle = "JOURNAL TITLE NOT ASSIGNED")
{
    if (_GetQuestExists(sTag) || sTag == "")
        return REQUEST_INVALID;
    
    Notice("Adding quest " + sTag +
           "\n  Jounral Title -> " + sTitle);

    object oQuest = _GetQuestDataItem(sTag);
    
    // Quest Identification Variables
    SetLocalString(oQuest, QUEST_TAG, sTag);
    SetLocalString(oQuest, QUEST_TITLE, sTitle);

    // Default Quest Properties
    SetLocalInt(oQuest, QUEST_ACTIVE, QUEST_CONFIG_QUEST_ACTIVE);
    SetLocalInt(oQuest, QUEST_REPETITIONS, QUEST_CONFIG_QUEST_REPETITIONS);
    SetLocalInt(oQuest, QUEST_STEP_ORDER, QUEST_CONFIG_QUEST_STEP_ORDER);

    return sTag;
}

string CopyQuest(string sTag, string sNewTag, string sTitle = "")
{
    if (_GetQuestExists(sTag))
    {
        if (sNewTag == "" || sNewTag == sTag || _GetQuestExists(sNewTag))
            return REQUEST_INVALID;

        // Copy the quest dataitem and set the correct variables to identify it
        object oQuest = CopyItem(_GetQuestDataItem(sTag), QUESTS, TRUE);
        SetLocalObject(QUESTS, sNewTag, oQuest);
        SetName(oQuest, sNewTag);

        // Ensure the new tag is on this dataitem
        SetLocalString(oQuest, QUEST_TAG, sNewTag);
        if (sTitle != "")
            SetLocalString(oQuest, QUEST_TITLE, sTitle);

        SetQuestPropertyInt(sNewTag, QUEST_DATAITEM_COPY, TRUE);
        return sNewTag;
    }
    else
        return REQUEST_INVALID;
}

void DeleteQuest(string sTag)
{
    _DeleteQuestDataItem(sTag);
}

void RunQuestScript(object oPC, string sTag, int nScriptType, int nStep = 0)
{
    string sScript;
    int bSetStep = FALSE;

    if (nScriptType = QUEST_SCRIPT_TYPE_ON_ACCEPT)
        sScript = GetQuestScriptOnAccept(sTag);
    else if (nScriptType = QUEST_SCRIPT_TYPE_ON_ADVANCE)
    {
        sScript = GetQuestScriptOnAdvance(sTag);
        bSetStep = TRUE;
    }
    else if (nScriptType = QUEST_SCRIPT_TYPE_ON_COMPLETE)
        sScript = GetQuestScriptOnComplete(sTag);

    if (sScript == "")
        return;
    
    SetLocalString(QUESTS, QUEST_CURRENT_QUEST, sTag);
    if (bSetStep)
        SetLocalInt(QUESTS, QUEST_CURRENT_STEP, nStep);

    RunLibraryScript(sScript, oPC);

    DeleteLocalString(QUESTS, QUEST_CURRENT_QUEST);
    DeleteLocalInt(QUESTS, QUEST_CURRENT_STEP);
}

int AddQuestStep(string sTag, string sJournalEntry = "JOURNAL ENTRY NOT ASSIGNED", int nID = -1)
{   
    int nStep;
    object oQuest = _GetQuestDataItem(sTag);
    
    // This checks allows use of journal quest entries from the toolset.  nID should only be
    //  used when the builder is using the toolset journal editor.  If using NWNX, the quest system
    //  will create the step id.
    if (nID != -1)
        nStep = nID;
    else
        nStep = CountIntList(oQuest, QUEST_STEP_ID) + 1;

    // Quest Step Properties
    AddListInt   (oQuest, nStep, QUEST_STEP_ID);
    AddListString(oQuest, sJournalEntry, QUEST_STEP_JOURNAL_ENTRY);
    AddListString(oQuest, "", QUEST_STEP_TIME_LIMIT);
    AddListInt   (oQuest, 0, QUEST_STEP_PARTY_COMPLETION);

    return nStep;
}

void AssignQuest(object oPC, string sTag)
{
    if (AddListString(oPC, sTag, QUEST_PC_QUEST, TRUE))
    {
        AddListString(oPC, _GetQuestStepQuantities(sTag), QUEST_PC_STATUS);
        AddListString(oPC, GetSystemTime(), QUEST_PC_TIME);
        AddListInt   (oPC, 0, QUEST_PC_COMPLETIONS);
    }
    else
    {
        int nIndex = _GetQuestIndex(oPC, sTag);
        SetListString(oPC, nIndex, _GetQuestStepQuantities(sTag), QUEST_PC_STATUS);
        SetListString(oPC, nIndex, GetSystemTime(), QUEST_PC_TIME);
    }

    RunQuestScript(oPC, sTag, QUEST_SCRIPT_TYPE_ON_ACCEPT, 0);
}

int CountQuestCompletions(object oPC, string sTag)
{
    int nIndex = _GetQuestIndex(oPC, sTag);
    return GetListInt(oPC, nIndex, QUEST_PC_COMPLETIONS);
}

int GetStepQuantityRemaining(object oPC, string sTag, int nStep)
{
    string sQuantities = _GetPCStepQuantities(oPC, sTag);
    return StringToInt(GetListItem(sQuantities, nStep - 1));
}

// TODO this should probably be a private function
void SetStepQuantityRemaining(object oPC, string sTag, int nStep, int nQuantity)
{
    int nIndex = _GetQuestIndex(oPC, sTag);
    string sNewQuantities, sQuantities = _GetPCStepQuantities(oPC, sTag);

    int n, nCount = CountList(sQuantities);
    for (n = 0; n < nCount; n++)
    {
        if (n == nStep - 1)
            sNewQuantities = AddListItem(sNewQuantities, IntToString(nQuantity));
        else
            sNewQuantities = AddListItem(sNewQuantities, GetListItem(sQuantities, n));
    }

    _SetPCStepQuantities(oPC, sTag, sNewQuantities);
}

int GetMeetsQuestTimeLimit(object oPC, string sTag, int nStep = 0)
{
    string sTimeAllowed, sTimeAssigned, sGoalTime;
    int nIndex;

    if (nStep)
        sTimeAllowed = GetQuestStepTimeLimit(sTag, nStep);
    else
        sTimeAllowed = GetQuestTimeLimit(sTag);

    nIndex = _GetQuestIndex(oPC, sTag);
    sTimeAssigned = GetListString(oPC, nIndex, QUEST_PC_TIME);
    sGoalTime = AddSystemTimeVector(sTimeAssigned, sTimeAllowed);
    return !(GetMinSystemTime(sGoalTime) == sGoalTime);
}

int GetMeetsQuestStepTimeLimit(object oPC, string sTag, int nStep)
{
    return GetMeetsQuestTimeLimit(oPC, sTag, nStep);
}

void AdvanceQuestStep(object oPC, string sTag, int nStep, int nQuantity = 1, int bForce = FALSE)
{

    
    // bForce == TRUE will bypass all checks and simply move the quest forward by nQuantity Steps
    // Set quanitites to 0 for forced bypass steps
    // Confirm that there enough steps left to bypass.
    // If all, then force complete the quest.

    // All logic for moving quests forward should reside in this function, or called by it.

    object oQuest = _GetQuestDataItem(sTag);
    int nRemaining =  GetStepQuantityRemaining(oPC, sTag, nStep);
    string sRemaining;

    if (bForce)
    {
        int nIndex = _GetQuestStepIndex(sTag, nStep);
        // Check for list end (index + quantity > list count)
        int nNextID = GetListInt(oQuest, nIndex + nQuantity, QUEST_STEP_ID);

        // Set 0 quantities for the current step and move along
    }


    nRemaining -= nQuantity;
    nRemaining = min(0, nRemaining);

    SetStepQuantityRemaining(oPC, sTag, nStep, nRemaining);

    // TODO need to confirm the step was completed
    // ie. killer is in the player's party or pc is killer, etc.

    // TODO allow for non-sequential quest completion

    // Check for timing fulfillment

    if (!nRemaining)
    {
        // Step complete
        AwardQuestStepRewards(oPC, sTag, nStep);
        AwardQuestStepPrewards(oPC, sTag, nStep + 1);
        RunQuestScript(oPC, sTag, QUEST_SCRIPT_TYPE_ON_ADVANCE, nStep);

        // TODO go to next step id, not just add one because using the nwn journal can be any id
        _SendJournalEntry(oPC, sTag, nStep + 1);
    }
}

// Accessor to call advancequeststep for forcing quest advancement.
void ForceAdvanceQuestStep(object oPC, string sTag, int nStep, int nQuantity = 1)
{
    AdvanceQuestStep(oPC, sTag, nStep, nQuantity, TRUE);
}

// These two functions are used to access temporary variables to
// allow script access for quest events
string GetCurrentQuest()
{
    return GetLocalString(QUESTS, QUEST_CURRENT_QUEST);
}

int GetCurrentQuestStep()
{
    return GetLocalInt(QUESTS, QUEST_CURRENT_STEP);
}

int CountQuestStepsCompleted(object oPC, string sTag)
{
    int n, nCount, nIndex = _GetQuestIndex(oPC, sTag);
    if (nIndex == -1)
        return nIndex;

    string sStatus = GetListString(oPC, nIndex, QUEST_PC_STATUS);
    nCount = CountList(sStatus);
    for (n = 0; n < nCount; n++)
        nCount += GetListItem(sStatus, n) == "0";

    return nCount;
}

// TODO incorporate nCompletions
// TODO this function doesn't make much sense
int GetIsQuestComplete(object oPC, string sTag, int nCompletions = 1)
{
    int nIndex = _GetQuestIndex(oPC, sTag);
    if (nIndex == -1)
        return nIndex;

    return CountQuestStepsCompleted(oPC, sTag) == _CountQuestSteps(sTag);    
}

// PC Stuff?
int GetIsQuestAssignable(object oPC, string sTag, int nStep = 0)
{
    if (GetIsQuestAssigned(oPC, sTag))
        return FALSE;

    if (!CountQuestPrerequisites(sTag))
        return TRUE;

    // If the PC has already completed the quest the maximum number of times, FALSE
    int nCompletions = CountQuestCompletions(oPC, sTag);
    int nRepetitions = GetQuestRepetitions(sTag);
    if (nCompletions >= nRepetitions)
        return FALSE;

    // Run through the prerequisites
    object oQuest = _GetQuestDataItem(sTag);
    
    string sPrefix = QUEST_STEP + IntToString(nStep);
    string sCategoryList = sPrefix + "_CATEGORY";
    string sKeys, sKeyList = sPrefix + "_KEYS";
    string sValues, sValueList = sPrefix + "_VALUES";

    int bAssignable = FALSE;
    
    int n, nCategory, nCount = CountIntList(oQuest, sCategoryList);
    for (n = 0; n < nCount; n++)
    {
        nCategory = GetListInt(oQuest, n, sCategoryList);
        sKeys = GetListString(oQuest, n, sKeyList);
        sValues = GetListString(oQuest, n, sValueList);

        if (nCategory & 0xff00 == QUEST_CATEGORY_PREREQUISITE)
        {
            switch (nCategory & 0x00ff)
            {
                case QUEST_VALUE_ALIGNMENT:
                {
                    int n, nAxis, nValue, nMeets, nCount = CountList(sKeys);
                    int nAlignmentGE = GetAlignmentGoodEvil(oPC);
                    int nAlignmentLC = GetAlignmentLawChaos(oPC);

                    for (n = 0; n < nCount; n++)
                    {
                        nAxis = StringToInt(GetListItem(sKeys, n));
                        nValue = StringToInt(GetListItem(sValues, n));

                        if (nValue)
                        {
                            if (nAlignmentGE == ALIGNMENT_NEUTRAL ||
                                nAlignmentLC == ALIGNMENT_NEUTRAL)
                                nMeets++;
                        }
                        else
                        {
                            if (nAlignmentGE == nAxis || nAlignmentLC == nAxis)
                                nMeets++;
                        }
                    }

                    if (nMeets == nCount)
                        bAssignable = TRUE;
                    else
                        return FALSE;
                    break;
                }
                case QUEST_VALUE_CLASS:
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
                case QUEST_VALUE_GOLD:
                {
                    int nKey = StringToInt(sKeys);
                    if (GetGold(oPC) >= nKey)
                        bAssignable = TRUE;
                    else
                        return FALSE;
                    break;
                }
                case QUEST_VALUE_ITEM:
                {
                    string sItem;
                    int n, nQuantity, nCount = CountList(sKeys);
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
                            if (_HasMinimumItemCount(oPC, sItem, nQuantity, FALSE))
                                bAssignable = TRUE;
                        }
                    }

                    break;
                }
                case QUEST_VALUE_LEVEL_MAX:
                {   // Mandate, no meet = FALSE
                    int nKey = StringToInt(sKeys);
                    if (GetHitDice(oPC) <= nKey)
                        bAssignable = TRUE;
                    else
                        return FALSE;
                    break;
                }
                case QUEST_VALUE_LEVEL_MIN:
                {
                    int nKey = StringToInt(sKeys);
                    if (GetHitDice(oPC) >= nKey)
                        bAssignable = TRUE;
                    else
                        return FALSE;
                    break;
                }
                case QUEST_VALUE_QUEST:
                {
                    int n, nCount = CountList(sKeys);
                    string sQuest;

                    for (n = 0; n < nCount; n++)
                    {
                        sQuest = GetListItem(sKeys, n);
                        nCount = StringToInt(GetListItem(sValues, n));
                        if (CountQuestCompletions(oPC, sQuest) >= nCount)
                            bAssignable = TRUE;
                        else
                            return FALSE;
                    }
                    break;
                }
                case QUEST_VALUE_RACE:
                {
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
                case QUEST_VALUE_FACTION:
                {
                    break;  // TODO
                }
            }
        }
    }

    return bAssignable;
}

void AwardQuestStepPrewards(object oPC, string sTag, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, sTag, QUEST_CATEGORY_PREWARD, nStep, nAwardType, bParty);
}

void AwardQuestStepRewards(object oPC, string sTag, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, sTag, QUEST_CATEGORY_REWARD, nStep, nAwardType, bParty);
}

string GetQuestTitle(string sTag)
{
    return _GetQuestPropertyString(sTag, QUEST_TITLE);
}

void SetQuestTitle(string sTag, string sTitle)
{
    _SetQuestPropertyString(sTag, QUEST_TITLE, sTitle);
}

int GetQuestActive(string sTag)
{
    return _GetQuestPropertyInt(sTag, QUEST_ACTIVE);
}

void SetQuestActive(string sTag)
{
    _SetQuestPropertyInt(sTag, QUEST_ACTIVE, TRUE);
}

void SetQuestInactive(string sTag)
{
    _SetQuestPropertyInt(sTag, QUEST_ACTIVE, FALSE);
}

int GetQuestRepetitions(string sTag)
{
    return _GetQuestPropertyInt(sTag, QUEST_REPETITIONS);
}

void SetQuestRepetitions(string sTag, int nRepetitions = 1)
{
    _SetQuestPropertyInt(sTag, QUEST_REPETITIONS, nRepetitions);
}

string GetQuestTimeLimit(string sTag)
{
    return _GetQuestPropertyString(sTag, QUEST_TIME_LIMIT);
}

void SetQuestTimeLimit(string sTag, string sTime)
{
    _SetQuestPropertyString(sTag, QUEST_TIME_LIMIT, sTime);
}

int GetQuestStepOrder(string sTag)
{
    return _GetQuestPropertyInt(sTag, QUEST_STEP_ORDER);
}

void SetQuestStepOrder(string sTag, int nOrder = QUEST_STEP_ORDER_SEQUENTIAL)
{
    _SetQuestPropertyInt(sTag, QUEST_STEP_ORDER, nOrder);
}

string GetQuestScriptOnAccept(string sTag)
{
    return _GetQuestPropertyString(sTag, QUEST_SCRIPT_ON_ACCEPT);
}

void SetQuestScriptOnAccept(string sTag, string sScript = "")
{
    _SetQuestPropertyString(sTag, QUEST_SCRIPT_ON_ACCEPT, sScript);
}

string GetQuestScriptOnAdvance(string sTag)
{
    return _GetQuestPropertyString(sTag, QUEST_SCRIPT_ON_ADVANCE);
}

void SetQuestScriptOnAdvance(string sTag, string sScript = "")
{
    _SetQuestPropertyString(sTag, QUEST_SCRIPT_ON_ADVANCE, sScript);
}

string GetQuestScriptOnComplete(string sTag)
{
    return _GetQuestPropertyString(sTag, QUEST_SCRIPT_ON_COMPLETE);
}

void SetQuestScriptOnComplete(string sTag, string sScript = "")
{
    _SetQuestPropertyString(sTag, QUEST_SCRIPT_ON_COMPLETE, sScript);
}

string GetQuestStepJournalEntry(string sTag, int nStep)
{
    return _GetQuestPropertyString(sTag, QUEST_STEP_JOURNAL_ENTRY, nStep);
}

void SetQuestStepJournalEntry(string sTag, int nStep, string sJournalEntry)
{
    _SetQuestPropertyString(sTag, QUEST_STEP_JOURNAL_ENTRY, sJournalEntry, nStep);
}

string GetQuestStepTimeLimit(string sTag, int nStep)
{
    return _GetQuestPropertyString(sTag, QUEST_STEP_TIME_LIMIT);
}

void SetQuestStepTimeLimit(string sTag, int nStep, string sTime)
{
    _SetQuestPropertyString(sTag, QUEST_STEP_TIME_LIMIT, sTime, nStep);
}

int GetQuestStepPartyCompletion(string sTag, int nStep)
{
    return _GetQuestPropertyInt(sTag, QUEST_STEP_PARTY_COMPLETION);
}

void SetQuestStepPartyCompletion(string sTag, int nStep, int nParty)
{
    _SetQuestPropertyInt(sTag, QUEST_STEP_PARTY_COMPLETION, nParty, nStep);
}

void SetQuestPrerequisiteAlignment(string sTag, int nKey, int nValue = FALSE)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestPrerequisite(sTag, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestPrerequisiteClass(string sTag, int nKey, int nValue = -1)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestPrerequisite(sTag, QUEST_VALUE_CLASS, sKey, sValue);
}

void SetQuestPrerequisiteGold(string sTag, int nValue = 1)
{
    string sValue = IntToString(min(0, nValue));
    _SetQuestPrerequisite(sTag, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestPrerequisiteItem(string sTag, string sKey, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPrerequisite(sTag, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestPrerequisiteLevelMax(string sTag, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPrerequisite(sTag, QUEST_VALUE_LEVEL_MAX, "", sValue);
}

void SetQuestPrerequisiteLevelMin(string sTag, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPrerequisite(sTag, QUEST_VALUE_LEVEL_MIN, "", sValue);
}

void SetQuestPrerequisiteQuest(string sTag, string sKey, int nValue = 0)
{
    string sValue = IntToString(nValue);
    _SetQuestPrerequisite(sTag, QUEST_VALUE_QUEST, sKey, sValue);
}

void SetQuestPrerequisiteRace(string sTag, int nKey, int nValue = TRUE)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);    
    _SetQuestPrerequisite(sTag, QUEST_VALUE_RACE, sKey, sValue);
}

void SetQuestStepObjectiveKill(string sTag, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(sTag, QUEST_OBJECTIVE_KILL, sKey, sValue, nStep);
}

void SetQuestStepObjectiveGather(string sTag, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(sTag, QUEST_OBJECTIVE_GATHER, sKey, sValue, nStep);
}

void SetQuestStepObjectiveDeliver(string sTag, int nStep, string sKey, string sValue)
{
    _SetQuestObjective(sTag, QUEST_OBJECTIVE_DELIVER, sKey, sValue, nStep);
}

void SetQuestStepObjectiveDiscover(string sTag, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(sTag, QUEST_OBJECTIVE_DISCOVER, sKey, sValue, nStep);
}

void SetQuestStepObjectiveSpeak(string sTag, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(sTag, QUEST_OBJECTIVE_SPEAK, sKey, sValue, nStep);
}

void SetQuestStepPrewardAlignment(string sTag, int nStep, int nKey, int nValue)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestPreward(sTag, QUEST_VALUE_ALIGNMENT, sKey, sValue, nStep);
}

void SetQuestStepPrewardGold(string sTag, int nStep, int nKey, int nValue = FALSE)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestPreward(sTag, QUEST_VALUE_GOLD, sKey, sValue, nStep);
}

void SetQuestStepPrewardItem(string sTag, int nStep, string sKey, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPreward(sTag, QUEST_VALUE_ITEM, sKey, sValue, nStep);
}

void SetQuestStepPrewardXP(string sTag, int nStep, int nKey, int nValue = 0)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nKey);
    _SetQuestPreward(sTag, QUEST_VALUE_XP, sKey, sValue, nStep);
}

void SetQuestStepRewardAlignment(string sTag, int nStep, int nKey, int nValue)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestReward(sTag, QUEST_VALUE_ALIGNMENT, sKey, sValue, nStep);
}

void SetQuestStepRewardGold(string sTag, int nStep, int nKey)
{
    string sKey = IntToString(nKey);
    _SetQuestReward(sTag, QUEST_VALUE_GOLD, sKey, "", nStep);
}

void SetQuestStepRewardItem(string sTag, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(sTag, QUEST_VALUE_ITEM, sKey, sValue, nStep);
}

void SetQuestStepRewardQuest(string sTag, int nStep, string sKey, int nValue = TRUE)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(sTag, QUEST_VALUE_QUEST, sKey, sValue, nStep);
}

void SetQuestStepRewardXP(string sTag, int nStep, int nKey, int nValue = 0)
{
    string sKey = IntToString(nKey);
    _SetQuestReward(sTag, QUEST_VALUE_XP, sKey, "", nStep);
}
