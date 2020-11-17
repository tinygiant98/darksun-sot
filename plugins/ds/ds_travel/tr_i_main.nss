// -----------------------------------------------------------------------------
//    File: unid_i_main.nss
//  System: UnID Item on Drop (core)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
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

#include "tr_i_config"
#include "tr_i_const"
#include "tr_i_text"
#include "ds_i_const"
#include "util_i_data"
#include "core_i_constants"
#include "corpse_i_const"
#include "loot_i_main"
#include "pw_i_core"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< _setEncounterVariables >---
// Internal function for setting the required variables on any object travelling
//  to an encounter area.
void _setEncounterVariables(object oPC, int nEncounterID);

// ---< tr_CreateEncounter >---
// Sets up all required objects for an encounter to occur.  Returns the encounter
//  ID.  Once this encounter has been created, the encounter ID can be used to 
//  start the encounter and kill the encounter.  The encounter cannot be killed
//  if there is a PC in the area.
int tr_CreateEncounter(object oPC);

// ---< tr_KillEncounter >---
// Deletes all variables associated with nEncounterID, if passed.  If not passed,
//  it is assumed the function is being called from the OnAreaEmpty event.  Will
//  check for PCs in the area and abort if found.  Destroys the encounter area.
void tr_KillEncounter(int nEncounterID = 0);

// ---< tr_StartEncounter >---
// Starts the encounter nEncounterID.  This should never be called if
//  tr_CreateEncounter did not return a valid encounter ID.  
void tr_StartEncounter(int nEncoutnerID);

// ---< tr_CheckForEncounter >---
// This is the executed script with the custom timer event for the overland travel
//  system expires.  This function checks to see if the party will have an
//  encounter during their overland travel and, if so, sends them there.
void tr_CheckForEncounter();

// ---< tr_EncounterExit >---
// This function sends the PC back to where they came from after the conclusion
//  of an encounter.
void tr_EncounterExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void _setEncounterVariables(object oPC, int nEncounterID)
{
    int nEncounters = _GetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    
    _SetLocalInt(oPC, TRAVEL_ENCOUNTER_ID, nEncounterID);
    _SetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS, ++nEncounters);
    _SetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION, GetLocation(oPC));
}

struct TRAVEL_ENCOUNTER tr_GetEncounterData(int nEncounterID)
{
    struct TRAVEL_ENCOUNTER te;

    te.nEncounterID = nEncounterID;
    te.sEncounterID = IntToString(nEncounterID);
    te.oEncounterArea = _GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + te.sEncounterID);
    te.oTriggeredBy = _GetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY + te.sEncounterID);
    te.sPrimaryWaypoint = _GetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT + te.sEncounterID);
    te.sSecondaryWaypoints = _GetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + te.sEncounterID);
    te.sSpawnPoints = _GetLocalString(ENCOUNTERS, ENCOUNTER_SPAWNPOINTS + te.sEncounterID);

    return te;
}

