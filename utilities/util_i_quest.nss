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
// 20210301:
//      Initial Release

/*
Note: util_i_quest will not function without other utility includes from squattingmonk's
sm-utils.  These utilities can be obtained from
https://github.com/squattingmonk/nwn-core-framework/tree/master/src/utils.

Specificially, the following files are required:  util_i_color.nss, util_i_csvlists.nss,
util_i_debug.nss, util_i_math.nss, util_i_string.nss, util_i_time.nss

*** WARNING *** This documentation is still a work-in-progress.  If anything in this documentation
    doesn't work the way you expect, refer to the code or find me on Discord...

Description:
    This utility is designed to allow builders/scripters to fully define quests within script without
    the need for game journal editing.  The greatest use of this utility comes from pairing it
    with NWNX journal functions, which completely obviates the need for editing journal entries
    in the toolset.  Since there are many modules that cannot or will not use NWNX, I've included
    functionality for interfacing with the game's journal system.

    *** NOTE *** NWNX functions have not yet been implemented due to some idosynchrasies in the code
        and how it interfaces with the game.  When those wrinkles have been ironed out, NWNX
        functionality will be added.  ETA is unknown, so all references to NWNX journal functionality
        below is future-growth.

    *** NOTE *** The primary functions of this system use QuestID numbers to identify various
        quests.  However, you need never know an actual QuestID number to use this successfully.
        All user-facing functions will only accept QuestID numbers if the system will supply the
        number for the user.  For example, using AddQuest() will return the QuestID, which can then
        be used to create various quest properties that accept the QuestID:

            int nQuestID = AddQuest("myQuest");
            SetQuestPrerequisiteLevelMin(nQuestID, 1);

        All other user-facing functions will accept the quest-tag instead of the QuestID.  For example,
        to determine if a PC has met all prerequisites and assign a specific quest:

            if GetIsQuestAssignable(oPC, "myQuest")
                AssignQuest(oPC, "myQuest");

        Because each Quest Tag must be unique, the quest system can internally convert between QuestID
        and Quest Tag when required.  If a user absolutely requires the conversion for other uses, two
        functions are provided:
            string GetQuestTag(int nQuestID)  will return the Quest Tag associated with nQuestID
            int GetQuestID(string sQuestTag)  will return the QuestID associated with sQuestTag

            *** WARNING *** All non-PC quest data is held in volatile memory and will be lost on server
                reset.  Do not save QuestIDs persistently as they may change in the future with no
                ability to associate a changed ID with a Quest Tag.  If you must save persistent quest
                data, identify it via the Quest Tag, not the QuestID.

NWN Journal Entries:
    This utility can be used with either the standard NWN or NWNX journal functions.  If you
    elect to use the standard NWN journal functions, you must build the quests within the
    game's journal editor and then enter the quest's properties into the build properties
    for each quest in the system.  Examples of how to do this, as well as use NWNX journal
    functions, are included below.

Reserved Words and Characters:
    - NONE

Usage Notes:
    This system makes extensive use of NWN's organic sqlite capability.  All static quest data is held
    in volatile memory in the module object's sqlite database.  All persistent quest data associated with
    individual player-characters are stored in the PC's persistent sqlite database, which is saved to
    the character's .bic file.
    
    The text entries in this system can store colorized text, however, there are no functions included in
    this utility to accomplish colorized text.  If you wish to have your journal titles or journal entries
    colored, the text must be pre-processed before storing the values on the quest or quest step.  The
    utility script util_i_color has several functions to accomplish this.

    This primary functionality of this utility resides in the ability to set various properties on quests
    and quest steps.  These properties include quest prerequisites, step rewards, step prewards and step
    objectives.  Most properties can be "stacked" (more than one added).  Examples of this will follow.
    

    TODO Move Warnings and Notes for Time Usage here.

Custom Quest-Assocated Variables:
    There are several functions that allow the user to associated Int and String variables with any
    quest.  These variables are stored in the volatile module-associated sqlite database in a separate
    table and referenced to the associated quest by QuestID.  These functions allow for a convenient
    place to store custom quest-associated variables and can be accessed by any module script as long
    as util_i_quest is included.

        GetQuestInt()
        SetQuestInt()
        DeleteQuestInt()

        GetQuestString()
        SetQuestString()
        DeleteQuestString()

Property Descriptions:

    Quest-Level Properties - each quest contains the following properties.  Not all properties are required.
        Active - Whether the quest is currently active.  If a quest is inactive, the quest cannot be
            assigned and PCs cannot progress in the quest.  FALSE by default, this value can be set to
            TRUE at any time.  This property allows builders to control when quests are available for 
            assignment or redemption.  For example, you can use an hourly event to only allow specific
            quests to be progressed during night hours.
        Title - The quest title.  This is the text that will appear as the title of the quest in
            the player's journal.  If you are using NWNX, you can color this text.  If you are using
            the game's journal editor, you must abide by the editor's capabilities and limitations for
            displaying text.  For NWN journals, this property is not used.
        Repetitions - The number of times a PC can complete the quest.  Generally, quests are one-time or
            repeatable.  Setting this value to 0 (zero) allows the quest to be repeated an infinite number
            of times.  Setting this value to any positive integer will limit the number of times a PC
            can accomplish this quest.  The default value is 1.
        Scripts - Actions to run for quest events.  Quests have four primary events: OnAccept, OnAdvance, 
            OnComplete and OnFail.  The script assigned to OnAccept will run when the quest is assigned to the player.
            The OnAdvance script will run before the first step and then again every time the PC successfully
            completes a step.  The OnComplete script will run when the player successfully completes all steps 
            in a given quest.  The OnFail script will run when the player meets a defined failure condition,
            such as taking too much time to complete a quest or killing a creature that required protection.
            The scripts will be run with the PC as OBJECT_SELF.
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
                    // TODO create convenience functions for time management

        Prerequisites - Requirements a PC must meet before a quest can be assigned.  You can add any number of
            prerequisites to each quest to narrow down which PCs can be assigned specific quests.  All
            prerequisites are checked when requested and the PC must pass all required checks before being
            assigned a quest.  Party Member characteristics cannot be used to satisfy quest prerequisites.

            ALIGNMENT:
                SetQuestPrerequisiteAlignment(int nQuestID, int nKey, int nValue = FALSE)
                    nQuestID   -> Quest ID
                    nKey   -> ALIGNMENT_* Constant
                    nValue -> Neutrality Flag

                This property can be stacked.  There should be one call for each alignment.  The PC must meet ALL
                of the prerequisitve alignments in order to pass this check.  Since the ALIGNMENT_NEUTRAL constant
                cannot denote which axis it lies on (Good-Evil or Law-Chaos), you can set nValue to TRUE to denote
                a requirements for neutrality on the desired axis.

                This example shows prerequisites for lawful-good alignments:
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_GOOD);
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_LAWFUL);

                This example shows prerequisites for true neutral:
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_GOOD, TRUE);
                    SetQuestPrerequisiteAlignment(nQuestID, ALIGNMENT_LAWFUL, TRUE);

                This example shows a prerequisite for evil characters:
                    SetQuestPrerequisityAlignment(nQuestID, ALIGNMENT_EVIL);

            CLASS:
                SetQuestPrerequisiteClass(int nQuestID, int nKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nKey   -> CLASS_TYPE_* Constant
                    nValue -> Class Levels Requirements

                This property can be stacked.  Class prerequisites are treated as OR, so the PC must meet
                AT LEAST ONE of the prerequisites, but does not have to meet all of them.  If a level-requirement
                is passed to nValue for the specified class, the PC must also meet the required number of levels
                in that class to pass this check.  Omitting the class level requirement assumes that any number
                of levels in that class satisfies the requirement.  Passing a class level requirement of 0 (zero)
                excludes any PCs that have any number of levels in that class.

                This example shows a requirement for at least 8 levels of Druid OR any number of Fighter levels:
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_DRUID, 8);
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_FIGHTER);

                This example shows a requirement for at least 2 levels of Fighter, but any PC with any levels of
                Paladin are excluded:
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_FIGHTER, 2);
                    SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_PALADIN, 0);

            GOLD:
                SetQuestPrerequisiteGold(int nQuestID, int nValue)
                    nQuestID -> Quest ID
                    nValue -> Gold Amount

                This property cannot be stacked.  This check passes if the PC has the required amount of gold in their
                inventory and fails if they do not.

            ITEM:
                SetQuestPrerequisiteItem(int nQuestID, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    sKey   -> Tag of Required Item
                    nValue -> Quantity of Required Item

                This property can be stacked.  Item prerequisites are treated as AND, so all item prerequisites must
                be met by the PC in order to pass this check.  nValues greater than 0 create an inclusive requirement and
                the PC must have the required number of each item to pass this check.  An nValue of 0 creates an exclusive
                requirement and any PC that has that referenced item in inventory will fail the check.

                This example shows a requirement to have 4 flowers and any number of vases in your inventory, but the PC
                cannot have any graveyard dirt:
                    SetQuestPrerequisiteItem(nQuestID, "item_flower", 4);
                    SetQuestPrerequisiteItem(nQuestID, "item vase");
                    SetQuestPrerequisiteItem(nQuestID, "item_gravedirt", 0);

            LEVEL_MAX:
                SetQuestPrerequisteLevelMax(int nQuestID, int nValue)
                    nQuestID -> Quest ID
                    nValue -> Maximum Total Character Levels

                This property cannot be stacked.  This check passes if the PC total character levels are less than or equal
                to nValue, and fails otherwise.

            LEVEL_MIN:
                SetQuestPrerequisiteLevelMin(int nQuestID, int nValue)
                    nQuestID -> Quest ID
                    nValue -> Minimum Total Character Levels

                This property cannot be stacked.  This check passes if the PC total character levels are more than or equal
                to nValue, and fails otherwise.

            QUEST:
                SetQuestPrerequisiteQuest(int nQuestID, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    sKey   -> Quest Tag of Prerequisite Quest
                    nValue -> Number of Prerequisite Quest Completions

                This property can be stacked.  Quest prerequisites are treated as AND, so all quest prerequisites must
                be met by the PC in order to pass this check.  An nValue greater than 0 creates an inclusive requirement and
                the PC must have completed each quest at least that number of times to pass the check.  An nValue of 0 creates
                an exclusive requirement and any PC that has completed that quest will fail this check.

                This example shows a requirement to have completed the flower collection quest at least once, but to never
                have completed the rat-killing quest:
                    SetQuestPrerequisiteQuest(nQuestID, "questFlowers");
                    SetQuestPrerequisiteQuest(nQuestID, "questRats", 0);

            QUEST_STEP:
                SetQuestPrerequisiteQuestStep(int nQuestID, string sKey, int nValue)
                    nQuestID -> Quest ID
                    sKey     -> Quest Tag of the Prerequisite Quest
                    nValue   -> Required minimum step number of the prerequisite quest

                This property can be stacked.  Quest step prerequisites are treated as AND, so all quest prerequisites must
                be met by the PC in order to pass this check.  The PC must have the prerequisite quest assigned, but not
                have completed it, in order to pass this check.

                This example shows a requirement to be on at least the second step of the prerequisite quest:
                    SetQuestPrerequisiteQuestStep(nQuestID, "myPrerequisiteQuestTag", 2);

            RACE:
                SetQuestPrerequisiteRace(int nQuestID, int nKey, int nValue = TRUE)
                    nQuestID   -> Quest ID
                    nKey   -> RACIAL_TYPE_* Constant
                    nValue -> Inclusion/Exclusion Flag

                This property can be stacked.  Race prerequisites are treated as OR, so the PC must meet AT LEAST ONE
                of the prerequisites to pass this check.  An nValue of TRUE creates an inclusive requirement and the PC
                must be of at least one of the races listed.  An nvalue of FALSE cretes an exclusive requirement and the
                PC cannot be of any of the races listed.  Unlike other properties, combining inclusive and exclusive requirements
                on the same quest does not make sense and should be avoided as it could create undefined behavior.

                This example shows a requirement for either a dwarf, a human or a halfling:
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_DWARF);
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HUMAN);
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HALFLING);

                This examples show a requirement for any race except a human:
                    SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HUMAN, FALSE);

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

        Prerequisites - Prerequisites cannot be assigned to invdividual steps.  It is assumed that the prerequisite
            for a sequential quest is the completion of all steps in-order.  For non-sequential quests, there are no
            step-level prerequisits and the PC can complete the steps in any order.
        Objectives - These properties define the purpose of each step in a quest.  Final steps in a quest for either
            success or failure should not have objectives assigned to them.
        
            *** WARNING *** It is possible to assign more than one objective to a quest step, however, only one type
                of objective can be assigned.  For example, you can use SetQuestStepObjectiveKill() multiple times on a
                single step, but using SetQuestStepObjectiveKill() and SetQuestObjectiveGather() on the same quest
                step will result in the first objective type being evaluated and the second objective type being ignored.

                So ... this is ok:
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_orc", 7);
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_princess", 0);

                This ... is not:
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_orc", 7);
                    SetQuestStepObjectiveGather(nQuestID, 1, "orc_ears", 0);

            KILL:
                SetQuestStepObjectiveKill(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object

                This property can be stacked.  Kill targets are treated as AND, so the PC must kill the required number
                of each assigned target object to fulfill this quest step.  A positive nValue creates an inclusive requirement
                and the PC must kill at least that many targets to fulfill the requirement.  An nValue of 0 creates an exclusive
                requirement and the PC cannot kill any of the specified target objects or the quest step will fail.

                This example shows a requirement to kill at least seven orcs, but to not kill the princess.  There is no
                penalty if a non-party member kills the target object.
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_orc", 7);
                    SetQuestStepObjectiveKill(nQuestID, 1, "creature_princess", 0);

            GATHER:
                SetQuestStepObjectiveGather(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object

                This property can be stacked.  Gather targets are treated as AND, so the PC must gather the required number
                of each assigned target object to fulfill this quest step.  This property is inclusive only.

                This examples shows a requirement to gather at least seven flower bouquets and one vase:
                    SetQuestStepObjectiveGather(nQuestID, 1, "item_bouquet", 7);
                    SetQuestStepObjectiveGather(nQuestID, 1, "item_vase");

            DELIVER:
                SetQuestStepObjectiveDeliver(int nQuestID, int nStep, string sKey, int nValue = 1)
                
                TODO - NEED TO FLESH THIS REQUIREMENT OUT A BIT -> It might need more than sKey and nValue to work right.

            DISCOVER:
                SetQuestStepObjectiveDiscover(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of Target Object
                    nValue -> Quantity of Target Object
                
                This property can be stacked.  Discover targets are treated as AND, so the PC must discover the required number
                of each assigned target object to fulfill this quest step.  This property is inclusive only.  Generally, the
                target objects will be triggers or areas to allow for easy identification, but any object with an assigned event
                can be used.

                This example shows a requirement to discover two different locations:
                    SetQuestStepObjectiveDiscover(nQuestID, 1, "trigger_fishing");
                    SetQuestStepObjectiveDiscover(nQuestID, 1, "area_hollow");

            SPEAK:
                SetQuestStepObjectiveSpeak(int nQuestID, int nStep, string sKey)

                This property can be stacked.  Speak targets are treated as AND, so the PC must speak to each of the assigned target
                objects to fulfill this quest step.  This property is inclusive only.

                This example shows a requirement to converse with a store keep NPC:
                    SteQuestStepObjectiveSpeak(nQuestID, 1, "creature_StoreKeep");

        Prewards - these are game objects or characteristics that are given or assigned to a PC at the beginning of a quest
            step.  They can be used as a reward system for simply accepting a difficult quest (i.e. gold and xp to prepare
            a PC for a difficult journey), to give the PC an item to deliver to another NPC or as a method to modify PC
            characteristics (i.e. changing the PC's alignment when they accept an assassination quest).
        Reward - these are game objects or characteristics that are give or assigned to a PC at the end of a quest step.
            Rewards and prewards share the same types.  The primary difference between rewards and prewards is when they
            are allotted.  Any other minor differences are noted in the descriptions below.

            *** Note *** Generally, for prewards and rewards that involves quantities, such as items, gold, xp, etc.,
                will credit the desired quantity if the passed value is greater than zero, or debit the desired
                quantity if the value is less than zero.  This allows, for example, items, gold, etc. to be removed
                from the PC should they fail to complete the quest within the required parameters.

            ALIGNMENT:
                SetQuestStepPrewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
                SetQuestStepRewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    nKey   -> ALIGNMENT_* Constant
                    nValue -> Alignment Shift Value

                This property can be stacked.  There should be one call for each alignment.  The PC will be awarded all
                alignment shifts listed.  For details on how alignment shifts work, see the NWN Lexicon entry for
                AdjustAlignment().

                This example shows an alignment preward for accepting an assassination quest:
                    SetQuestStepPrewardAlignment(nQuestID, 1, ALIGNMENT_EVIL, 20);

                This example show an alignment reward for completing a quest step that protects the local farmer's stock:
                    SetQuestStepRewardAlignment(nQuestID, 2, ALIGNMENT_GOOD, 20);
                    SetQuestStepRewardAlignment(nQuestID, 2, ALIGNMENT_LAWFUL, 20);

            GOLD:
                SetQuestStepPrewardGold(int nQuestID, int nStep, int nKey)
                SetQuestStepRewardGold(int nQuestID, int nStep, int nKey)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    nKey   -> Gold Amount

                This property cannot be stacked.  An nKey greater than zero denotes that a PC will receive the specified
                amount of gold.  An nKey less than zero denotes that the PC will lose the specified amount of gold.

                This example shows the PC paying 5000 gold to gain access to specified quest:
                    SetQuestStepPrewardGold(nQuestID, 1, -5000);

            ITEM:
                SetQuestStepPrewardItem(int nQuestID, int nStep, string sKey, int nValue = 1)
                SetQuestStepRewardItem(int nQuestID, int nStep, string sKey, int nValue = 1)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Tag of [P]reward Item
                    nValue -> Quantity of [P]reward Item

                This property can be stacked.  An nValue of greater than zero denotes that the PC will receive the designated
                number of items when the quest [p]rewards are allotted.  An nValue of less than zero denotes that the PC will
                lose the designated number of items.  Gained and lost items can be stacked.

                This example shows the PC receiving a reward of several items, but losing a prewarded item, upon completion of
                a quest step:
                    SetQuestStepRewardItem(nQuestID, 3, "item_cakes", 2);
                    SetQuestStepRewardItem(nQuestID, 3, "item_flour", -1);

            MESSAGE:
                SetQuestStepPrewardMessage(int nQuestID, int nStep, string sValue);
                SetQuestStepRewardMessage(int nQuestID, int nStep, string sValue);
                    nQuestID -> Quest ID
                    nStep    -> Quest Step Number
                    sValue   -> The message to display to the PC

                This property can be stacked.  This property allows you to send a message to the PC either at the beginning of
                a quest step or at the end of a quest step.  This property will be useful for smaller, randomized quests that
                may not merit full NWN journal entries, but still need to interface with the PC for information purposes.

                This example shows the PC receiving a message at the end of the specified step:
                    SetQuestStepRewardMessage(nQuestID, nStep, "Thanks for helping us keep the road clear of bandits.");

            QUEST:
                SetQuestStepRewardQuest(int nQuestID, int nStep, string sKey, int nValue = TRUE)
                    nQuestID   -> Quest ID
                    nStep  -> Quest Step Number
                    sKey   -> Reward Quest Tag
                    nValue -> Assignment Flag

                This property can be stacked.  An nValue of TRUE denotes that the quest should be assigned to the PC.  An nValue
                of FALSE denotes that the quest should be removed from the PC.  By adding a quest as a reward for completing a
                quest, quest chaining is implemented.

                *** NOTE *** For rewarded quests, prerequistes are NOT checked.  It is assumed that if you are awarding a quest
                as a reward, accomplishing the associated step is the prerequisite for the reward.

                This example show the PC receiving a reward of the next quest in the quest chain and having the current quest
                removed completely:
                    SetQuestStepRewardQuest(nQuestID, 4, "questTag2");
                    SetQuestStepRewardQuest(nQuestID, 4, nQuestID, FALSE);

            XP:
                SetQuestStepPrewardXP(int nQuestID, int nStep, int nKey)
                SetquestStepRewardXP(int nQuestID, int nStep, int nKey)
                    nQuestID  -> Quest ID
                    nStep -> Quest Step Number
                    nKey  -> XP Amount

                This property cannot be stacked.  An nValue greater than zero denotes that a PC will receive the specified
                amount of XP.  An nKey value less than zero denotes that the PC will lose the specified amount of XP.

Usage Example:

    Following is a complete usage example for creating a sequential three-step quest that:
        - Requires the PC to be a 3rd-level halfling rogue
        - Requires the PC to break into three houses
        - Requires the PC collect two maps
        - Limits the PC to 24 hours of game time
        - Provides the PC with a set of advanced lockpicks after the find the maps
        - Rewards the PC with Gold, XP and Alignment Shift upon completion
        - Requires the PC report back to the NPC that assigned the quest

    *** Note *** In the scripts below, nStep values are assumed to be sequential, however, if
        the step id values in the NWN journal entries are not sequential, you can supply your
        own step ids.  The only requirement is that the step ids increase as steps are added.
        Additionally, each quest MUST have an AddStepResolutionSuccess().  All other steps are
        optional.  A quest with only a resolution step could be used to display quests in the
        journal that don't have completion steps, such as a module update note, or general
        module familiarity/instructions for the PC.  This type of quest can be used, for
        example, in the start area for new PCs, giving them an instructional quest entry as
        well as a few starting items/gold/xp.

    void DefineRogueQuest()
    {
        int nQuestId, nStep;

        // Create the quest database entry
        nQuestID = AddQuest("quest_rogue");

        SetQuestPrerequisiteRace(nQuestID, RACIAL_TYPE_HALFLING);
        SetQuestPrerequisiteClass(nQuestID, CLASS_TYPE_ROGUE, 3);
        SetQuestTimeLimit(nQuestID, CreateDifferenceVector(0, 0, 0, 24, 0, 0));

        // Step 1 - Find Maps
        nStep = AddQuestStep(nQuestID);
        SetQuestObjectiveGather(nQuestID, nStep, "map_rogue1");
        SetQuestObjectiveGather(nQuestID, nStep, "map_rogue2");

        // Step 2 - Break into the houses
        nStep = AddQuestStep(nQuestID);
        SetQuestStepObjectiveDiscover(nQuestID, nStep, "trigger_house1");
        SetQuestStepObjectiveDiscover(nQuestID, nStep, "trigger_house2");
        SetQuestStepObjectiveDiscover(nQuestID, nStep, "trigger_house3");
        SetQuestStepPrewardItem(nQuestID, nStep, "lockpicks_10", 3);

        // Step 3 - Go tell the guild
        nStep = AddQuestStep(nQuestID, sJournalEntry);
        SetQuestStepObjectiveSpeak(nQuestID, nStep, "guild_master");
        
        // Create a step for successful completion and rewards
        nStep = AddQuestResolutionSuccess(nQuestID);
        SetQuestStepRewardGold(nQuestID, nStep, 1000);
        SetQuestStepRewardXP(nQuestID, nStep, 500);
        SetQuestStepRewardAlignment(nQuestID, nStep, ALIGNMENT_CHAOS, 10);

        // Since there is a failure condition, create a step for quest failure
        nStep = AddQuestResolutionFail(nQuestID);
        SetQuestStepRewardGold(nQuestID, nStep, -500);
        SetQuestStepRewardXP(nquestID, nStep, 100);
    }

    In order to make this quest work, an event of some type has to call the quest system to
    check if the PC correctly accomplished the steps.  In the Rogue Quest example above,
    it would be necessary to have checks for OnAcquireItem (for the maps), OnTriggerEnter
    (for breaking into the houses) and OnCreatureConversation (for speaking with the NPC);

    This is accomplished by sending a Quest Step Advance Request to the quest system through
    the SignalQuestStepProgress() function.  If you want to do any pre-processing before calling
    this function, the events are the correct scripts to do that in.  For example, if you set
    a quest step objective to kill a creature, but you only want to count it if that creature is
    killed with a specific weapon or weapon type, you would check those custom prerequisites in
    your script before calling SignalQuestStepProgress().

    This is a simple example of requesting a quest step advance from the quest system when a creature
    is killed:

    // In the OnCreatureDeath script
    void main()
    {
        SignalQuestStepProgress(GetLastKiller(), OBJECT_SELF, QUEST_OBJECTIVE_KILL);
    }

    GetLastKiller() will be a PC or any creature in the PC's party.  If an associate scored the kill,
    the quest system will determine who the master PC is and work from there.  OBJECT_SELF is the
    creature that was killed (or, for other objective types, the focus creature or object).
    QUEST_OBJECTIVE_KILL is the type of objective to satisfy with this call.  This is required to
    prevent non-linked objectives from being credited.  For example, if there's one quest where a
    PC must speak to "TownWizard", but another where the PC must kill the "TownWizard", the system
    must be able to differentiate.  It does this by passing the objective type.  If this signal
    can satisfy more than one quest for the PC, it will with this one call.

    The quest system will then evaluate whether the PC has fulfilled the requirements to move forward
    in the quest.  If so, the quest is advanced.  If not, the kill is noted, but the quest does not
    advance.  If the PC has fulfilled a failure condition, such as killing a protected creature, the
    quest will immediately fail and go to the Failure Resolution step, if it exists.

    The system can also run scripts for each quest event type -> Accept, Advance, Complete and Fail.
    Before the script is run, two variables are stored on the module:  the current quest tag and the
    current quest step.  You can retrieve these by using GetCurrentQuest() and GetCurrentQuestStep().
    These values will allow builder's to run quest-specific code.  Here's a short example that creates
    a single goblin creature at waypoint "quest_test" when the PC reaches the first step of the
    quest with the tag "myFirstQuest".

    void quest_OnAdvance()
    {
        string sCurrentQuest = GetCurrentQuest();
        int nCurrentStep = GetCurrentQuestStep();

        if (sCurrentQuest == "myFirstQuest")
        {
            if (nCurrentStep == 1)
            {
                object oWP = GetWaypointByTag("quest_test");
                location lWP = GetLocation(oWP);
                object oTarget = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP);

                SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
                SetLocalString(oTarget, CREATURE_EVENT_ON_DEATH, "test_goblindeath");
            }
        }
    }
*/



