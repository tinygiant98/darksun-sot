/// ----------------------------------------------------------------------------
/// @file   ds_p_core.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Dark Sun PW (plugin)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "ds_i_core"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    //Need to check for pw plugin and this is a sub-plugin
    if (!GetIfPluginExists("ds"))
    {
        object oPlugin = CreatePlugin("ds");
        SetName(oPlugin, "[Plugin] DS :: Core");
        SetDescription(oPlugin,
            "This plugin represents the Dark Sun Core functions.");
        LoadLibrary("ds_rest_l_plugin");
        LoadLibrariesByPattern("ds_l_*");

        //Add module level events
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "ds_OnClientEnter", 4.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_STABLE, "ds_OnModuleStable", 4.0);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_HEARTBEAT, "ds_OnHeartbeat", EVENT_PRIORITY_FIRST);
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_CHAT, "ds_OnPlayerChat", 4.0);
    }

    RegisterLibraryScript("ds_OnClientEnter", 1);
    RegisterLibraryScript("ds_OnModuleStable", 2);
    RegisterLibraryScript("ds_OnHeartbeat", 3);
    RegisterLibraryScript("ds_OnPlayerChat", 4);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  ds_OnClientEnter(); break;
        case 2:  ds_OnModuleStable(); break;
        case 3:  ds_OnHeartbeat(); break;
        case 4:  ds_OnPlayerChat(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
