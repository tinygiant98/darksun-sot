// -----------------------------------------------------------------------------
//    File: chat_l_plugin.nss
//  System: Chat Command System (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "chat_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!USE_CHAT_COMMAND_SYSTEM)
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_CHAT, "chat_OnPlayerChat", 9.0);

    RegisterLibraryScript("chat_OnPlayerChat", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  chat_OnPlayerChat();       break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