const int QUEST_STEP_ORDER_SEQUENTIAL = 1;
const int QUEST_STEP_ORDER_RANDOM = 2;

// -----------------------------------------------------------------------------
//                      LEAVE EVERYTHING BELOW HERE ALONE!
// -----------------------------------------------------------------------------

// Variable names for event scripts
const string QUEST_CURRENT_QUEST = "QUEST_CURRENT_QUEST";
const string QUEST_CURRENT_STEP = "QUEST_CURRENT_STEP";

// Table column names
const string QUEST_ACTIVE = "nActive";
const string QUEST_REPETITIONS = "nRepetitions";
const string QUEST_STEP_ORDER = "nStepOrder";
const string QUEST_TITLE = "sJournalTitle";
const string QUEST_TIME_LIMIT = "sTimeLimit";
const string QUEST_SCRIPT_ON_ACCEPT = "sScriptOnAccept";
const string QUEST_SCRIPT_ON_ADVANCE = "sScriptOnAdvance";
const string QUEST_SCRIPT_ON_COMPLETE = "sScriptOnComplete";
const string QUEST_SCRIPT_ON_FAIL = "sScriptOnFail";
const string QUEST_COOLDOWN = "sCooldown";

const string QUEST_STEP_JOURNAL_ENTRY = "sJournalEntry";
const string QUEST_STEP_TIME_LIMIT = "sTimeLimit";
const string QUEST_STEP_PARTY_COMPLETION = "nPartyCompletion";
const string QUEST_STEP_TYPE = "nStepType";

