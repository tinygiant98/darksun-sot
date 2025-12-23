/// ----------------------------------------------------------------------------
/// @file   pw_p_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (plugin).
/// ----------------------------------------------------------------------------

#include "util_i_library"
//#include "util_i_color"
#include "core_i_framework"
#include "pw_e_audit"

// -----------------------------------------------------------------------------
//                           Library Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!AUDIT_ENABLE_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
    {
        AwaitPlugin(__FILE__);
        return;
    }

    if (!GetIfPluginExists("audit"))
    {
        object oPlugin = CreatePlugin("audit");
        SetName(oPlugin, "[Plugin] AUDIT :: Core");
        //SetDescription(oPlugin,
        //    "This plugin controls audit collection and reporting.");
        SetDebugPrefix(HexColorString("[AUDIT]", COLOR_CRIMSON));

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "audit_OnClientEnter",         9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,          "audit_OnClientLeave",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "audit_OnModuleLoad",     9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,          "audit_OnPlayerDeath",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP,       "audit_OnPlayerLevelUp",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,        "audit_OnPlayerReSpawn",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "audit_OnPlayerRestFinished",  10.0);

        RegisterEventScript(oPlugin, "AUDIT_EVENT_SYNC_ON_TIMER_EXPIRE", "audit_Sync_OnTimerExpire", 10.0);

        int n;
        RegisterLibraryScript("audit_OnClientEnter",         n++);
        RegisterLibraryScript("audit_OnClientLeave",         n++);
        RegisterLibraryScript("audit_OnModuleLoad",          n++);
        RegisterLibraryScript("audit_OnPlayerDeath",         n++);
        RegisterLibraryScript("audit_OnPlayerLevelUp",       n++);
        RegisterLibraryScript("audit_OnPlayerReSpawn",       n++);
        RegisterLibraryScript("audit_OnPlayerRestFinished",  n++);

        n = 100;
        RegisterLibraryScript("audit_Sync_OnTimerExpire", n++);
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
            if      (nEntry == n++) audit_OnClientEnter();
            else if (nEntry == n++) audit_OnClientLeave();
            else if (nEntry == n++) audit_OnModuleLoad();
            else if (nEntry == n++) audit_OnPlayerDeath();
            else if (nEntry == n++) audit_OnPlayerLevelUp();
            else if (nEntry == n++) audit_OnPlayerReSpawn();
            else if (nEntry == n++) audit_OnPlayerRestFinished();
        } break;

        case 100:
        {
            if      (nEntry == n++) audit_Sync_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
