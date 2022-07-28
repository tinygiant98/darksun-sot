// -----------------------------------------------------------------------------
//    File: tr_l_plugin.nss
//  System: Travel (library)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "tr_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("ds");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, AREA_EVENT_ON_ENTER,              "tr_OnAreaEnter");
    RegisterEventScript(oPlugin, AREA_EVENT_ON_EXIT,               "tr_OnAreaExit");
    RegisterEventScript(oPlugin, TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE, "tr_encounter_OnTimerExpire");

    // ----- Module Events -----
    RegisterLibraryScript("tr_encounter_OnTimerExpire", 1);
    RegisterLibraryScript("tr_OnAreaEnter",             2);
    RegisterLibraryScript("tr_OnAreaExit",              3);
    RegisterLibraryScript("tr_encounter_OnAOEEnter",    4);
    RegisterLibraryScript("tr_encounter_OnAreaExit",    5);
    RegisterLibraryScript("tr_encounter_OnPlayerDeath", 6);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: tr_encounter_OnTimerExpire(); break;
        case 2: tr_OnAreaEnter();             break;
        case 3: tr_OnAreaExit();              break;
        case 4: tr_encounter_OnAOEEnter();    break;
        case 5: tr_encounter_OnAreaExit();    break;
        case 6: tr_encounter_OnPlayerDeath(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
