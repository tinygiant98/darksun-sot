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

void test_OnPlayerChat()
{
    Notice("Testing all functions");
    object oPC = GetPCChatSpeaker();

    if (HasParsedChatCommand(oPC))
    {
        Debug("  " + GetName(oPC) + " has a parsed chat command");

        string sChat = GetChatLine(oPC);
        string sDes = GetChatDesignator(oPC);
        string sCmd = GetChatCommand(oPC);
        string sArgs = GetChatArguments(oPC);
        string sOpts = GetChatOptions(oPC);
        string sPairs = GetChatPairs(oPC);

        Debug("\n    Chat Line -> " + sChat +
              "\n    GetChatLine(oPC)          -> " + GetChatLine(oPC) +
              "\n    GetChatDesignator(oPC)    -> " + GetChatDesignator(oPC) +
              "\n    GetChatCommand(oPC)       -> " + GetChatCommand(oPC));

        Debug("\n  Testing Argument-Specific Functions" +
              "\n    GetChatArguments(oPC)                -> " + GetChatArguments(oPC) +
              "\n    CountChatArguments(oPC)              -> " + IntToString(CountChatArguments(oPC)) +
              "\n    HasChatArgument(oPC, \"argument1\")  -> " + (HasChatArgument(oPC, "arg1") ? "TRUE" : "FALSE") +
              "\n    HasChatArgument(oPC, \"none\")       -> " + (HasChatArgument(oPC, "none") ? "TRUE" : "FALSE") +
              "\n    FindChatArgument(oPC, \"argument2\") -> " + IntToString(FindChatArgument(oPC, "argument2")) +
              "\n    GetChatArgument(oPC, 1)              -> " + GetChatArgument(oPC, 1));

        Debug("\n  Testing Option-Specific Functions" +
              "\n    GetChatOptions(oPC)        -> " + GetChatOptions(oPC) +
              "\n    CountChatOptions(oPC)      -> " + IntToString(CountChatOptions(oPC)) +
              "\n    HasChatOption(oPC, \"g\")  -> " + (HasChatOption(oPC, "g") ? "TRUE" : "FALSE") +
              "\n    HasChatOption(oPC, \"-g\") -> " + (HasChatOption(oPC, "-g") ? "TRUE" : "FALSE") +
              "\n    HasChatOption(oPC, \"q\")  -> " + (HasChatOption(oPC, "q") ? "TRUE" : "FALSE") +
              "\n    FindChatOption(oPC, \"i\") -> " + IntToString(FindChatOption(oPC, "i")) +
              "\n    GetChatOption(oPC, 1)      -> " + GetChatOption(oPC, 1));

        Debug("\n  Testing Pairs-Specific Functions" +
              "\n    GetChatPairs(oPC)                    -> " + GetChatPairs(oPC) +
              "\n    CountChatPairs(oPC)                  -> " + IntToString(CountChatPairs(oPC)) +
              "\n    HasChatKey(oPC, \"longOpt\")         -> " + (HasChatKey(oPC, "longOpt") ? "TRUE" : "FALSE") +
              "\n    HasChatKey(oPC, \"s\")               -> " + (HasChatKey(oPC, "s") ? "TRUE" : "FALSE") +
              "\n    HasChatKey(oPC, \"--longOpt\")       -> " + (HasChatKey(oPC, "--longOpt") ? "TRUE" : "FALSE") +
              "\n    HasChatKey(oPC, \"-s\")              -> " + (HasChatKey(oPC, "-s") ? "TRUE" : "FALSE" ) +
              "\n    HasChatKey(oPC, \"short\")           -> " + (HasChatKey(oPC, "short") ? "TRUE" : "FALSE") +
              "\n    FindChatKey(oPC, \"-s\")             -> " + IntToString(FindChatKey(oPC, "-s")) +
              "\n    GetChatKey(oPC, 1)                   -> " + GetChatKey(oPC, 1) +
              "\n    GetChatValue(oPC, 1)                 -> " + GetChatValue(oPC, 1) +
              "\n    GetChatKeyValue(oPC, \"longOpt\")    -> " + GetChatKeyValue(oPC, "longOpt") +
              "\n    GetChatKeyValueInt(oPC, \"int\")     -> " + IntToString(GetChatKeyValueInt(oPC, "int")) +
              "\n    GetChatKeyValueInt(oPC, \"none\")    -> " + IntToString(GetChatKeyValueInt(oPC, "none")) +
              "\n    GetChatKeyValueFloat(oPC, \"float\") -> " + FloatToString(GetChatKeyValueFloat(oPC, "float"), 0, _GetPrecision(GetChatKeyValue(oPC, "float"))) +
              "\n    GetChatKeyValueFloat(oPC, \"none\")  -> " + FloatToString(GetChatKeyValueFloat(oPC, "none"), 0, _GetPrecision(GetChatKeyValue(oPC, "none"))));
    }
    else
        Error(GetName(oPC) + " does not have a parsed commmand line");
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
