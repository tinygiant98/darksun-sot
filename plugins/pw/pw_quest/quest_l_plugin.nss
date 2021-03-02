// -----------------------------------------------------------------------------
//    File: quest_l_plugin.nss
//  System: Quest Persistent World Subsystem (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "quest_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!USE_QUEST_SYSTEM)
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "quest_OnModuleLoad");
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "quest_OnClientEnter");
    RegisterEventScripts(oPlugin, CHAT_PREFIX + "!quest", "quest_OnPlayerChat");

    RegisterLibraryScript("quest_OnModuleLoad", 1);
    RegisterLibraryScript("quest_OnClientEnter", 2);
    RegisterLibraryScript("quest_OnPlayerChat", 3);
    
    RegisterLibraryScript("quest_OnAdvance", 20);
    RegisterLibraryScript("test_goblindeath", 21);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  quest_OnModuleLoad(); break;
        case 2:  quest_OnClientEnter(); break;
        case 3:  quest_OnPlayerChat(); break;

        case 20:  quest_OnAdvance(); break;
        case 21:  test_goblindeath(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
