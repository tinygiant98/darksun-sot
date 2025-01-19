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

    if (GetLocalInt(oCreature, FRAMEWORK_REGISTERED))
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
    if (GetLocalInt(oPlaceable, FRAMEWORK_OUTSIDER))
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
    if (GetLocalInt(oPlaceable, FRAMEWORK_OUTSIDER))
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
    int nObjectType, nCount;
    object oObject, oArea = GetFirstArea();

    // instead of looping each game object, which could easily run into TMIs, how's about we use the CompileScript function to
    //  create a new game override for each heartbeat script, then in each heartbeat, register that object to the framework and assign
    //  a different script?

    // Every object type, except stores has a heartbeat.  So we really just need to know the names of the heartbeat scripts, this take them
    // over for their first run; but, um, not every object has a heartbeat script assigned?  so that might not work as expected ...

    // Look in the game code to see which ones use `default`, maybe be can override that for some effet?
    // How's about maybe the first heartbeat of each area registering objects in that area?  On Module Load could assign the heartbeat script
    //  to us, then we take it away once we're all done with it.

    while (GetIsObjectValid(oArea))
    {
        if (GetStringLeft(GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
        {
            if (!GetLocalInt(oArea, HOOK_SKIP))
            {
                SetLocalInt(oArea, FRAMEWORK_OUTSIDER, TRUE);
                RegisterAreaToFramework(oArea);
            }
        }

        oObject = GetFirstObjectInArea(oArea);

        while (GetIsObjectValid(oObject))
        {
            if (GetLocalInt(oObject, HOOK_SKIP))
            {
                oObject = GetNextObjectInArea(oArea);
                continue;
            }

            int nObjectType = GetObjectType(oObject);
            
            switch (nObjectType)
            {
                case OBJECT_TYPE_AREA_OF_EFFECT:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                    {
                        SetLocalInt(oObject, FRAMEWORK_OUTSIDER, TRUE);
                        DelayCommand(0.1, RegisterAreaOfEffectToFramework(oObject));
                    }
                    break;
                case OBJECT_TYPE_CREATURE:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                    {
                        SetLocalInt(oObject, FRAMEWORK_OUTSIDER, TRUE);
                        DelayCommand(0.1, RegisterCreatureToFramework(oObject));
                    }
                    break;
                case OBJECT_TYPE_DOOR:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_DOOR_ON_CLICKED), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                    {
                        SetLocalInt(oObject, FRAMEWORK_OUTSIDER, TRUE);
                        DelayCommand(0.1, RegisterDoorToFramework(oObject));
                    }
                    break;
                case OBJECT_TYPE_ENCOUNTER:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                    {
                        SetLocalInt(oObject, FRAMEWORK_OUTSIDER, TRUE);
                        DelayCommand(0.1, RegisterEncounterToFramework(oObject));
                    }
                    break;
                case OBJECT_TYPE_PLACEABLE:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                    {
                        SetLocalInt(oObject, FRAMEWORK_OUTSIDER, TRUE);
                        DelayCommand(0.1, RegisterPlaceableToFramework(oObject));
                    }
                    break;
                case OBJECT_TYPE_STORE:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_STORE_ON_OPEN), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                    {
                        SetLocalInt(oObject, FRAMEWORK_OUTSIDER, TRUE);
                        DelayCommand(0.1, RegisterStoreToFramework(oObject));
                    }
                    break;
                case OBJECT_TYPE_TRIGGER:
                    if (GetStringLeft(GetEventScript(oObject, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER), GetStringLength(HOOK_SCRIPT_PREFIX)) != HOOK_SCRIPT_PREFIX)
                    {
                        SetLocalInt(oObject, FRAMEWORK_OUTSIDER, TRUE);
                        DelayCommand(0.1, RegisterTriggerToFramework(oObject));
                    }
                    break;
                default:
                    break;
            }

            oObject = GetNextObjectInArea(oArea);
        }

        oArea = GetNextArea();
    }
}
