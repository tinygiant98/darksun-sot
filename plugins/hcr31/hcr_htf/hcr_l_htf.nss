/// -----------------------------------------------------------------------------
/// @file:  hcr_l_htf.nss
/// @brief: HCR2 Hunger Thirst Fatigue System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_htf"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_USE_HUNGERTHIRST_SYSTEM && !H2_USE_FATIGUE_SYSTEM) 
        return;

    if (!GetIfPluginExists("hcr2") || !H2_HTF_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_htf");
    SetName(oPlugin, "[Plugin] HCR2 :: Hunger Thirst Fatigue System");
    SetDescription(oPlugin, "HCR2 HTF System");
    SetDebugPrefix(HexColorString("[HCR2 HTF]", COLOR_GREEN_LIGHT), oPlugin);

    if (H2_USE_HUNGERTHIRST_SYSTEM || H2_USE_FATIGUE_SYSTEM)
    {
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,          "htf_OnModuleLoad",                  1.0);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_USER_DEFINED,       "htf_OnCreatureUserDefined",         8.0);
    }

    if (H2_USE_HUNGERTHIRST_SYSTEM)
    {
        // ----- Module Events -----
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,          "hungerthirst_OnModuleLoad",         4.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "hungerthirst_OnClientEnter",        4.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,         "hungerthirst_OnPlayerDeath",        4.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED, "hungerthirst_OnPlayerRestFinished", 4.0);
        RegisterEventScript(oPlugin, TRIGGER_EVENT_ON_ENTER,               "hungerthirst_OnTriggerEnter",       4.0);
        RegisterEventScript(oPlugin, TRIGGER_EVENT_ON_EXIT,                "hungerthirst_OnTriggerExit",        4.0);
        
        // ----- Timer Events -----
        RegisterEventScript(oPlugin, H2_HT_ON_TIMER_EXPIRE,                "htf_ht_OnTimerExpire",              4.0);
    }

    if (H2_USE_FATIGUE_SYSTEM)
    {
        // ----- Module Events -----
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "fatigue_OnClientEnter",             4.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED, "fatigue_OnPlayerRestFinished",      4.0);
        
        // ----- Timer Events -----
        RegisterEventScript(oPlugin, H2_FATIGUE_ON_TIMER_EXPIRE,           "htf_f_OnTimerExpire",               4.0);
    }

    if (H2_USE_HUNGERTHIRST_SYSTEM || H2_USE_FATIGUE_SYSTEM)
    {
        RegisterLibraryScript("htf_OnModuleLoad",                   13);
        RegisterLibraryScript("htf_OnCreatureUserDefined",          14);
    }

    if (H2_USE_HUNGERTHIRST_SYSTEM)
    {
        // ----- Module Events -----
        RegisterLibraryScript("hungerthirst_OnModuleLoad",          0);
        RegisterLibraryScript("hungerthirst_OnClientEnter",         1);
        RegisterLibraryScript("hungerthirst_OnPlayerDeath",         2);
        RegisterLibraryScript("hungerthirst_OnPlayerRestFinished",  3);
        RegisterLibraryScript("hungerthirst_OnTriggerEnter",        11);
        RegisterLibraryScript("hungerthirst_OnTriggerExit",         12);
        
        // ----- Timer Events -----
        RegisterLibraryScript("htf_ht_OnTimerExpire",               8);
        RegisterLibraryScript("htf_drunk_OnTimerExpire",            10);
    }

    if (H2_USE_FATIGUE_SYSTEM)
    {
        // ----- Module Events -----
        RegisterLibraryScript("fatigue_OnClientEnter",              4);
        RegisterLibraryScript("fatigue_OnPlayerRestFinished",       5);

        // ----- Timer Events -----
        RegisterLibraryScript("htf_f_OnTimerExpire",                9);
    }

    // ----- Tag-based Scripting -----
    RegisterLibraryScript(H2_HT_CANTEEN,                            6);
    RegisterLibraryScript(H2_HT_FOODITEM,                           7);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    if (!H2_USE_HUNGERTHIRST_SYSTEM && !H2_USE_FATIGUE_SYSTEM) 
    {
        CriticalError("Library function called on inactive system (HTF).");
        return;
    }

    switch (nEntry)
    {
        // ----- Module Events -----
        case 0:  hungerthirst_OnModuleLoad();         break;
        case 1:  hungerthirst_OnClientEnter();        break;
        case 2:  hungerthirst_OnPlayerDeath();        break;
        case 3:  hungerthirst_OnPlayerRestFinished(); break;
        case 4:  fatigue_OnClientEnter();             break;
        case 5:  fatigue_OnPlayerRestFinished();      break;
        case 11: hungerthirst_OnTriggerEnter();       break;
        case 12: hungerthirst_OnTriggerExit();        break;
        case 13: htf_OnModuleLoad();                  break;
        case 14: htf_OnCreatureUserDefined();         break;
        case EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM: htf_fooditem(); break;

        // ----- Tag-based Scripting -----
        case 6:  htf_canteen();                       break;
        case 7:  htf_fooditem();                      break;

        // ----- Timer Events -----
        case 8:  htf_ht_OnTimerExpire();              break;
        case 9:  htf_f_OnTimerExpire();               break;
        case 10: htf_drunk_OnTimerExpire();           break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
