/// ----------------------------------------------------------------------------
/// @file   hcr_p_bleed.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Bleed System (plugin)
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "hcr_i_bleed"

void OnLibraryLoad()
{
    if (!H2_BLEED_ENABLE_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,        "bleed_OnClientEnter",       4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,        "bleed_OnPlayerDying",       4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED, "bleed_OnPlayerRestStarted", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,        "bleed_OnPlayerDeath",       4.0);

    // ----- Timer Events -----
    RegisterEventScript(oPlugin, H2_BLEED_EVENT_ON_TIMER_EXPIRE,         "bleed_OnTimerExpire",       8.0);

    int n;

    // --- Module Events ---
    RegisterLibraryScript("bleed_OnClientEnter",       n++);
    RegisterLibraryScript("bleed_OnPlayerDying",       n++);
    RegisterLibraryScript("bleed_OnPlayerRestStarted", n++);
    RegisterLibraryScript("bleed_OnPlayerDeath",       n++);

    n = 100;

    // --- Tag-based Scripting ---
    RegisterLibraryScript(H2_BLEED_HEAL_WIDGET,              n++);

    n = 200;

    // --- Timer Events ---
    RegisterLibraryScript("bleed_OnTimerExpire",       n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) bleed_OnClientEnter();
            else if (nEntry == n++) bleed_OnPlayerDying();
            else if (nEntry == n++) bleed_OnPlayerRestStarted();
            else if (nEntry == n++) bleed_OnPlayerDeath();
        } break;

        case 100:
        {
            if      (nEntry == n++) bleed_healwidget();
        } break;

        case 200:
        {
            if      (nEntry == n++) bleed_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }       
}
