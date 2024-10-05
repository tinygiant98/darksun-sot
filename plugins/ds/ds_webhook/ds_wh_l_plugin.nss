// -----------------------------------------------------------------------------
//    File: ds_wh_l_plugin.nss
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
#include "ds_wh_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!USE_WEBHOOK_PLUGIN)
        return;

    object oPlugin = GetPlugin("ds");

    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "webhook_OnModuleLoad", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "webhook_OnClientEnter", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE, "webhook_OnClientLeave", 4.0);
    RegisterEventScripts(oPlugin, "OnModuleShutdown", "webhook_OnModuleShutdown", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_STABLE, "webhook_OnModuleStable", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "webhook_OnPlayerDeath", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "webhook_OnPlayerDying", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN, "webhook_OnPlayerReSpawn", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP, "webhook_OnPlayerLevelUp", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_CHAT, "webhook_OnPlayerChat", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_CHAT_COMMAND, "webhook_OnPlayerChatCommand", 1.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_HOUR, "webhook_OnHour", 1.0);

    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_ACCEPT", "webhook_OnQuestEvent", 3.5);
    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_ADVANCE", "webhook_OnQuestEvent", 3.5);
    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_COMPLETE", "webhook_OnQuestEvent", 3.5);
    RegisterEventScripts(oPlugin, "QUEST_EVENT_ON_FAIL", "webhook_OnQuestEvent", 3.5);

    RegisterLibraryScript("webhook_OnModuleLoad", 1);
    RegisterLibraryScript("webhook_OnClientEnter", 2);
    RegisterLibraryScript("webhook_OnClientLeave", 3);
    RegisterLibraryScript("webhook_OnModuleShutdown", 4);
    RegisterLibraryScript("webhook_OnModuleStable", 5);
    RegisterLibraryScript("webhook_OnPlayerDeath", 6);
    RegisterLibraryScript("webhook_OnPlayerDying", 7);
    RegisterLibraryScript("webhook_OnReSpawn", 8);
    RegisterLibraryScript("webhook_OnLevelUp", 9);
    RegisterLibraryScript("webhook_OnPlayerChat", 10);
    RegisterLibraryScript("webhook_OnPlayerChatCommand", 11);
    RegisterLibraryScript("webhook_OnModuleDebug", 12);
    RegisterLibraryScript("webhook_OnHour", 13);

    RegisterLibraryScript("webhook_OnQuestEvent", 20);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: webhook_OnModuleLoad(); break;
        case 2: webhook_OnClientEnter(); break;
        case 3: webhook_OnClientLeave(); break;
        case 4: webhook_OnModuleShutdown(); break;
        case 5: webhook_OnModuleStable(); break;
        case 6: webhook_OnPlayerDeath(); break;
        case 7: webhook_OnPlayerDying(); break;
        case 8: webhook_OnPlayerReSpawn(); break;
        case 9: webhook_OnPlayerLevelUp(); break;
        case 10: webhook_OnPlayerChat(); break;
        case 11: webhook_OnPlayerChatCommand(); break;
        case 12: webhook_OnModuleDebug(); break;
        case 13: webhook_OnHour(); break;

        case 20: webhook_OnQuestEvent(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
