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

    if (!GetIfPluginExists("eventman"))
    {
        object oPlugin = CreatePlugin("eventman");
        SetName(oPlugin, "[Plugin] EVENTMAN :: Core");
        SetDescription(oPlugin,
            "High level event management and default event registration.");
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

        /// @note The core framework prevents normally bioware event handlers from firing.  In the rare instance that no
        ///     event handlers are registered for a default nwn event, these handlers can be registered to allow at
        ///     least the normal default behavior to occur.
        if (EVENTMAN_USE_DEFAULT_BIOWARE_EVENTS)
        {   //TODO add events for horse stuff to override EVENT_PRIORITY_DEFAULT_OPTIONS.
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_ACQUIRE_ITEM,         "x2_mod_def_aqu",   2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_ACTIVATE_ITEM,        "x2_mod_def_act",   2.0);
            //RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "x3_mod_def_enter", 2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,          "x2_mod_def_load",  2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,         "nw_o0_death",      EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,         "nw_o0_dying",      EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_EQUIP_ITEM,    "x2_mod_def_equ",   2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,       "nw_o0_respawn",    2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST,          "x2_mod_def_rest",  EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_UNEQUIP_ITEM,  "x2_mod_def_unequ", 2.0);
            RegisterEventScripts(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM,       "x2_mod_def_unaqu", 2.0);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_BLOCKED,            "nw_c2_defaulte",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_COMBAT_ROUND_END,   "nw_c2_default3",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_CONVERSATION,       "nw_c2_default4",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DAMAGED,            "nw_c2_default6",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DEATH,              "nw_c2_default7",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DISTURBED,          "nw_c2_default8",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_HEARTBEAT,          "nw_c2_default1",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_PERCEPTION,         "nw_c2_default2",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_PHYSICAL_ATTACKED,  "nw_c2_default5",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_RESTED,             "nw_c2_defaulta",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_SPAWN,              "nw_c2_default9",   EVENT_PRIORITY_DEFAULT);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_SPELL_CAST_AT,      "nw_c2_defaultb",   EVENT_PRIORITY_LAST);
            RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_USER_DEFINED,       "nw_c2_defaultd",   EVENT_PRIORITY_LAST);
        }
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
            else if (nEntry == n++) eventman_OnPlayerRestFinished();
        } break;

        case 100:
        {
            //if      (nEntry == n++) eventman_Sync_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