// Quest PC Variable Names
const string QUEST_PC_QUEST_TIME = "sQuestStartTime";
const string QUEST_PC_STEP_TIME = "sStepStartTime";
const string QUEST_PC_LAST_COMPLETE = "sLastCompleteTime";
const string QUEST_PC_COMPLETIONS = "nCompletions";
const string QUEST_PC_STEP = "nStep";

// Quest Categories and Values
const int QUEST_CATEGORY_PREREQUISITE = 1;
const int QUEST_CATEGORY_OBJECTIVE = 2;
const int QUEST_CATEGORY_PREWARD = 3;
const int QUEST_CATEGORY_REWARD = 4;

const int QUEST_VALUE_NONE = 0;
const int QUEST_VALUE_ALIGNMENT = 1;
const int QUEST_VALUE_CLASS = 2;
const int QUEST_VALUE_GOLD = 3;
const int QUEST_VALUE_ITEM = 4;
const int QUEST_VALUE_LEVEL_MAX = 5;
const int QUEST_VALUE_LEVEL_MIN = 6;
const int QUEST_VALUE_QUEST = 7;
const int QUEST_VALUE_RACE = 8;
const int QUEST_VALUE_XP = 9;
const int QUEST_VALUE_FACTION = 10;
const int QUEST_VALUE_MESSAGE = 11;
const int QUEST_VALUE_QUEST_STEP = 12;

// Quest Step Types
const int QUEST_STEP_TYPE_PROGRESS = 0;
const int QUEST_STEP_TYPE_SUCCESS = 1;
const int QUEST_STEP_TYPE_FAIL = 2;

// Quest Advance Types
const int QUEST_ADVANCE_SUCCESS = 1;
const int QUEST_ADVANCE_FAIL = 2;

// Quest Objective Types
const int QUEST_OBJECTIVE_GATHER = 1;
const int QUEST_OBJECTIVE_KILL = 2;
const int QUEST_OBJECTIVE_DELIVER = 3;
const int QUEST_OBJECTIVE_SPEAK = 4;
const int QUEST_OBJECTIVE_DISCOVER = 5;

// Quest Award Bitmasks
const int AWARD_ALL = 0;
const int AWARD_GOLD = 1;
const int AWARD_XP = 2;
const int AWARD_ITEM = 3;
const int AWARD_ALIGNMENT = 4;
const int AWARD_QUEST = 5;
const int AWARD_MESSAGE = 6;

// Quest Script Types
const int QUEST_SCRIPT_TYPE_ON_ACCEPT = 1;
const int QUEST_SCRIPT_TYPE_ON_ADVANCE = 2;
const int QUEST_SCRIPT_TYPE_ON_COMPLETE = 3;
const int QUEST_SCRIPT_TYPE_ON_FAIL = 4;

// Variable Validity
const string REQUEST_INVALID = "REQUEST_INVALID";

// Odds & Ends
const int QUEST_PAIR_KEYS = 1;
const int QUEST_PAIR_VALUES = 2;

// -----------------------------------------------------------------------------
//                          Database Function Prototypes
// -----------------------------------------------------------------------------

/*
    The following prototype are listed separately from the primary quest system
    prototypes because they are database-related direct-access functions.  These
    functions are avaialable for general use by including quest_i_database.
*/

// ---< Create[Module|PC]QuestTables >---
// Creates the required database tables on either the module (usually called in the
// OnModuleLoad event) or on the PC (usually called in the OnClientEnter event).
void CreateModuleQuestTables(int bReset = FALSE);
void CreatePCQuestTables(object oPC, int bReset = FALSE);

// ---< CleanPCQuestTables >---
// Clears PC quest tables of all quest data if a matching quest tag is not found
// in the module's quest database.  If this is called before quest definitions are
// loaded, all PC quest data will be erased.  Usually called in the OnClientEnter
// event.
void CleanPCQuestTables(object oPC);

// ---< GetQuest[Tag|ID] >---
// Converts a QuestTag to a QuestID
string GetQuestTag(int nQuestID);
int GetQuestID(string sQuestTag);

// ---< CountQuestSteps >---
// Counts the total number of steps in a quest, not including the final success/
// completion step.
int CountQuestSteps(int nQuestID);

