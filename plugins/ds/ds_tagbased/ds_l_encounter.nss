// -----------------------------------------------------------------------------
//    File: ds_l_encounter.nss
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

/* Example
void encounter_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oEncounter = OBJECT_SELF;

    if (sEvent == ENCOUNTER_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();

    }
    else if (sEvent == ENCOUNTER_EVENT_ON_EXHAUSTED)
    {

    }
    else if (sEvent == ENCOUNTER_EVENT_ON_EXIT)
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

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // RegisterLibraryScript("encounter_tag", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  encounter_tag();           break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
