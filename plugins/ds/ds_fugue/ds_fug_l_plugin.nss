// -----------------------------------------------------------------------------
//    File: ds_fug_l_plugin.nss
//  System: Fugue Death and Resurrection (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for DS Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------
// Jacyn - 2020-11-30  -Added the Registration for the OnPlayerDeath Handler
// -----------------------------------------------------------------------------
#include "util_i_library"
#include "core_i_framework"
#include "ds_fug_i_events"

// -----------------------------------------------------------------------------
// Library Dispatch
// -----------------------------------------------------------------------------
void OnLibraryLoad() 
{
    if (!USE_ANGEL_SYSTEM)
        return;

    object oPlugin = GetPlugin("ds");
    // ----- Module Events -----
    // Set priority to 4.1 so it runs just before the PW script.
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "ds_fug_OnPlayerDeath", 4.1);
    // No priority needed here.
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "ds_fug_OnClientEnter");
    // ----- Module Scripts -----
    RegisterLibraryScript("ds_fug_OnPlayerDeath", 1);
    RegisterLibraryScript("ds_fug_OnClientEnter", 2);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: ds_fug_OnPlayerDeath(); break;
        case 2: ds_fug_OnClientEnter(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}