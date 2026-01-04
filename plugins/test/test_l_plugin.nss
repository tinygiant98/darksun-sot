// -----------------------------------------------------------------------------
//    File: test_l_plugin.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "chat_i_main"
#include "core_i_framework"
#include "test_i_events"

#include "nwnx_events"
#include "nwnx_creature"
#include "nwnx_player"

void nwnx_WalkTest()
{
    // TODO
    /*
    int bRun = StringToInt(NWNX_Events_GetEventData("RUN_TO_POINT"));

    if (bRun)
        DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
    */
}

void test_run_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    if (GetLocalInt(oPC, "ALWAYS_WALK") == TRUE)
        DeleteLocalInt(oPC, "ALWAYS_WALK");
    else
        SetLocalInt(oPC, "ALWAYS_WALK", TRUE);

    if (GetLocalInt(oPC, "ALWAYS_WALK") == TRUE)
        Notice("We're walking, people!");
    else
        Notice("Get your groove on, we're running up in this bitch!");

    NWNX_Player_SetAlwaysWalk(oPC, GetLocalInt(oPC, "ALWAYS_WALK"));
}

void nwnx_KeyboardTest()
{
    // TODO
    /*
    string sKey = NWNX_Events_GetEventData("KEY");
    if (sKey == "W")
        DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
    */
}

void test_pc_OnPlayerHeartbeat()
{
    // TODO
    /*
    DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
    */
}

void test_pc_CheckMovementRate()
{
    object oPC = OBJECT_SELF;
    int nType = NWNX_Creature_GetMovementType(oPC);

    if (nType == NWNX_CREATURE_MOVEMENT_TYPE_RUN)
    {
        if (GetLocalInt(oPC, "RUNNING") == FALSE)
        {
            SetLocalInt(oPC, "RUNNING", TRUE);
            Notice(HexColorString("You're running; HTF rate increased", COLOR_RED_LIGHT));
        }
    }
    else
    {
        if (GetLocalInt(oPC, "RUNNING") == TRUE)
        {
            DeleteLocalInt(oPC, "RUNNING");
            Notice(HexColorString("You're not running; HTF rate normal", COLOR_GREEN_LIGHT));
        }
    }

}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!TEST_USE_TEST_SYSTEM)
        return;

    if (!GetIfPluginExists("test"))
    {
        object oPlugin = CreatePlugin("test");
        SetName(oPlugin, "[Plugin] System :: Module Testing System");
        SetDescription(oPlugin,
            "This plugin provides functionality for testing various module systems.");
        //LoadLibraries("test_l_dialog");
    
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "test_OnClientEnter", 10.0);
        RegisterEventScript(oPlugin, CHAT_PREFIX + "!test", "test_OnPlayerChat");
        //RegisterEventScript(oPlugin, "NWNX_ON_INPUT_WALK_TO_WAYPOINT_BEFORE", "nwnx_WalkTest");
        //RegisterEventScript(oPlugin, "NWNX_ON_INPUT_KEYBOARD_BEFORE", "nwnx_KeyboardTest");

        RegisterEventScript(oPlugin, PLAYER_EVENT_ON_HEARTBEAT, "test_pc_OnPlayerHeartbeat", 10.0);

        int n;
        RegisterLibraryScript("test_OnClientEnter", n++);
        RegisterLibraryScript("test_OnPlayerChat", n++);

        n = 100;
        RegisterLibraryScript("nwnx_WalkTest", n++);
        RegisterLibraryScript("nwnx_KeyboardTest", n++);
        RegisterLibraryScript("test_pc_OnPlayerHeartbeat", n++);
        RegisterLibraryScript("test_pc_CheckMovementRate", n++);
        // Tag-based Scripting

        n = 200;
        RegisterLibraryScript("util_playerdata", n++);
    }
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) test_OnClientEnter();
            else if (nEntry == n++) test_OnPlayerChat();
        } break;

        case 100:
        {
            if      (nEntry == n++) nwnx_WalkTest();
            else if (nEntry == n++) nwnx_KeyboardTest();
            else if (nEntry == n++) test_pc_OnPlayerHeartbeat();
            else if (nEntry == n++) test_pc_CheckMovementRate();
        } break;

        case 200:
        {
            if      (nEntry == n++) test_PlayerDataItem();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
