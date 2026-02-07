/// ----------------------------------------------------------------------------
/// @file   pw_l_unid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  UnID System (library).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_i_unid"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!UNID_SYSTEM_ENABLED)
        return;

    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScript(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM, "unid_OnUnacquireItem");
    RegisterLibraryScript("unid_OnUnacquireItem", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  unid_OnUnacquireItem(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
