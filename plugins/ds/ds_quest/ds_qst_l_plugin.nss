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
    define_quest_demo_gather();
    define_quest_demo_deliver();
    define_quest_demo_speak();



}

void ds_quest_OnQuestAssign()
{
    object oPC = OBJECT_SELF;

    //if (_GetIsPC(oPC) == FALSE)
    //    SetEventState(EVENT_STATE_DENIED);
}

void ds_quest_OnAcquireItem()
{
    object oItem = GetModuleItemAcquired();
    object oPC = GetModuleItemAcquiredBy();

    if (GetIsPC(oPC))
        SignalQuestStepProgress(oPC, GetTag(oItem), QUEST_OBJECTIVE_GATHER);
}

void ds_quest_OnUnacquireItem()
{
    object oItem = GetModuleItemLost();
    object oPC = GetModuleItemLostBy();

    if (GetIsPC(oPC))
        SignalQuestStepRegress(oPC, GetTag(oItem), QUEST_OBJECTIVE_GATHER);
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
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_ACQUIRE_ITEM, "ds_quest_OnAcquireItem");
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM, "ds_quest_OnUnacquireItem");

    // ----- Module Events -----
    RegisterLibraryScript("ds_quest_OnModuleLoad", 1);
    RegisterLibraryScript("ds_quest_OnQuestAssign", 2);
    RegisterLibraryScript("ds_quest_OnAcquireItem", 3);
    RegisterLibraryScript("ds_quest_OnUnacquireItem", 4);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1: ds_quest_OnModuleLoad(); break;
        case 2: ds_quest_OnQuestAssign(); break;
        case 3: ds_quest_OnAcquireItem(); break;
        case 4: ds_quest_OnUnacquireItem(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
