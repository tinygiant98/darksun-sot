// -----------------------------------------------------------------------------
//    File: ds_p_pw.nss
//  System: Persistent World Administration (plugin)
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "ds_e_pw"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("hcr"))
    {
        object oPlugin = CreatePlugin("hcr");
        SetName(oPlugin, "[Plugin] HCR2 :: Core");
        SetDescription(oPlugin,
            "This plugin controls basic functions of the HCR2-base persistent world system and " +
            "loads all HCR2 subsystems.");
        SetDebugPrefix(HexColorString("[HCR2]", COLOR_BLUE_SLATE_MEDIUM));
        LoadLibrariesByPattern("hcr_l_*");

        // ----- Module Events -----
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "pw_OnClientEnter",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,          "pw_OnClientLeave",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_HEARTBEAT,             "pw_OnModuleHeartbeat",     10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "pw_OnModuleLoad",          10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,          "pw_OnPlayerDeath",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,          "pw_OnPlayerDying",         9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP,       "pw_OnPlayerLevelUp",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,        "pw_OnPlayerReSpawn",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST,           "pw_OnPlayerRest",          EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED,   "pw_OnPlayerRestStarted",   EVENT_PRIORITY_LAST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_CANCELLED, "pw_OnPlayerRestCancelled", 10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "pw_OnPlayerRestFinished",  10.0);

        // ----- Timer Events -----
        RegisterEventScript(oPlugin, H2_SAVE_LOCATION_ON_TIMER_EXPIRE, "pw_SavePCLocation_OnTimerExpire", 10.0);
        RegisterEventScript(oPlugin, H2_EXPORT_CHAR_ON_TIMER_EXPIRE,   "pw_ExportPCs_OnTimerExpire", 10.0);
    }

    // ----- Module Events -----
    RegisterLibraryScript("pw_OnClientEnter",           1);
    RegisterLibraryScript("pw_OnClientLeave",           2);
    RegisterLibraryScript("pw_OnModuleHeartbeat",       3);
    RegisterLibraryScript("pw_OnModuleLoad",            4);
    RegisterLibraryScript("pw_OnPlayerDeath",           5);
    RegisterLibraryScript("pw_OnPlayerDying",           6);
    RegisterLibraryScript("pw_OnPlayerLevelUp",         7);
    RegisterLibraryScript("pw_OnPlayerReSpawn",         8);
    RegisterLibraryScript("pw_OnPlayerRest",            9);
    RegisterLibraryScript("pw_OnPlayerRestStarted",    20);
    RegisterLibraryScript("pw_OnPlayerRestCancelled",  21);
    RegisterLibraryScript("pw_OnPlayerRestFinished",   22);

    // ----- Timer Events -----
    RegisterLibraryScript("pw_SavePCLocation_OnTimerExpire", 14);
    RegisterLibraryScript("pw_ExportPCs_OnTimerExpire",      15);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:   pw_OnClientEnter();          break;
        case 2:   pw_OnClientLeave();          break;
        case 3:   pw_OnModuleHeartbeat();      break;
        case 4:   pw_OnModuleLoad();           break;
        case 5:   pw_OnPlayerDeath();          break;
        case 6:   pw_OnPlayerDying();          break;
        case 7:   pw_OnPlayerLevelUp();        break;
        case 8:   pw_OnPlayerReSpawn();        break;
        case 9:   pw_OnPlayerRest();           break;
        case 20:  pw_OnPlayerRestStarted();    break;
        case 21:  pw_OnPlayerRestCancelled();  break;
        case 22:  pw_OnPlayerRestFinished();   break;

        // ----- Timer Events -----
        case 14: pw_SavePCLocation_OnTimerExpire(); break;
        case 15: pw_ExportPCs_OnTimerExpire(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
