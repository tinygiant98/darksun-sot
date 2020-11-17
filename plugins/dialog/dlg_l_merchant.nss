// -----------------------------------------------------------------------------
//    File: dlg_l_plugin.nss
//  System: Dynamic Dialogs (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This library contains hook-in scripts for the Dynamic Dialogs plugin. If the
// Dynamic Dialogs plugin is activated, these scripts will fire on the
// appropriate events.
// -----------------------------------------------------------------------------

#include "core_i_framework"
#include "dlg_i_dialogs"
#include "util_i_library"
#include "util_i_data"

// -----------------------------------------------------------------------------
//                             Event Hook-In Scripts
// -----------------------------------------------------------------------------

// ----- WrapDialog ------------------------------------------------------------
// Starts a dialog between the calling object and the PC that triggered the
// event being executed. Only valid when being called by an event queue.
// ----- Variables -------------------------------------------------------------
// string "*Dialog":  The name of the dialog script (library or otherwise)
// int    "*Private": Whether the dialog should be hidden from other players.
// int    "*NoHello": Prevent the NPC from saying hello on dialog start
// int    "*NoZoom":  Prevent camera from zooming in on dialog start
// ----- Aliases ---------------------------------------------------------------

void merchant_StartDialog(int bGhost = FALSE)
{
    // Get the PC that triggered the event. This information is pulled off the
    // event queue since we don't know which event is calling us.
    object oPC = GetEventTriggeredBy();

    if (!_GetIsPC(oPC))
        return;

    string sDialog  = GetLocalString(OBJECT_SELF, DLG_DIALOG);
    int    bPrivate = GetLocalInt   (OBJECT_SELF, DLG_PRIVATE);
    int    bNoHello = GetLocalInt   (OBJECT_SELF, DLG_NO_HELLO);
    int    bNoZoom  = GetLocalInt   (OBJECT_SELF, DLG_NO_ZOOM);

    StartDialog(oPC, OBJECT_SELF, sDialog, bPrivate, bNoHello, bNoZoom);
}

// -----------------------------------------------------------------------------
//                             Merchant Master Dialog
// -----------------------------------------------------------------------------
// This dialog is the base conversation for all basic merchants in the module.
//  individual conditions can be created for specific merchants.  Specific stores
//  can be assigned using the DLG_MERCHANT_STORE variable.  If this variable is
//  not assigned on the merchant, the script will search for a merchant/store
//  waypoint near the NPC.  If not found, a failure conversation will be
//  initiated.
// -----------------------------------------------------------------------------

const string DLG_MERCHANT_STORE     = "*Store";

const string MERCHANT_MASTER_DIALOG = "MerchantDialog";
const string MERCHANT_PAGE_MAIN     = "MERCHANTMAIN";
const string MERCHANT_NOSTORE       = "MERCHANTNOSTORE";
const string MERCHANT_CONDITION     = "MERCHANTCONDITION";

void merchantDialog_Init()
{
    EnableDialogNode(DLG_NODE_END);

    SetDialogPage(MERCHANT_PAGE_MAIN);
    AddDialogPage(MERCHANT_PAGE_MAIN, "Hello, my <lord/lady>.  I am the proud owner " +
        "of this shop and would love to do business with you.  Would you like to see " +
        "my wares?");
    SetDialogLabel(DLG_NODE_END, "No thanks, sorry to bother you.", MERCHANT_PAGE_MAIN);    
    
    AddDialogPage(MERCHANT_NOSTORE, "I'm sorry, my <lord/lady>.  I would love to do " +
        "business with you today, but, as you can see, we're not quite ready to open " +
        "yet.  Please, I beg of you, return soon and we will be ready.");
    SetDialogLabel(DLG_NODE_END, "Oh, sorry to bother you.  I'll return another time.", MERCHANT_NOSTORE);

    AddDialogPage(MERCHANT_CONDITION, "Now look here, I don't do business with the likes " +
        "of you.  Go get your keeper and I'll talk to him.  Go! Get!");
    SetDialogLabel(DLG_NODE_END, "You won't be seeing any of my coin any time soon!", MERCHANT_CONDITION);
}

void merchantDialog_Page()
{
    object oStore, oPC = GetPCSpeaker();
    object oMerchant = OBJECT_SELF;
    string sNodeText, sStore, sPage = GetDialogPage();

    sStore = _GetLocalString(oMerchant, DLG_MERCHANT_STORE);

    // This is here as an example only and not best practice for setting up conditional conversations
    if (GetTag(oMerchant) == "ds_condshop" && GetGender(oPC) != GENDER_MALE)
    {
        SetDialogPage(MERCHANT_CONDITION);
        return;
    }

    if (sStore == "")
    {
        location lMerchant = GetLocation(oMerchant);
        object oStore = GetFirstObjectInShape(SHAPE_SPHERE, 1.0, lMerchant, FALSE, OBJECT_TYPE_STORE);

        if (GetIsObjectValid(oStore))
            sStore = GetTag(oStore);
        else
        {
            SetDialogPage(MERCHANT_NOSTORE);
            return;
        }
    }

    if (sPage == MERCHANT_PAGE_MAIN)
    {
        string sNodeText = "Yes, yes I would.";

        DeleteDialogNodes(MERCHANT_PAGE_MAIN);
        AddDialogNode(MERCHANT_PAGE_MAIN, "", sNodeText, sStore);
    }
}

void merchantDialog_Node()
{
    string sPage = GetDialogPage();
    int nNode = GetDialogNode();
    string sData = GetDialogData(sPage, nNode);

    object oStore = GetObjectByTag(sData);
    OpenStore(oStore, GetPCSpeaker());
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // Event scripts
    RegisterLibraryScript(MERCHANT_MASTER_DIALOG, 0x0100+0x01);
    RegisterLibraryScript("MerchantDialogGhost",  0x0100+0x02);

    // Plugin Control Dialog
    RegisterLibraryScript("merchantDialog_Init",  0x0200+0x01);
    RegisterLibraryScript("merchantDialog_Page",  0x0200+0x02);
    RegisterLibraryScript("merchantDialog_Node",  0x0200+0x03);

    RegisterDialogScript(MERCHANT_MASTER_DIALOG, "merchantDialog_Init", DLG_EVENT_INIT, DLG_PRIORITY_FIRST);
    RegisterDialogScript(MERCHANT_MASTER_DIALOG, "merchantDialog_Page", DLG_EVENT_PAGE);
    RegisterDialogScript(MERCHANT_MASTER_DIALOG, "merchantDialog_Node", DLG_EVENT_NODE);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry & 0xff00)
    {
        case 0x0100:
            switch (nEntry & 0x00ff)
            {
                case 0x01: merchant_StartDialog();          break;
                case 0x02: merchant_StartDialog(TRUE);      break;
            }  break;

        case 0x0200:
            switch (nEntry & 0x00ff)
            {
                 case 0x01: merchantDialog_Init(); break;
                 case 0x02: merchantDialog_Page(); break;
                 case 0x03: merchantDialog_Node(); break;
             }   break;
    }
}
