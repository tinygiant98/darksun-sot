/// ----------------------------------------------------------------------------
/// @file   pw_l_crowd.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Crowd Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_e_crowd"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------
void OnLibraryLoad()
{
    if (!CROWD_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,  "crowd_OnModuleLoad");

    // ----- Area Events -----
    RegisterEventScripts(oPlugin, AREA_EVENT_ON_ENTER,          "crowd_OnAreaEnter");
    RegisterEventScripts(oPlugin, AREA_EVENT_ON_EXIT,           "crowd_OnAreaExit");
 
    // ----- Timer Events -----
    RegisterEventScripts(oPlugin, CROWD_EVENT_ON_TIMER_EXPIRED, "crowd_OnTimerExpired");

    // ----- Module Events -----
    RegisterLibraryScript("crowd_OnModuleLoad",    1);

    // ----- Area Events -----
    RegisterLibraryScript("crowd_OnAreaEnter",     2);
    RegisterLibraryScript("crowd_OnAreaExit",      3);

    // ----- Creature Events -----
    RegisterLibraryScript("crowd_OnCreatureDeath", 4);

    // ----- Timer Events -----
    RegisterLibraryScript("crowd_OnTimerExpired",  5);

    LoadLibrary("pw_d_crowd");
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1: crowd_OnModuleLoad();     break;

        // ----- Area Events -----
        case 2: crowd_OnAreaEnter();      break;
        case 3: crowd_OnAreaExit();       break;

        // ----- Creature Events -----
        case 4 : crowd_OnCreatureDeath(); break;

        // ----- Timer Events -----
        case 5: crowd_OnTimerExpired();   break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_crowd.nss");
    }
}
