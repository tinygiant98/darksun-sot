// -----------------------------------------------------------------------------
//    File: pw_p_corpse.nss
//  System: PC Corpse (plugin)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_corpse"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!H2_USE_CORPSE_SYSTEM)
        return;

    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    // --- Module Events ---
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "corpse_OnClientEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE, "corpse_OnClientLeave", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "corpse_OnPlayerDeath", 4.0);
    RegisterEventScript(oPlugin, H2_EVENT_ON_PLAYER_LIVES,     "corpse_OnPlayerLives", 4.0);

    int n;

    // --- Module Events ---
    RegisterLibraryScript("corpse_OnClientEnter", n++);
    RegisterLibraryScript("corpse_OnClientLeave", n++);
    RegisterLibraryScript("corpse_OnPlayerDeath", n++);
    RegisterLibraryScript("corpse_OnPlayerLives", n++);
    
    n = 100;

    // --- Tag-based Scripting ---
    RegisterLibraryScript(H2_PC_CORPSE_ITEM, n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) corpse_OnClientEnter();
            else if (nEntry == n++) corpse_OnClientLeave();
            else if (nEntry == n++) corpse_OnPlayerDeath();
            else if (nEntry == n++) corpse_OnPlayerLives();
        } break;

        case 100:
        {
            if      (nEntry == n++) corpse_pccorpseitem();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }       
}
