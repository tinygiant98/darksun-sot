// -----------------------------------------------------------------------------
//    File: ds_l_quest.nss
//  System: Quest Persistent World Subsystem
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "util_i_library"
#include "core_i_framework"
#include "quest_i_demo"

void ds_quest_OnModuleLoad()
{
    // Load most of the module quests here.
    // Sample quests for start area are located here
    define_quest_demo_discover();
    define_quest_demo_kill();
    define_quest_demo_protect();
    define_quest_demo_gather();
    define_quest_demo_deliver();
    define_quest_demo_speak();
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("ds");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "ds_quest_OnModuleLoad", 3.0);

    // ----- Module Events -----
    RegisterLibraryScript("ds_quest_OnModuleLoad", 1);

    LoadLibrary("quest_d_demo");
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1: ds_quest_OnModuleLoad(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
