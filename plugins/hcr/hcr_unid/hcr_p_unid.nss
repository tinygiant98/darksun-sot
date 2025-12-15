// -----------------------------------------------------------------------------
//    File: unid_l_plugin.nss
//  System: UnID Item on Drop (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_unid"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_USE_UNID_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM, "unid_OnUnacquireItem");

    // ----- Module Events -----
    RegisterLibraryScript("unid_OnUnacquireItem", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  unid_OnUnacquireItem(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
