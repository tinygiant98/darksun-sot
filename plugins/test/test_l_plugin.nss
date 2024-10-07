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
#include "util_i_chat"
#include "core_i_framework"
#include "test_i_events"

#include "nwnx_events"
#include "nwnx_creature"
#include "nwnx_player"

void nwnx_WalkTest()
{
    int bRun = StringToInt(NWNX_Events_GetEventData("RUN_TO_POINT"));

    if (bRun)
        DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
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
    string sKey = NWNX_Events_GetEventData("KEY");
    if (sKey == "W")
        DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
}

void test_pc_OnPlayerHeartbeat()
{
    DelayCommand(0.2, DelayLibraryScript("test_pc_CheckMovementRate", OBJECT_SELF));
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
        object oPlugin = GetPlugin("test", TRUE);
        SetName(oPlugin, "[Plugin] System :: Module Testing System");
        SetDescription(oPlugin,
            "This plugin provides functionality for testing various module systems.");
        SetPluginLibraries(oPlugin, "test_l_dialog");
    
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "test_OnClientEnter", 10.0);
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!convo", "test_convo_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!go", "test_go_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!get", "test_get_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!stake", "test_stake_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!items", "test_items_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!level", "test_level_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!identify", "test_identify_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!unlock", "test_unlock_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!libraries", "test_libraries_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!time", "test_time_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!var", "test_var_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!script", "test_script_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!debug", "test_debug_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!destroy", "test_destroy_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!run", "test_run_OnPlayerChat");
        RegisterEventScripts(oPlugin, CHAT_PREFIX + "!test", "test_test_OnPlayerChat");

        RegisterEventScripts(oPlugin, "NWNX_ON_INPUT_WALK_TO_WAYPOINT_BEFORE", "nwnx_WalkTest");
        RegisterEventScripts(oPlugin, "NWNX_ON_INPUT_KEYBOARD_BEFORE", "nwnx_KeyboardTest");

        RegisterEventScripts(oPlugin, PLAYER_EVENT_ON_HEARTBEAT, "test_pc_OnPlayerHeartbeat", 10.0);
    }

    RegisterLibraryScript("test_OnClientEnter", 0);
    RegisterLibraryScript("test_convo_OnPlayerChat", 1);
    RegisterLibraryScript("test_go_OnPlayerChat", 2);
    RegisterLibraryScript("test_get_OnPlayerChat", 3);
    RegisterLibraryScript("test_stake_OnPlayerChat", 4);
    RegisterLibraryScript("test_level_OnPlayerChat", 5);
    RegisterLibraryScript("test_items_OnPlayerChat", 6);
    RegisterLibraryScript("test_identify_OnPlayerChat", 7);
    RegisterLibraryScript("test_unlock_OnPlayerChat", 8);
    RegisterLibraryScript("test_libraries_OnPlayerChat", 9);
    RegisterLibraryScript("test_time_OnPlayerChat", 10);
    RegisterLibraryScript("test_var_OnPlayerChat", 11);
    RegisterLibraryScript("test_script_OnPlayerChat", 12);
    RegisterLibraryScript("test_debug_OnPlayerChat", 13);
    RegisterLibraryScript("test_destroy_OnPlayerChat", 14);
    RegisterLibraryScript("test_run_OnPlayerChat", 15);
    RegisterLibraryScript("test_test_OnPlayerChat", 16);

    RegisterLibraryScript("nwnx_WalkTest", 100);
    RegisterLibraryScript("nwnx_KeyboardTest", 101);

    RegisterLibraryScript("test_pc_OnPlayerHeartbeat", 102);
    RegisterLibraryScript("test_pc_CheckMovementRate", 103);

    // Tag-based Scripting
    RegisterLibraryScript("util_playerdata", 30);

}

void OnLibraryScript(string sScript, int nEntry)
{
    object oPC = GetEventTriggeredBy();
    object oArea = GetArea(oPC);

    switch (nEntry)
    {
        case 0:  test_OnClientEnter(); break;
        case 1:  test_convo_OnPlayerChat(); break;
        case 2:  test_go_OnPlayerChat(); break;
        case 3:  test_get_OnPlayerChat(); break;
        case 4:  test_stake_OnPlayerChat(); break;
        case 5:  test_level_OnPlayerChat(); break;
        case 6:  test_items_OnPlayerChat(); break;
        case 7:  test_identify_OnPlayerChat(); break;
        case 8:  test_unlock_OnPlayerChat(); break;
        case 9:  test_libraries_OnPlayerChat(); break;
        case 10: test_time_OnPlayerChat(); break;
        case 11: test_var_OnPlayerChat(); break;
        case 12: test_script_OnPlayerChat(); break;
        case 13: test_debug_OnPlayerChat(); break;
        case 14: test_destroy_OnPlayerChat(); break;
        case 15: test_run_OnPlayerChat(); break;
        case 16: test_test_OnPlayerChat(); break;

        case 100: nwnx_WalkTest(); break;
        case 101: nwnx_KeyboardTest(); break;
        case 102: test_pc_OnPlayerHeartbeat(); break;
        case 103: test_pc_CheckMovementRate(); break;

        case 30: test_PlayerDataItem(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}

/*
c - config - no change
i - include - any includes that aren't covered with other letters, and are available for inclusion in other plug-ins or subsystems
e - events - not a single event script like core_e_nwn would be, but a file that contains all the event procedures in a plugin to help keep them separate from the chaff that might be used for an include somehwere else.  (i.e. subsystems may want to use `tot_i_common`, but they probably don't want or need `tot_e_events`.
n - nwnx - like e above, but using the standardized file I created for nwnx events (certainly not a requirements, but complicated enough to have its own letter)
s - starting conditions - but used as a clearing house for all dialog sc scripts through the use of script params
a - action taken - same as for `s`, but with dialog actions taken
d - dialog files - primarily custom dialogs associated with the plug-in that create conversations using your dialog system
l - library - no change
t - test
p - plugin
b f g h j m o q r u v w x y z

*/