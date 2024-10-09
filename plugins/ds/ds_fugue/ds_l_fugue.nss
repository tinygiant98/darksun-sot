/// ----------------------------------------------------------------------------
/// @file   ds_l_fugue.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Fugue System (library)
/// ----------------------------------------------------------------------------

/// @brief This library handles the Fugue System child plugin.  It is dependent
///     on, and must be loaded after, the ds management plugin in ds_p_main.

/// This library extends the fugue system by adding an "angel" functionality,
///     giving a dead player a specified chance to revive in the angel's home.
///     Additionally, it houses the dialog files for the angel system.

#include "util_i_library"
#include "util_i_chat"
#include "core_i_framework"
#include "pw_i_const"
#include "ds_e_fugue"

// -----------------------------------------------------------------------------
// Library Dispatch
// -----------------------------------------------------------------------------
void OnLibraryLoad() 
{
    if (!USE_ANGEL_SYSTEM)
        return;

    object oPlugin = GetPlugin("ds");

    // ----- Module Events -----
    // Set priority to 4.1 so it runs just before the PW script.
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
