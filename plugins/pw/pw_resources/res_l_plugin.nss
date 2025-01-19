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
    if (!GetIfPluginExists("pw"))
        return;

    object oPlugin = GetPlugin("pw");

    RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "resources_OnModuleLoad", EVENT_PRIORITY_FIRST);

    // ----- Creature Events -----
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_BLOCKED, "resources_OnCreatureBlocked", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_COMBAT_ROUND_END, "resources_OnCreatureCombatRoundEnd", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_CONVERSATION, "resources_OnCreatureConversation", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_DAMAGED, "resources_OnCreatureDamaged", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_DEATH, "resources_OnCreatureDeath", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_DISTURBED, "resources_OnCreatureDisturbed", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_HEARTBEAT, "resources_OnCreatureHeartbeat", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_PERCEPTION, "resources_OnCreaturePerception", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_PHYSICAL_ATTACKED, "resources_OnCreaturePhysicalAttacked", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_RESTED, "resources_OnCreatureRested", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_SPAWN, "resources_OnCreatureSpawn", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_SPELL_CAST_AT, "resources_OnCreatureSpellCastAt", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, CREATURE_EVENT_ON_USER_DEFINED, "resources_OnCreatureUserDefined", EVENT_PRIORITY_FIRST);

    // ----- Placeable Events -----
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_CLICK, "resources_OnPlaceableClick", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_CLOSE, "resources_OnPlaceableClose", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_DAMAGED, "resources_OnPlaceableDamaged", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_DEATH, "resources_OnPlaceableDeath", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_DISTURBED, "resources_OnPlaceableDisturbed", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_HEARTBEAT, "resources_OnPlaceableHeartbeat", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_LOCK, "resources_OnPlaceableLock", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED, "resources_OnPlaceablePhysicalAttacked", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_OPEN, "resources_OnPlaceableOpen", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_SPELL_CAST_AT, "resources_OnPlaceableSpellCastAt", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_UNLOCK, "resources_OnPlaceableUnlock", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_USED, "resources_OnPlaceableUsed", EVENT_PRIORITY_FIRST);
    RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_USER_DEFINED, "resources_OnPlaceableUserDefined", EVENT_PRIORITY_FIRST);
    
    int n;
    // ----- Module Events -----
    RegisterLibraryScript("resources_OnModuleLoad", 0);

    n = 100;
    // ----- Creature Events -----
    RegisterLibraryScript("resources_OnCreatureBlocked", n++);
    RegisterLibraryScript("resources_OnCreatureCombatRoundEnd", n++);
    RegisterLibraryScript("resources_OnCreatureConversation", n++);
    RegisterLibraryScript("resources_OnCreatureDamaged", n++);
    RegisterLibraryScript("resources_OnCreatureDeath", n++);
    RegisterLibraryScript("resources_OnCreatureDisturbed", n++);
    RegisterLibraryScript("resources_OnCreatureHeartbeat", n++);
    RegisterLibraryScript("resources_OnCreaturePerception", n++);
    RegisterLibraryScript("resources_OnCreaturePhysicalAttacked", n++);
    RegisterLibraryScript("resources_OnCreatureRested", n++);
    RegisterLibraryScript("resources_OnCreatureSpawn", n++);
    RegisterLibraryScript("resources_OnCreatureSpellCastAt", n++);
    RegisterLibraryScript("resources_OnCreatureUserDefined", n++);
    
    n = 200;
    // ----- Placeable Events -----
    RegisterLibraryScript("resources_OnPlaceableClick", n++);
    RegisterLibraryScript("resources_OnPlaceableClose", n++);
    RegisterLibraryScript("resources_OnPlaceableDamaged", n++);
    RegisterLibraryScript("resources_OnPlaceableDeath", n++);
    RegisterLibraryScript("resources_OnPlaceableDisturbed", n++);
    RegisterLibraryScript("resources_OnPlaceableHeartbeat", n++);
    RegisterLibraryScript("resources_OnPlaceableLock", n++);
    RegisterLibraryScript("resources_OnPlaceablePhysicalAttacked", n++);
    RegisterLibraryScript("resources_OnPlaceableOpen", n++);
    RegisterLibraryScript("resources_OnPlaceableSpellCastAt", n++);
    RegisterLibraryScript("resources_OnPlaceableUnlock", n++);
    RegisterLibraryScript("resources_OnPlaceableUsed", n++);
    RegisterLibraryScript("resources_OnPlaceableUserDefined", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            // ----- Module Events -----
            if      (nEntry == n++) DelayCommand(2.0, resources_OnModuleLoad());
        } break;

        case 100:
        {
            // ----- Creature Events -----
            if      (nEntry == n++) resources_OnCreatureBlocked();
            else if (nEntry == n++) resources_OnCreatureCombatRoundEnd();
            else if (nEntry == n++) resources_OnCreatureConversation();
            else if (nEntry == n++) resources_OnCreatureDamaged();
            else if (nEntry == n++) resources_OnCreatureDeath();
            else if (nEntry == n++) resources_OnCreatureDisturbed();
            else if (nEntry == n++) resources_OnCreatureHeartbeat();
            else if (nEntry == n++) resources_OnCreaturePerception();
            else if (nEntry == n++) resources_OnCreaturePhysicalAttacked();
            else if (nEntry == n++) resources_OnCreatureRested();
            else if (nEntry == n++) resources_OnCreatureSpawn();
            else if (nEntry == n++) resources_OnCreatureSpellCastAt();
            else if (nEntry == n++) resources_OnCreatureUserDefined();
        } break;

        case 200:
        {
            // ----- Placeable Events -----
            if      (nEntry == n++) resources_OnPlaceableClick();
            else if (nEntry == n++) resources_OnPlaceableClose();
            else if (nEntry == n++) resources_OnPlaceableDamaged();
            else if (nEntry == n++) resources_OnPlaceableDeath();
            else if (nEntry == n++) resources_OnPlaceableDisturbed();
            else if (nEntry == n++) resources_OnPlaceableHeartbeat();
            else if (nEntry == n++) resources_OnPlaceableLock();
            else if (nEntry == n++) resources_OnPlaceablePhysicalAttacked();
            else if (nEntry == n++) resources_OnPlaceableOpen();
            else if (nEntry == n++) resources_OnPlaceableSpellCastAt();
            else if (nEntry == n++) resources_OnPlaceableUnlock();
            else if (nEntry == n++) resources_OnPlaceableUsed();
            else if (nEntry == n++) resources_OnPlaceableUserDefined();
        } break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
