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
    }

    RegisterLibraryScript("test_OnClientEnter", 0);
    RegisterLibraryScript("test_convo_OnPlayerChat", 1);
    RegisterLibraryScript("test_go_OnPlayerChat", 2);
    RegisterLibraryScript("test_get_OnPlayerChat", 3);
    RegisterLibraryScript("test_stake_OnPlayerChat", 4);

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

        case 30: test_PlayerDataItem(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
