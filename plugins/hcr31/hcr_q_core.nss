/// -----------------------------------------------------------------------------
/// @file:  hcr_l_plugin.nss
/// @brief: HCR2 System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_chat"
#include "core_i_framework"
#include "hcr_e_core"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{

    if (GetIfPluginExists("hcr2"))
        return;

    int n = 0;
    RegisterLibraryScript("hcr_LoadQuests",           1);

}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----


        default: CriticalError("Library function " + sScript + " not found");
    }
}