// ---< CountQuestPrerequisites >---
// Counts the total number or prerequisites assigned to nQuestID.
int CountQuestPrerequisites(int nQuestID);

// ---< GetPCHasQuest >---
// Returns TRUE if oPC has quest sQuestTag assigned.
int GetPCHasQuest(object oPC, string sQuestTag);

// ---< GetIsPCQuestComplete >---
// Returns TRUE if oPC has complete quest nQuestID at least once
int GetIsPCQuestComplete(object oPC, int nQuestID);

// ---< GetPCQuestCompletions >---
// Returns the total number of times oPC has completed quest sQuestTag
int GetPCQuestCompletions(object oPC, string sQuestTag);

// ---< GetPCQuestStep >---
// Returns the current step oPC is on for quest nQuestID
int GetPCQuestStep(object oPC, int nQuestID);

// ---< GetNextPCQuestStep >---
// Given nCurrentStep, returns the step number of the next step in quest nQuestID
int GetNextPCQuestStep(int nQuestID, int nCurrentStep);

#include "util_i_csvlists"
#include "util_i_libraries"  // TODO remove after change to ExecuteScript()
#include "util_i_debug"
#include "util_i_time"
#include "quest_i_debug"
#include "quest_i_database"

// -----------------------------------------------------------------------------
//                          Quest System Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddQuest >---
// Adds a new quest with tag sTag and Journal Entry Title sTitle.  sTag is required;
// the Journal Entry title can be added later with SetQuestTitle().
int AddQuest(string sTag, string sTitle = "");

// ---< [Get|Set]Quest[Active|Inactive] >---
// Gets or sets the active status of quest sTag.
int GetQuestActive(int nQuestID);
void SetQuestActive(int nQuestID);
void SetQuestInactive(int nQuestID);

// ---< [Get|Set]QuestTitle >---
// TODO Gets or sets the quest title shown for quest sTag in the player's journal,  This is only
// useful for NWNX implementation and currently has no effect.
string GetQuestTitle(int nQuestID);
void SetQuestTitle(int nQuestID, string sTitle);

// ---< [Get|Set]QuestRepetitions >---
// Gets or sets the number of times a PC can complete quest sTag.
int GetQuestRepetitions(int nQuestID);  // TODO sQuestTag?
void SetQuestRepetitions(int nQuestID, int nRepetitions = 1);

// ---< [Get|Set]QuestScriptOn[Accept|Advance|Complete|Fail] >---
// Gets or sets the script associated with quest events OnAccept|Advance|Complete|Fail for
//  quest sTag.
string GetQuestScriptOnAccept(int nQuestID);
string GetQuestScriptOnAdvance(int nQuestID);
string GetQuestScriptOnComplete(int nQuestID);
string GetQuestScriptOnFail(int nQuestID);
void SetQuestScriptOnAccept(int nQuestID, string sScript = "");
void SetQuestScriptOnAdvance(int nQuestID, string sScript = "");
void SetQuestScriptOnComplete(int nQuestID, string sScript = "");
void SetQuestScriptOnFail(int nQuestID, string sScript = "");

// ---< RunQuestScript >---
// Runs the assigned quest script for quest nQuestID and nScriptType with oPC
// as OBJECT_SELF.
// TODO script type constants
void RunQuestScript(object oPC, int nQuestID, int nScriptType);

// ---< [Get|Set]QuestStepOrder >---
// Gets or sets the quest step order for quest sTag to nOrder.
// nOrder can be:
//  QUEST_STEP_ORDER_SEQUENTIAL
//  QUEST_STEP_ORDER_NONSEQUENTIAL
int GetQuestStepOrder(int nQuestID);
void SetQuestStepOrder(int nQuestID, int nOrder = QUEST_STEP_ORDER_SEQUENTIAL);

// ---< [Get|Set]QuestTimeLimit >---
// Gets or sets the quest time limit for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.
string GetQuestTimeLimit(int nQuestID);
void SetQuestTimeLimit(int nQuestID, string sTime);

// ---< [Get|Set]QuestCooldown >---
// Gets or sets the quest cooldown for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.  Cooldown is the minimum amount of time that
// must elapse before a player can repeat a repeatable quest.
string GetQuestCooldown(int nQuestID);
void SetQuestCooldown(int nQuestID, string sTime);

// ---< SetQuestPrerequisite[Alignment|Class|Gold|Item|LevelMax|LevelMin|Quest|QuestStep|Race] >---
// Sets a prerequisite for a PC to be able to be assigned a quest.  Prerequisites are used by
//  GetIsQuestAssignable() to determine if a PC is eligible to be assigned quest sTag
void SetQuestPrerequisiteAlignment(int nQuestID, int nKey, int nValue = FALSE);
void SetQuestPrerequisiteClass(int nQuestID, int nKey, int nValue = -1);
void SetQuestPrerequisiteGold(int nQuestID, int nValue = 1);
void SetQuestPrerequisiteItem(int nQuestID, string sKey, int nValue = 1);
void SetQuestPrerequisiteLevelMax(int nQuestID, int nValue);
void SetQuestPrerequisiteLevelMin(int nQuestID, int nValue);
void SetQuestPrerequisiteQuest(int nQuestID, string sKey, int nValue = 0);
void SetQuestPrerequisiteRace(int nQuestID, int nKey, int nValue = TRUE);

// ---< AddQuestStep >---
// Adds a new quest step to quest sTag with Journal Entry sJournalEntry.  The quest
//  step's journal entry can be added at a later time with SetQuestStepJournalEntry().
//  Returns the new quest step for use in assigning quest step variables.
int AddQuestStep(int nQuestID, string sJournalEntry = "", int nID = -1);

// ---< [Get|Set]QuestStepJournalEntry >---
// Gets or sets the journal entry associated with nStep of quest sTag
string GetQuestStepJournalEntry(int nQuestID, int nStep);
void SetQuestStepJournalEntry(int nQuestID, int nStep, string sJournalEntry);

// ---< [Get|Set]QuestTimeLimit >---
// Gets or sets nStep's time limit for quest sQuestTag to sTime.  sTime is a time
// difference vector retrieved with util_i_time.
string GetQuestStepTimeLimit(int nQuestID, int nStep);
void SetQuestStepTimeLimit(int nQuestID, int nStep, string sTime = "");

// ---< [Get|Set]QuestStepPartyCompletion >---
// Gets or sets the ability to allow party members to help complete quest steps
int GetQuestStepPartyCompletion(int nQuestID, int nStep);
void SetQuestStepPartyCompletion(int nQuestID, int nStep, int nParty);

// ---< [AddQuestResolution[Success|Fail] >---
// Adds the final quest step to quest nQuestID.
int AddQuestResolutionSuccess(int nQuestID, string sJournalEntry = "", int nStep = -1);
int AddQuestResolutionFail(int nQuestID, string sJournalEntry = "", int nStep = -1);

// ---< SetQuestStepObjective[Kill|Gather|Deliver|Discover|Speak] >---
// Sets the objective type for a specified quest step
void SetQuestStepObjectiveKill(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveGather(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveDeliver(int nQuestID, int nStep, string sKey, string sValue);
void SetQuestStepObjectiveDiscover(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepObjectiveSpeak(int nQuestID, int nStep, string sKey, int nValue = 1);

// ---< SetQuestStep[Preward|Reward][Alignment|Gold|Item|XP] >---
// Sets nStep's preward or reward
void SetQuestStepPrewardAlignment(int nQuestID, int nStep, int nKey, int nValue);
void SetQuestStepPrewardGold(int nQuestID, int nStep, int nValue);
void SetQuestStepPrewardItem(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepPrewardXP(int nQuestID, int nStep, int nValue);
void SetQuestStepPrewardMessage(int nQuestID, int nStep, string sValue);
void SetQuestStepRewardAlignment(int nQuestID, int nStep, int nKey, int nValue);
void SetQuestStepRewardGold(int nQuestID, int nStep, int nValue);
void SetQuestStepRewardItem(int nQuestID, int nStep, string sKey, int nValue = 1);
void SetQuestStepRewardXP(int nQuestID, int nStep, int nValue);
void SetQuestStepRewardMessage(int nQuestID, int nStep, string sValue);

// ---< GetIsQuestAssignable >---
// Returns whether oPC meets all prerequisites for quest sTag.  If nStep is passed,
// will evaluate reprequisites for a specific step.  Quest prerequisites can only
// be satisfied by the PC object, not party members.
int GetIsQuestAssignable(object oPC, string sTag);

// ---< [Un]AssignQuest >---
// Assigns or unassigns quest sTag to player object oPC.  Does not check for quest elgibility. 
// GetIsQuestAssignable() should be run before calling this procedure to ensure the PC
// meets all prerequisites for quest assignment.
void AssignQuest(object oPC, string sQuestTag);
void UnassignQuest(object oPC, int nQuestID);

// ---< AdvanceQuest >---
// Called from the internal function that checks quest progress, this function can be called
// on its own to force-advance the quest by one step regardless of whether the PC completed
// the current step.
void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS);

// ---< SignalQuestStepProgress >---
// Called from module/game object scripts to signal the quest system to advance the quest, if
// the PC has completed all required objectives for the current step.
void SignalQuestStepProgress(object oPC, object oTarget, int nObjectiveType);

// ---< GetCurrentQuest[Step] >---
// Global accessors to retrieve the current quest tag and step number when quest scripts are
// running.
string GetCurrentQuest();
int GetCurrentQuestStep();

// ---< [Get|Set|Delete]Quest[Int|String] >---
// Gets|Sets|Deletes a variable from a database table associated with nQuestID.  These variables
// are stored in a module-level sqlite database table and associated with the quest, so it's
// a good place to store random variables that you want to save to the quest.  Currently only
// implemented with Ints and Strings.
int GetQuestInt(string sTag, string sVarName);
void SetQuestInt(string sTag, string sVarName, int nValue);
void DeleteQuestInt(string sTag, string sVarName);

string GetQuestString(string sTag, string sVarName);
void SetQuestString(string sTag, string sVarName, string sValue);
void DeleteQuestString(string sTag, string sVarName);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

string _GetPCQuestData(object oPC, int nQuestID, string sField)
{
    string sQuestTag = GetQuestTag(nQuestID);

    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_pc_data " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@tag", sQuestTag);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

void _SetPCQuestData(object oPC, int nQuestID, string sField, string sValue)
{
    string sQuestTag = GetQuestTag(nQuestID);
    string sQuery = "UPDATE quest_pc_data " +
                    "SET " + sField + " = @value " +
                    "WHERE quest_tag = @tag;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(sql, "@value", sValue);
    SqlBindString(sql, "@tag", sQuestTag);
    
    SqlStep(sql);
}

// Should only be called after the quest has been created
// Done
void _SetQuestData(int nQuestID, string sField, string sValue)
{
    if (nQuestID == 0)
    {
        Error("Attempt to set quest data when quest does not exist" +
              "\n  Quest ID -> " + IntToString(nQuestID) +
              "\n  Field    -> " + sField +
              "\n  Value    -> " + sValue);
        return;
    }

    string sQuery = "UPDATE quest_quests " +
                    "SET " + sField + " = @sValue " +
                    "WHERE id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindString(sql, "@sValue", sValue);
    SqlBindInt(sql, "@id", nQuestID);
    SqlStep(sql);
}

// Done
string _GetQuestData(int nQuestID, string sField)
{
    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_quests " +
                    "WHERE id = @id;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

// Done
void _SetQuestVariable(int nQuestID, string sType, string sVarName, string sValue)
{
    // Don't create the table unless we need it
    CreateQuestVariablesTable();

    string sQuery = "INSERT INTO quest_variables (quests_id, sType, sName, sValue) " +
                    "VALUES (@id, @type, @name, @value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
}

// Done
string _GetQuestVariable(int nQuestID, string sType, string sVarName)
{
    string sQuery = "SELECT sValue FROM quest_variables " +
                    "WHERE quests_id = @id " +
                        "AND sType = @type " +
                        "AND sName = @name;";

    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);

    return (SqlStep(sql) ? SqlGetString(sql, 0) : "");
}

// Done
void _DeleteQuestVariable(int nQuestID, string sType, string sVarName)
{
    string sQuery = "DELETE FROM quest_variables " +
                    "WHERE quests_id = @id " +
                        "AND sPropertyType = @type " +
                        "AND sPropertyName = @name;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@name", sVarName);

    SqlStep(sql);
}

// Accessors for quest variables  -- All Done
void SetQuestInt(string sTag, string sVarName, int nValue)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "INT", sVarName, IntToString(nValue));
}

