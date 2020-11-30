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
    object oPlugin = GetPlugin("ds");
    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "ds_fug_OnPlayerDeath");
    // ----- Module Events -----
    RegisterLibraryScript("ds_fug_OnPlayerDeath", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: ds_fug_OnPlayerDeath(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}