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

/// @brief Library script to allow metrics schema registration without forcing the
///     caller to include this file.
/// @note Values are popped from the stack in reverse order.  Push values in this
///     order before calling this function:
///         PushString(sName)
///         PushString(sSource)
///         PushJson(jSchema)
/// @note Do not specify a game object for the argstack list when pushing values
///     onto the stack.
void RegisterMetricsSchema()
{
    metrics_RegisterSchema(PopString(), PopString(), PopJson());
}

void UnregisterMetricsSchema()
{
    metrics_UnregisterSchema(PopString(), PopString());
}

void ListMetricsSchemas()
{
    PushJson(metrics_ListSchemas(PopString()));
}

void GetMetricsSchema()
{
    PushJson(metrics_GetSchema(PopString(), PopString()));
}

void SubmitPlayerMetric()
{
    metrics_SubmitPlayerMetric(PopString(), PopString(), PopString(), PopJson());
}

void SubmitCharacterMetric()
{
    metrics_SubmitCharacterMetric(PopString(), PopString(), PopString(), PopJson());
}

void SubmitServerMetric()
{
    metrics_SubmitServerMetric(PopString(), PopString(), PopJson());
}

/// @todo All the getters

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
            "This plugin manages metrics collection and reporting.");
        SetDebugPrefix(HexColorString("[METRICS]", COLOR_CRIMSON));

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,  "metrics_OnClientEnter",         9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,  "metrics_OnClientLeave",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,   "metrics_OnModuleLoad",          9.0);
        RegisterEventScript(oPlugin, "MODULE_EVENT_ON_MODULE_POST", "metrics_OnModulePOST");
        RegisterEventScript(oPlugin, "MODULE_EVENT_ON_PLAYER_DELETED", "metrics_OnPlayerDeleted");
        RegisterEventScript(oPlugin, CHAT_PREFIX + "!metrics",      "metrics_OnPlayerChat",          10.0);

        RegisterEventScript(oPlugin, METRICS_EVENT_FLUSH_ON_TIMER_EXPIRE, "metrics_Flush_OnTimerExpire", 10.0);

        int n;
        RegisterLibraryScript("metrics_OnClientEnter", n++);
        RegisterLibraryScript("metrics_OnClientLeave", n++);
        RegisterLibraryScript("metrics_OnModuleLoad",  n++);
        RegisterLibraryScript("metrics_OnModulePOST",  n++);
        RegisterLibraryScript("metrics_OnPlayerDeleted", n++);
        RegisterLibraryScript("metrics_OnPlayerChat",  n++);

        n = 100;
        RegisterLibraryScript("metrics_Flush_OnTimerExpire", n++);

        n = 200;
        RegisterLibraryScript("RegisterMetricsSchema", n++);
        RegisterLibraryScript("UnregisterMetricsSchema", n++);
        RegisterLibraryScript("GetMetricsSchemas", n++);
        RegisterLibraryScript("GetMetricsSchema", n++);
        RegisterLibraryScript("SubmitPlayerMetric", n++);
        RegisterLibraryScript("SubmitCharacterMetric", n++);
        RegisterLibraryScript("SubmitServerMetric", n++);
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
            else if (nEntry == n++) metrics_OnPlayerDeleted();
            else if (nEntry == n++) metrics_OnPlayerChat();
        } break;

        case 100:
        {
            if      (nEntry == n++) metrics_Flush_OnTimerExpire();
        } break;

        case 200:
        {
            if      (nEntry == n++) RegisterMetricsSchema();
            else if (nEntry == n++) UnregisterMetricsSchema();
            else if (nEntry == n++) ListMetricsSchemas();
            else if (nEntry == n++) GetMetricsSchema();
            else if (nEntry == n++) SubmitPlayerMetric();
            else if (nEntry == n++) SubmitCharacterMetric();
            else if (nEntry == n++) SubmitServerMetric();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
