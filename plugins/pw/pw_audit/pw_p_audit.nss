/// ----------------------------------------------------------------------------
/// @file   pw_p_audit.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Audit System (plugin).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_e_audit"

// -----------------------------------------------------------------------------
//                           Library Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!AUDIT_ENABLE_SYSTEM)
        return;

    if (!GetIfPluginExists("audit"))
    {
        object oPlugin = CreatePlugin("audit");
        SetName(oPlugin, "[Plugin] AUDIT :: Core");
        //SetDescription(oPlugin,
        //    "This plugin controls audit collection and reporting.");
        SetDebugPrefix(HexColorString("[AUDIT]", COLOR_CRIMSON));

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,          "audit_OnModuleLoad",         9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "audit_OnClientEnter",        9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,         "audit_OnClientLeave",        10.0);
        RegisterEventScript(oPlugin, "MODULE_EVENT_ON_MODULE_POST",        "audit_OnModulePOST",         9.0);
        RegisterEventScript(oPlugin, CHAT_PREFIX + "!audit",               "audit_OnPlayerChat",         10.0);

        RegisterEventScript(oPlugin, AUDIT_EVENT_FLUSH_ON_TIMER_EXPIRE,    "audit_Flush_OnTimerExpire",  10.0);
        
        int n;
        RegisterLibraryScript("audit_OnModuleLoad",  n++);
        RegisterLibraryScript("audit_OnClientEnter", n++);
        RegisterLibraryScript("audit_OnClientLeave", n++);
        RegisterLibraryScript("audit_OnModulePOST",  n++);
        RegisterLibraryScript("audit_OnPlayerChat",  n++);

        n = 100;
        RegisterLibraryScript("audit_Flush_OnTimerExpire", n++);
    }
}

// -----------------------------------------------------------------------------
//                           Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) audit_OnModuleLoad();
            else if (nEntry == n++) audit_OnClientEnter();
            else if (nEntry == n++) audit_OnClientLeave();
            else if (nEntry == n++) audit_OnModulePOST();
            else if (nEntry == n++) audit_OnPlayerChat();
        } break;

        case 100:
        {
            if      (nEntry == n++) audit_Flush_OnTimerExpire();
        } break;

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
