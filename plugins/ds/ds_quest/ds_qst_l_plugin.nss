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

#include "util_i_data"
#include "util_i_library"
#include "core_i_framework"
#include "ds_qst_i_main"

void ds_quest_OnModuleLoad()
{
    // Load most of the module quests here.
    // Sample quests for start area are located here
    define_quest_demo_discover();
    define_quest_demo_kill();
    define_quest_demo_protect();



}

void ds_quest_OnQuestAssign()
{
    object oPC = OBJECT_SELF;

    if (_GetIsPC(oPC) == FALSE)
        SetEventState(EVENT_STATE_DENIED);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("ds");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "ds_quest_OnModuleLoad", 3.0);
    RegisterEventScripts(oPlugin, QUEST_EVENT_ON_ASSIGN, "ds_quest_OnQuestAssign");

    // ----- Module Events -----
    RegisterLibraryScript("ds_quest_OnModuleLoad", 1);
    RegisterLibraryScript("ds_quest_OnQuestAssign", 2);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1: ds_quest_OnModuleLoad(); break;
        case 2: ds_quest_OnQuestAssign(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
