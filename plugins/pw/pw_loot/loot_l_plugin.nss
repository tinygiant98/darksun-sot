// -----------------------------------------------------------------------------
//    File: loot_l_plugin.nss
//  System: PC Corpse Loot (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "loot_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_USE_LOOT_SYSTEM)
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "loot_OnPlayerDying", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "loot_OnPlayerDeath", 4.5);

    // ----- Module Events -----
    RegisterLibraryScript("loot_OnPlayerDying", 1);
    RegisterLibraryScript("loot_OnPlayerDeath", 2);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  loot_OnPlayerDying(); break;
        case 2:  loot_OnPlayerDeath(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
