/// ----------------------------------------------------------------------------
/// @file   pw_l_torch.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Torch Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_e_torch"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!TORCH_ACTIVE)
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_SPELLHOOK,    "torch_OnSpellHook",   4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "torch_OnClientEnter", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE, "torch_OnClientLeave", 4.0);

    // ----- Timer Events -----
    RegisterEventScripts(oPlugin, TORCH_EVENT_ON_TIMER_EXPIRE, "torch_OnTimerExpire", 4.0);

    int n;
    // ----- Module Events -----
    RegisterLibraryScript("torch_OnClientEnter",  n++);
    RegisterLibraryScript("torch_OnSpellHook",    n++);
    RegisterLibraryScript("torch_OnClientLeave",  n++);

    // ----- Tag-based Scripting -----
    n = 100;
    int i; for (i = 0; i < CountList(LANTERN_TAG); i++)
        RegisterLibraryScript(GetListItem(LANTERN_TAG, i), n++);
    
    n = 200;
    for (i = 0; i < CountList(TORCH_TAG); i++)
        RegisterLibraryScript(GetListItem(TORCH_TAG, i), n++);

    n = 300;
    for (i = 0; i < CountList(OILFLASK_TAG); i++)
        RegisterLibraryScript(GetListItem(OILFLASK_TAG, i), n++);
    
    n = 400;
    // ----- Timer Events -----
    RegisterLibraryScript("torch_OnTimerExpire", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) torch_OnClientEnter();
            else if (nEntry == n++) torch_OnSpellHook();
            else if (nEntry == n++) torch_OnClientLeave();
        } break;
        case 100:
        case 200:
            torch_torch();
            break;
        case 300:
            torch_oilflask();
            break;
        case 400:
        {
            if     (nEntry == n++) torch_OnTimerExpire();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_torch.nss");
    }
}
