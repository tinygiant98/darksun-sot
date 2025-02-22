/// ----------------------------------------------------------------------------
/// @file   ds_l_trap.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_data"

/*
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
    int n;
    // RegisterLibraryScript("trap_tag", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            //if      (nEntry == n++) trap_tag();
            //else if (nEntry == n++) something_else();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_trap.nss");
    }
}

