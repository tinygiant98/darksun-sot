/// -----------------------------------------------------------------------------
/// @file:  hcr_l_torch.nss
/// @brief: HCR2 Torch System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_torch"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_TORCH_LOAD_PLUGIN)
        return;

    if (!GetIfPluginExists("hcr2") || !H2_TORCH_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_torch");
    SetName(oPlugin, "[Plugin] HCR2 :: Torch System");
    SetDescription(oPlugin, "HCR2 Torch System");
    SetDebugPrefix(HexColorString("[HCR2 Torch]", COLOR_ORANGE), oPlugin);

    // Module Events
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_SPELLHOOK,   "torch_OnSpellHook",   4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "torch_OnClientEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,  "torch_OnClientLeave", 4.0);

    // Timer Events
    RegisterEventScript(oPlugin, TORCH_EVENT_ON_TIMER_EXPIRE, "torch_OnTimerExpire", 4.0);

    // Module Events
    RegisterLibraryScript("torch_OnClientEnter", 0);
    RegisterLibraryScript("torch_OnSpellHook",   1);
    RegisterLibraryScript("torch_OnClientLeave",  10);

    // Tag-based Scripting
    RegisterLibraryScript(H2_LANTERN,            2);
    RegisterLibraryScript(H2_TORCH,              3);
    RegisterLibraryScript(H2_OILFLASK,           4);

    // Timer Events
    RegisterLibraryScript("torch_OnTimerExpire", 5);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // Module Events
        case 0: torch_OnClientEnter(); break;
        case 1: torch_OnSpellHook();   break;
        case 10: torch_OnClientLeave();  break;

        // Tag-based Scripting
        case 2: 
        case 3: torch_torch();         break;
        case 4: torch_oilflask();      break;

        // Timer Events
        case 5: torch_OnTimerExpire(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
