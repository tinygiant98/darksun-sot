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
void RegisterAreaToFramework(object oArea, int bIncludeHeartbeat = FALSE);
void RegisterAreaOfEffectToFramework(object oAoE);
void RegisterCreatureToFramework(object oCreature, int bIncludeHeartbeat = FALSE);
void RegisterDoorToFramework(object oDoor, int bIncludeHeartbeat = FALSE);
void RegisterEncounterToFramework(object oEncounter, int bIncludeHeartbeat = FALSE);
void RegisterPlaceableToFramework(object oPlaceable, int bIncludeHeartbeat = FALSE);
void RegisterStoreToFramework(object oStore);
void RegisterTriggerToFramework(object oTrigger, int bIncludeHeartbeat = FALSE);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void RegisterAreaToFramework(object oArea, int bIncludeHeartbeat = FALSE)
{
    /* For future use
    _SetLocalString(oArea, AREA_EVENT_ON_ENTER, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER) + HOOK_PRIORITY);
    _SetLocalString(oArea, AREA_EVENT_ON_EXIT, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT) + HOOK_PRIORITY);
    _SetLocalString(oArea, AREA_EVENT_ON_HEARTBEAT, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_HEARTBEAT) + HOOK_PRIORITY);
    _SetLocalString(oArea, AREA_EVENT_ON_USER_DEFINED, GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_USER_DEFINED_EVENT) + HOOK_PRIORITY);
    */

    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER, "hook_area01");
    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT, "hook_area02");
    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_HEARTBEAT, (bIncludeHeartbeat ? "hook_area03" : ""));
    SetEventScript(oArea, EVENT_SCRIPT_AREA_ON_USER_DEFINED_EVENT, "hook_area04");

    Debug("Base game area resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oArea) +
        "\n  Name   -> " + GetName(oArea) +
        "\n  Tag    -> " + GetTag(oArea));
}

void RegisterAreaOfEffectToFramework(object oAoE)
{
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

void RegisterCreatureToFramework(object oCreature, int bIncludeHeartbeat = FALSE)
{
    if (_GetLocalInt(oCreature, FRAMEWORK_OUTSIDER))
    {
        _DeleteLocalInt(oCreature, FRAMEWORK_OUTSIDER);
        _SetLocalInt(oCreature, FRAMEWORK_REGISTERED, TRUE);
    }

    string CREATURE_FRAMEWORK_SCRIPTS = "hook_creature01,hook_creature02,hook_creature03,hook_creature04," +
                                        "hook_creature05,hook_creature06,~,hook_creature08," +
                                        "hook_creature09,hook_creature10,hook_creature11,hook_creature12," +
                                        "hook_creature13";

    string CREATURE_FRAMEWORK_EVENTS;
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_BLOCKED);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_COMBAT_ROUND_END);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_CONVERSATION);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_DAMAGED);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_DEATH);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_DISTURBED);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_HEARTBEAT);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_PERCEPTION);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_PHYSICAL_ATTACKED);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_RESTED);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_SPAWN);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_SPELL_CAST_AT);
    CREATURE_FRAMEWORK_EVENTS = AddListItem(CREATURE_FRAMEWORK_EVENTS, CREATURE_EVENT_ON_USER_DEFINED);

    string CREATURE_NWN_EVENTS;
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_DIALOGUE));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_DAMAGED));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_DEATH));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_DISTURBED));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_HEARTBEAT));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_NOTICE));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_RESTED));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_SPAWN_IN));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT));
    CREATURE_NWN_EVENTS = AddListItem(CREATURE_NWN_EVENTS, IntToString(EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT));
    
    int n, nEvents = CountList(CREATURE_NWN_EVENTS);
    for (n = 0; n < nEvents; n++)
    {
        string sFrameworkEvent = GetListItem(CREATURE_FRAMEWORK_EVENTS, n);
        int    nNWNEvent = StringToInt(GetListItem(CREATURE_NWN_EVENTS, n));
        string sFrameworkEventScript = GetListItem(CREATURE_FRAMEWORK_SCRIPTS, n);
        string sNWNEventScript = GetEventScript(oCreature, nNWNEvent);

        if (sNWNEventScript != "")
            _SetLocalString(oCreature, sFrameworkEvent, sNWNEventScript);

        if (sFrameworkEventScript == "~")
            sFrameworkEventScript = bIncludeHeartbeat ? "hook_creature07" : "";
        
        SetEventScript(oCreature, nNWNEvent, sFrameworkEventScript);
    }

    Debug("Base game creature resource has been registered to the framework" + 
            "\n  Resref -> " + GetResRef(oCreature) +
            "\n  Name   -> " + GetName(oCreature) +
            "\n  Tag    -> " + GetTag(oCreature) +
            "\n  Area   -> " + GetName(GetArea(oCreature)));
}

