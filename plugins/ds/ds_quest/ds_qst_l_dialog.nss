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

const string JOHNNY_DIALOG = "JohnnyDialog";
const string JOHNNY_PAGE_MAIN = "JohnnyMain";
const string JOHNNY_PAGE_KILL = "JohnnyKill";
const string JOHNNY_PAGE_DISCOVER = "JohnnyDiscover";
const string JOHNNY_PAGE_GATHER = "JohnnyGather";
const string JOHNNY_PAGE_SPEAK = "JohnnySpeak";
const string JOHNNY_PAGE_DELIVER = "JohnnyDeliver";

void JohnnyDialog()
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

            SetDialogPage(JOHNNY_PAGE_MAIN);
            AddDialogPage(JOHNNY_PAGE_MAIN, "Welcome!  I'm glad you could join me in discovering Dark Sun's " +
                "quest system.  This system contains five base quest types which, when combined, can create " +
                "some pretty awesome stuff.  Select a quest type below to learn more.");
            AddDialogNode(JOHNNY_PAGE_MAIN, JOHNNY_PAGE_DISCOVER, "<discovery> Quests");
            AddDialogNode(JOHNNY_PAGE_MAIN, JOHNNY_PAGE_KILL, "<kill/protect> Quests");
            AddDialogNode(JOHNNY_PAGE_MAIN, JOHNNY_PAGE_GATHER, "<gather> Quests");
            AddDialogNode(JOHNNY_PAGE_MAIN, JOHNNY_PAGE_DELIVER, "<deliver> Quests");
            AddDialogNode(JOHNNY_PAGE_MAIN, JOHNNY_PAGE_SPEAK, "<speak> Quests");
            AddDialogNode(JOHNNY_PAGE_MAIN, JOHNNY_PAGE_MAIN, HexColorString("Reset All Discovery Quest Progress", COLOR_RED_LIGHT), "reset");
            DisableDialogNode(DLG_NODE_BACK, JOHNNY_PAGE_MAIN);

            AddDialogPage(JOHNNY_PAGE_DISCOVER, "<discovery> quests require that the PC discover a specific game " +
                "object, such as a trigger, creature or door.  In this case, I have lost my pet Spot.  I don't " +
                "know where he could've gone.  Can you find him for me?");
            AddDialogNode(JOHNNY_PAGE_DISCOVER, "", "Why yes, of course, I can!  I live for finding helpless, lost animals", "discover_accept");
            SetDialogLabel(DLG_NODE_BACK, "Ummm, no.  I'm sure he'll find his way back eventually.", JOHNNY_PAGE_DISCOVER);
            SetDialogLabel(DLG_NODE_END, "I don't have time for this crap, there's so much more to discover!", JOHNNY_PAGE_DISCOVER);

            AddDialogPage(JOHNNY_PAGE_KILL, "<kill/protect> quests require that the PC either destroy a specified " +
                "quantity of game objects or prevent those objects from being destroyed.  For example, a fledgling " +
                "defenseless start area might need some help protecting themselves from a raid of tiny goblins.  Or " +
                "maybe an old man is assaulted crossing the street and you need to protect him.");
            AddDialogNode(JOHNNY_PAGE_KILL, "", "I'm your huckleberry.  Show me those goblins!", "kill_accept");
            AddDialogNode(JOHNNY_PAGE_KILL, "", "Aw, I love old people.  Where is the old codger?  I'll help him.", "protect_accept");
            SetDialogLabel(DLG_NODE_BACK, "You suck!  I'm not risking my beautiful face to protect you people!", JOHNNY_PAGE_KILL);
            SetDialogLabel(DLG_NODE_END, "Yeah, no.  Bye.", JOHNNY_PAGE_KILL);

            AddDialogPage(JOHNNY_PAGE_GATHER, "<gather> quests require that the PC obtain a specified number of " +
                "items.  For example, I loves me some flowers.  Really pretty ones.  If you go get me five super-" +
                "duper pretty flowers, I'll be your bestest friend forever!");
            AddDialogNode(JOHNNY_PAGE_GATHER, "", "Well, I do need a friend.  Yes, I'll get them!", "gather_accept");
            SetDialogLabel(DLG_NODE_BACK, "Ew!", JOHNNY_PAGE_GATHER);
            SetDialogLabel(DLG_NODE_END, "Umm, is there someone ... else ... that I could take to?", JOHNNY_PAGE_GATHER);

            AddDialogPage(JOHNNY_PAGE_DELIVER, "<deliver> quests require that the PC deliver a specified number of " +
                "items to a specified object.  That object can be a creature, placeable, trigger or any other game " +
                "object.  For example, my pet Spot is hungry.  Can you take him this food?  Just put it down in front " +
                "of him and he'll be super-happy.");
            AddDialogNode(JOHNNY_PAGE_DELIVER, "", "Sure, as long as he doesn't eat me.", "deliver_accept");
            SetDialogLabel(DLG_NODE_BACK, "You're nuts.  I've seen your \"pet\".", JOHNNY_PAGE_DELIVER);
            SetDialogLabel(DLG_NODE_END, "Are there any sane people here I can talk to?", JOHNNY_PAGE_DELIVER);

            AddDialogPage(JOHNNY_PAGE_SPEAK, "<speak> quests require that the PC speak to a specified game object. " +
                "Speak targets are usually NPCs, but can be any game object you want.  In this case, go see the " +
                "Dungeon Master behind you.  He'd like to talk to you.");
            AddDialogNode(JOHNNY_PAGE_SPEAK, "", "Oh, sure, he seems like a nice fellow.", "speak_accept");
            SetDialogLabel(DLG_NODE_BACK, "I don't do dwarves.", JOHNNY_PAGE_SPEAK);
            SetDialogLabel(DLG_NODE_END, "Psh. Pfft. Thbh. Whatevs. I'm out.", JOHNNY_PAGE_SPEAK);
        } break;

        case DLG_EVENT_PAGE:
        {
            string sPage = GetDialogPage();
            int bReset, nNode = GetDialogNode();

            if (sPage == JOHNNY_PAGE_DISCOVER)
            {
                if (bHasDiscover) FilterDialogNodes(0);
            }
            else if (sPage == JOHNNY_PAGE_KILL)
            {
                if (bHasKill) FilterDialogNodes(0);
                if (bHasProtect) FilterDialogNodes(1);
            }                
            else if (sPage == JOHNNY_PAGE_GATHER)
            {
                if (bHasGather) FilterDialogNodes(0);
            }
            else if (sPage == JOHNNY_PAGE_DELIVER)
            {
                if (bHasDeliver) FilterDialogNodes(0);
            }
            else if (sPage == JOHNNY_PAGE_SPEAK)
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
            else if (sNodeData == "accept_discover")
                AssignQuest(oPC, sDiscover);
            else if (sNodeData == "accept_kill")
                AssignQuest(oPC, sKill);
            else if (sNodeData == "accept_protect")
                AssignQuest(oPC, sProtect);
            else if (sNodeData == "accept_gather")
                AssignQuest(oPC, sGather);
            else if (sNodeData == "accept_deliver")
                AssignQuest(oPC, sDeliver);
            else if (sNodeData == "accept_speak")
                AssignQuest(oPC, sSpeak);
        }
    }
}

// -----------------------------------------------------------------------------
//                           Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript(JOHNNY_DIALOG);
    RegisterDialogScript (JOHNNY_DIALOG);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (sScript == JOHNNY_DIALOG) JohnnyDialog();
}
