// -----------------------------------------------------------------------------
//    File: tr_i_events.nss
//  System: Travel (events)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

#include "tr_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< tr_OnAreaEnter >---
// Local OnAreaEnter event function for overland travel maps.  This function
//  initiates the encounter variables for the current travel map and starts
//  the encounter check timer for each PC.
void tr_OnAreaEnter();

// ---< tr_OnAreaEnter >---
// Local OnAreaExit event function for overland travel maps.  This function
//  cleans up the variables set when the PC entered the map.
void tr_OnAreaExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void tr_OnAreaEnter()
{
    object oPC = GetEnteringObject();

    if (!_GetIsPC(oPC))
        return;

    if (!CountList(_GetLocalString(OBJECT_SELF, TRAVEL_ENCOUNTER_AREAS)))
        return;

    int nTimerID, nReturning = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);

    if (!nReturning)    //Entering area from another area, not from an encounter
    {
        _SetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS, TRAVEL_ENCOUNTER_LIMIT + (-1 + Random(3)) * Random(TRAVEL_ENCOUNTER_LIMIT_JITTER));
        _DeleteLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);

        Debug("Maximum encounters for this PC is " + IntToString(_GetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS)));

        nTimerID = CreateTimer(oPC, TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE, TRAVEL_ENCOUNTER_TIMER_INTERVAL, 0, TRAVEL_ENCOUNTER_TIMER_JITTER);
        _SetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID, nTimerID);
        StartTimer(nTimerID, FALSE);
    }
    else
    {
        nTimerID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
        StartTimer(nTimerID, FALSE);
        DelayCommand(5.0f, _DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_ID));
    }

    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5f);
}

void tr_OnAreaExit()
{
    object oPC = GetExitingObject();

    if (!_GetIsPC(oPC))
        return;

    if (!CountList(_GetLocalString(OBJECT_SELF, TRAVEL_ENCOUNTER_AREAS)))
        return;

    int nEncounterID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
    int nTimerID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
    
    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 1.0f);

    if (!nEncounterID)
    {
        KillTimer(nTimerID);

        _DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
        _DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
        _DeleteLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS);
        _DeleteLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
        _DeleteLocalLocation(oPC, TRAVEL_CREATURE_LOCATION);

        /*TODO Chase implementation
        if (_GetLocalInt(oPC,TRAVEL_ENCOUNTER_CHASE ))
        {
            _DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_CHASE);
            tr_KillEncounter(nEncounterID)
        }*/
    }
    else
        StopTimer(nTimerID);
}

void tr_encounter_OnPlayerDeath()
{
    _SetLocalInt(OBJECT_SELF, TRAVEL_ENCOUNTER_PLAYER_DEATH, TRUE);
}

void tr_encounter_OnTimerExpire()
{
    object oPC = OBJECT_SELF;
    int nTimerID, nGoing, nEncounters = _GetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    int nEncounterID, nMaxEncounters = _GetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS);

    if (!_GetIsPC(oPC))
        return;

    /* TODO Chase implementation
    - if being chased and variable set
    - guarantee the encounter to the previous id
    */
    
    if (nEncounters >= nMaxEncounters && TRAVEL_ENCOUNTER_LIMIT)
    {
        nTimerID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER_ID);
        KillTimer(nTimerID);
        Debug("Max encounters reached, no more for this guys.");
        return;
    }
 
    if (GetIsDawn() || GetIsDay())
        nGoing = (Random(100) <= TRAVEL_ENCOUNTER_CHANCE_DAY);
    else
        nGoing = (Random(100) < TRAVEL_ENCOUNTER_CHANCE_NIGHT);

    if (nGoing)
    {
        if (nEncounterID = tf_CreateEncounter(oPC))
            tr_StartEncounter(nEncounterID);
    }
    else
        Debug("Encounter checked for " + GetName(oPC) + ".  Party is staying put for now.");
}

void tr_encounter_OnAreaExit()
{
    //This needs to be run after the module removes the player from the area_roster
    object oPC = GetExitingObject();
    location lPC = _GetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION);
    int nEncounterID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);;

    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);

    if (!GetIsObjectValid(GetAreaFromLocation(lPC)))
    {
        //TODO Need a default destination here, in case of getting stucks and no DMs are online.
        return;
    }

    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, JumpToLocation(lPC));

    //big TODO make sure all required functions are exposed in the library script
    if (!CountObjectList(te.oEncounterArea, AREA_ROSTER))
    {
        /* TODO Chase implementation
        - if any enemies in area
            - decide if going to give chase
            - if yes, set variable to guarantee re-encounter after specific number of
            -   timer intervals
            -if not, kill encounter*/
    
        tr_KillEncounter(te.nEncounterID);
    }
}

void tr_encounter_OnAOEEnter()
{
    object oTarget, oEncounterAOE = OBJECT_SELF;
    object oPC = GetEnteringObject();
    int nEncounterID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
        
    if (nEncounterID)
        return;

    nEncounterID = _GetLocalInt(oEncounterAOE, TRAVEL_ENCOUNTER_ID);
    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);
 
    int nWaypointCount = CountList(te.sSecondaryWaypoints);

    if ((TRAVEL_ENCOUNTER_ALLOW_STRANGERS) || (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY && _GetIsPartyMember(oPC, te.oTriggeredBy)))
    {
        if (GetIsObjectValid(te.oEncounterArea) && CountObjectList(te.oEncounterArea, AREA_ROSTER))
        {
            if (nWaypointCount)
                oTarget = GetWaypointByTag(GetListItem(te.sSecondaryWaypoints, Random(nWaypointCount) + 1));
            else
                oTarget = GetWaypointByTag(te.sPrimaryWaypoint);

            if (GetIsObjectValid(oTarget))
            {
                _SetLocalInt(oPC, TRAVEL_ENCOUNTER_ID, nEncounterID);
                _SetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION, GetLocation(oPC));
                AssignCommand(oPC, ClearAllActions());
                AssignCommand(oPC, JumpToObject(oTarget));

                Debug(GetName(oPC) + " has been sent to the encounter area for encounter " +
                    te.sEncounterID + " via the encounter AOE");
            }
            else
                Debug(GetName(oPC) + " is attempting to enter encounter " + te.sEncounterID +
                    "via an AOE entry, but a valid entry waypoint could not be found.");
        }
    }
}
