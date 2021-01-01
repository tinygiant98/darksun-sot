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
    if (_GetLocalString(oArea, HOOK_SKIP))
        return;

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
    if (_GetLocalString(oAoE, HOOK_SKIP))
        return;

    SetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_ENTER, "hook_aoe01");
    SetEventScript(oAoE, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "hook_aoe02");
    SetEventScript(oAoE, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_EXIT, "hook_aoe03");

    Debug("Base game aoe resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oAoE) +
        "\n  Name   -> " + GetName(oAoE) +
        "\n  Tag    -> " + GetTag(oAoE) +
        "\n  Area   -> " + GetName(GetArea(oAoE)));
}

void RegisterCreatureToFramework(object oCreature)
{
    if (_GetLocalString(oCreature, HOOK_SKIP))
        return;

    if (_GetLocalInt(oCreature, FRAMEWORK_OUTSIDER))
    {
        _DeleteLocalInt(oCreature, FRAMEWORK_OUTSIDER);
        _SetLocalInt(oCreature, FRAMEWORK_REGISTERED, TRUE);
    }

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
    if (_GetLocalString(oDoor, HOOK_SKIP))
        return;

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
    if (_GetLocalString(oEncounter, HOOK_SKIP))
        return;

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
    if (_GetLocalString(oPlaceable, HOOK_SKIP))
        return;

    if (_GetLocalInt(oPlaceable, FRAMEWORK_OUTSIDER))
    {   
        _DeleteLocalInt(oPlaceable, FRAMEWORK_OUTSIDER);
        _SetLocalInt(oPlaceable, FRAMEWORK_REGISTERED, TRUE);
    }

    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "hook_placeable01");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, "hook_placeable02");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED, "hook_placeable03");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "hook_placeable04");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
    SetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED, "hook_placeable06");
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
    if (_GetLocalString(oStore, HOOK_SKIP))
        return;

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
    if (_GetLocalString(oTrigger, HOOK_SKIP))
        return;

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
