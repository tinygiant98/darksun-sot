/// ----------------------------------------------------------------------------
/// @file   ds_l_fugue.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Fugue System (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_chat"

#include "pw_i_const"
#include "ds_e_fugue"

// -----------------------------------------------------------------------------
// Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad() 
{
    if (!ANGEL_ACTIVE)
        return;

    object oPlugin = GetPlugin("ds");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "ds_fug_OnPlayerDeath", 4.1);

    // ----- Module Scripts -----
    RegisterLibraryScript("ds_fug_OnPlayerDeath", 1);

    LoadLibrary("ds_d_fugue");
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: ds_fug_OnPlayerDeath(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
