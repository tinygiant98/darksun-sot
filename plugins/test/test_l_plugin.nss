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

#include "x3_inc_horse"
void horse_dismount()
{
    HorseDismount();
}

void horse_instant_dismount()
{
    HorseInstantDismount(OBJECT_SELF);
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

    // Tag-based Scripting
    RegisterLibraryScript("util_playerdata", 30);

    // Testing stuff
    RegisterLibraryScript("horse_dismount", 31);
    RegisterLibraryScript("horse_instant_dismount", 32);
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

        case 30: test_PlayerDataItem(); break;

        case 31: horse_dismount(); break;
        case 32: horse_instant_dismount(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
