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
#include "util_i_chat"

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

void test_convo_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    
    SetLocalString(oPC, "*Dialog", "TestDialog");
    Debug("Convo:  Starting Test System Dialog");
    StartDialog(oPC, OBJECT_SELF, "TestDialog", TRUE, TRUE, TRUE);
    SetPCChatMessage();
}

void test_go_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    if (!_GetIsPC(oPC))
        return;

    int nArguments;

    if (nArguments = CountChatArguments(oPC))
    {
        if (nArguments == 1)
        {
            string sTarget = GetChatArgument(oPC, 0);
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

    SetPCChatMessage();
}

void test_get_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    if (!_GetIsPC(oPC))
        return;

    int n, nCount = CountChatArguments(oPC);
    string sTarget;
    object oTarget;

    if (!nCount)
        Error("Get: No target argument(s) provided");
    
    for (n = 0; n < nCount; n++)
    {
        sTarget = GetChatArgument(oPC, n);
        oTarget = GetObjectByTag(sTarget);
        if (GetIsObjectValid(oTarget))
        {
            Debug("Get: getting " + sTarget);
            AssignCommand(oTarget, ActionJumpToObject(oPC));
        }
    }

    SetPCChatMessage();
}

void test_stake_OnPlayerChat()
{

    Debug("Stake chat command not yet active");
    /*
    if (CountChatArguments(sArguments) > 1)
    {
        Error("Stake: Too many arguments, only the first will be used");
        string sVarName = GetListItem(sArguments);
        location lPC = GetLocation(oPC);

        Debug("Stake: Setting current location as ''")
        _SetLocalLocation(oPC, sVarName, lPC);
    }*/
    SetPCChatMessage();
}
