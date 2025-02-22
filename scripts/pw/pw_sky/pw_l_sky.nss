/// ----------------------------------------------------------------------------
/// @file   pw_l_sky.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Sky Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"
#include "util_i_library"

#include "pw_c_sky"
#include "pw_e_sky"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!SKY_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScripts(oPlugin, AREA_EVENT_ON_ENTER, "sky_OnAreaEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_HEARTBEAT, "sky_OnModuleHeartbeat");

    int n;
    RegisterLibraryScript("sky_OnModuleHeartbeat",  n++);
    RegisterLibraryScript("torch_OnSpellHook",    n++);
    RegisterLibraryScript("torch_OnClientLeave",  n++);

    n = 100;
    //int i; for (i = 0; i < CountList(LANTERN_TAG); i++)
    //    RegisterLibraryScript(GetListItem(LANTERN_TAG, i), n++);
    
    n = 200;
    //for (i = 0; i < CountList(TORCH_TAG); i++)
    //    RegisterLibraryScript(GetListItem(TORCH_TAG, i), n++);

    n = 300;
    //for (i = 0; i < CountList(OILFLASK_TAG); i++)
    //    RegisterLibraryScript(GetListItem(OILFLASK_TAG, i), n++);
    
    n = 400;
    //RegisterLibraryScript("torch_OnTimerExpire", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) sky_OnModuleHeartbeat();
            //else if (nEntry == n++) torch_OnSpellHook();
            //else if (nEntry == n++) torch_OnClientLeave();
        } break;
        case 100:
        case 200:
            //torch_torch();
            break;
        case 300:
            //torch_oilflask();
            break;
        case 400:
        {
            //if     (nEntry == n++) torch_OnTimerExpire();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_torch.nss");
    }
}
