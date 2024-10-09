/// ----------------------------------------------------------------------------
/// @file   pw_l_loot.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Loot Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_e_loot"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!LOOT_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "loot_OnPlayerDying", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "loot_OnPlayerDeath", 4.5);

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
