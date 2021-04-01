// -----------------------------------------------------------------------------
//    File: ds_qst_l_plugin.nss
//  System: Quest Persistent World Subsystem
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "ds_qst_i_main"

void ds_quest_OnModuleLoad()
{
    // Load most of the module quests here.
    // Sample quests for start area are located here


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
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  ds_quest_OnModuleLoad(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