int tf_CreateEncounter(object oPC)
{
    object oEncounterArea, oTravelArea = GetArea(oPC);
    string sSecondaryWaypoints, sWaypointTag, sWaypoints, sTriggers, sSpawnPoints, sEncounterArea;
    string sWaypointType, sEncounterAreas = _GetLocalString(oTravelArea, TRAVEL_ENCOUNTER_AREAS);
    int nArea, nEncounterID, nCount = CountList(sEncounterAreas);
    int i = 2;

    if (!nCount)
    {
        Debug("Unable to create encounter, no encounter areas defined on oTravelArea's ENCOUNTER_AREA variable.");
        return 0;
    }
    
    nEncounterID = _GetLocalInt(ENCOUNTERS, TRAVEL_ENCOUNTER_NEXT_ID);
    
    if (!nEncounterID)
        nEncounterID = 1;

    string sEncounterID = IntToString(nEncounterID);
    
    Debug("Creating encounter ID " + sEncounterID + " for " + GetName(oPC));

    sEncounterArea = GetListItem(sEncounterAreas, Random(nCount));

    Debug("Attempting to create new area from resref " + sEncounterArea +
        "\n  nCount " + IntToString(nCount) +
        "\n  sEncounterAreas " + sEncounterAreas +
        "\n  sEncounterArea " + sEncounterArea);
    oEncounterArea = CreateArea(sEncounterArea, TRAVEL_ENCOUNTER_AREA_TAG + IntToString(nEncounterID), "Encounter");

    object oAreaObject = GetFirstObjectInArea(oEncounterArea);

    while (GetIsObjectValid(oAreaObject))
    {
        if (GetObjectType(oAreaObject) == OBJECT_TYPE_WAYPOINT)
        {
            Debug("  Encounter area object:  " + GetTag(oAreaObject));
            sWaypointType = GetStringLowerCase(_GetLocalString(oAreaObject, TRAVEL_WAYPOINT_TYPE));
            if (sWaypointType == TRAVEL_WAYPOINT_TYPE_PRIMARY)
                SetTag(oAreaObject, TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(1));
            else if (sWaypointType == TRAVEL_WAYPOINT_TYPE_SECONDARY)
            {
                sWaypointTag = TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(i++);
                SetTag(oAreaObject, sWaypointTag);
                sSecondaryWaypoints = AddListItem(sSecondaryWaypoints, sWaypointTag);
            }
            else if (sWaypointType == TRAVEL_WAYPOINT_TYPE_SPAWN)
            {
                sWaypointTag = TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(i++);
                SetTag(oAreaObject, sWaypointTag);
                sSpawnPoints = AddListItem(sSpawnPoints, sWaypointTag);
            }
        }

        oAreaObject = GetNextObjectInArea(oEncounterArea);
    }

    //Save encounter variables
    _SetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID, TRAVEL_WAYPOINT_TAG + sEncounterID + IntToString(1));
    _SetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID, sSecondaryWaypoints);
    _SetLocalString(ENCOUNTERS, ENCOUNTER_SPAWNPOINTS         + sEncounterID, sSpawnPoints);
    _SetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID, oPC);
    _SetLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID, oEncounterArea);
    _SetLocalInt   (ENCOUNTERS, TRAVEL_ENCOUNTER_NEXT_ID                    , nEncounterID + 1);

    //Set area events.
    _SetLocalString(oEncounterArea, AREA_EVENT_ON_EXIT, "tr_encounter_OnAreaExit:only");
    _SetLocalString(oEncounterArea, MODULE_EVENT_ON_PLAYER_DEATH, "tr_encounter_OnPlayerDeath");

    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);

    Debug("Successfully created encounter with ID " + sEncounterID + 
                "\n  Triggered by " + GetName(te.oTriggeredBy) +
                "\n  Occuring in " + GetName(te.oEncounterArea) +
                "\n  Primary " + te.sPrimaryWaypoint +
                "\n  Secondary " + te.sSecondaryWaypoints +
                "\n  Spawn " + te.sSpawnPoints);
    return nEncounterID;
}

void tr_StartEncounter(int nEncounterID)
{
    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);
    int nWaypointCount = CountList(te.sSecondaryWaypoints);
    object oEncounterAOE, oTarget, oPartyMember = GetFirstFactionMember(te.oTriggeredBy);    
    location lEncounterAOE = GetLocation(te.oTriggeredBy);    
    float fDistance;
    
    if (!GetIsObjectValid(te.oTriggeredBy) || !_GetIsPC(te.oTriggeredBy))
    {
        tr_KillEncounter(nEncounterID);
        Debug("Could not start encounter ID " + IntToString(nEncounterID) + "\nTriggering object is invalid.");
        return;
    }

    Debug("Encounter " + te.sEncounterID + " started; triggered by " + GetName(te.oTriggeredBy));

    while (GetIsObjectValid(oPartyMember))
    {
        if (te.oTriggeredBy != oPartyMember && (fDistance = GetDistanceBetween(te.oTriggeredBy, oPartyMember)) == 0.0)
        {
            oPartyMember = GetNextFactionMember(te.oTriggeredBy);
            continue;
        }

        Debug("Distance between " + GetName(te.oTriggeredBy) + " and " + GetName(oPartyMember) + " is " + FloatToString(fDistance) + "m");

        if (fDistance <= TRAVEL_ENCOUNTER_WAYPOINT_INCLUDE)
            oTarget = GetWaypointByTag(te.sPrimaryWaypoint);
        else if (fDistance > TRAVEL_ENCOUNTER_WAYPOINT_INCLUDE && fDistance <= TRAVEL_ENCOUNTER_PARTY_INCLUDE)
            oTarget = GetWaypointByTag(GetListItem(te.sSecondaryWaypoints, Random(nWaypointCount) + 1));

        //TODO need to check for resting.  You can have an encoutner while you're resting, but you shouldn't port?  Or
        //  port and cancel rest?

        if (GetIsObjectValid(oTarget))
        {
            _setEncounterVariables(oPartyMember, nEncounterID);
            AssignCommand(oPartyMember, ClearAllActions());
            AssignCommand(oPartyMember, JumpToObject(oTarget));
            Debug(GetName(oPartyMember) + " send to encounter " + te.sEncounterID);
        }
        else
        {
            Debug("Could not find valid waypoint for encounter " + te.sEncounterID);
        }

        oPartyMember = GetNextFactionMember(te.oTriggeredBy);
    }

    if (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY)
    {
        effect eEncounterAOE = EffectAreaOfEffect(AOE_PER_CUSTOM_AOE, TRAVEL_ENCOUNTER_AOE_SCRIPT, "", "");
        ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eEncounterAOE, lEncounterAOE);
        oEncounterAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lEncounterAOE);
        SetTag(oEncounterAOE, TRAVEL_ENCOUNTER_AOE_TAG + te.sEncounterID);
        
        _SetLocalInt(oEncounterAOE, TRAVEL_ENCOUNTER_ID, nEncounterID);
        _SetLocalObject(ENCOUNTERS, TRAVEL_ENCOUNTER_AOE + te.sEncounterID, oEncounterAOE);
        
        //TODO increase the AOE radius and add a visual effect so we know there's an encounter there
        //Don't let the AOE be dispelled or destroyed
        _SetLocalInt(oEncounterAOE, "X1_L_IMMUNE_TO_DISPEL", 10);
        AssignCommand(oEncounterAOE, SetIsDestroyable(FALSE));

        Debug("Encounter AOE for encounter " + te.sEncounterID + " created.");
    }
}

