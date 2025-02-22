// -----------------------------------------------------------------------------
//    File: pw_l_webhook.nss
//  System: Webhooks (library)
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pw_e_webhook"
#include "util_i_chat"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!USE_WEBHOOK_PLUGIN)
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "webhook_OnModuleLoad", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "webhook_OnClientEnter", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE, "webhook_OnClientLeave", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_SHUTDOWN, "webhook_OnModuleShutdown", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_STABLE, "webhook_OnModuleStable", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "webhook_OnPlayerDeath", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "webhook_OnPlayerDying", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN, "webhook_OnPlayerReSpawn", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP, "webhook_OnPlayerLevelUp", 1.0);
    RegisterEventScripts(oPlugin, CHAT_PREFIX + "!webhook", "webhook_OnPlayerChat", 1.0);
    RegisterEventScripts(oPlugin, "OnPlayerChatCommand", "webhook_OnPlayerChatCommand", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_HOUR, "webhook_OnHour", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_DEBUG, "webhook_OnModuleDebug", 1.0);

    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_ACCEPT", "webhook_OnQuestEvent", 3.5);
    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_ADVANCE", "webhook_OnQuestEvent", 3.5);
    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_COMPLETE", "webhook_OnQuestEvent", 3.5);
    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_FAIL", "webhook_OnQuestEvent", 3.5);

    int n;
    RegisterLibraryScript("webhook_OnModuleLoad",        n++);
    RegisterLibraryScript("webhook_OnClientEnter",       n++);
    RegisterLibraryScript("webhook_OnClientLeave",       n++);
    RegisterLibraryScript("webhook_OnModuleShutdown",    n++);
    RegisterLibraryScript("webhook_OnModuleStable",      n++);
    RegisterLibraryScript("webhook_OnPlayerDeath",       n++);
    RegisterLibraryScript("webhook_OnPlayerDying",       n++);
    RegisterLibraryScript("webhook_OnReSpawn",           n++);
    RegisterLibraryScript("webhook_OnLevelUp",           n++);
    RegisterLibraryScript("webhook_OnPlayerChat",        n++);
    RegisterLibraryScript("webhook_OnPlayerChatCommand", n++);
    RegisterLibraryScript("webhook_OnModuleDebug",       n++);
    RegisterLibraryScript("webhook_OnHour",              n++);

    RegisterLibraryScript("webhook_OnQuestEvent",        n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) webhook_OnModuleLoad();
            else if (nEntry == n++) webhook_OnClientEnter();
            else if (nEntry == n++) webhook_OnClientLeave();
            else if (nEntry == n++) webhook_OnModuleShutdown();
            else if (nEntry == n++) webhook_OnModuleStable();
            else if (nEntry == n++) webhook_OnPlayerDeath();
            else if (nEntry == n++) webhook_OnPlayerDying();
            else if (nEntry == n++) webhook_OnPlayerReSpawn();
            else if (nEntry == n++) webhook_OnPlayerLevelUp();
            else if (nEntry == n++) webhook_OnPlayerChat();
            else if (nEntry == n++) webhook_OnPlayerChatCommand();
            else if (nEntry == n++) webhook_OnModuleDebug();
            else if (nEntry == n++) webhook_OnHour();
            else if (nEntry == n++) webhook_OnQuestEvent();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in pw_l_webhook.nss");
    }
}
