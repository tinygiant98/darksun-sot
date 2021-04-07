// -----------------------------------------------------------------------------
//    File: pw_l_plugin.nss
//  System: Persistent World Administration (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("pw"))
    {
        object oPlugin = GetPlugin("pw", TRUE);
        SetName(oPlugin, "[Plugin] HCR2 :: Core");
        SetDescription(oPlugin,
            "This plugin controls basic functions of the HCR2-base persistent world system and " +
            "loads all pw subsystems.");
        SetPluginLibraries(oPlugin, "bleed_l_plugin, corpse_l_plugin, crowd_l_plugin, deity_l_plugin, " +
            "fugue_l_plugin, fugue_l_dialog, htf_l_plugin, loot_l_plugin, rest_l_plugin, rest_l_dialog, " +
            "torch_l_plugin, unid_l_plugin, gren_l_plugin, bus_l_plugin, res_l_plugin, res_l_placeables, " +
            "res_l_creatures, quest_l_plugin");

        // ----- Module Events -----
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "pw_OnClientEnter",         10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,          "pw_OnClientLeave",         10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_HEARTBEAT,             "pw_OnModuleHeartbeat",     10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "pw_OnModuleLoad",          10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,          "pw_OnPlayerDeath",         10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,          "pw_OnPlayerDying",         9.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP,       "pw_OnPlayerLevelUp",       10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,        "pw_OnPlayerReSpawn",       10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST,           "pw_OnPlayerRest",          EVENT_PRIORITY_FIRST);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED,   "pw_OnPlayerRestStarted",   EVENT_PRIORITY_LAST);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST_CANCELLED, "pw_OnPlayerRestCancelled", 10.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "pw_OnPlayerRestFinished",  10.0);

        // ----- Timer Events -----
        RegisterEventScripts(oPlugin, H2_SAVE_LOCATION_ON_TIMER_EXPIRE, "pw_SavePCLocation_OnTimerExpire", 10.0);
        RegisterEventScripts(oPlugin, H2_EXPORT_CHAR_ON_TIMER_EXPIRE,   "pw_ExportPCs_OnTimerExpire", 10.0);


        // These are the default bioware events.  This section is a replacement for SquattingMonk's
        //  bw_defaultevents item which intializes the same events.
        if (H2_USE_DEFAULT_BIOWARE_EVENTS)
        {   //TODO add events for horse stuff to override EVENT_PRIORITY_DEFAULT_OPTIONS.
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_ACQUIRE_ITEM,         "x2_mod_def_aqu",   2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_ACTIVATE_ITEM,        "x2_mod_def_act",   2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "x3_mod_def_enter", 2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,          "x2_mod_def_load",  2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,         "nw_o0_death",      EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,         "nw_o0_dying",      EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_EQUIP_ITEM,    "x2_mod_def_equ",   2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,       "nw_o0_respawn",    2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST,          "x2_mod_def_rest",  EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_UNEQUIP_ITEM,  "x2_mod_def_unequ", 2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM,       "x2_mod_def_unaqu", 2.0);

            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_BLOCKED,            "nw_c2_defaulte",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_COMBAT_ROUND_END,   "nw_c2_default3",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_CONVERSATION,       "nw_c2_default4",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DAMAGED,            "nw_c2_default6",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DEATH,              "nw_c2_default7",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DISTURBED,          "nw_c2_default8",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_HEARTBEAT,          "nw_c2_default1",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_PERCEPTION,         "nw_c2_default2",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_PHYSICAL_ATTACKED,  "nw_c2_default5",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_RESTED,             "nw_c2_defaulta",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_SPAWN,              "nw_c2_default9",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_SPELL_CAST_AT,      "nw_c2_defaultb",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_USER_DEFINED,       "nw_c2_defaultd",   EVENT_PRIORITY_DEFAULT);
        }
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
