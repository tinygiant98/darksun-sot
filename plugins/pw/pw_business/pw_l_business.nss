// -----------------------------------------------------------------------------
//    File: bus_l_plugin.nss
//  System: Business and NPC Operations
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "bus_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "business_OnModuleLoad", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_HOUR, "business_OnHour", 4.0);

    // ----- Module Events -----
    RegisterLibraryScript("business_OnModuleLoad", 0);
    RegisterLibraryScript("business_OnHour", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 0:  business_OnModuleLoad();  break;
        case 1:  business_OnHour(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
