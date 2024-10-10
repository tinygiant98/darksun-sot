/// ----------------------------------------------------------------------------
/// @file   ds_l_trigger.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_data"

#include "pw_i_quest"

/*
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
    string sEvent = GetCurrentEvent(); //GetName(GetCurrentEvent());
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
    string sEvent = GetCurrentEvent(); //GetName(GetCurrentEvent());
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
    int n;
    // n = 0; quest triggers
    RegisterLibraryScript("quest_trigger_1", n++);
    RegisterLibraryScript("quest_trigger_2", n++);

    n = 100;
    // RegisterLibraryScript("trigger_tag", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) quest_trigger_1();
            else if (nEntry == n++) quest_trigger_2();
        } break;
        case 100:
        {
            //if      (nEntry == n++) trigger_tag();
            //else if (nEntry == n++) something_else();
        }
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_trigger.nss");
    }
}