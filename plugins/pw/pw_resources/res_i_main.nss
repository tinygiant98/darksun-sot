// -----------------------------------------------------------------------------
//    File: res_i_main.nss
//  System: Base Game Resource Management
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "res_i_const"
#include "core_i_constants"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< Register[object]ToFramework >---
// Registers the correct framework hook scripts to all standard events for the
// passed object type.
void RegisterAreaToFramework(object oArea);
void RegisterAreaOfEffectToFramework(object oAoE);
void RegisterCreatureToFramework(object oCreature);
void RegisterDoorToFramework(object oDoor);
void RegisterEncounterToFramework(object oEncounter);
void RegisterPlaceableToFramework(object oPlaceable);
void RegisterStoreToFramework(object oStore);
void RegisterTriggerToFramework(object oTrigger);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void RegisterAreaToFramework(object oArea)
{
    if (_GetLocalInt(oArea, HOOK_SKIP))
        return;

    /* For future use
    _SetLocalString(oArea, AREA_EVENT_ON_ENTER, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER) + HOOK_PRIORITY);
    _SetLocalString(oArea, AREA_EVENT_ON_EXIT, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT) + HOOK_PRIORITY);
    _SetLocalString(oArea, AREA_EVENT_ON_HEARTBEAT, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oArea, AREA_EVENT_ON_USER_DEFINED, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_USER_DEFINED_EVENT) + HOOK_PRIORITY);
    */

    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER, "hook_area01");
    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT, "hook_area02");
    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_HEARTBEAT, "hook_area03");
    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_USER_DEFINED_EVENT, "hook_area04");

    Debug("Base game area resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oArea) +
        "\n  Name   -> " + GetName(oArea) +
        "\n  Tag    -> " + GetTag(oArea));
}

void RegisterAreaOfEffectToFramework(object oAoE)
{
    if (_GetLocalInt(oAoE, HOOK_SKIP))
        return;

    /* For future us
    _SetLocalString(oAoE, AOE_EVENT_ON_ENTER, GetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_ENTER) + HOOK_PRIORITY);
    _SetLocalString(oAoE, AOE_EVENT_ON_HEARTBEAT, GetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oAoE, AOE_EVENT_ON_EXIT, GetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_EXIT) + HOOK_PRIORITY);
    */

    SetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_ENTER, "hook_aoe01");
    SetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_HEARTBEAT, "hook_aoe02");
    SetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_EXIT, "hook_aoe03");

    Debug("Base game aoe resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oAoE) +
        "\n  Name   -> " + GetName(oAoE) +
        "\n  Tag    -> " + GetTag(oAoE) +
        "\n  Area   -> " + GetName(GetArea(oAoE)));
}

void RegisterCreatureToFramework(object oCreature)
{
    if (_GetLocalInt(oCreature, HOOK_SKIP))
        return;

    if (_GetLocalInt(oCreature, FRAMEWORK_OUTSIDER))
    {
        _DeleteLocalInt(oCreature, FRAMEWORK_OUTSIDER);
        _SetLocalInt(oCreature, FRAMEWORK_REGISTERED, TRUE);
    }

    _SetLocalString(oCreature, CREATURE_EVENT_ON_BLOCKED, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_COMBAT_ROUND_END, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_CONVERSATION, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_DAMAGED, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_DEATH, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_DISTURBED, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_HEARTBEAT, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_PERCEPTION, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_PHYSICAL_ATTACKED, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_RESTED, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_SPAWN, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_SPELL_CAST_AT, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT) + HOOK_PRIORITY);
    _SetLocalString(oCreature, CREATURE_EVENT_ON_USER_DEFINED, GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT) + HOOK_PRIORITY);

    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "hook_creature01");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "hook_creature02");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "hook_creature03");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "hook_creature04");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "hook_creature06");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "hook_creature08");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "hook_creature09");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "hook_creature10");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "hook_creature11");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "hook_creature12");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "hook_creature13");

    Debug("Base game creature resource has been registered to the framework" + 
            "\n  Resref -> " + GetResRef(oCreature) +
            "\n  Name   -> " + GetName(oCreature) +
            "\n  Tag    -> " + GetTag(oCreature) +
            "\n  Area   -> " + GetName(GetArea(oCreature)));
}

