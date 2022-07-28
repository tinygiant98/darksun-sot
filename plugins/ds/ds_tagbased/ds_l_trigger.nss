// -----------------------------------------------------------------------------
//    File: ds_l_trigger.nss
//  System: Event Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"

#include "quest_i_main"

/* Example
void trigger_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oTrigger = OBJECT_SELF;

    if (sEvent == TRIGGER_EVENT_ON_CLICK)
    {
        oPC = GetClickingObject();

    }
    else if (sEvent == TRIGGER_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();

    }
    else if (sEvent == TRIGGER_EVENT_ON_EXIT)
    {
        oPC = GetExitingObject();

    }
    else if (sEvent == TRIGGER_EVENT_ON_HEARTBEAT)
    {

    }
    else if (sEvent == TRIGGER_EVENT_ON_USER_DEFINED)
    {

    }
}
*/

void quest_trigger_1()
{
    string sEvent = GetCurrentEvent();
    object oPC, oTrigger = OBJECT_SELF;

    if (sEvent == TRIGGER_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();
        if (GetIsPC(oPC))
            SignalQuestStepProgress(oPC, GetTag(oTrigger), QUEST_OBJECTIVE_DISCOVER);
    }
}

void quest_trigger_2()
{
    string sEvent = GetCurrentEvent();
    object oPC, oTrigger = OBJECT_SELF;

    if (sEvent == TRIGGER_EVENT_ON_EXIT)
    {
        oPC = GetExitingObject();
        if (!GetIsPC(oPC))
            DestroyObject(oPC);
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript("quest_trigger_1", 1);
    RegisterLibraryScript("quest_trigger_2", 2);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: quest_trigger_1(); break;
        case 2: quest_trigger_2(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
