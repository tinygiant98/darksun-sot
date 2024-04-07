/// -----------------------------------------------------------------------------
/// @file:  hcr_l_deity.nss
/// @brief: HCR2 Deity System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_deity"

// -----------------------------------------------------------------------------
//                               Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("hcr2") || !H2_DEITY_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_deity");
    SetName(oPlugin, "[Plugin] HCR2 :: Deity System");
    SetDescription(oPlugin, "HCR2 Deity System");
    SetDebugPrefix(HexColorString("[HCR2 Deity]", COLOR_RED_LIGHT), oPlugin);

    // Module Events
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "deity_OnPlayerDeath", 4.0);

    // Module Events
    RegisterLibraryScript("deity_OnPlayerDeath", 1);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // Module Events
        case 1:  deity_OnPlayerDeath(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
