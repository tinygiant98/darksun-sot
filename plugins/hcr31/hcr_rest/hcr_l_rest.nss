/// -----------------------------------------------------------------------------
/// @file:  hcr_l_rest.nss
/// @brief: HCR2 Rest System (library)
/// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "hcr_i_rest"

// -----------------------------------------------------------------------------
//                              Plugin Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("hcr2") || !H2_REST_LOAD_PLUGIN)
        return;

    object oPlugin = CreatePlugin("hcr2_rest");
    SetName(oPlugin, "[Plugin] HCR2 :: Rest System");
    SetDescription(oPlugin, "HCR2 Rest System");
    SetDebugPrefix(HexColorString("[HCR2 Rest]", COLOR_GOLDENROD_LIGHT), oPlugin);

    // ----- Module Events -----
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_CANCELLED, "rest_OnPlayerRestCancelled", 4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "rest_OnPlayerRestFinished",  4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED,   "rest_OnPlayerRestStarted",   4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "rest_OnClientEnter",         4.0);
    RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "rest_OnModuleLoad",          4.0);

    // ----- Custom Events -----
    if (H2_REQUIRE_REST_TRIGGER_OR_CAMPFIRE)
    {
        RegisterEventScript(oPlugin, REST_EVENT_ON_TRIGGER_ENTER,       "rest_OnTriggerEnter",        9.0);
        RegisterEventScript(oPlugin, REST_EVENT_ON_TRIGGER_EXIT,        "rest_OnTriggerExit",         9.0);
    }

    // ----- Module Events -----
    RegisterLibraryScript("rest_OnPlayerRestCancelled", 1);
    RegisterLibraryScript("rest_OnPlayerRestFinished",  2);
    RegisterLibraryScript("rest_OnPlayerRestStarted",   3);
    RegisterLibraryScript("rest_OnClientEnter",         0);
    RegisterLibraryScript("rest_OnModuleLoad",          7);

    // ----- Custom Events -----
    if (H2_REQUIRE_REST_TRIGGER_OR_CAMPFIRE)
    {
        RegisterLibraryScript("rest_OnTriggerEnter",    4);
        RegisterLibraryScript("rest_OnTriggerExit",     5);
    }   

    // ----- Tag Based Scripting -----
    RegisterLibraryScript(H2_FIREWOOD,                  6);

    // Dialog
    LoadLibrary("hcr_d_rest");
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1: rest_OnPlayerRestCancelled(); break;
        case 2: rest_OnPlayerRestFinished();  break;
        case 3: rest_OnPlayerRestStarted();   break;
        case 0: rest_OnClientEnter();         break;
        case 7: rest_OnModuleLoad();          break;

        // ----- Custom Events -----
        case 4: rest_OnTriggerEnter();        break;
        case 5: rest_OnTriggerExit();         break;

        // ----- Tag-based Scripting
        case 6: rest_firewood();              break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