void RegisterDoorToFramework(object oDoor, int bIncludeHeartbeat = FALSE)
{
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
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_HEARTBEAT, (bIncludeHeartbeat ? "hook_door04" : ""));
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

void RegisterEncounterToFramework(object oEncounter, int bIncludeHeartbeat = FALSE)
{
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
    SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_HEARTBEAT, (bIncludeHeartbeat ? "hook_encounter04" : ""));
    SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_USER_DEFINED_EVENT, "hook_encounter05");

    Debug("Base game creature resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oEncounter) +
        "\n  Name   -> " + GetName(oEncounter) +
        "\n  Tag    -> " + GetTag(oEncounter) +
        "\n  Area   -> " + GetName(GetArea(oEncounter)));
}

void RegisterPlaceableToFramework(object oPlaceable, int bIncludeHeartbeat = FALSE)
{
    if (_GetLocalInt(oPlaceable, FRAMEWORK_OUTSIDER))
    {
        _DeleteLocalInt(oPlaceable, FRAMEWORK_OUTSIDER);
        _SetLocalInt(oPlaceable, FRAMEWORK_REGISTERED, TRUE);
    }

    string PLACEABLE_FRAMEWORK_SCRIPTS = "hook_placeable01,hook_placeable02,hook_placeable03,hook_placeable04," +
                                         "hook_placeable05,~,hook_placeable07,hook_placeable08," +
                                         "hook_placeable09,hook_placeable10,hook_placeable11,hook_placeable12," +
                                         "hook_placeable13";

    string PLACEABLE_FRAMEWORK_EVENTS;
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_CLICK);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_CLOSE);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_DAMAGED);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_DEATH);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_DISTURBED);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_HEARTBEAT);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_LOCK);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_OPEN);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_SPELL_CAST_AT);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_UNLOCK);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_USED);
    PLACEABLE_FRAMEWORK_EVENTS = AddListItem(PLACEABLE_FRAMEWORK_EVENTS, PLACEABLE_EVENT_ON_USER_DEFINED);

    string PLACEABLE_NWN_EVENTS;
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_CLOSED));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_DAMAGED));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_DEATH));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_LOCK));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_OPEN));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_UNLOCK));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_USED));
    PLACEABLE_NWN_EVENTS = AddListItem(PLACEABLE_NWN_EVENTS, IntToString(EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED_EVENT));
    
    int n, nEvents = CountList(PLACEABLE_NWN_EVENTS);
    for (n = 0; n < nEvents; n++)
    {
        string sFrameworkEvent = GetListItem(PLACEABLE_FRAMEWORK_EVENTS, n);
        int    nNWNEvent = StringToInt(GetListItem(PLACEABLE_NWN_EVENTS, n));
        string sFrameworkEventScript = GetListItem(PLACEABLE_FRAMEWORK_SCRIPTS, n);
        string sNWNEventScript = GetEventScript(oPlaceable, nNWNEvent);

        if (sNWNEventScript != "")
            _SetLocalString(oPlaceable, sFrameworkEvent, sNWNEventScript);

        if (sFrameworkEventScript == "~")
            sFrameworkEventScript = bIncludeHeartbeat ? "hook_placeable06" : "";
        
        SetEventScript(oPlaceable, nNWNEvent, sFrameworkEventScript);
    }

    Debug("Base game placeable resource has been registered to the framework" + 
            "\n  Resref -> " + GetResRef(oPlaceable) +
            "\n  Name   -> " + GetName(oPlaceable) +
            "\n  Tag    -> " + GetTag(oPlaceable) +
            "\n  Area   -> " + GetName(GetArea(oPlaceable)));
}

void RegisterStoreToFramework(object oStore)
{
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

void RegisterTriggerToFramework(object oTrigger, int bIncludeHeartbeat = FALSE)
{
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
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT, (bIncludeHeartbeat ? "hook_trigger04" : ""));
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_USER_DEFINED_EVENT, "hook_trigger05");

    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_DISARMED, "hook_trap01");
    SetEventScript(oTrigger, EVENT_SCRIPT_TRIGGER_ON_TRAPTRIGGERED, "hook_trap02");

    Debug("Base game creature resource has been registered to the framework" + 
        "\n  Resref -> " + GetResRef(oTrigger) +
        "\n  Name   -> " + GetName(oTrigger) +
        "\n  Tag    -> " + GetTag(oTrigger) +
        "\n  Area   -> " + GetName(GetArea(oTrigger)));
}
