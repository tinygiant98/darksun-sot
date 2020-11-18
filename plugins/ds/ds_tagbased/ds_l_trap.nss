// -----------------------------------------------------------------------------
//    File: ds_l_trap.nss
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
void trap_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oTrap = OBJECT_SELF;

    if (sEvent == TRAP_EVENT_ON_DISARM)
    {
        oPC = GetLastDisarmed();

    }
    else if (sEvent == TRAP_EVENT_ON_TRIGGERED)
    {
        oPC = GetEnteringObject();

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // RegisterLibraryScript("trap_tag", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  trap_tag();           break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