int GetQuestInt(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return 0;

    return StringToInt(_GetQuestVariable(nQuestID, "INT", sVarName));
}

void DeleteQuestInt(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _DeleteQuestVariable(nQuestID, "INT", sVarName);
}

void SetQuestString(string sTag, string sVarName, string sValue)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _SetQuestVariable(nQuestID, "STRING", sVarName, sValue);
}

string GetQuestString(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return "";

    return _GetQuestVariable(nQuestID, "STRING", sVarName);
}

void DeleteQuestString(string sTag, string sVarName)
{
    int nQuestID = GetQuestID(sTag);
    if (nQuestID == 0 || sVarName == "")
        return;

    _DeleteQuestVariable(nQuestID, "STRING", sVarName);
}
// Not planning on other types, this is probably of limited use anyway.
// End accessors for quest variables

// Set quest step data // done
void _SetQuestStepData(int nQuestID, int nStep, string sField, string sValue)
{
    string sQuery = "UPDATE quest_steps " +
                    "SET " + sField + " = @value " +
                    "WHERE quests_id = @id " +
                        "AND nStep = @nStep;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@nStep", nStep);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
}

// done
string _GetQuestStepData(int nQuestID, int nStep, string sField)
{
    string sQuery = "SELECT " + sField + " " +
                    "FROM quest_steps " +
                    "WHERE quests_id = @id " +
                        "AND nStep = @step;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@id", nQuestID);
    SqlBindInt(sql, "@step", nStep);
    
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

//done
int _GetIsPropertyStackable(int nPropertyType)
{
    if (nPropertyType == QUEST_VALUE_GOLD ||
        nPropertyType == QUEST_VALUE_LEVEL_MAX ||
        nPropertyType == QUEST_VALUE_LEVEL_MIN ||
        nPropertyType == QUEST_VALUE_XP)
        return FALSE;
    else
        return TRUE;
}

//done
void _SetQuestStepProperty(int nQuestID, int nStep, int nCategoryType, 
                           int nValueType, string sKey, string sValue)
{
    // If an objective, must the same type as the rest of the objectives, if any
    if (nCategoryType == QUEST_CATEGORY_OBJECTIVE)
    {
        int nCurrentType = GetQuestStepObjectiveType(nQuestID, nStep);
        if (nCurrentType != 0)
        {
            if (nValueType != nCurrentType)
            {
                Error("Attempted to add an objective type that is not the same as " +
                    "current objective types" +
                    "\n  Quest ID -> " + IntToString(nQuestID) +
                    "\n  Step -> " + IntToString(nStep) +
                    "\n  Category Type -> Objective" +
                    "\n  Value Type -> " + IntToString(nValueType) +
                    "\n  Key -> " + sKey +
                    "\n  Value -> " + sValue);
                return;
            }
        }
    }
    else    // If it's not stackable, delete the previous record and replace
    {
        if (_GetIsPropertyStackable(nValueType) == FALSE)
            DeleteQuestStepPropertyPair(nQuestID, nStep, nCategoryType, nValueType);
    }

    string sQuery = "INSERT INTO quest_step_properties " +
                        "(quest_steps_id, nCategoryType, nValueType, sKey, sValue) " +
                    "VALUES (@step_id, @category, @type, @key, @value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindInt(sql, "@step_id", GetQuestStepID(nQuestID, nStep));
    SqlBindInt(sql, "@type", nValueType);
    SqlBindInt(sql, "@category", nCategoryType);
    SqlBindString(sql, "@key", sKey);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
}

// Private accessor for setting quest step objectives
void _SetQuestObjective(int nQuestID, int nStep, int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_OBJECTIVE;
    _SetQuestStepProperty(nQuestID, nStep, nCategoryType, nValueType, sKey, sValue);
}

// Private accessor for setting quest step prewards
void _SetQuestPreward(int nQuestID, int nStep, int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_PREWARD;
    _SetQuestStepProperty(nQuestID, nStep, nCategoryType, nValueType, sKey, sValue);
}

// Private accessor for setting quest step rewards
void _SetQuestReward(int nQuestID, int nStep, int nValueType, string sKey, string sValue)
{
    int nCategoryType = QUEST_CATEGORY_REWARD;
    _SetQuestStepProperty(nQuestID, nStep, nCategoryType, nValueType, sKey, sValue);
}

void _AssignQuest(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);

    if (GetPCHasQuest(oPC, sQuestTag))
    {
        DeletePCQuestProgress(oPC, nQuestID);
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, "0");
        _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, "");
    }
    else
        _AddQuestToPC(oPC, nQuestID);

    // Set the quest start time
    _SetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME, GetSystemTime());
    
    RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_ACCEPT);
    // Go to the first step
    AdvanceQuest(oPC, nQuestID);
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

int GetPCItemCount(object oPC, string sItemTag)
{
    int nItemCount = 0;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetStringLowerCase(GetTag(oItem)) == GetStringLowerCase(sItemTag))
            nItemCount += GetNumStackedItems(oItem);
        oItem = GetNextItemInInventory(oPC);
    }

    return nItemCount;
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

