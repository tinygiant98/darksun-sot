// -----------------------------------------------------------------------------
//    File: ds_fug_l_dialog.nss
//  System: Dynamic Dialogs (library script)
// Authors: Anthony Savoca (Jacyn)
// -----------------------------------------------------------------------------
#include "dlg_i_dialogs"
#include "util_i_library"
#include "util_i_debug"

// Temporary includes go here
#include "core_i_framework"

// -----------------------------------------------------------------------------
//                                  Angel Dialog
// -----------------------------------------------------------------------------
// What can I say, she's the Angel.
// Jacyn -  2020-12-01 -Added the Angel Dialogue.  Kinder and Gentler than the
//          Fugue Lord, but the same.          
// -----------------------------------------------------------------------------

const string ANGEL_DIALOG = "AngelDialog";
const string ANGEL_INIT = "Angel_Init";
const string ANGEL_NODE = "Angel_Node";

const string PAGE_MAIN = "PAGE_MAIN";
const string PAGE_RESPAWN_START = "PAGE_RESPAWN_START";

void angel_StartDialog(int bGhost = FALSE)
{
    // Get the PC that triggered the event. This information is pulled off the
    // event queue since we don't know which event is calling us.
    object oPC = GetEventTriggeredBy();

    if (!GetIsPC(oPC))
        return;

    string sDialog  = GetLocalString(OBJECT_SELF, DLG_DIALOG);
    StartDialog(oPC, OBJECT_SELF, sDialog, TRUE, TRUE, TRUE);
}

void DoFunction(string sNodeData)
{
    object oPC = GetPCSpeaker();

    if (sNodeData == "respawn_start")
    {
        SetDialogState(DLG_STATE_ENDED);
        location lStart = GetStartingLocation();
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, JumpToLocation(lStart));
    }
}

void angel_Init()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    SetDialogPage(PAGE_MAIN);
    AddDialogPage(PAGE_MAIN, "Ah, child, approach me. " +
        "You have attempted something beyond your experience, young <class>. " +
        "Never fear.  I have brought you here to my home. " +
        "I will help you. ");
    AddDialogNode(PAGE_MAIN, PAGE_RESPAWN_START, "Respawn to Module Starting Location");
    EnableDialogEnd("I don't want to talk to you any more.");

    AddDialogPage(PAGE_RESPAWN_START, "This is the basic respawn option provided with the system.  The " +
        "module builder has not customized this system yet.  Press 'Yes, I Want to Respawn!' to respawn " +
        "to the module's start location.  No penalties will be applied.");
    AddDialogNode(PAGE_RESPAWN_START, "", "Yes, I Want to Respawn!", "respawn_start");
    EnableDialogBack("I don't want to respawn right now.", PAGE_RESPAWN_START);

    ClearDialogHistory();
}

void angel_Node()
{
    string sPage = GetDialogPage();

    if (sPage == PAGE_RESPAWN_START)
    {
        int nNode = GetDialogNode();
        string sData = GetDialogData(sPage, nNode);
        DoFunction(sData);
    }
}

// -----------------------------------------------------------------------------
//                             Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript(ANGEL_DIALOG, 0);
    RegisterLibraryScript(ANGEL_INIT, 1);
    RegisterLibraryScript(ANGEL_NODE, 2);

    RegisterDialogScript(ANGEL_DIALOG, ANGEL_INIT, DLG_EVENT_INIT);
    RegisterDialogScript(ANGEL_DIALOG, ANGEL_NODE, DLG_EVENT_NODE);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 0: angel_StartDialog(); break;
        case 1: angel_Init(); break;
        case 2: angel_Node(); break;
    }
}