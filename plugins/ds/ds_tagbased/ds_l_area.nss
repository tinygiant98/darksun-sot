// -----------------------------------------------------------------------------
//    File: ds_l_area.nss
//  System: Event Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"

#include "nwnx_creature"

/* Sample ===
void area_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oArea = OBJECT_SELF;

    if (sEvent == AREA_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();

    }
    else if (sEvent == AREA_EVENT_ON_EXIT)
    {
        oPC = GetExitingObject();

    }
    else if (sEvent == AREA_EVENT_ON_HEARTBEAT)
    {

    }
    else if (sEvent == AREA_EVENT_ON_USER_DEFINED)
    {
        int nEvent = GetUserDefinedEventNumber();

    }
    else if (sEvent == AREA_EVENT_ON_EMPTY)
    {

    }
}
*/

void travel001()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oArea = OBJECT_SELF;

    if (sEvent == AREA_EVENT_ON_ENTER)
    {
        oPC = GetEnteringObject();
        SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 0.25f);

        float fFactor = 0.25;
        SetLocalFloat(oArea, "MOVEMENT_RATE_FACTOR", fFactor);

        NWNX_Creature_SetMovementRateFactor(oPC, NWNX_Creature_GetMovementRateFactor(oPC) * fFactor);
    }
    else if (sEvent == AREA_EVENT_ON_EXIT)
    {
        oPC = GetExitingObject();
        SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 1.0f);

        NWNX_Creature_SetMovementRateFactor(oPC, 1.0);
    }
    else if (sEvent == AREA_EVENT_ON_HEARTBEAT)
    {

    }
    else if (sEvent == AREA_EVENT_ON_USER_DEFINED)
    {
        int nEvent = GetUserDefinedEventNumber();

    }
    else if (sEvent == AREA_EVENT_ON_EMPTY)
    {

    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // RegisterLibraryScript("area_tag", 1);
    RegisterLibraryScript("travel001", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  area_tag();           break;
        case 1: travel001(); break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
