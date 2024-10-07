// -----------------------------------------------------------------------------
//    File: pd_d_rest.nss
//  System: Dynamic Dialogs (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This library contains some example dialogs that show the features of the Core
// Dialogs system. You can use it as a model for your own dialog libraries.
// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"
#include "util_i_debug"
#include "pw_i_core"

// -----------------------------------------------------------------------------
//                                  Rest Dialog
// -----------------------------------------------------------------------------
// What can I say, it's a Rest System.
// -----------------------------------------------------------------------------

const string REST_DIALOG = "RestDialog";
const string REST_INIT = "rest_Init";
const string REST_NODE = "rest_Node";

const string PAGE_MAIN = "PAGE_MAIN";

void DoFunction(string sNodeData)
{
    object oPC = GetPCSpeaker();

    if (sNodeData == "rest")
    {
        SetDialogState(DLG_STATE_ENDED);
        h2_MakePCRest(oPC);
    }
}

void rest_Init()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    SetDialogPage(PAGE_MAIN);
    AddDialogPage(PAGE_MAIN, "Feeling sleepy?  Just want to recover some HP and get back your spells? " + 
        "Either way, doesn't matter to me.  Press 1 to rest!");
    AddDialogNode(PAGE_MAIN, "", "Yes, rest already, this dialog is stupid.  I pressed 'R'.", "rest");
    EnableDialogEnd("Just kidding, I don't really want to rest, I was just testing the dialog.");
}

void rest_Node()
{
    string sPage = GetDialogPage();

    if (sPage == PAGE_MAIN)
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
    RegisterLibraryScript(REST_INIT, 1);
    RegisterLibraryScript(REST_NODE, 2);

    RegisterDialogScript(REST_DIALOG, REST_INIT, DLG_EVENT_INIT);
    RegisterDialogScript(REST_DIALOG, REST_NODE, DLG_EVENT_NODE);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: rest_Init(); break;
        case 2: rest_Node(); break;
    }
}
