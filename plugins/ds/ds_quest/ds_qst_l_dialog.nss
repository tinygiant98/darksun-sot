// -----------------------------------------------------------------------------
//    File: ds_qst_l_dialog.nss
//  System: Dynamic Dialogs (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This library contains some example dialogs that show the features of the Core
// Dialogs system. You can use it as a model for your own dialog libraries.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "dlg_i_dialogs"
#include "quest_i_main"

void _ResetPCQuestData(object oPC, string sQuestTag)
{
    int nQuestID = GetQuestID(sQuestTag);
    DeletePCQuestProgress(oPC, nQuestID);
    ResetPCQuestData(oPC, nQuestID);
}

string CacheColoredToken(string sToken)
{
    return HexColorString(sToken, COLOR_GREEN_LIGHT);
}

// -----------------------------------------------------------------------------
//                           Discovery Quest Dialog
// -----------------------------------------------------------------------------

const string JONNY_DIALOG = "JonnyDialog";
const string JONNY_PAGE_MAIN = "JonnyMain";
const string JONNY_PAGE_KILL = "JonnyKill";
const string JONNY_PAGE_DISCOVER = "JonnyDiscover";
const string JONNY_PAGE_GATHER = "JonnyGather";
const string JONNY_PAGE_SPEAK = "JonnySpeak";
const string JONNY_PAGE_DELIVER = "JonnyDeliver";
const string JONNY_PAGE_FOUND_BANDIT = "JonnyBandit";

