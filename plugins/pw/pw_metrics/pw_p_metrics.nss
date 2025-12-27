/// ----------------------------------------------------------------------------
/// @file   pw_p_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (plugin).
///
/// @defgroup pw_metrics Metrics Management System
/// @ingroup pw
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

    if (!GetIfPluginExists("metrics"))
    {
        object oPlugin = CreatePlugin("metrics");
        SetName(oPlugin, "[Plugin] Metrics Management System");
        SetDescription(oPlugin,
            "This plugin controls metrics collection and reporting.");
        SetDebugPrefix(HexColorString("[METRICS]", COLOR_CRIMSON));

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,  "metrics_OnClientEnter",         9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,  "metrics_OnClientLeave",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,   "metrics_OnModuleLoad",          9.0);
        RegisterEventScript(oPlugin, "MODULE_EVENT_ON_MODULE_POST", "metrics_OnModulePOST");
        RegisterEventScript(oPlugin, CHAT_PREFIX + "!metrics",      "metrics_OnPlayerChat",          10.0);

        RegisterEventScript(oPlugin, METRICS_EVENT_FLUSH_ON_TIMER_EXPIRE, "metrics_Flush_OnTimerExpire", 10.0);

        int n;
        RegisterLibraryScript("metrics_OnClientEnter", n++);
        RegisterLibraryScript("metrics_OnClientLeave", n++);
        RegisterLibraryScript("metrics_OnModuleLoad",  n++);
        RegisterLibraryScript("metrics_OnModulePOST",  n++);
        RegisterLibraryScript("metrics_OnPlayerChat",  n++);

        n = 100;
        RegisterLibraryScript("metrics_Flush_OnTimerExpire", n++);
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
            else if (nEntry == n++) metrics_OnModulePOST();
            else if (nEntry == n++) metrics_OnPlayerChat();
        } break;

        case 100:
        {
            if      (nEntry == n++) metrics_Flush_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
