// -----------------------------------------------------------------------------
//    File: ds_l_aoe.nss
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
void aoe_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oAOE = OBJECT_SELF;

    if (sEvent == AOE_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();

    }
    else if (sEvent == AOE_EVENT_ON_EXIT)
    {
        oPC = GetExitingObject();

    }
    else if (sEvent == AOE_EVENT_ON_HEARTBEAT)
    {

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // RegisterLibraryScript("aoe_tag", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  aoe_tag();           break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