void JonnyDialog()
{
    object oPC = GetPCSpeaker();
    string sDiscover = "quest_demo_discover";
    string sKill = "quest_demo_kill";
    string sProtect = "quest_demo_protect";
    string sGather = "quest_demo_gather";
    string sDeliver = "quest_demo_deliver";
    string sSpeak = "quest_demo_speak";

    int bHasDiscover = GetPCHasQuest(oPC, sDiscover);
    int bHasKill = GetPCHasQuest(oPC, sKill);
    int bHasProtect = GetPCHasQuest(oPC, sProtect);
    int bHasGather = GetPCHasQuest(oPC, sGather);
    int bHasDeliver = GetPCHasQuest(oPC, sDeliver);
    int bHasSpeak = GetPCHasQuest(oPC, sSpeak);

    int bDiscoverComplete = bHasDiscover ? GetIsPCQuestComplete(oPC, sDiscover) : FALSE;
    int bKillComplete = bHasKill ? GetIsPCQuestComplete(oPC, sKill) : FALSE;
    int bProtectComplete = bHasProtect ? GetIsPCQuestComplete(oPC, sProtect) : FALSE;
    int bGatherComplete = bHasGather ? GetIsPCQuestComplete(oPC, sGather) : FALSE;
    int bDeliverComplete = bHasDeliver ? GetIsPCQuestComplete(oPC, sDeliver) : FALSE;
    int bSpeakComplete = bHasSpeak ? GetIsPCQuestComplete(oPC, sSpeak) : FALSE;

    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            string sPage;

            AddCachedDialogToken("discovery", HexColorString("Discovery", COLOR_GREEN_LIGHT));
            AddCachedDialogToken("kill/protect", HexColorString("Kill/Protect", COLOR_GREEN_LIGHT));
            AddCachedDialogToken("gather", HexColorString("Gather", COLOR_GREEN_LIGHT));
            AddCachedDialogToken("deliver", HexColorString("Deliver", COLOR_GREEN_LIGHT));
            AddCachedDialogToken("speak", HexColorString("Speak", COLOR_GREEN_LIGHT));

            EnableDialogBack();
            EnableDialogEnd();

            SetDialogPage(JONNY_PAGE_MAIN);
            AddDialogPage(JONNY_PAGE_MAIN, "Welcome!  I'm glad you could join me in discovering Dark Sun's " +
                "quest system.  This system contains five base quest types which, when combined, can create " +
                "some pretty awesome stuff.  Select a quest type below to learn more.");
            AddDialogNode(JONNY_PAGE_MAIN, JONNY_PAGE_DISCOVER, "<discovery> Quests");
            AddDialogNode(JONNY_PAGE_MAIN, JONNY_PAGE_KILL, "<kill/protect> Quests");
            AddDialogNode(JONNY_PAGE_MAIN, JONNY_PAGE_GATHER, "<gather> Quests");
            AddDialogNode(JONNY_PAGE_MAIN, JONNY_PAGE_DELIVER, "<deliver> Quests");
            AddDialogNode(JONNY_PAGE_MAIN, JONNY_PAGE_SPEAK, "<speak> Quests");
            AddDialogNode(JONNY_PAGE_MAIN, JONNY_PAGE_MAIN, HexColorString("Reset All Discovery Quest Progress", COLOR_RED_LIGHT), "reset");
            DisableDialogNode(DLG_NODE_BACK, JONNY_PAGE_MAIN);

            AddDialogPage(JONNY_PAGE_DISCOVER, "<discovery> quests require that the PC discover a specific game " +
                "object, such as a trigger, creature or door.  In this case, I have lost my pet Bandit.  I don't " +
                "know where he could've gone.  Can you find him for me?");
            AddDialogNode(JONNY_PAGE_DISCOVER, "", "Why yes, of course, I can!  I live for finding helpless, lost animals", "discover_accept");
            SetDialogLabel(DLG_NODE_BACK, "Ummm, no.  I'm sure he'll find his way back eventually.", JONNY_PAGE_DISCOVER);
            SetDialogLabel(DLG_NODE_END, "I don't have time for this crap, there's so much more to discover!", JONNY_PAGE_DISCOVER);

            AddDialogPage(JONNY_PAGE_KILL, "<kill/protect> quests require that the PC either destroy a specified " +
                "quantity of game objects or prevent those objects from being destroyed.  For example, a fledgling " +
                "defenseless start area might need some help protecting themselves from a raid of tiny goblins.  Or " +
                "maybe an old man is assaulted crossing the street and you need to protect him.");
            AddDialogNode(JONNY_PAGE_KILL, "", "I'm your huckleberry.  Show me those goblins!", "kill_accept");
            AddDialogNode(JONNY_PAGE_KILL, "", "Aw, I love old people.  Where is the old codger?  I'll help him.", "protect_accept");
            SetDialogLabel(DLG_NODE_BACK, "You suck!  I'm not risking my beautiful face to protect you people!", JONNY_PAGE_KILL);
            SetDialogLabel(DLG_NODE_END, "Yeah, no.  Bye.", JONNY_PAGE_KILL);

            AddDialogPage(JONNY_PAGE_GATHER, "<gather> quests require that the PC obtain a specified number of " +
                "items.  For example, I loves me some flowers.  Really pretty ones.  If you go get me five super-" +
                "duper pretty flowers, I'll be your bestest friend forever!");
            AddDialogNode(JONNY_PAGE_GATHER, "", "Well, I do need a friend.  Yes, I'll get them!", "gather_accept");
            SetDialogLabel(DLG_NODE_BACK, "Ew!", JONNY_PAGE_GATHER);
            SetDialogLabel(DLG_NODE_END, "Umm, is there someone ... else ... that I could take to?", JONNY_PAGE_GATHER);

            AddDialogPage(JONNY_PAGE_DELIVER, "<deliver> quests require that the PC deliver a specified number of " +
                "items to a specified object.  That object can be a creature, placeable, trigger or any other game " +
                "object.  For example, my pet Bandit is hungry.  Can you take him this food?  Just put it down in front " +
                "of him and he'll be super-happy.");
            AddDialogNode(JONNY_PAGE_DELIVER, "", "Sure, as long as he doesn't eat me.", "deliver_accept");
            SetDialogLabel(DLG_NODE_BACK, "You're nuts.  I've seen your \"pet\".", JONNY_PAGE_DELIVER);
            SetDialogLabel(DLG_NODE_END, "Are there any sane people here I can talk to?", JONNY_PAGE_DELIVER);

            AddDialogPage(JONNY_PAGE_SPEAK, "<speak> quests require that the PC speak to a specified game object. " +
                "Speak targets are usually NPCs, but can be any game object you want.  In this case, go see the " +
                "Dungeon Master behind you.  He'd like to talk to you.");
            AddDialogNode(JONNY_PAGE_SPEAK, "", "Oh, sure, he seems like a nice fellow.", "speak_accept");
            SetDialogLabel(DLG_NODE_BACK, "I don't do dwarves.", JONNY_PAGE_SPEAK);
            SetDialogLabel(DLG_NODE_END, "Psh. Pfft. Thbh. Whatevs. I'm out.", JONNY_PAGE_SPEAK);

            AddDialogPage(JONNY_PAGE_FOUND_BANDIT, "You've found Bandit!  I'm so happy to hear that.  Thanks you so " +
                "much.  I don't have much, but please take this as a token of my gratitude.");
            DisableDialogNode(DLG_NODE_BACK, JONNY_PAGE_FOUND_BANDIT);
            SetDialogLabel(DLG_NODE_END, "Any time, kiddo.", JONNY_PAGE_FOUND_BANDIT);
        } break;

        case DLG_EVENT_PAGE:
        {
            string sPage = GetDialogPage();
            int bReset, nNode = GetDialogNode();

            if (GetPCQuestStep(oPC, "quest_demo_discover") == 2)
            {
                SetDialogPage(JONNY_PAGE_FOUND_BANDIT);
                SignalQuestStepProgress(oPC, "quest_jonny", QUEST_OBJECTIVE_SPEAK);
                return;
            }

            if (sPage == JONNY_PAGE_DISCOVER)
            {
                if (bHasDiscover && !bDiscoverComplete) FilterDialogNodes(0);
            }
            else if (sPage == JONNY_PAGE_KILL)
            {
                if (bHasKill) FilterDialogNodes(0);
                if (bHasProtect) FilterDialogNodes(1);
            }                
            else if (sPage == JONNY_PAGE_GATHER)
            {
                if (bHasGather) FilterDialogNodes(0);
            }
            else if (sPage == JONNY_PAGE_DELIVER)
            {
                if (bHasDeliver) FilterDialogNodes(0);
            }
            else if (sPage == JONNY_PAGE_SPEAK)
            {
                if (bHasSpeak) FilterDialogNodes(0);
            }
        } break;

        case DLG_EVENT_NODE:
        {
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();
            string sNodeData = GetDialogData(sPage, nNode);

            if (sNodeData == "reset")
            {
                if (bHasDiscover) _ResetPCQuestData(oPC, sDiscover);
                if (bHasKill) _ResetPCQuestData(oPC, sKill);
                if (bHasProtect) _ResetPCQuestData(oPC, sProtect);
                if (bHasGather) _ResetPCQuestData(oPC, sGather);
                if (bHasDeliver) _ResetPCQuestData(oPC, sDeliver);
                if (bHasSpeak) _ResetPCQuestData(oPC, sSpeak);
            }
            else if (sNodeData == "discover_accept")
                AssignQuest(oPC, sDiscover);
            else if (sNodeData == "kill_accept")
                AssignQuest(oPC, sKill);
            else if (sNodeData == "protect_accept")
                AssignQuest(oPC, sProtect);
            else if (sNodeData == "gather_accept")
                AssignQuest(oPC, sGather);
            else if (sNodeData == "deliver_accept")
                AssignQuest(oPC, sDeliver);
            else if (sNodeData == "speak_accept")
                AssignQuest(oPC, sSpeak);
        }
    }
}

// -----------------------------------------------------------------------------
//                           Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript(JONNY_DIALOG);
    RegisterDialogScript (JONNY_DIALOG);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (sScript == JONNY_DIALOG) JonnyDialog();
}
