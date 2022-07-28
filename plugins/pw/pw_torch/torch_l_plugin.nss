// -----------------------------------------------------------------------------
//    File: torch_l_plugin.nss
//  System: Torch and Lantern (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "torch_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

//TODO on login, replace all player torches with h2 torches

void OnLibraryLoad()
{
    if (!H2_USE_TORCH_SYSTEM)
        return;

        if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_SPELLHOOK,   "torch_OnSpellHook",   4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "torch_OnClientEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,  "torch_OnClientLeave", 4.0);

    // ----- Timer Events -----
    RegisterEventScript(oPlugin, TORCH_EVENT_ON_TIMER_EXPIRE, "torch_OnTimerExpire", 4.0);

    // ----- Module Events -----
    RegisterLibraryScript("torch_OnClientEnter", 0);
    RegisterLibraryScript("torch_OnSpellHook",   1);
    RegisterLibraryScript("torch_OnClientLeave",  10);

    // ----- Tag-based Scripting -----
    RegisterLibraryScript(H2_LANTERN,            2);
    RegisterLibraryScript(H2_TORCH,              3);
    RegisterLibraryScript(H2_OILFLASK,           4);

    // ----- Timer Events -----
    RegisterLibraryScript("torch_OnTimerExpire", 5);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 0: torch_OnClientEnter(); break;
        case 1: torch_OnSpellHook();   break;
        case 10: torch_OnClientLeave();  break;

        // ----- Tag-based Scripting -----
        case 2: 
        case 3: torch_torch();         break;
        case 4: torch_oilflask();      break;

        // ----- Timer Events -----
        case 5: torch_OnTimerExpire(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
