// -----------------------------------------------------------------------------
//    File: res_i_events.nss
//  System: Base Game Resource Management
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "res_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void resources_OnCreatureBlocked()
{

}

void resources_OnCreatureCombatRoundEnd()
{

}

void resources_OnCreatureConversation()
{
    // Creatures will not have the standard conversation assigned to them if they're base game resources.
    // This function should allow then to open a conversation with the custom dialog system.  For this to
    // work, they need to have the string variable "*Dialog" set on them with the name of the custom
    // dialog.  This variable should be set OnCreatureSpawn.

    object oCreature = OBJECT_SELF;
    if (_GetLocalInt(oCreature, FRAMEWORK_REGISTERED))
    {
        int nPattern = GetListenPatternNumber();
        if (nPattern == -1)
        {
            // Creature was clicked instead of some other perception
            object oPC = GetLastSpeaker();
            if (!GetIsInCombat(oCreature))
                AssignCommand(oCreature, ActionStartConversation(oPC, "dlg_convnozoom", FALSE, FALSE));
        }
    }
}

void resources_OnCreatureDamaged()
{

}

void resources_OnCreatureDeath()
{

}

void resources_OnCreatureDisturbed()
{

}

void resources_OnCreatureHeartbeat()
{

}

void resources_OnCreaturePerception()
{

}

void resources_OnCreaturePhysicalAttacked()
{

}

void resources_OnCreatureRested()
{

}

void resources_OnCreatureSpawn()
{
    object oPlaceable = OBJECT_SELF;
    if (_GetLocalInt(oPlaceable, FRAMEWORK_OUTSIDER))
        RegisterCreatureToFramework(oPlaceable);
}

void resources_OnCreatureSpellCastAt()
{

}

void resources_OnCreatureUserDefined()
{

}

void resources_OnPlaceableClick()
{

}

void resources_OnPlaceableClose()
{

}

void resources_OnPlaceableDamaged()
{

}

void resources_OnPlaceableDeath()
{

}

void resources_OnPlaceableDisturbed()
{

}

void resources_OnPlaceableHeartbeat()
{
    object oPlaceable = OBJECT_SELF;
    if (_GetLocalInt(oPlaceable, FRAMEWORK_OUTSIDER))
        RegisterPlaceableToFramework(oPlaceable);
}

void resources_OnPlaceableLock()
{

}

void resources_OnPlaceablePhysicalAttacked()
{

}

void resources_OnPlaceableOpen()
{

}

void resources_OnPlaceableSpellCastAt()
{

}

void resources_OnPlaceableUnlock()
{

}

void resources_OnPlaceableUsed()
{

}

void resources_OnPlaceableUserDefined()
{

}

void resources_OnModuleLoad()
{
    int nObjectType;
    object oObject, oArea = GetFirstArea();

    while (GetIsObjectValid(oArea))
    {
        if (GetStringLeft(GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
            RegisterAreaToFramework(oArea);

        oObject = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oObject))
        {
            int nObjectType = GetObjectType(oObject);
            switch (nObjectType)
            {
                case OBJECT_TYPE_AREA_OF_EFFECT:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                        RegisterAreaOfEffectToFramework(oObject);
                    break;
                case OBJECT_TYPE_CREATURE:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                       RegisterCreatureToFramework(oObject);
                    break;
                case OBJECT_TYPE_DOOR:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_CLICKED), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                        RegisterDoorToFramework(oObject);
                    break;
                case OBJECT_TYPE_ENCOUNTER:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                        RegisterEncounterToFramework(oObject);
                    break;
                case OBJECT_TYPE_PLACEABLE:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                        RegisterPlaceableToFramework(oObject);
                    break;
                case OBJECT_TYPE_STORE:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_STORE_ON_OPEN), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                        RegisterStoreToFramework(oObject);
                    break;
                case OBJECT_TYPE_TRIGGER:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                        RegisterTriggerToFramework(oObject);
                    break;
            }

            oObject = GetNextObjectInArea(oArea);
        }

        oArea = GetNextArea();
    }
}
