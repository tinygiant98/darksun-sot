/// -----------------------------------------------------------------------------
/// @file:  hcr_l_bleed.nss
/// @brief: HCR2 Bleed System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_bleed"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("hcr2") || !H2_BLEED_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_bleed");
    SetName(oPlugin, "[Plugin] HCR2 :: Bleed System");
    SetDescription(oPlugin, "HCR2 Bleed System");
    SetDebugPrefix(HexColorString("[HCR2 Bleed]", COLOR_RED_LIGHT), oPlugin);

    // Module Events
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,        "bleed_OnClientEnter",       4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,        "bleed_OnPlayerDying",       4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED, "bleed_OnPlayerRestStarted", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,        "bleed_OnPlayerDeath",       4.0);

    // Timer Events
    RegisterEventScript(oPlugin, BLEED_EVENT_ON_TIMER_EXPIRE,         "bleed_OnTimerExpire",       4.0);

    // Module Events
    RegisterLibraryScript("bleed_OnClientEnter",       1);
    RegisterLibraryScript("bleed_OnPlayerDying",       2);
    RegisterLibraryScript("bleed_OnPlayerRestStarted", 3);
    RegisterLibraryScript("bleed_OnPlayerDeath",       4);

    // Tag-based Scripting
    RegisterLibraryScript(H2_HEAL_WIDGET,              5);

    // Timer Events
    RegisterLibraryScript("bleed_OnTimerExpire",       6);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // Module Events
        case 1:  bleed_OnClientEnter();       break;
        case 2:  bleed_OnPlayerDying();       break;
        case 3:  bleed_OnPlayerRestStarted(); break;
        case 4:  bleed_OnPlayerDeath();       break;
       
        // Tag-based Scripting
        case 5:  bleed_healwidget();          break;

        // Timer Events
        case 6:  bleed_OnTimerExpire();       break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
