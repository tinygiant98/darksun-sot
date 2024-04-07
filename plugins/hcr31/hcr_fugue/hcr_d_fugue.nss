/// ----------------------------------------------------------------------------
/// @file:  hcr_d_fugue.nss
/// @brief: HCR2 Fugue System (dialog)
/// ----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"
#include "util_i_debug"
#include "core_i_framework"

// -----------------------------------------------------------------------------
//                                  Fugue Dialog
// -----------------------------------------------------------------------------

const string FUGUE_DIALOG = "FugueDialog";
const string FUGUE_INIT = "Fugue_Init";
const string FUGUE_NODE = "Fugue_Node";

const string PAGE_MAIN = "PAGE_MAIN";
const string PAGE_RESPAWN_START = "PAGE_RESPAWN_START";

void fugue_StartDialog(int bGhost = FALSE)
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

void Fugue_Init()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    SetDialogPage(PAGE_MAIN);
    AddDialogPage(PAGE_MAIN, "Ah, I see your training has not prepared your for the " +
        "adventures you've recently embarked upon, young <class>.  To make matters worse, " +
        "it appears your God has forsaken you.  Well, I have no use of an adventurer " +
        "with so little skill, be gone!  How you accomplish that is your choice, but try to " +
        "make a better decision than the one that brought you to me.");
    AddDialogNode(PAGE_MAIN, PAGE_RESPAWN_START, "Respawn to Module Starting Location");
    EnableDialogEnd("I don't want to talk to you any more.");

    AddDialogPage(PAGE_RESPAWN_START, "Estas en limbo, alguna vez estuviste vivo, quieres volver al mundo de los vivos?");
    AddDialogNode(PAGE_RESPAWN_START, "", "SI, lo deseo!", "respawn_start");
    EnableDialogBack("No, esperare que mis amigos me revivan.", PAGE_RESPAWN_START);

    ClearDialogHistory();
}

void Fugue_Node()
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
    RegisterLibraryScript(FUGUE_DIALOG, 0);
    RegisterLibraryScript(FUGUE_INIT, 1);
    RegisterLibraryScript(FUGUE_NODE, 2);

    RegisterDialogScript(FUGUE_DIALOG, FUGUE_INIT, DLG_EVENT_INIT);
    RegisterDialogScript(FUGUE_DIALOG, FUGUE_NODE, DLG_EVENT_NODE);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        //case 0: fugue_StartDialog(); break;
        case 1: Fugue_Init(); break;
        case 2: Fugue_Node(); break;
    }
}
