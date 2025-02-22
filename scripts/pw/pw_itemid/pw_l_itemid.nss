/// ----------------------------------------------------------------------------
/// @file   pw_l_itemid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Item Identification Library (library)
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_e_itemid"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!ITEMID_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM, "itemid_OnUnacquireItem");
    RegisterLibraryScript("itemid_OnUnacquireItem", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  itemid_OnUnacquireItem(); break;
        default: CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
            "not found in pw_l_unid.nss");
    }
}
