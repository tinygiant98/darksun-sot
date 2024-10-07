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
#include "util_i_chat"
#include "core_i_framework"
#include "pw_i_const"
#include "ds_e_fugue"

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

    // ----- Module Scripts -----
    RegisterLibraryScript("ds_fug_OnPlayerDeath", 1);

    LoadLibrary("ds_d_fugue");
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: ds_fug_OnPlayerDeath(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
