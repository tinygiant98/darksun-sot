/// ----------------------------------------------------------------------------
/// @file   pw_l_corpse.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Corpse Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_e_corpse"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!CORPSE_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    // --- Module Events ---
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "corpse_OnClientEnter", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE, "corpse_OnClientLeave", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "corpse_OnPlayerDeath", 4.0);
    RegisterEventScripts(oPlugin, H2_EVENT_ON_PLAYER_LIVES,     "corpse_OnPlayerLives", 4.0);

    // --- Module Events ---
    RegisterLibraryScript("corpse_OnClientEnter", 1);
    RegisterLibraryScript("corpse_OnClientLeave", 2);
    RegisterLibraryScript("corpse_OnPlayerDeath", 3);
    RegisterLibraryScript("corpse_OnPlayerLives", 5);
    
    // --- Tag-based Scripting ---
    RegisterLibraryScript(H2_PC_CORPSE_ITEM,     4);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  corpse_OnClientEnter(); break;
        case 2:  corpse_OnClientLeave(); break;
        case 3:  corpse_OnPlayerDeath(); break;
        case 5:  corpse_OnPlayerLives(); break;
        
        // ----- Tag-based Scripting -----
        case 4:  corpse_pccorpseitem(); break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_crowd.nss");
    }
}