void RegisterDoorToFramework(object oDoor)
{
    if (_GetLocalInt(oDoor, HOOK_SKIP))
        return;

    /* For future us
    _SetLocalString(oDoor, DOOR_EVENT_ON_AREA_TRANSITION_CLICK, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_CLICKED) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_CLOSE, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_CLOSE) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_DAMAGED, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_DAMAGE) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_DEATH, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_DEATH) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_FAIL_TO_OPEN, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_HEARTBEAT, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_LOCK, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_LOCK) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_PHYSICAL_ATTACKED, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_OPEN, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_OPEN) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_SPELL_CAST_AT, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_SPELLCASTAT) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_UNLOCK, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_UNLOCK) + HOOK_PRIORITY);
    _SetLocalString(oDoor, DOOR_EVENT_ON_USER_DEFINED, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_USERDEFINED) + HOOK_PRIORITY);

    _SetLocalString(oDoor, TRAP_EVENT_ON_DISARM, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_DISARM) + HOOK_PRIORITY);
    _SetLocalString(oDoor, TRAP_EVENT_ON_TRIGGERED, GetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_TRAPTRIGGERED) + HOOK_PRIORITY);
    */

    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_CLICKED, "hook_door01");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_CLOSE, "hook_door02");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_DAMAGE, "hook_door03");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_DEATH, "hook_door04");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN, "hook_door05");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_HEARTBEAT, "");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_LOCK, "hook_door07");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED, "hook_door08");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_OPEN, "hook_door09");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_SPELLCASTAT, "hook_door10");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_UNLOCK, "hook_door11");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_USERDEFINED, "hook_door12");
    
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_DISARM, "hook_trap01");
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_TRAPTRIGGERED, "hook_trap02");

    Debug("Base game creature resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oDoor) +
        "\n  Name   -> " + GetName(oDoor) +
        "\n  Tag    -> " + GetTag(oDoor) +
        "\n  Area   -> " + GetName(GetArea(oDoor)));
}

void RegisterEncounterToFramework(object oEncounter)
{
    if (_GetLocalInt(oEncounter, HOOK_SKIP))
        return;

    /* For future use
    _SetLocalString(oEncounter, ENCOUNTER_EVENT_ON_ENTER, GetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER) + HOOK_PRIORITY);
    _SetLocalString(oEncounter, ENCOUNTER_EVENT_ON_EXHAUSTED, GetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED) + HOOK_PRIORITY);
    _SetLocalString(oEncounter, ENCOUNTER_EVENT_ON_EXIT, GetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_EXIT) + HOOK_PRIORITY);
    _SetLocalString(oEncounter, ENCOUNTER_EVENT_ON_HEARTBEAT, GetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oEncounter, ENCOUNTER_EVENT_ON_USER_DEFINED, GetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_USER_DEFINED_EVENT) + HOOK_PRIORITY);
    */
    
    SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER, "hook_encounter01");
    SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED, "hook_encounter02");
    SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_EXIT, "hook_encounter03");
    SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_HEARTBEAT, "");
    SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_USER_DEFINED_EVENT, "hook_encounter05");

    Debug("Base game creature resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oEncounter) +
        "\n  Name   -> " + GetName(oEncounter) +
        "\n  Tag    -> " + GetTag(oEncounter) +
        "\n  Area   -> " + GetName(GetArea(oEncounter)));
}

