/// ----------------------------------------------------------------------------
/// @file   pw_p_eventman.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Event Manager (plugin).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_e_eventman"

// -----------------------------------------------------------------------------
//                           Library Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!EVENTMAN_ENABLE_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
    {
        AwaitPlugin(__FILE__);
        return;
    }

    if (!GetIfPluginExists("eventman"))
    {
        object oPlugin = CreatePlugin("eventman");
        SetName(oPlugin, "[Plugin] EVENTMAN :: Core");
        //SetDescription(oPlugin,
        //    "This plugin controls audit collection and reporting.");
        SetDebugPrefix(HexColorString("[EVENTMAN]", COLOR_CRIMSON));

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "eventman_OnClientEnter",         EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,          "eventman_OnClientLeave",         EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "eventman_OnModuleLoad",          EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,          "eventman_OnPlayerDeath",         EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP,       "eventman_OnPlayerLevelUp",       EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,        "eventman_OnPlayerReSpawn",       EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "eventman_OnPlayerRestFinished",  EVENT_PRIORITY_FIRST);
        int n;
        RegisterLibraryScript("eventman_OnClientEnter",         n++);
        RegisterLibraryScript("eventman_OnClientLeave",         n++);
        RegisterLibraryScript("eventman_OnModuleLoad",          n++);
        RegisterLibraryScript("eventman_OnPlayerDeath",         n++);
        RegisterLibraryScript("eventman_OnPlayerLevelUp",       n++);
        RegisterLibraryScript("eventman_OnPlayerReSpawn",       n++);
        RegisterLibraryScript("eventman_OnPlayerRestFinished",  n++);
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
            if      (nEntry == n++) eventman_OnClientEnter();
            else if (nEntry == n++) eventman_OnClientLeave();
            else if (nEntry == n++) eventman_OnModuleLoad();
            else if (nEntry == n++) eventman_OnPlayerDeath();
            else if (nEntry == n++) eventman_OnPlayerLevelUp();
            else if (nEntry == n++) eventman_OnPlayerReSpawn();
            else if (nEntry == n++) audit_OnPlayerRestFinished();
        } break;

        case 100:
        {
            //if      (nEntry == n++) eventman_Sync_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
