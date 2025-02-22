// -----------------------------------------------------------------------------
//    File: res_l_plugin.nss
//  System: Base Game Resource Management
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"
#include "res_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("pw");

    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "resources_OnModuleLoad", EVENT_PRIORITY_FIRST);

    // ----- Creature Events -----
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_BLOCKED, "resources_OnCreatureBlocked", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_COMBAT_ROUND_END, "resources_OnCreatureCombatRoundEnd", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_CONVERSATION, "resources_OnCreatureConversation", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DAMAGED, "resources_OnCreatureDamaged", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DEATH, "resources_OnCreatureDeath", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_DISTURBED, "resources_OnCreatureDisturbed", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_HEARTBEAT, "resources_OnCreatureHeartbeat", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_PERCEPTION, "resources_OnCreaturePerception", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_PHYSICAL_ATTACKED, "resources_OnCreaturePhysicalAttacked", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_RESTED, "resources_OnCreatureRested", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_SPAWN, "resources_OnCreatureSpawn", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_SPELL_CAST_AT, "resources_OnCreatureSpellCastAt", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, CREATURE_EVENT_ON_USER_DEFINED, "resources_OnCreatureUserDefined", EVENT_PRIORITY_FIRST);

    // ----- Placeable Events -----
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_CLICK, "resources_OnPlaceableClick", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_CLOSE, "resources_OnPlaceableClose", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_DAMAGED, "resources_OnPlaceableDamaged", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_DEATH, "resources_OnPlaceableDeath", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_DISTURBED, "resources_OnPlaceableDisturbed", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_HEARTBEAT, "resources_OnPlaceableHeartbeat", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_LOCK, "resources_OnPlaceableLock", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED, "resources_OnPlaceablePhysicalAttacked", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_OPEN, "resources_OnPlaceableOpen", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_SPELL_CAST_AT, "resources_OnPlaceableSpellCastAt", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_UNLOCK, "resources_OnPlaceableUnlock", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_USED, "resources_OnPlaceableUsed", EVENT_PRIORITY_FIRST);
    RegisterEventScripts(oPlugin, PLACEABLE_EVENT_ON_USER_DEFINED, "resources_OnPlaceableUserDefined", EVENT_PRIORITY_FIRST);
    
    // ----- Module Events -----
    RegisterLibraryScript("resources_OnModuleLoad", 0);

    // ----- Creature Events -----
    RegisterLibraryScript("resources_OnCreatureBlocked", 1);
    RegisterLibraryScript("resources_OnCreatureCombatRoundEnd", 2);
    RegisterLibraryScript("resources_OnCreatureConversation", 3);
    RegisterLibraryScript("resources_OnCreatureDamaged", 4);
    RegisterLibraryScript("resources_OnCreatureDeath", 5);
    RegisterLibraryScript("resources_OnCreatureDisturbed", 6);
    RegisterLibraryScript("resources_OnCreatureHeartbeat", 7);
    RegisterLibraryScript("resources_OnCreaturePerception", 8);
    RegisterLibraryScript("resources_OnCreaturePhysicalAttacked", 9);
    RegisterLibraryScript("resources_OnCreatureRested", 10);
    RegisterLibraryScript("resources_OnCreatureSpawn", 11);
    RegisterLibraryScript("resources_OnCreatureSpellCastAt", 12);
    RegisterLibraryScript("resources_OnCreatureUserDefined", 13);
    
    // ----- Placeable Events -----
    RegisterLibraryScript("resources_OnPlaceableClick", 20);
    RegisterLibraryScript("resources_OnPlaceableClose", 21);
    RegisterLibraryScript("resources_OnPlaceableDamaged", 22);
    RegisterLibraryScript("resources_OnPlaceableDeath", 23);
    RegisterLibraryScript("resources_OnPlaceableDisturbed", 24);
    RegisterLibraryScript("resources_OnPlaceableHeartbeat", 25);
    RegisterLibraryScript("resources_OnPlaceableLock", 26);
    RegisterLibraryScript("resources_OnPlaceablePhysicalAttacked", 27);
    RegisterLibraryScript("resources_OnPlaceableOpen", 28);
    RegisterLibraryScript("resources_OnPlaceableSpellCastAt", 29);
    RegisterLibraryScript("resources_OnPlaceableUnlock", 30);
    RegisterLibraryScript("resources_OnPlaceableUsed", 31);
    RegisterLibraryScript("resources_OnPlaceableUserDefined", 32);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 0:  DelayCommand(2.0, resources_OnModuleLoad()); break;

        // ----- Creature Events -----
        case 1:  resources_OnCreatureBlocked(); break;
        case 2:  resources_OnCreatureCombatRoundEnd(); break;
        case 3:  resources_OnCreatureConversation(); break;
        case 4:  resources_OnCreatureDamaged(); break;
        case 5:  resources_OnCreatureDeath(); break;
        case 6:  resources_OnCreatureDisturbed(); break;
        case 7:  resources_OnCreatureHeartbeat(); break;
        case 8:  resources_OnCreaturePerception(); break;
        case 9:  resources_OnCreaturePhysicalAttacked(); break;
        case 10: resources_OnCreatureRested(); break;
        case 11: resources_OnCreatureSpawn(); break;
        case 12: resources_OnCreatureSpellCastAt(); break;
        case 13: resources_OnCreatureUserDefined(); break;

        // ----- Placeable Events -----
        case 20: resources_OnPlaceableClick(); break;
        case 21: resources_OnPlaceableClose(); break;
        case 22: resources_OnPlaceableDamaged(); break;
        case 23: resources_OnPlaceableDeath(); break;
        case 24: resources_OnPlaceableDisturbed(); break;
        case 25: resources_OnPlaceableHeartbeat(); break;
        case 26: resources_OnPlaceableLock(); break;
        case 27: resources_OnPlaceablePhysicalAttacked(); break;
        case 28: resources_OnPlaceableOpen(); break;
        case 29: resources_OnPlaceableSpellCastAt(); break;
        case 30: resources_OnPlaceableUnlock(); break;
        case 31: resources_OnPlaceableUsed(); break;
        case 32: resources_OnPlaceableUserDefined(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
