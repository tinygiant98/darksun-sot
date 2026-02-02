/// ----------------------------------------------------------------------------
/// @file   pw_l_torch.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Torch System (library).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_i_torch"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

//TODO on login, replace all player torches with h2 torches

void OnLibraryLoad()
{
    if (!TORCH_SYSTEM_ENABLED)
        return;

        if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScript(oPlugin, MODULE_EVENT_ON_SPELLHOOK,   "torch_OnSpellHook",   4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "torch_OnClientEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,  "torch_OnClientLeave", 4.0);

    RegisterEventScript(oPlugin, TORCH_EVENT_ON_TIMER_EXPIRE, "torch_OnTimerExpire", 4.0);

    int n;
    RegisterLibraryScript("torch_OnClientEnter", n++);
    RegisterLibraryScript("torch_OnClientLeave", n++);
    RegisterLibraryScript("torch_OnSpellHook",   n++);    

    n = 100;
    RegisterLibraryScript(TORCH_LANTERN_RESREF,  n++);
    RegisterLibraryScript(TORCH_TORCH_RESREF,    n++);
    RegisterLibraryScript(TORCH_OILFLASK_RESREF, n++);

    n = 200;
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
            else if (nEntry == n++) torch_OnClientLeave();
            else if (nEntry == n++) torch_OnSpellHook();
        } break;

        case 100:
        {
            if      (nEntry == n++) torch_torch();
            else if (nEntry == n++) torch_torch();
            else if (nEntry == n++) torch_oilflask();
        } break;

        case 200:
        {
            if      (nEntry == n++) torch_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}