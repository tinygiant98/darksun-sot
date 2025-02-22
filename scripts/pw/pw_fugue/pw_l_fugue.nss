/// ----------------------------------------------------------------------------
/// @file   pw_l_fugue.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Fugue Library (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "pw_e_fugue"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!FUGUE_ACTIVE)
        return;
    
    object oPlugin = GetPlugin("pw");
    if (!GetIsObjectValid(oPlugin))
    {
        CriticalError("Fugue library could not be loaded; PW plugin not found.");
        return;
    }

    // ----- Module Events -----      
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "fugue_OnModuleLoad", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "fugue_OnClientEnter", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "fugue_OnPlayerDeath", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "fugue_OnPlayerDying", 4.0);
    RegisterEventScript(oPlugin, CHAT_PREFIX + "!fugue", "fugue_OnPlayerChat");

    int n;
    // ----- Module Events -----
    RegisterLibraryScript("fugue_OnModuleLoad",  n++);
    RegisterLibraryScript("fugue_OnClientEnter", n++);
    RegisterLibraryScript("fugue_OnPlayerDeath", n++);
    RegisterLibraryScript("fugue_OnPlayerDying", n++);
    RegisterLibraryScript("fugue_OnAreaExit",    n++);
    RegisterLibraryScript("fugue_OnPlayerChat",  n++);

    LoadLibrary("pw_d_fugue");
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            // Module Events
            if      (nEntry == n++) fugue_OnModuleLoad();
            else if (nEntry == n++) fugue_OnClientEnter();
            else if (nEntry == n++) fugue_OnPlayerDeath();
            else if (nEntry == n++) fugue_OnPlayerDying();
            else if (nEntry == n++) fugue_OnAreaExit();
            else if (nEntry == n++) fugue_OnPlayerChat();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_fugue.nss");
    }
}
