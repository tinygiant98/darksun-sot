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

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // RegisterLibraryScript("trigger_tag", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  trigger_tag();           break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
