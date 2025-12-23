/// ----------------------------------------------------------------------------
/// @file   pw_p_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (plugin).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_e_metrics"

// -----------------------------------------------------------------------------
//                           Library Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!METRICS_ENABLE_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
    {
        AwaitPlugin(__FILE__);
        return;
    }

    if (!GetIfPluginExists("metrics"))
    {
        object oPlugin = CreatePlugin("metrics");
        SetName(oPlugin, "[Plugin] METRICS :: Core");
        SetDescription(oPlugin,
            "This plugin controls metrics collection and reporting.");
        SetDebugPrefix(HexColorString("[METRICS]", COLOR_CRIMSON));

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "metrics_OnClientEnter",         9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,          "metrics_OnClientLeave",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "metrics_OnModuleLoad",     9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,          "metrics_OnPlayerDeath",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP,       "metrics_OnPlayerLevelUp",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,        "metrics_OnPlayerReSpawn",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "metrics_OnPlayerRestFinished",  10.0);

        RegisterEventScript(oPlugin, "METRICS_EVENT_SYNC_ON_TIMER_EXPIRE", "metrics_Sync_OnTimerExpire", 10.0);

        int n;
        RegisterLibraryScript("metrics_OnClientEnter",         n++);
        RegisterLibraryScript("metrics_OnClientLeave",         n++);
        RegisterLibraryScript("metrics_OnModuleLoad",          n++);
        RegisterLibraryScript("metrics_OnPlayerDeath",         n++);
        RegisterLibraryScript("metrics_OnPlayerLevelUp",       n++);
        RegisterLibraryScript("metrics_OnPlayerReSpawn",       n++);
        RegisterLibraryScript("metrics_OnPlayerRestFinished",  n++);

        n = 100;
        RegisterLibraryScript("metrics_Sync_OnTimerExpire", n++);
    }
}

// -----------------------------------------------------------------------------
//                           Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) metrics_OnClientEnter();
            else if (nEntry == n++) metrics_OnClientLeave();
            else if (nEntry == n++) metrics_OnModuleLoad();
            else if (nEntry == n++) metrics_OnPlayerDeath();
            else if (nEntry == n++) metrics_OnPlayerLevelUp();
            else if (nEntry == n++) metrics_OnPlayerReSpawn();
            else if (nEntry == n++) metrics_OnPlayerRestFinished();
        } break;

        case 100:
        {
            if      (nEntry == n++) metrics_Sync_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
