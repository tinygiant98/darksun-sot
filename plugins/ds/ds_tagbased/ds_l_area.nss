/// ----------------------------------------------------------------------------
/// @file   ds_l_area.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_data"

/*
void area_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oArea = OBJECT_SELF;

    if (sEvent == AREA_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();

    }
    else if (sEvent == AREA_EVENT_ON_EXIT)
    {
        oPC = GetExitingObject();

    }
    else if (sEvent == AREA_EVENT_ON_HEARTBEAT)
    {

    }
    else if (sEvent == AREA_EVENT_ON_USER_DEFINED)
    {
        int nEvent = GetUserDefinedEventNumber();

    }
    else if (sEvent == AREA_EVENT_ON_EMPTY)
    {

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    int n;
    // RegisterLibraryScript("area_tag", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            //if      (nEntry == n++) area_tag();
            //else if (nEntry == n++) something_else();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_area.nss");
    }
}
