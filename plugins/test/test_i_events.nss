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
#include "util_i_libraries"
#include "core_c_config"
#include "util_i_time"

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

void test_script_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;

    string sScript = GetChatArgument(oPC);
    if (sScript != "")
    {
        SendChatResult("Running script " + sScript + " on " + (_GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget)), oPC);
        RunLibraryScript(sScript, oTarget);
    }
    else
        SendChatResult("Cannot run script; script argument blank" +
                       "\n  Arguments received -> " + GetChatArguments(oPC), oPC, FLAG_ERROR);
}

void test_identify_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (!GetIdentified(oItem))
        {
            SetIdentified(oItem, TRUE);
            SendChatResult("Identifying " + GetTag(oItem) + " as " + GetName(oItem), oPC);
        }

        oItem = GetNextItemInInventory(oPC);
    }
}

void test_items_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    string sObject, sObjects = GetChatArguments(oPC);
    int n, nQty, nIndex, nCount = CountList(sObjects);

    for (n = 0; n < nCount; n++)
    {
        sObject = GetListItem(sObjects, n);
        if ((nIndex = FindSubString(sObject, ":")) != -1)
            nQty = StringToInt(StringParse(sObject, ":", TRUE));
        else
            nQty = 1;

        object oItem = CreateItemOnObject(sObject, oPC, nQty);
        SetIdentified(oItem, TRUE);

        SendChatResult("Created item {tag} " + GetTag(oItem) +
                       "{name} " + GetName(oItem) + " on " + GetName(oPC), oPC);
    }
}

void test_unlock_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    object oLocked = GetNearestObject(OBJECT_TYPE_DOOR, oPC);
    if (GetIsObjectValid(oLocked) && GetLocked(oLocked))
        SetLocked(oLocked, FALSE);

    oLocked = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC);
    if (GetIsObjectValid(oLocked) && GetLocked(oLocked))
    {
        SetLocked(oLocked, FALSE);
        SendChatResult("Unlocking " + GetTag(oLocked), oPC);
    }
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
}

void test_libraries_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    if (!CountChatArguments(oPC))
        LoadLibraries(INSTALLED_LIBRARIES, TRUE);
    else
        LoadLibraries(GetChatArguments(oPC), TRUE);
}

void test_destroy_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    object oTarget = GetChatTarget(oPC);
    object oDestroy = GetNearestObjectByTag(GetChatArgument(oPC), oTarget);
    DestroyObject(oDestroy);
}

void test_go_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
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
                SendChatResult("Go: " + sTarget + " is not a valid target", oPC, FLAG_ERROR);
        }
        else
            SendChatResult("Go: You can only jump to one place, dumbass.  Make a decision already.", oPC, FLAG_ERROR);
    }
    else
        SendChatResult("Go: No target argument provided", oPC, FLAG_ERROR);
}

void test_get_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    int n, nCount = CountChatArguments(oPC);
    string sTarget;
    object oTarget, oStake;

    if (!nCount)
        SendChatResult("Get: No target argument(s) provided", oPC, FLAG_ERROR);

    oStake = GetChatTarget(oPC);
    
    for (n = 0; n < nCount; n++)
    {
        sTarget = GetChatArgument(oPC, n);
        oTarget = GetObjectByTag(sTarget);
        if (GetIsObjectValid(oTarget))
        {
            SendChatResult("Get: getting " + sTarget, oPC);
            AssignCommand(oTarget, ActionJumpToObject(oStake));
        }
    }
}

void test_time_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;

    int nHours;
    string sTime;

    if (HasChatKey(oPC, "add"))
    {
        nHours = StringToInt(GetChatKeyValue(oPC, "add"));
        sTime = AddGameTimeElement(TIME_HOURS, nHours);
    }
    else if (HasChatKey(oPC, "sub,subtract"))
    {
        nHours = StringToInt(GetChatKeyValue(oPC, "sub,subtract"));
        sTime = SubtractGameTimeElement(TIME_HOURS, nHours);
    }
    else
        SendChatResult("Current game time is " + FormatGameTime(), oPC, FLAG_INFO);

    if (sTime != "")
    {
        Notice("test_time_OnPlayerChat: sTime -> " + sTime);
        sTime = ConvertGameTimeToSystemTime(sTime);
        _SetCalendar(sTime, TRUE, TRUE);   
        SendChatResult("Game time has been set to " + FormatGameTime(), oPC);
    } 
}

void test_var_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    int bHelp;
    
    // If no variable names passed, abort
    if (!CountChatArguments(oPC))
    {
        SendChatResult("Variable names required, but not received", oPC, FLAG_ERROR);
        return;
    }

    if (HasChatOption(oPC, "h,help"))
        bHelp = TRUE;

    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;

    if (HasChatOption(oPC, "set"))
    {
        if (bHelp)
            SendChatResult(SetVariableHelp(), oPC, FLAG_HELP);
        else
            SetVariable(oPC, oTarget);
    }
    else if (HasChatOption(oPC, "d,del,delete"))
    {
        if (bHelp)
            SendChatResult(DeleteVariableHelp(), oPC, FLAG_HELP);
        else
            DeleteVariable(oPC, oTarget);
    }
    else
    {
        if (bHelp)
            SendChatResult(GetVariableHelp(), oPC, FLAG_HELP);
        else
            GetVariable(oPC, oTarget);
    }
}

void test_level_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    int nLevel = StringToInt(GetChatArgument(oPC, 0));
    int nLevelXP = 500 * nLevel * (nLevel - 1);
    int nPC = GetXP(oPC);

    GiveXPToCreature(oPC, nLevelXP - nPC);
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

void test_debug_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC, TARGET_NO_REVERT, GetModule())) == OBJECT_INVALID)
        return;

    int nLevel;
    if (HasChatOption(oPC, "5,debug"))
        nLevel = 5;
    else if (HasChatOption(oPC, "4,notice"))
        nLevel = 4;
    else if (HasChatOption(oPC, "3,warning,warn"))
        nLevel = 3;
    else if (HasChatOption(oPC, "2,error"))
        nLevel = 2;
    else if (HasChatOption(oPC, "1,critical,crit"))
        nLevel = 1;
    else if (HasChatOption(oPC, "0,none"))
        nLevel = 0;
    else
        nLevel = 5;

    SetDebugLevel(nLevel, oTarget);
    SendChatResult("Debug level for " + (oTarget == GetModule() ? GetName(oTarget) : GetTag(oTarget)) + " set to " +
                   (nLevel == 5 ? "DEBUG" : 
                    nLevel == 4 ? "NOTICE" :
                    nLevel == 3 ? "WARNING" :
                    nLevel == 2 ? "ERROR" :
                    nLevel == 1 ? "CRITICAL ERROR" : "NONE"), oPC);
}
