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
#include "pw_i_loot"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_USE_LOOT_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "loot_OnPlayerDying", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "loot_OnPlayerDeath", 4.5);

    // ----- Module Events -----
    RegisterLibraryScript("loot_OnPlayerDying", 1);
    RegisterLibraryScript("loot_OnPlayerDeath", 2);
    RegisterLibraryScript("loot_OnPlaceableClose", 3);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  loot_OnPlayerDying(); break;
        case 2:  loot_OnPlayerDeath(); break;
        case 3:  loot_OnPlaceableClose(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
