/// ----------------------------------------------------------------------------
/// @file   pw_l_htf.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Hunger, Thirst, Fatigue Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_k_htf"
#include "pw_e_htf"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("pw");

    if (!HUNGERTHIRST_ACTIVE && !FATIGUE_ACTIVE) 
        return;

    if (HUNGERTHIRST_ACTIVE)
    {
        // Module Events
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "hungerthirst_OnClientEnter",        4.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,         "hungerthirst_OnPlayerDeath",        4.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED, "hungerthirst_OnPlayerRestFinished", 4.0);
        RegisterEventScripts(oPlugin, TRIGGER_EVENT_ON_ENTER,               "hungerthirst_OnTriggerEnter",       4.0);
        RegisterEventScripts(oPlugin, TRIGGER_EVENT_ON_EXIT,                "hungerthirst_OnTriggerExit",        4.0);
        
        // ----- Timer Events
        RegisterEventScripts(oPlugin, H2_HT_ON_TIMER_EXPIRE,                "htf_ht_OnTimerExpire",              4.0);
    }

    if (FATIGUE_ACTIVE)
    {
        // ----- Module Events
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "fatigue_OnClientEnter",             4.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED, "fatigue_OnPlayerRestFinished",      4.0);
        
        // ----- Timer Events
        RegisterEventScripts(oPlugin, H2_FATIGUE_ON_TIMER_EXPIRE,           "htf_f_OnTimerExpire",               4.0);
    }

    int n = 100;
    if (HUNGERTHIRST_ACTIVE)
    {
        // Module Events
        RegisterLibraryScript("hungerthirst_OnClientEnter",         n++);
        RegisterLibraryScript("hungerthirst_OnPlayerDeath",         n++);
        RegisterLibraryScript("hungerthirst_OnPlayerRestFinished",  n++);
        RegisterLibraryScript("hungerthirst_OnTriggerEnter",        n++);
        RegisterLibraryScript("hungerthirst_OnTriggerExit",         n++);
        
        // Timer Events
        RegisterLibraryScript("htf_ht_OnTimerExpire",               n++);
        RegisterLibraryScript("htf_drunk_OnTimerExpire",            n++);
    }

    n = 200;
    if (FATIGUE_ACTIVE)
    {
        // Module Events
        RegisterLibraryScript("fatigue_OnClientEnter",              n++);
        RegisterLibraryScript("fatigue_OnPlayerRestFinished",       n++);

        // Timer Events
        RegisterLibraryScript("htf_f_OnTimerExpire",                n++);
    }

    n = 300;
    // Tag-based Scripting
    RegisterLibraryScript(H2_HT_CANTEEN,                            n++);
    RegisterLibraryScript(H2_HT_FOODITEM,                           n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 100:
        {
            // Module Events
            if      (nEntry == n++) hungerthirst_OnClientEnter();
            else if (nEntry == n++) hungerthirst_OnPlayerDeath();
            else if (nEntry == n++) hungerthirst_OnPlayerRestFinished();
            else if (nEntry == n++) hungerthirst_OnTriggerEnter();
            else if (nEntry == n++) hungerthirst_OnTriggerExit();

            // Timer Events
            else if (nEntry == n++) htf_ht_OnTimerExpire();
            else if (nEntry == n++) htf_drunk_OnTimerExpire();
        } break;
        case 200:
        {
            // Module Events
            if      (nEntry == n++) fatigue_OnClientEnter();
            else if (nEntry == n++) fatigue_OnPlayerRestFinished();

            // Timer Events
            else if (nEntry == n++) htf_f_OnTimerExpire();
        } break;
        case 300:
        {
            // Tag-based Scripting
            if      (nEntry == n++) htf_canteen();
            else if (nEntry == n++) htf_fooditem();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_htf.nss");
    }
}