void tr_KillEncounter(int nEncounterID = 0)
{
    string sEncounterID = IntToString(nEncounterID);
    object oEncounterArea = nEncounterID ? _GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + sEncounterID) : OBJECT_SELF;

    //TODO check why area_roster shows a PC when DestroyArea does not.
    /*if (!CountObjectList(oEncounterArea, AREA_ROSTER))
        {
            Debug("Cannot kill encounter " + sEncounterID + "; PCs detected in encounter area.");
            //TODO delaycommand to recall this procedures?
            return;
        }*/

    if (_GetLocalInt(oEncounterArea, TRAVEL_ENCOUNTER_PLAYER_DEATH))
    {
        //Search for dead bodies and bring them back.
        object oNewCorpse, oObject = GetFirstObjectInArea(oEncounterArea);
        while (GetIsObjectValid(oObject))
        {
            string sObjectTag = GetTag(oObject);

            if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE
                && GetStringLeft(sObjectTag, GetStringLength(H2_CORPSE)) == H2_CORPSE)
            {
                //TODO figure out a more efficient way to do this.
                object oCorpseToken = GetItemPossessedBy(oObject, H2_PC_CORPSE_ITEM);
                string uniquePCID = _GetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID);
                object oPC = h2_FindPCWithGivenUniqueID(uniquePCID);
                if (GetIsObjectValid(oPC))
                {
                    location lDestination = _GetLocalLocation(oPC, TRAVEL_CREATURE_LOCATION);
                    _SetLocalLocation(oCorpseToken, H2_LAST_DROP_LOCATION, lDestination);
                    oNewCorpse = CopyObject(oObject, lDestination);
                    object oLootBag = _GetLocalObject(oPC, H2_LOOT_BAG);
                    object oNewLootBag = h2_CreateLootBag(oNewCorpse);
                    h2_MovePossessorInventory(oLootBag, TRUE, oNewLootBag);
                    _SetLocalObject(oPC, H2_LOOT_BAG, oNewLootBag);

                    /*  TODO ALTERNATE METHOD, IF IT WORKS
                    AssignCommand(oObject, ClearAllActions());
                    AssignCommand(oObject, JumpToObject(lDestination))
                    AssignCommand(oLootBag, ClearAllActions());
                    AssignCommand(oLootBag, JumpToObject(lDestination));
                    */   
                }
                else
                    oNewCorpse = CopyObject(oObject, GetLocation(GetObjectByTag(H2_WP_DEATH_CORPSE)));

                AssignCommand(oObject, SetIsDestroyable(TRUE, FALSE));
                DestroyObject(oObject);
            }
        }
    }

    //Get rid of the AOE portal
    if (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY)
    {
        object oEncounterAOE = _GetLocalObject(ENCOUNTERS, TRAVEL_ENCOUNTER_AOE + sEncounterID);
        _DeleteLocalObject(ENCOUNTERS, TRAVEL_ENCOUNTER_AOE + sEncounterID);
        AssignCommand(oEncounterAOE, SetIsDestroyable(TRUE));
        DestroyObject(oEncounterAOE);
    }

    //TODO chased by enemies that are still alive?
    // Idea:  If the spawn hasn't been depeleted, make a decision based on spawn strength
    //  whether the spawn will "give chase".  If so, on next timer expire, the party is
    //  guaranteed to re-encounter that spawn.  So, when returning, instead of killing
    //  everything, setup the auto-encounter to the same area.
    int nDestroy = DestroyArea(oEncounterArea);

    if (nDestroy < 1)
    {
        Debug("Cannot kill encounter " + sEncounterID + "; failure id " + IntToString(nDestroy));
        return;
    }
    else
        Debug("Encounter area for encounter " + sEncounterID + " destroyed.");

    _DeleteLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID);
    _DeleteLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID);
    _DeleteLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID);
    _DeleteLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID);
    _DeleteLocalString(ENCOUNTERS, ENCOUNTER_SPAWNPOINTS         + sEncounterID);
}