void _AwardQuest(object oPC, int nQuestID, int nFlag = TRUE, int bParty = FALSE)
{
    int nAssigned, nComplete;
    string sQuestTag = GetQuestTag(nQuestID);

    if (bParty)
    {
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            nAssigned = GetPCHasQuest(oPartyMember, sQuestTag);
            nComplete = GetIsPCQuestComplete(oPartyMember, nQuestID);

            if (nFlag)
            {
                if (!nAssigned || (nAssigned && nComplete))
                    _AssignQuest(oPartyMember, nQuestID);
            }
            else
                UnassignQuest(oPartyMember, nQuestID);
            
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
    {
        nAssigned = GetPCHasQuest(oPC, sQuestTag);
        nComplete = GetIsPCQuestComplete(oPC, nQuestID);

        if (nFlag)
        {
            if (!nAssigned || (nAssigned && nComplete))
                _AssignQuest(oPC, nQuestID);
        }
        else
            UnassignQuest(oPC, nQuestID);
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

// Awards quest sTag step nStep [p]rewards.  The awards type will be limited by nAwardType and can be
// provided to the entire party with bParty.  nCategoryType is a QUEST_CATEGORY_* constant.
void _AwardQuestStepAllotments(object oPC, int nQuestID, int nStep, int nCategoryType, 
                               int nAwardType = AWARD_ALL, int bParty = FALSE)
{
    int nValueType;
    string sKey, sValue;

    sqlquery sPairs = GetQuestStepPropertySets(nQuestID, nStep, nCategoryType);
    while (SqlStep(sPairs))
    {
        nValueType = SqlGetInt(sPairs, 0);
        sKey = SqlGetString(sPairs, 1);
        sValue = SqlGetString(sPairs, 2);

        switch (nValueType)
        {
            case QUEST_VALUE_GOLD:
            {
                if ((nAwardType && AWARD_GOLD) || nAwardType == AWARD_ALL)
                {
                    int nGold = StringToInt(sValue);
                    _AwardGold(oPC, nGold, bParty);
                }
                continue;
            }
            case QUEST_VALUE_XP:
            {
                if ((nAwardType && AWARD_XP) || nAwardType == AWARD_ALL)
                {
                    int nXP = StringToInt(sValue);
                    _AwardXP(oPC, nXP, bParty);
                }
                continue;
            }
            case QUEST_VALUE_ALIGNMENT:
            {
                if ((nAwardType && AWARD_ALIGNMENT) || nAwardType == AWARD_ALL)
                {
                    int nAxis = StringToInt(sKey);
                    int nShift = StringToInt(sValue);
                    _AwardAlignment(oPC, nAxis, nShift, bParty);
                }
                continue;
            }  
            case QUEST_VALUE_ITEM:
            {
                if ((nAwardType && AWARD_ITEM) || nAwardType == AWARD_ALL)
                {
                    string sResref = sKey;     
                    int nQuantity = StringToInt(sValue);
                    _AwardItem(oPC, sResref, nQuantity, bParty);
                }
            }
            case QUEST_VALUE_QUEST:
            {
                if ((nAwardType && AWARD_QUEST) || nAwardType == AWARD_ALL)
                {
                    int nValue = StringToInt(sValue);
                    int nFlag = StringToInt(sValue);
                    _AwardQuest(oPC, nValue, nFlag, bParty);
                }
            }
            case QUEST_VALUE_MESSAGE:
            {
                if ((nAwardType && AWARD_MESSAGE) || nAwardType == AWARD_ALL)
                {
                    string sMessage = HexColorString(sValue, COLOR_CYAN);
                    SendMessageToPC(oPC, sMessage);
                }
            }
        }
    }
}


// -----------------------------------------------------------------------------
//                          Public Function Definitions
// -----------------------------------------------------------------------------

int AddQuest(string sQuestTag, string sTitle = "")
{
    if (GetQuestExists(sQuestTag) == TRUE || sQuestTag == "")
        return FALSE;
    
    return _AddQuest(sQuestTag, sTitle);
}

//done
int AddQuestStep(int nQuestID, string sJournalEntry = "", int nStep = -1)
{   
    // Steps must be created in order of sending a custom step id (i.e. if using existing
    // journal entries).
    if (nStep == -1)
        nStep = CountQuestSteps(nQuestID) + 1;

    _AddQuestStep(nQuestID, sJournalEntry, nStep);
    return nStep;
}

int GetIsQuestAssignable(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    int bAssignable = FALSE;

    // TODO check that quest as steps
    // minimum = 1 successful completion test

    if (GetPCHasQuest(oPC, sQuestTag) == TRUE)
    {
        if (GetIsPCQuestComplete(oPC, nQuestID))
        {

            string sCompleteTime, sCooldownTime = _GetQuestData(nQuestID, QUEST_COOLDOWN);
            if (sCooldownTime == "")
                bAssignable = TRUE;
            else
            {
                sCompleteTime = _GetPCQuestData(oPC, nQuestID, QUEST_PC_LAST_COMPLETE);
                sCompleteTime = AddSystemTimeVector(sCompleteTime, sCooldownTime);
                if (GetMinSystemTime(sCompleteTime) == sCompleteTime)
                    bAssignable = TRUE;
                else
                    return FALSE;
            }
        }
        else
            return FALSE;
    }
    else
    {
        Notice("PC does not have " + sQuestTag + " assigned");
        bAssignable = TRUE;
    }

    // If there are no quest prerequisites, allow the assignment
    if (CountQuestPrerequisites(nQuestID) == 0)
    {
        Notice("Quest prerequisites for " + sQuestTag + " not found");
        return TRUE;
    }
    else
        Notice("Found " + IntToString(CountQuestPrerequisites(nQuestID)) + " prerequisites for " + sQuestTag);

    string sError, sErrors;
    sqlquery sqlPrerequisites = GetQuestPrerequisiteTypes(nQuestID);
    while (SqlStep(sqlPrerequisites))
    {
        int nValueType = SqlGetInt(sqlPrerequisites, 0);
        int nTypeCount = SqlGetInt(sqlPrerequisites, 1);

        Notice(HexColorString("Checking quest prerequisite " + ValueTypeToString(nValueType) + " " + IntToString(nTypeCount), COLOR_CYAN));

        if (_GetIsPropertyStackable(nValueType) == FALSE && nTypeCount > 1)
        {
            Error("GetIsQuestAssignable found multiple entries for a " +
                "non-stackable property" +
                "\n  Quest ID -> " + IntToString(nQuestID) +
                "\n  Quest Tag -> " + GetQuestTag(nQuestID) +
                "\n  Category -> " + CategoryTypeToString(QUEST_CATEGORY_PREREQUISITE) +
                "\n  Value -> " + ValueTypeToString(nValueType) +
                "\n  Entries -> " + IntToString(nTypeCount));
            return FALSE;
        }

        sqlquery sqlPrerequisitesByType = GetQuestPrerequisitesByType(nQuestID, nValueType);
        switch (nValueType)
        {
            case QUEST_VALUE_ALIGNMENT:
            {
                int nAxis, bNeutral, bQualifies;
                int nGE = GetAlignmentGoodEvil(oPC);
                int nLC = GetAlignmentLawChaos(oPC);
                
                Notice("  PC GE -> " + AlignmentAxisToString(nGE) +
                     "\n  PC LC -> " + AlignmentAxisToString(nLC));                

                while (SqlStep(sqlPrerequisitesByType))
                {
                    nAxis = SqlGetInt(sqlPrerequisitesByType, 0);
                    bNeutral = SqlGetInt(sqlPrerequisitesByType, 1);

                    Notice("  ALIGNMENT | " + AlignmentAxisToString(nAxis) + " | " + (bNeutral ? "TRUE":"FALSE"));

                    if (bNeutral == TRUE)
                    {
                        if (nGE == ALIGNMENT_NEUTRAL ||
                            nLC == ALIGNMENT_NEUTRAL)
                        {
                            Notice("  Setting assigability by Neutral check");
                            bQualifies = TRUE;
                        }
                    }
                    else
                    {
                        if (nGE == nAxis || nLC == nAxis)
                        {
                            Notice("  Setting assigability by axis check");
                            bQualifies = TRUE;
                        }
                    }
                }

                Notice("  ALIGNMENT resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_CLASS:
            {
                int nClass, nLevels, bQualifies;
                int nClass1 = GetClassByPosition(1, oPC);
                int nClass2 = GetClassByPosition(2, oPC);
                int nClass3 = GetClassByPosition(3, oPC);
                int nLevels1 = GetLevelByClass(nClass1, oPC);
                int nLevels2 = GetLevelByClass(nClass2, oPC);
                int nLevels3 = GetLevelByClass(nClass3, oPC);
                
                Notice("  PC Classes -> " + ClassToString(nClass1) + " (" + IntToString(nLevels1) + ") | " +
                                            ClassToString(nClass2) + " (" + IntToString(nLevels2) + ") | " +
                                            ClassToString(nClass3) + " (" + IntToString(nLevels3) + ")");

                while (SqlStep(sqlPrerequisitesByType))
                {
                    nClass = SqlGetInt(sqlPrerequisitesByType, 0);
                    nLevels = SqlGetInt(sqlPrerequisitesByType, 1);

                    Notice("  CLASS | " + ClassToString(nClass) + " | Levels " + IntToString(nLevels));

                    switch (nLevels)
                    {
                        case 0:   // No levels in specific class
                            if (nClass1 == nClass || nClass2 == nClass || nClass3 == nClass)
                            {
                                bQualifies = FALSE;
                                break;
                            }

                            Notice("  Setting assigability by exclusion check");
                            bQualifies = TRUE;
                            break;
                        default:  // Specific number or more of levels in a specified class
                            if (nClass1 == nClass && nLevels1 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass2 == nClass && nLevels2 >= nLevels)
                                bQualifies = TRUE;
                            else if (nClass3 == nClass && nLevels3 >= nLevels)
                                bQualifies = TRUE;
                            
                            Notice("  Setting assigability by inclusion check");
                            break;
                    }
                }

                Notice("  CLASS resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_FACTION:   // TODO
                // Not yet implemented
                break;
            case QUEST_VALUE_GOLD:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nGoldRequired = SqlGetInt(sqlPrerequisitesByType, 1);
                
                Notice("  GOLD | " + IntToString(nGoldRequired) + " | PC -> " + IntToString(GetGold(oPC)));
                
                if (GetGold(oPC) >= nGoldRequired)
                    bQualifies = TRUE;

                Notice("  GOLD resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_ITEM:
            {
                string sItemTag;
                int nItemQuantity, bQualifies;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sItemTag = SqlGetString(sqlPrerequisitesByType, 0);
                    nItemQuantity = SqlGetInt(sqlPrerequisitesByType, 1);

                    Notice("  ITEM | " + sItemTag + " | " + IntToString(nItemQuantity));

                    int nItemCount = GetPCItemCount(oPC, sItemTag);
                    Notice("  PC has " + IntToString(nItemCount) + " " + sItemTag);
                    
                    if (nItemQuantity == 0 && nItemCount > 0)
                    {
                        bQualifies = FALSE;
                        break;
                    }
                    else if (nItemQuantity > 0 && nItemCount >= nItemQuantity)
                        bQualifies = TRUE;
                }

                Notice("  ITEM resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_LEVEL_MAX:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nMaximumLevel = SqlGetInt(sqlPrerequisitesByType, 1);

                Notice("  LEVEL_MAX | " + IntToString(nMaximumLevel) + " | PC -> " + IntToString(GetHitDice(oPC)));
                
                if (GetHitDice(oPC) <= nMaximumLevel)
                    bQualifies = TRUE;
                
                Notice("  LEVEL_MAX resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_LEVEL_MIN:
            {
                SqlStep(sqlPrerequisitesByType);
                int bQualifies, nMinimumLevel = SqlGetInt(sqlPrerequisitesByType, 1);
                
                Notice("  LEVEL_MIN | " + IntToString(nMinimumLevel) + " | PC -> " + IntToString(GetHitDice(oPC)));
                
                if (GetHitDice(oPC) >= nMinimumLevel)
                    bQualifies = TRUE;

                Notice("  LEVEL_MAX resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_QUEST:
            {
                string sQuestTag;
                int nRequiredCompletions;
                int bQualifies, bPCHasQuest, nPCCompletions;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sQuestTag = SqlGetString(sqlPrerequisitesByType, 0);
                    nRequiredCompletions = SqlGetInt(sqlPrerequisitesByType, 1);

                    Notice("  QUEST | " + sQuestTag + " | Completions -> " + IntToString(nRequiredCompletions));

                    bPCHasQuest = GetPCHasQuest(oPC, sQuestTag);
                    nPCCompletions = GetPCQuestCompletions(oPC, sQuestTag);

                    Notice("  PC | Has Quest -> " + (bPCHasQuest ? "TRUE":"FALSE") + " | Completions -> " + IntToString(nPCCompletions));

                    if (nRequiredCompletions > 0)
                    {
                        if (bPCHasQuest == TRUE && nPCCompletions >= nRequiredCompletions)
                            bQualifies = TRUE;
                    }
                    else if (nRequiredCompletions == 0)
                    {
                        if (bPCHasQuest == TRUE && nPCCompletions == 0)
                            bQualifies = TRUE;
                    }
                    else if (nRequiredCompletions < 0)
                    {
                        if (bPCHasQuest == TRUE)
                        {
                            bQualifies = FALSE;
                            break;
                        }
                    }
                }

                Notice("  QUEST resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_QUEST_STEP:
            {
                string sQuestTag;
                int nRequiredStep;
                int bQualifies, bPCHasQuest, nPCStep;

                while (SqlStep(sqlPrerequisitesByType))
                {
                    sQuestTag = SqlGetString(sqlPrerequisitesByType, 0);
                    nRequiredStep = SqlGetInt(sqlPrerequisitesByType, 1);

                    Notice("  QUEST_STEP | " + sQuestTag + " | Step -> " + IntToString(nRequiredStep));

                    bPCHasQuest = GetPCHasQuest(oPC, sQuestTag);
                    nPCStep = GetPCQuestStep(oPC, nQuestID);

                    Notice("  PC | Has Quest -> " + (bPCHasQuest ? "TRUE":"FALSE") + " | Step -> " + IntToString(nRequiredStep));

                    if (bPCHasQuest)
                    {
                        if (nPCStep >= nRequiredStep)
                            bQualifies = TRUE;
                    }
                    else
                    {
                        bQualifies = FALSE;
                        break;
                    }
                }

                Notice("  QUEST_STEP resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
            case QUEST_VALUE_RACE:
            {
                int nRace, nPCRace = GetRacialType(oPC);
                int bQualifies, bAllowed;

                Notice("  PC Race -> " + RaceToString(nPCRace));
                
                while (SqlStep(sqlPrerequisitesByType))
                {
                    nRace = SqlGetInt(sqlPrerequisitesByType, 0);
                    bAllowed = SqlGetInt(sqlPrerequisitesByType, 1);

                    Notice("  RACE | " + RaceToString(nRace) + " | Allowed -> " + (bAllowed ? "TRUE":"FALSE"));

                    if (bAllowed == TRUE)
                    {
                        if (nPCRace == nRace)
                            bQualifies = TRUE;
                    }
                    else if (bAllowed == FALSE)
                    {
                        if (nPCRace == nRace)
                        {
                            bQualifies = FALSE;
                            break;
                        }
                        else
                            bQualifies = TRUE;
                    }
                }
                    
                Notice("  RACE resolution -> " + (bQualifies ? "" : "NOT ") + "Assignable");

                if (bQualifies == TRUE)
                    bAssignable = TRUE;
                else
                    sErrors = AddListItem(sErrors, IntToString(nValueType));

                break;
            }
        }
    }

    if (sErrors != "")
    {
        int n, nCount = CountList(sErrors);
        string sResult;

        for (n = 0; n < nCount; n++)
        {
            string sError = GetListItem(sErrors, n);
            sResult = AddListItem(sResult, ValueTypeToString(StringToInt(sError)));
        }

        Warning("Quest " + sQuestTag + " could not be assigned to " + GetName(oPC) +
            "; PC did not meet the following prerequisites: " + sResult);

        return FALSE;
    }
    else
        return TRUE;
}

void AssignQuest(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    _AssignQuest(oPC, nQuestID);
}

void RunQuestScript(object oPC, int nQuestID, int nScriptType)
{
    string sScript, sQuestTag = GetQuestTag(nQuestID);
    int bSetStep = FALSE;

    if (nScriptType == QUEST_SCRIPT_TYPE_ON_ACCEPT)
        sScript = GetQuestScriptOnAccept(nQuestID);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_ADVANCE)
    {
        sScript = GetQuestScriptOnAdvance(nQuestID);
        bSetStep = TRUE;
    }
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_COMPLETE)
        sScript = GetQuestScriptOnComplete(nQuestID);
    else if (nScriptType == QUEST_SCRIPT_TYPE_ON_FAIL)
        sScript = GetQuestScriptOnFail(nQuestID);

    if (sScript == "")
        return;
    
    // Set values that the script has available to it
    SetLocalString(GetModule(), QUEST_CURRENT_QUEST, sQuestTag);
    if (bSetStep)
    {
        int nStep = GetPCQuestStep(oPC, nQuestID);
        SetLocalInt(GetModule(), QUEST_CURRENT_STEP, nStep);
    }

    RunLibraryScript(sScript, oPC);

    DeleteLocalInt(GetModule(), QUEST_CURRENT_QUEST);
    DeleteLocalInt(GetModule(), QUEST_CURRENT_STEP);
}

void UnassignQuest(object oPC, int nQuestID)
{
    DeletePCQuest(oPC, nQuestID);
    // TODO remove the journal entry?
}

int CountPCQuestCompletions(object oPC, int nQuestID)
{
    string sQuestTag = GetQuestTag(nQuestID);
    return GetPCQuestCompletions(oPC, sQuestTag);
}

void CopyQuestStepObjectiveData(object oPC, int nQuestID, int nStep)
{
    sqlquery sqlStepData = GetQuestStepObjectiveData(nQuestID, nStep);
    while (SqlStep(sqlStepData))
    {
        int nObjectiveType = SqlGetInt(sql, 0);
        string sTag = SqlGetString(sql, 1);
        int nQuantity = SqlGetInt(sql, 2);

        AddQuestStepObjectiveData(oPC, nQuestID, nObjectiveType, sTag, nQuantity);
    }
}

void SendJournalQuestEntry(object oPC, int nQuestID, int nStep)
{
    string sTag = GetQuestTag(nQuestID);
    AddJournalQuestEntry(sTag, nStep, oPC, FALSE, FALSE, TRUE);
}

void AdvanceQuest(object oPC, int nQuestID, int nRequestType = QUEST_ADVANCE_SUCCESS)
{
    if (nRequestType == QUEST_ADVANCE_SUCCESS)
    {
        int nCurrentStep = GetPCQuestStep(oPC, nQuestID);
        int nNextStep = GetNextPCQuestStep(nQuestID, nCurrentStep);

        if (nNextStep == -1)
        {
            // Next step is the last step, go to the completion step
            nNextStep = GetQuestCompletionStep(nQuestID);

            DeletePCQuestProgress(oPC, nQuestID);
            SendJournalQuestEntry(oPC, nQuestID, nNextStep);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
            IncrementPCQuestCompletions(oPC, nQuestID);
            ResetPCQuestData(oPC, nQuestID);
            RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_COMPLETE);
        }
        else
        {
            DeletePCQuestProgress(oPC, nQuestID);
            CopyQuestStepObjectiveData(oPC, nQuestID, nNextStep);
            SendJournalQuestEntry(oPC, nQuestID, nNextStep);
            _AwardQuestStepAllotments(oPC, nQuestID, nCurrentStep, QUEST_CATEGORY_REWARD);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_PREWARD);
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP, IntToString(nNextStep));
            _SetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME, GetSystemTime());
            RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_ADVANCE);
        }
    }
    else if (nRequestType == QUEST_ADVANCE_FAIL)
    {
        int nNextStep = GetQuestCompletionStep(nQuestID, QUEST_ADVANCE_FAIL);
        DeletePCQuestProgress(oPC, nQuestID);
        ResetPCQuestData(oPC, nQuestID);

        if (nNextStep != -1)
        {
            SendJournalQuestEntry(oPC, nQuestID, nNextStep);
            _AwardQuestStepAllotments(oPC, nQuestID, nNextStep, QUEST_CATEGORY_REWARD);
        }

        RunQuestScript(oPC, nQuestID, QUEST_SCRIPT_TYPE_ON_FAIL);
    }
}

void CheckQuestStepProgress(object oPC, int nQuestID, int nStep)
{

    int QUEST_STEP_INCOMPLETE = 1;
    int QUEST_STEP_COMPLETE = 2;
    int QUEST_STEP_FAIL = 3;

    int nRequired, nAcquired, nStatus = QUEST_STEP_INCOMPLETE;
    string sStartTime, sGoalTime;

    // Check for time failure first, if there is a time limit
    string sQuestTimeLimit = GetQuestTimeLimit(nQuestID);
    string sStepTimeLimit = GetQuestStepTimeLimit(nQuestID, nStep);

    // Check for quest step time limit ...
    if (sStepTimeLimit != "")
    {   // There was a time limit assigned
        sStartTime = _GetPCQuestData(oPC, nQuestID, QUEST_PC_STEP_TIME);
        sGoalTime = AddSystemTimeVector(sStartTime, sStepTimeLimit);
        if (GetMinSystemTime(sGoalTime) == sGoalTime)
            nStatus = QUEST_STEP_FAIL;
    }

    if (nStatus != QUEST_STEP_FAIL)
    {
        // Check for overall quest time limit ...
        if (sQuestTimeLimit != "")
        {
            sStartTime = _GetPCQuestData(oPC, nQuestID, QUEST_PC_QUEST_TIME);
            sGoalTime = AddSystemTimeVector(sStartTime, sQuestTimeLimit);
            if (GetMinSystemTime(sGoalTime) == sGoalTime)
                nStatus = QUEST_STEP_FAIL;
        }
    }

    // Okay, we passed the time tests, not see if we failed an "exclusive" objective
    if (nStatus != QUEST_STEP_FAIL)
    {
        sqlquery sqlSums = GetQuestStepSums(oPC, nQuestID);
        sqlquery sqlFail = GetQuestStepSumsFailure(oPC, nQuestID);

        if (SqlStep(sqlFail))
        {

            nRequired = SqlGetInt(sqlFail, 1);
            nAcquired = SqlGetInt(sqlFail, 2);

            if (nAcquired > nRequired)
                nStatus = QUEST_STEP_FAIL;
        }

        // We passed the exclusive checks, see about the inclusive checks
        if (nStatus != QUEST_STEP_FAIL)
        {
            // Check for success
            if (SqlStep(sqlSums))
            {
                nRequired = SqlGetInt(sqlSums, 1);
                nAcquired = SqlGetInt(sqlSums, 2);

                if (nAcquired >= nRequired)
                    nStatus = QUEST_STEP_COMPLETE;
            }
        }
    }

    if (nStatus == QUEST_STEP_COMPLETE)
        AdvanceQuest(oPC, nQuestID);
    else if (nStatus == QUEST_STEP_FAIL)
        AdvanceQuest(oPC, nQuestID, QUEST_ADVANCE_FAIL);
}

void SignalQuestStepProgress(object oPC, object oTarget, int nObjectiveType)
{
    string sTargetTag = GetStringLowerCase(GetTag(oTarget));
    int bPCFound = FALSE;

    // TODO should we have the scripter send the PC in, or just take the target
    // and objective type to find the pc (i.e. GetEnteringObject())?  For now,
    // probably easier on use if we let the scripter determine who conducted the
    // action and go from there, this allows easier future expansion of quest
    // types.

    // TODO find a way to make this recursive, if possible, to prevent maintaining
    // multiple redundant loops

    // Ensure we're not running on a henchman or NPC
    while (GetIsObjectValid(GetMaster(oPC)))
        oPC = GetMaster(oPC);

    // ... and that the final solution is a pc, shouldn't be any
    // npc characters that are not henchmen/associates
    if (GetIsPC(oPC) == FALSE)
        return;

    // Two ways to go here, we can either check to see if the pc has any
    //  quest with the targets tag, if not check all party pcs ...
    // ... or we can query the main database for all quests that have the
    // target tag and objective type and then query each pc to see if
    // they have those quests on board.  Going to try the first version
    // first, might be more efficient since I think we'll have to loop all the
    // pcs in the party anyway.
    
    // Get the database records from the pc that are associated with
    // the target and objective type
    sqlquery sqlQuestData = GetTargetQuestData(oPC, sTargetTag, nObjectiveType);
    
    // See if there are any records to look at it
    while (SqlStep(sqlQuestData))
    {   
        // If this loop doesn't execute, then there are no records to retrieve
        // that involve that target and objective type
        string sQuestTag = SqlGetString(sql, 0);
        int nStep = SqlGetInt(sql, 1);
        int nQuestID = GetQuestID(sQuestTag);

        // Probably need to put some of this in another function for recursion
        // we'll figure that out after the basic logic works

        // Since we're here, that means that this pc has at least one quest
        // active associated with oTarget and objective type.  Since we only 
        // have active steps in this table, it should be safe to simply increment 
        // those values without a further check
        IncrementQuestStepQuantity(oPC, sTargetTag, nObjectiveType);
        
        // Check the new status of the quest, this checks to see if the quest step
        // is now complete, incomplete or failed and takes the appropriate action.
        // None of those actions, however should prevent us from completing these
        // checks, however, so press on
        CheckQuestStepProgress(oPC, nQuestID, nStep);

        // See if this can be done with party members
        // this will have to be optioned out so if we're already looping
        // party members from another pc, we don't loop the same party over
        // again, do that if/when we get to recursion.
        if (GetQuestStepPartyCompletion(nQuestID, nStep) == TRUE)
        {
            object oParty = GetFirstFactionMember(oPC, TRUE);
            while (GetIsObjectValid(oParty))
            {
                // Don't need to do a bunch of checking here, if they have the
                // data, they get it incremented
                IncrementQuestStepQuantity(oParty, sTargetTag, nObjectiveType);
                CheckQuestStepProgress(oPC, nQuestID, nStep);
                oParty = GetNextFactionMember(oPC, TRUE);
            }
        }

        bPCFound = TRUE;
    }

    if (bPCFound)
        return;

    // if we're here, the original acting pc (oPC) didnt' have any quests
    // associated with oTarget and nObjectiveType

    // Loop the party to see if anyone has a quest that does
    object oParty = GetFirstFactionMember(oPC, TRUE);
    while (GetIsObjectValid(oParty))
    {
        // We already checked the current pc, skip!
        if (oParty == oPC)
        {
            oParty = GetNextFactionMember(oPC, TRUE);
            continue;
        }
        
        // Get the quest data for that pc to see if they have any qualifying
        // quests ... we can re-use slqQuestData from above, so might be able
        // to recurse this
        sqlquery sqlPartyData = GetTargetQuestData(oParty, sTargetTag, nObjectiveType);
        while (SqlStep(sqlPartyData))
        {
            // If we're in here, they do have at least one qualifying quest...
            int nQuestID = SqlGetInt(sql, 0);
            int nStep = SqlGetInt(sql, 1);

            // This isn't the original actor, so we need party completion before
            // we can increment
            if (GetQuestStepPartyCompletion(nQuestID, nStep) == TRUE)
            {
                IncrementQuestStepQuantity(oParty, sTargetTag, nObjectiveType);
                CheckQuestStepProgress(oPC, nQuestID, nStep);
            }
        }

        oParty = GetNextFactionMember(oPC, TRUE);
    } 
}

// These two functions are used to access temporary variables to
// allow script access for quest events
string GetCurrentQuest()
{
    return GetLocalString(GetModule(), QUEST_CURRENT_QUEST);
}

int GetCurrentQuestStep()
{
    return GetLocalInt(GetModule(), QUEST_CURRENT_STEP);
}



void AwardQuestStepPrewards(object oPC, int nQuestID, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_PREWARD, nAwardType, bParty);
}

void AwardQuestStepRewards(object oPC, int nQuestID, int nStep, int bParty = FALSE, int nAwardType = AWARD_ALL)
{
    _AwardQuestStepAllotments(oPC, nQuestID, nStep, QUEST_CATEGORY_REWARD, nAwardType, bParty);
}

string GetQuestTitle(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_TITLE);
}

void SetQuestTitle(int nQuestID, string sTitle)
{
    _SetQuestData(nQuestID, QUEST_TITLE, sTitle);
}

int GetQuestActive(int nQuestID)
{
    string sActive = _GetQuestData(nQuestID, QUEST_ACTIVE);
    return StringToInt(sActive);
}

void SetQuestActive(int nQuestID)
{
    _SetQuestData(nQuestID, QUEST_ACTIVE, IntToString(TRUE));
}

void SetQuestInactive(int nQuestID)
{
    _SetQuestData(nQuestID, QUEST_ACTIVE, IntToString(FALSE));
}

int GetQuestRepetitions(int nQuestID)
{
    string sRepetitions = _GetQuestData(nQuestID, QUEST_REPETITIONS);
    return StringToInt(sRepetitions);
}

void SetQuestRepetitions(int nQuestID, int nRepetitions = 1)
{
    string sRepetitions = IntToString(nRepetitions);
    _SetQuestData(nQuestID, QUEST_REPETITIONS, sRepetitions);
}

string GetQuestTimeLimit(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_TIME_LIMIT);
}

void SetQuestTimeLimit(int nQuestID, string sTime)
{
    _SetQuestData(nQuestID, QUEST_TIME_LIMIT, sTime);
}

string GetQuestCooldown(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_COOLDOWN);
}

void SetQuestCooldown(int nQuestID, string sTime)
{
    _SetQuestData(nQuestID, QUEST_COOLDOWN, sTime);
}

int GetQuestStepOrder(int nQuestID)
{
    string sStepOrder = _GetQuestData(nQuestID, QUEST_STEP_ORDER);
    return StringToInt(sStepOrder);
}

void SetQuestStepOrder(int nQuestID, int nOrder = QUEST_STEP_ORDER_SEQUENTIAL)
{
    string sOrder = IntToString(nOrder);
    _SetQuestData(nQuestID, QUEST_STEP_ORDER, sOrder);
}

string GetQuestScriptOnAccept(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ACCEPT);
}

void SetQuestScriptOnAccept(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_ACCEPT, sScript);
}

string GetQuestScriptOnAdvance(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_ADVANCE);
}

void SetQuestScriptOnAdvance(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_ADVANCE, sScript);
}

