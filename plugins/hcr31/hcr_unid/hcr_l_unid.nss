/// -----------------------------------------------------------------------------
/// @file:  hcr_l_unid.nss
/// @brief: HCR2 UnID System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_unid"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_UNID_LOAD_PLUGIN)
        return;

    if (!GetIfPluginExists("hcr2") || !H2_UNID_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_unid");
    SetName(oPlugin, "[Plugin] HCR2 :: UnID System");
    SetDescription(oPlugin, "HCR2 UnID System");
    SetDebugPrefix(HexColorString("[HCR2 UnID]", COLOR_YELLOW_LIGHT), oPlugin);

    // Module Events
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM, "unid_OnUnacquireItem");

    // Module Events
    RegisterLibraryScript("unid_OnUnacquireItem", 1);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // Module Events
        case 1:  unid_OnUnacquireItem(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
