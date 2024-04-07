/// -----------------------------------------------------------------------------
/// @file:  hcr_l_fugue.nss
/// @brief: HCR2 Fugue System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_fugue"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("hcr2") || !H2_FUGUE_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_fugue");
    SetName(oPlugin, "[Plugin] HCR2 :: Fugue System");
    SetDescription(oPlugin, "HCR2 Fugue System");
    SetDebugPrefix(HexColorString("[HCR2 Fugue]", COLOR_FUCHSIA), oPlugin);

    // Module Events
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,  "fugue_OnModuleLoad",  4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "fugue_OnClientEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "fugue_OnPlayerDeath", 8.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "fugue_OnPlayerDying", 8.0);

    // Module Events
    RegisterLibraryScript("fugue_OnModuleLoad",  1);
    RegisterLibraryScript("fugue_OnClientEnter", 2);
    RegisterLibraryScript("fugue_OnPlayerDeath", 3);
    RegisterLibraryScript("fugue_OnPlayerDying", 4);

    // Local Events
    RegisterLibraryScript("fugue_OnAreaExit",    5);

    // Dialog
    LoadLibrary("hcr_d_fugue");
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // Module Events
        case 1:  fugue_OnModuleLoad(); break;
        case 2:  fugue_OnClientEnter(); break;
        case 3:  fugue_OnPlayerDeath(); break;
        case 4:  fugue_OnPlayerDying(); break;

        // Local Events
        case 5:  fugue_OnAreaExit(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