string GetQuestScriptOnComplete(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_COMPLETE);
}

void SetQuestScriptOnComplete(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_COMPLETE, sScript);
}

string GetQuestScriptOnFail(int nQuestID)
{
    return _GetQuestData(nQuestID, QUEST_SCRIPT_ON_FAIL);
}

void SetQuestScriptOnFail(int nQuestID, string sScript = "")
{
    _SetQuestData(nQuestID, QUEST_SCRIPT_ON_FAIL, sScript);
}

string GetQuestStepJournalEntry(int nQuestID, int nStep)
{
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY);
}

void SetQuestStepJournalEntry(int nQuestID, int nStep, string sJournalEntry)
{
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_JOURNAL_ENTRY, sJournalEntry);
}

string GetQuestStepTimeLimit(int nQuestID, int nStep)
{
    return _GetQuestStepData(nQuestID, nStep, QUEST_STEP_TIME_LIMIT);
}

void SetQuestStepTimeLimit(int nQuestID, int nStep, string sTime = "")
{
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_TIME_LIMIT, sTime);
}

int GetQuestStepPartyCompletion(int nQuestID, int nStep)
{   
    string sData = _GetQuestStepData(nQuestID, nStep, QUEST_STEP_PARTY_COMPLETION);
    return StringToInt(sData);
}

