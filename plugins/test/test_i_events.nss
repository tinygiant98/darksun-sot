// -----------------------------------------------------------------------------
//    File: test_i_events.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Event handlers
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "test_i_main"
#include "x2_inc_switches"
#include "dlg_i_dialogs"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void test_OnClientEnter()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC))
        return;

    object oItem = GetItemPossessedBy(oPC, "util_playerdata");
    if (!GetIsObjectValid(oItem))
        CreateItemOnObject("util_playerdata", oPC);
}

void test_PlayerDataItem()
{
    int nEvent = GetUserDefinedItemEventNumber();

    // * This code runs when the Unique Power property of the item is used
    // * Note that this event fires PCs only
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC = GetItemActivator();
        SetLocalString(oPC, "*Dialog", "TestDialog");
        StartDialog(oPC, OBJECT_SELF, "TestDialog", TRUE, TRUE, TRUE);
    }
}

void test_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    string sTokens, sCommand, sArguments, sMessage = GetPCChatMessage();
    object oArea = GetArea(oPC);

/*

    if (GetSubString(sMessage, 0, 1) != "!")
        return;

    struct COMMAND_LINE cl = ParseCommandLine(sMessage);
    Notice("Parsing command line entry: " + sMessage);

    if (cl.cmdChar != COMMAND_INVALID)
        Notice("cl.cmdChar   -> " + cl.cmdChar +
            "\ncl.cmd       -> " + cl.cmd +
            "\ncl.shortOpts -> " + cl.shortOpts +
            "\ncl.longOpts  -> " + cl.longOpts +
            "\ncl.args      -> " + cl.args);
    else
        Error("Unable to parse command line -> " + sMessage +
              "\n  Error returned: " + cl.cmdChar);*/

/*
    if (sMessage != "")
        sTokens = Tokenize(sMessage);
    else
        return;

    sCommand = GetSubString(GetListItem(sTokens), 1, 1000);
    sArguments = DeleteListItem(sTokens);

    // Just for demo purposes, display what we received
    if (sCommand != "")
        Notice("Received chat command [" + HexColorString(sCommand, COLOR_GREEN_LIGHT) + "]\n" +
               "Available arguments are [" + HexColorString(sArguments, COLOR_GREEN_LIGHT) + "]");

    if (sCommand == "convo")
    {
        SetLocalString(oPC, "*Dialog", "TestDialog");
        Debug("Convo:  Starting Test System Dialog");
        StartDialog(oPC, OBJECT_SELF, "TestDialog", TRUE, TRUE, TRUE);
    }
    else if (sCommand == "go")
    {
        if (CountList(sArguments))
        {
            if (CountList(sArguments) == 1)
            {
                string sTarget = GetListItem(sArguments);
                object oTarget = GetObjectByTag(sTarget);
                if (GetIsObjectValid(oTarget))
                {
                    Debug("Go: TargetFound -> " + GetTag(oTarget));
                    if (!GetObjectType(oTarget))
                        oTarget = GetFirstObjectInArea(oTarget);

                    AssignCommand(oPC, ActionJumpToObject(oTarget));
                }
                else
                    Error("Go: " + sTarget + " is not a valid target");
            }
            else
                Error("Go: You can only jump to one place, dumbass.  Make a decision already.");
        }
        else
            Error("Go: No target argument provided");
    }
    else if (sCommand == "get")
    {
        int n, nCount = CountList(sArguments);
        string sTarget;
        object oTarget;

        if (!nCount)
            Error("Get: No target argument(s) provided");
        
        for (n = 0; n < nCount; n++)
        {
            sTarget = GetListItem(sArguments, n);
            oTarget = GetObjectByTag(sTarget);
            if (GetIsObjectValid(oTarget))
            {
                Debug("Get: getting " + sTarget);
                AssignCommand(oTarget, ActionJumpToObject(oPC));
            }
        }
    }
    else if (sCommand == "stake")
    {
        if (CountList(sArguments) > 1)
        {
            Error("Stake: Too many arguments, only the first will be used");
            string sVarName = GetListItem(sArguments);
            location lPC = GetLocation(oPC);

            Debug("Stake: Setting current location as ''")
            _SetLocalLocation(oPC, sVarName, lPC);
        }
        else
    }
*/
    SetPCChatMessage("");
}