void RegisterPlaceableToFramework(object oPlaceable)
{
    if (_GetLocalInt(oPlaceable, HOOK_SKIP))
        return;

    if (_GetLocalInt(oPlaceable, FRAMEWORK_OUTSIDER))
    {   
        _DeleteLocalInt(oPlaceable, FRAMEWORK_OUTSIDER);
        _SetLocalInt(oPlaceable, FRAMEWORK_REGISTERED, TRUE);
    }

    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_CLICK, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_CLOSE, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_CLOSED) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_DAMAGED, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_DEATH, GetEventScript(oPlaceable, EVENT_SCRIPT_DOOR_ON_DEATH) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_DISTURBED, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_HEARTBEAT, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_LOCK, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LOCK) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_OPEN, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_OPEN) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_SPELL_CAST_AT, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_UNLOCK, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_USED, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USED) + HOOK_PRIORITY);
    _SetLocalString(oPlaceable, PLACEABLE_EVENT_ON_USER_DEFINED, GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED_EVENT) + HOOK_PRIORITY);

    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "hook_placeable01");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, "hook_placeable02");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED, "hook_placeable03");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "hook_placeable04");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED, "hook_placeable05");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LOCK, "hook_placeable07");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "hook_placeable08");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_OPEN, "hook_placeable09");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT, "hook_placeable10");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, "hook_placeable11");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USED, "hook_placeable12");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED_EVENT, "hook_placeable13");

    Debug("Base game placeable resource has been registered to the framework" + 
            "\n  Resref -> " + GetResRef(oPlaceable) +
            "\n  Name   -> " + GetName(oPlaceable) +
            "\n  Tag    -> " + GetTag(oPlaceable) +
            "\n  Area   -> " + GetName(GetArea(oPlaceable)));
}

void RegisterStoreToFramework(object oStore)
{
    if (_GetLocalInt(oStore, HOOK_SKIP))
        return;

    /* For future use
    _SetLocalString(oStore, STORE_EVENT_ON_OPEN, GetEventScript(oStore, EVENT_SCRIPT_STORE_ON_OPEN) + HOOK_PRIORITY);
    _SetLocalString(oStore, STORE_EVENT_ON_CLOSE, GetEventScript(oStore, EVENT_SCRIPT_STORE_ON_CLOSE) + HOOK_PRIORITY);
    */

    SetEventScript(oStore, EVENT_SCRIPT_STORE_ON_OPEN, "hook_store01");
    SetEventScript(oStore, EVENT_SCRIPT_STORE_ON_CLOSE, "hook_store01");
    
    Debug("Base game placeable resource has been registered to the framework" + 
            "\n  Resref -> " + GetResRef(oStore) +
            "\n  Name   -> " + GetName(oStore) +
            "\n  Tag    -> " + GetTag(oStore) +
            "\n  Area   -> " + GetName(GetArea(oStore)));
}

void RegisterTriggerToFramework(object oTrigger)
{
    if (_GetLocalInt(oTrigger, HOOK_SKIP))
        return;

    /* For future use
    _SetLocalString(oTrigger, TRIGGER_EVENT_ON_CLICK, GetEventScript(oStore, EVENT_SCRIPT_TRIGGER_ON_CLICKED) + HOOK_PRIORITY);
    _SetLocalString(oTrigger, TRIGGER_EVENT_ON_ENTER, GetEventScript(oStore, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER) + HOOK_PRIORITY);
    _SetLocalString(oTrigger, TRIGGER_EVENT_ON_EXIT, GetEventScript(oStore, EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT) + HOOK_PRIORITY);
    _SetLocalString(oTrigger, TRIGGER_EVENT_ON_HEARTBEAT, GetEventScript(oStore, EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oTrigger, TRIGGER_EVENT_ON_USER_DEFINED, GetEventScript(oStore, EVENT_SCRIPT_TRIGGER_ON_USER_DEFINED_EVENT) + HOOK_PRIORITY);
   
    _SetLocalString(oTrigger, TRAP_EVENT_ON_DISARM, GetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_DISARMED) + HOOK_PRIORITY);
    _SetLocalString(oTrigger, TRAP_EVENT_ON_TRIGGERED, GetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_TRAPTRIGGERED) + HOOK_PRIORITY);
    */

    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_CLICKED, "hook_trigger01");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER, "hook_trigger02");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT, "hook_trigger03");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT, "");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_USER_DEFINED_EVENT, "hook_trigger05");

    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_DISARMED, "hook_trap01");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_TRAPTRIGGERED, "hook_trap02");

    Debug("Base game creature resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oTrigger) +
        "\n  Name   -> " + GetName(oTrigger) +
        "\n  Tag    -> " + GetTag(oTrigger) +
        "\n  Area   -> " + GetName(GetArea(oTrigger)));
}