void SetQuestStepPartyCompletion(int nQuestID, int nStep, int nParty)
{
    string sData = IntToString(nParty);
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_PARTY_COMPLETION, sData);
}

void SetQuestPrerequisiteAlignment(int nQuestID, int nKey, int nValue = FALSE)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestPrerequisiteClass(int nQuestID, int nKey, int nValue = -1)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_CLASS, sKey, sValue);
}

void SetQuestPrerequisiteGold(int nQuestID, int nValue = 1)
{
    string sValue = IntToString(max(0, nValue));
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestPrerequisiteItem(int nQuestID, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestPrerequisiteLevelMax(int nQuestID, int nValue)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_LEVEL_MAX, "", sValue);
}

void SetQuestPrerequisiteLevelMin(int nQuestID, int nValue)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_LEVEL_MIN, "", sValue);
}

void SetQuestPrerequisiteQuest(int nQuestID, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_QUEST, sKey, sValue);
}

void SetQuestPrerequisiteQuestStep(int nQuestID, string sKey, int nValue)
{
    string sValue = IntToString(nValue);
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_QUEST_STEP, sKey, sValue);
}

void SetQuestPrerequisiteRace(int nQuestID, int nKey, int nValue = TRUE)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);    
    AddQuestPrerequisite(nQuestID, QUEST_VALUE_RACE, sKey, sValue);
}

void SetQuestStepObjectiveKill(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_KILL, sKey, sValue);
}

void SetQuestStepObjectiveGather(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_GATHER, sKey, sValue);
}

void SetQuestStepObjectiveDeliver(int nQuestID, int nStep, string sKey, string sValue)
{
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_DELIVER, sKey, sValue);
}

void SetQuestStepObjectiveDiscover(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_DISCOVER, sKey, sValue);
}

void SetQuestStepObjectiveSpeak(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestObjective(nQuestID, nStep, QUEST_OBJECTIVE_SPEAK, sKey, sValue);
}

void SetQuestStepPrewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestStepPrewardGold(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestStepPrewardItem(int nQuestID, int nStep, string sKey, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestStepPrewardXP(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_XP, "", sValue);
}

void SetQuestStepPrewardMessage(int nQuestID, int nStep, string sValue)
{
    _SetQuestPreward(nQuestID, nStep, QUEST_VALUE_MESSAGE, "", sValue);
}

void SetQuestStepRewardAlignment(int nQuestID, int nStep, int nKey, int nValue)
{
    string sKey = IntToString(nKey);
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_ALIGNMENT, sKey, sValue);
}

void SetQuestStepRewardGold(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_GOLD, "", sValue);
}

void SetQuestStepRewardItem(int nQuestID, int nStep, string sKey, int nValue = 1)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_ITEM, sKey, sValue);
}

void SetQuestStepRewardQuest(int nQuestID, int nStep, string sKey, int nValue = TRUE)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_QUEST, sKey, sValue);
}

void SetQuestStepRewardXP(int nQuestID, int nStep, int nValue)
{
    string sValue = IntToString(nValue);
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_XP, "", sValue);
}

void SetQuestStepRewardMessage(int nQuestID, int nStep, string sValue)
{
    _SetQuestReward(nQuestID, nStep, QUEST_VALUE_MESSAGE, "", sValue);
}

int AddQuestResolutionSuccess(int nQuestID, string sJournalEntry = "", int nStep = -1)
{
    nStep = AddQuestStep(nQuestID, sJournalEntry, nStep);
    
    string sType = IntToString(QUEST_STEP_TYPE_SUCCESS);
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_TYPE, sType);

    return nStep;
}

int AddQuestResolutionFail(int nQuestID, string sJournalEntry = "", int nStep = -1)
{
    nStep = AddQuestStep(nQuestID, sJournalEntry, nStep);
    
    string sType = IntToString(QUEST_STEP_TYPE_FAIL);
    _SetQuestStepData(nQuestID, nStep, QUEST_STEP_TYPE, sType);

    return nStep;
}

