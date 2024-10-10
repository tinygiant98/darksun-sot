/// ----------------------------------------------------------------------------
/// @file   pw_l_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_k_bleed"
#include "pw_e_bleed"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!BLEED_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,        "bleed_OnClientEnter",       4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,        "bleed_OnPlayerDying",       4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED, "bleed_OnPlayerRestStarted", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,        "bleed_OnPlayerDeath",       4.0);

    // ----- Timer Events -----
    RegisterEventScripts(oPlugin, BLEED_EVENT_ON_TIMER_EXPIRE,         "bleed_OnTimerExpire",       4.0);

    // --- Module Events ---
    RegisterLibraryScript("bleed_OnClientEnter",       1);
    RegisterLibraryScript("bleed_OnPlayerDying",       2);
    RegisterLibraryScript("bleed_OnPlayerRestStarted", 3);
    RegisterLibraryScript("bleed_OnPlayerDeath",       6);

    // --- Tag-based Scripting ---
    RegisterLibraryScript(H2_HEAL_WIDGET,              4);

    // --- Timer Events ---
    RegisterLibraryScript("bleed_OnTimerExpire",       5);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  bleed_OnClientEnter();       break;
        case 2:  bleed_OnPlayerDying();       break;
        case 3:  bleed_OnPlayerRestStarted(); break;
        case 6:  bleed_OnPlayerDeath();       break;
       
        // ----- Tag-based Scripting -----
        case 4:  bleed_healwidget();          break;

        // ----- Timer Events -----
        case 5:  bleed_OnTimerExpire();       break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_bleed.nss");
    }
}
