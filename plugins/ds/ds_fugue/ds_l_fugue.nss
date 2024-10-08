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
// Jacyn -Added the Registration for the OnPlayerDeath Handler
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "ds_i_const"
#include "ds_fug_i_events"

// -----------------------------------------------------------------------------
// Library Dispatch
// -----------------------------------------------------------------------------
void OnLibraryLoad() 
{
    if (!USE_ANGEL_SYSTEM)
        return;

    object oPlugin = GetPlugin("ds");
    LoadLibraries("dlg_ds_l_fugue");

    // ----- Module Events -----
    // Set priority to 4.1 so it runs just before the PW script.
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "ds_fug_OnPlayerDeath", 4.1);

    // ----- Module Scripts -----
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
