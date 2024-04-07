/// -----------------------------------------------------------------------------
/// @file:  hcr_l_loot.nss
/// @brief: HCR2 Loot System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_loot"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("hcr2") || !H2_LOOT_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_loot");
    SetName(oPlugin, "[Plugin] HCR2 :: Loot System");
    SetDescription(oPlugin, "HCR2 Loot System");
    SetDebugPrefix(HexColorString("[HCR2 Loot]", COLOR_GREEN), oPlugin);

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "loot_OnPlayerDying", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "loot_OnPlayerDeath", 4.5);

    // ----- Module Events -----
    RegisterLibraryScript("loot_OnPlayerDying", 1);
    RegisterLibraryScript("loot_OnPlayerDeath", 2);
    RegisterLibraryScript("loot_OnPlaceableClose", 3);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

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
