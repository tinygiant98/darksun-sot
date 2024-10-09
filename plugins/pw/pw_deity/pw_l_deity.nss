/// ----------------------------------------------------------------------------
/// @file   pw_l_deity.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Deity Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_e_deity"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!DEITY_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "deity_OnPlayerDeath", 5.0);

    // ----- Module Events -----
    RegisterLibraryScript("deity_OnPlayerDeath", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  deity_OnPlayerDeath(); break;
        default:            
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_deity.nss");
    }
}
