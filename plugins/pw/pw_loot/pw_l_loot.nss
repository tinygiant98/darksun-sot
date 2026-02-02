/// ----------------------------------------------------------------------------
/// @file   pw_l_loot.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Loot System (library).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_i_loot"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!LOOT_SYSTEM_ENABLED)
        return;

    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "loot_OnPlayerDying", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "loot_OnPlayerDeath", 4.5);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_CLOSE, "loot_OnPlaceableClosed");

    int n;
    RegisterLibraryScript("loot_OnPlayerDying", n++);
    RegisterLibraryScript("loot_OnPlayerDeath", n++);
    RegisterLibraryScript("loot_OnPlaceableClose", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) loot_OnPlayerDying();
            else if (nEntry == n++) loot_OnPlayerDeath();
            else if (nEntry == n++) loot_OnPlaceableClose();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
