/// -----------------------------------------------------------------------------
/// @file:  hcr_l_corpse.nss
/// @brief: HCR2 Corpse Token System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_corpse"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("hcr2") || !H2_CORPSE_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_corpse");
    SetName(oPlugin, "[Plugin] HCR2 :: Corpse Token System");
    SetDescription(oPlugin, "HCR2 Corpse Token System");
    SetDebugPrefix(HexColorString("[HCR2 Corpse Token]", COLOR_BLUE_LIGHT), oPlugin);

    // Module Events
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "corpse_OnClientEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE, "corpse_OnClientLeave", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "corpse_OnPlayerDeath", 4.0);
    RegisterEventScript(oPlugin, H2_EVENT_ON_PLAYER_LIVES,     "corpse_OnPlayerLives", 4.0);

    // Module Events
    RegisterLibraryScript("corpse_OnClientEnter", 1);
    RegisterLibraryScript("corpse_OnClientLeave", 2);
    RegisterLibraryScript("corpse_OnPlayerDeath", 3);
    RegisterLibraryScript("corpse_OnPlayerLives", 4);
    
    // Tag-based Scripting
    RegisterLibraryScript(H2_PC_CORPSE_ITEM,     5);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // Module Events
        case 1:  corpse_OnClientEnter(); break;
        case 2:  corpse_OnClientLeave(); break;
        case 3:  corpse_OnPlayerDeath(); break;
        case 4:  corpse_OnPlayerLives(); break;
        
        // Tag-based Scripting
        case 5:  corpse_pccorpseitem(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
