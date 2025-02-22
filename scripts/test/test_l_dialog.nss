// -----------------------------------------------------------------------------
//    File: test_l_dialog.nss
//  System: Dynamic Dialogs (library script)
// -----------------------------------------------------------------------------
// Talking 'bout stuff.
// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"
#include "util_i_debug"

// Temporary includes go here
#include "util_i_libraries"

// -----------------------------------------------------------------------------
//                                  Test Dialog
// -----------------------------------------------------------------------------
// What can I say, it's a sandbox.
// -----------------------------------------------------------------------------

const string TEST_DIALOG = "TestDialog";
const string TEST_INIT = "Test_Init";
const string TEST_PAGE = "Test_Init_Page";
const string TEST_NODE = "Test_Init_Node";
const string TEST_QUIT = "Test_Init_Quit";

const string PAGE_MAIN = "PAGE_MAIN";

//Put the node text and targets/data in these CSVs to populate the main data page.
string sNodeText = "Node 1,Node 2,Node 3";

// sNodeText values will display various options in the dialog.
// sNodeData should be integers, which will be referenced in this function
//  to perform some designated test function.
void DoFunction(string sFunction)
{
    int nFunction = StringToInt(sFunction);
    object oPC = GetPCSpeaker();

    switch (nFunction)
    {
        // case 1 will always be called by the first node in the conversation, same with 2 and 3
        case 1:
        {
            Notice("You've selected Node 1.\nGood job!");
            break;
        }
        case 2:
        {
            Notice("You've selected Node 2.\nYou're such a brave adventurer!");
            break;
        }
        case 3:
        {
            Notice("You've selected Node 3.\nSo you can click a mouse, your mom must be very proud.");
            break;
        }
    }
}

void Test_Init()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    SetDialogPage(PAGE_MAIN);
    AddDialogPage(PAGE_MAIN, "Welcome to the sandbox!  We'll be using this dialog " +
        "to test various functions of the module as they're installed.  " +
        "Which system or function would you like to test?");
    EnableDialogEnd("Nothing for me today, thanks!", PAGE_MAIN);
}

void Test_Page()
{
    string sText, sData, sTarget, sPage = GetDialogPage();
    object oPC = GetPCSpeaker();

    DeleteDialogNodes(sPage);
    
    int i, nCount = CountList(sNodeText);
    if (sPage == PAGE_MAIN)
    {
        for (i = 0; i < nCount; i++)
        {
            sTarget = PAGE_MAIN;
            sText = GetListItem(sNodeText, i);
            AddDialogNode(sPage, sTarget, sText, IntToString(i + 1));
        }
    }

    ClearDialogHistory();
}

void Test_Node()
{
    string sPage = GetDialogPage();

    if (sPage == PAGE_MAIN)
    {
        int nNode = GetDialogNode();
        string sData = GetDialogData(sPage, nNode);
        DoFunction(sData);
    }
}

void Test_Quit()
{
    // Meh, we're good.
}

// -----------------------------------------------------------------------------
//                             Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript(TEST_INIT, 1);
    RegisterLibraryScript(TEST_PAGE, 2);
    RegisterLibraryScript(TEST_NODE, 3);
    RegisterLibraryScript(TEST_QUIT, 4);

    RegisterDialogScript(TEST_DIALOG, TEST_INIT, DLG_EVENT_INIT);
    RegisterDialogScript(TEST_DIALOG, TEST_PAGE, DLG_EVENT_PAGE);
    RegisterDialogScript(TEST_DIALOG, TEST_NODE, DLG_EVENT_NODE);
    RegisterDialogScript(TEST_DIALOG, TEST_QUIT, DLG_EVENT_END | DLG_EVENT_ABORT);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: Test_Init(); break;
        case 2: Test_Page(); break;
        case 3: Test_Node(); break;
        case 4: Test_Quit(); break;
    }
}
