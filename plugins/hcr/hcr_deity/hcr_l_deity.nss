/// ----------------------------------------------------------------------------
/// @file   hcr_l_deity.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Deity System (library).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_deity"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_DEITY_ENABLE_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "deity_OnPlayerDeath", 4.0);

    // ----- Module Events -----
    RegisterLibraryScript("deity_OnPlayerDeath", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  deity_OnPlayerDeath(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
