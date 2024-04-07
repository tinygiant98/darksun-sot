/// -----------------------------------------------------------------------------
/// @file:  hcr_l_plugin.nss
/// @brief: HCR2 System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_chat"
#include "core_i_framework"
#include "hcr_e_core"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{

    if (GetIfPluginExists("hcr2"))
        return;

    object oPlugin = CreatePlugin("hcr2");
    SetName(oPlugin, "[Plugin] HCR2 :: Core");
    SetDescription(oPlugin,
        "This plugin controls basic functions of the HCR2-base persistent world system and " +
        "loads all HCR2 subsystems.");
    SetDebugPrefix(HexColorString("[HCR2]", COLOR_BLUE_SLATE_MEDIUM), oPlugin);
    LoadLibrariesByPattern("hcr_l_*");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "hcr_OnClientEnter",         10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,          "hcr_OnClientLeave",         10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_HEARTBEAT,             "hcr_OnModuleHeartbeat",     10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "hcr_OnModuleLoad",          10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,          "hcr_OnPlayerDeath",         10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,          "hcr_OnPlayerDying",         9.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP,       "hcr_OnPlayerLevelUp",       10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,        "hcr_OnPlayerReSpawn",       10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST,           "hcr_OnPlayerRest",          EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED,   "hcr_OnPlayerRestStarted",   EVENT_PRIORITY_LAST);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_CANCELLED, "hcr_OnPlayerRestCancelled", 10.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "hcr_OnPlayerRestFinished",  10.0);

    // Chat Commands
    RegisterEventScript(oPlugin, CHAT_PREFIX + "!hcr", "hcr_OnPlayerChat");

    // ----- Timer Events -----
    RegisterEventScript(oPlugin, H2_SAVE_LOCATION_ON_TIMER_EXPIRE, "hcr_SavePCLocation_OnTimerExpire", 10.0);
    RegisterEventScript(oPlugin, H2_EXPORT_CHAR_ON_TIMER_EXPIRE,   "hcr_ExportPCs_OnTimerExpire", 10.0);

    // ----- Module Events -----
    RegisterLibraryScript("hcr_OnClientEnter",           1);
    RegisterLibraryScript("hcr_OnClientLeave",           2);
    RegisterLibraryScript("hcr_OnModuleHeartbeat",       3);
    RegisterLibraryScript("hcr_OnModuleLoad",            4);
    RegisterLibraryScript("hcr_OnPlayerDeath",           5);
    RegisterLibraryScript("hcr_OnPlayerDying",           6);
    RegisterLibraryScript("hcr_OnPlayerLevelUp",         7);
    RegisterLibraryScript("hcr_OnPlayerReSpawn",         8);
    RegisterLibraryScript("hcr_OnPlayerRest",            9);
    RegisterLibraryScript("hcr_OnPlayerRestStarted",    20);
    RegisterLibraryScript("hcr_OnPlayerRestCancelled",  21);
    RegisterLibraryScript("hcr_OnPlayerRestFinished",   22);
    RegisterLibraryScript("hcr_OnPlayerChat",           23);

    // ----- Timer Events -----
    RegisterLibraryScript("hcr_SavePCLocation_OnTimerExpire", 14);
    RegisterLibraryScript("hcr_ExportPCs_OnTimerExpire",      15);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:   hcr_OnClientEnter();          break;
        case 2:   hcr_OnClientLeave();          break;
        case 3:   hcr_OnModuleHeartbeat();      break;
        case 4:   hcr_OnModuleLoad();           break;
        case 5:   hcr_OnPlayerDeath();          break;
        case 6:   hcr_OnPlayerDying();          break;
        case 7:   hcr_OnPlayerLevelUp();        break;
        case 8:   hcr_OnPlayerReSpawn();        break;
        case 9:   hcr_OnPlayerRest();           break;
        case 20:  hcr_OnPlayerRestStarted();    break;
        case 21:  hcr_OnPlayerRestCancelled();  break;
        case 22:  hcr_OnPlayerRestFinished();   break;
        case 23:  hcr_OnPlayerChat();           break;

        // ----- Timer Events -----
        case 14: hcr_SavePCLocation_OnTimerExpire(); break;
        case 15: hcr_ExportPCs_OnTimerExpire(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
