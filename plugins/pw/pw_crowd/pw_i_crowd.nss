// -----------------------------------------------------------------------------
//    File: pw_i_crowd.nss
//  System: Simulated Population (core)
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "pw_c_crowd"
#include "pw_k_crowd"
#include "core_i_framework"
#include "util_i_varlists"
#include "util_i_data"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< NormalizeCrowdVariables >---
// Checks specific variables set on crowd initializer item to ensure the
//  values are compatible with this system.  If not, a default value will
//  be set and a NOTICE will be sent to the server log.
void NormalizeCrowdVariables(object oItem);

// ---< InitializeCrowds >---
// Creates an object list on an area datapoint to hold crowd data.
void InitializeCrowds(object oArea = OBJECT_SELF);

// ---< SpawnCrowds >---
// Loops through the area's crowd initializer items, loads variables from those
//  items into a CommonerSettingStructure and calls the primary function to
//  spawn and update the referenced crowd.
void SpawnCrowds(object oArea = OBJECT_SELF);

// ---< ClearCrowds >---
// Loops through the area's crowd initializer items, finds the tags of the crowd
//  members that are active and destroys all crowd members.  This is called from
//  crowd_OnAreaExit (event) when there are no PCs in the area.
void ClearCrowds(object oArea = OBJECT_SELF);

// ---< GetSpawnDelay >---
// Generates and returns a random float between min and max.
float GetSpawnDelay(object oItem);

// ---< GetCrowdLimit >---
// Determines the maximum population the crowd is allowed to be based on
//  initializer item settings.
int GetCrowdLimit(object oItem);

// ---< GetCrowdWaypointCount >---
// Determines the number of available waypoints for this crowd and saves it
//  for future use
int GetCrowdWaypointCount(object oArea, string sTag);

// ---< DerosterCrowdMember >---
// Crowd members who make it to their destination or are otherwise removed from
//  the area without being killed will be removed from the crowd roster with
//  this function.
void DerosterCrowdMember(object oMember);

// ---< WalkCrowdMember >---
// Selects a waypoint for the crowd member to walk to and forces the crowd
//  member to walk to that point.
void WalkCrowdMember(object oMember, object oOrigin, object oItem);

// ---< SpawnCrowdMember >---
// Primary function for spawning a crowd member.  This function will select the
//  NPC resref, clothing resref and spawn location for the crowd member.
void SpawnCrowdMember(object oItem);

// ---< DelayAndSpawnCrowdMember >---
// This function randomly delays spawning the next crowd member by an amount
// between the min and max delays settings on the crowd initializer item.
void DelayAndSpawnCrowdMember(object oItem);

// ---< UpdateCrowds >---
// Called from the timer expiration event, this function check to see if any
//  new crowd members need to be spawned and, if so, sets them up for spawning.
void UpdateCrowds(object oItem);

// ---< ResumeCrowdMemberActivity >---
// Since all NPCs can be interacted with, this function will return an NPC to
//  their routine after being interupted by a PC.
void ResumeCrowdMemberActivity(object oMember = OBJECT_SELF);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void NormalizeCrowdVariables(object oItem)
{
    dbg = sDebugPlugin + "NormalizeCrowdVariables:: ";
    Debug(dbg);

    float epsilon = 0.0001f;
    if (GetLocalString(oItem, CROWD_CONVERSATION) == "")
    {
        SetLocalString(oItem, CROWD_CONVERSATION, CROWD_DEFAULT_CONVERSATION);
        Notice(dbg + "Crowd conversation not assigned to initializer item, " +
            "default conversation '" + CROWD_DEFAULT_CONVERSATION + "' assigned to " + GetName(oItem));
    }

    if (GetLocalFloat(oItem, CROWD_SPAWN_DELAY_MIN) <= epsilon &&
        GetLocalFloat(oItem, CROWD_SPAWN_DELAY_MAX) <= epsilon ||
        GetLocalFloat(oItem, CROWD_SPAWN_DELAY_MAX) < GetLocalFloat(oItem, CROWD_SPAWN_DELAY_MIN))
    {
        SetLocalFloat(oItem, CROWD_SPAWN_DELAY_MIN, CROWD_DEFAULT_MIN_SPAWN_DELAY);
        SetLocalFloat(oItem, CROWD_SPAWN_DELAY_MAX, CROWD_DEFAULT_MAX_SPAWN_DELAY);
        Notice(dbg + "Default values for spawn delays set on " + GetName(oItem));
    }

    if (GetLocalFloat(oItem, CROWD_WALKTIME_LIMIT) < 1.0f)
    {
        SetLocalFloat(oItem, CROWD_WALKTIME_LIMIT, CROWD_DEFAULT_WALK_TIME);
        Notice(dbg + "Crowd default walk time set on " + GetName(oItem));
    }

    if (!GetLocalInt(oItem, CROWD_POPULATION_DAY) &&
        !GetLocalInt(oItem, CROWD_POPULATION_NIGHT) &&
        !GetLocalInt(oItem, CROWD_POPULATION_WEATHER))
    {
        SetLocalInt(oItem, CROWD_POPULATION_DAY, 1);
        Notice(dbg + "Crowd count set to '1' on " + GetName(oItem));
    }

    if (GetLocalString(oItem, CROWD_MEMBER_TAG) == "")
    {
        SetLocalString(oItem, CROWD_MEMBER_TAG, CROWD_DEFAULT_TAG);
        Notice(dbg + "Default crowd member tag set on " + GetName(oItem));
    }

    if (GetLocalString(oItem, CROWD_MEMBER_NAME) == "")
    {
        SetLocalString(oItem, CROWD_MEMBER_NAME, CROWD_DEFAULT_NAME);
        Notice(dbg + "Default value for crowd member name set on " + GetName(oItem));
    }

    if (GetLocalFloat(oItem, CROWD_UPDATE_INTERVAL) < 6.0001f)
    {
        SetLocalFloat(oItem, CROWD_UPDATE_INTERVAL, CROWD_DEFAULT_INTERVAL);
        Notice(dbg + "Crowd update interval must be greater than heartbeat interval; " + 
            "default value set on " + GetName(oItem));
    }
}

void InitializeCrowds(object oArea = OBJECT_SELF)
{
    dbg = sDebugPlugin + "InitializeCrowds:: ";
    Debug(dbg);

    string sCrowds = GetLocalString(oArea, CROWD_CSV);
    int i, nIndex, nCount = CountList(sCrowds);
    if (!nCount)
    {
        Error(dbg + "Crowd list variable '" + CROWD_CSV + "' is empty for " + GetName(oArea));
        return;
    }
    
    for (i = 0; i < nCount; i++)
    {
        string sCrowd = GetListItem(sCrowds, i);
        if ((nIndex = FindListItem(GetLocalString(CROWDS, CROWD_ITEM_LOADED_CSV), sCrowd)) > -1)
        {
            CopyListObject(CROWDS, AREA_CROWDS, CROWD_ITEM_OBJECT_LIST, AREA_CROWD_ITEM_OBJECT_LIST, nIndex, TRUE);
            Debug(dbg + "Crowd item " + CROWD_ITEM_PREFIX + sCrowd + " loaded on " + GetName(oArea));
        }
    }

    SetLocalInt(oArea, AREA_CROWD_ITEM_INITIALIZED, TRUE);
    SpawnCrowds(oArea);
}

void SpawnCrowds(object oArea = OBJECT_SELF)
{
    dbg = sDebugPlugin + "SpawnCrowds:: ";
    Debug(dbg);

    if (!GetLocalInt(oArea, AREA_CROWD_ITEM_INITIALIZED))
    {
        InitializeCrowds(oArea);
        Warning(dbg + "Crowd system for " + GetName(oArea) + " initialized from backup check.");
    }

    int i, nIndex, nCount = CountObjectList(AREA_CROWDS, AREA_CROWD_ITEM_OBJECT_LIST);
    int nTimerID, nWaypointCount;
    float fInterval;
    object oItem;

    if (!nCount)
    {
        Error(dbg + "No crowd initializer objects set on " + GetName(oArea) +
            "; check '" + CROWD_CSV + "' variable set on area in toolset or via code.");
        return;
    }
    
    for (i=0; i < nCount; i++)
    {
        oItem = GetListObject(AREA_CROWDS, i, AREA_CROWD_ITEM_OBJECT_LIST);
        NormalizeCrowdVariables(oItem);

        if (GetIsObjectValid(oItem))
        {
            string sWaypointTag = GetLocalString(oItem, CROWD_WAYPOINT_TAG);
            if (sWaypointTag == "")
            {
                Error(dbg + "Waypoint tag required for crowd to spawn; check '" + CROWD_WAYPOINT_TAG +
                    " is set on initializaer item " + GetName(oItem));
                return;
            }
            else
            {
                if (!(nWaypointCount = GetCrowdWaypointCount(oArea, sWaypointTag)))
                {
                    Error(dbg + "Crowd waypoints not found for " + GetName(oItem) +
                        " in " + GetName(oArea));
                    break;
                }
                else
                    SetLocalInt(oItem, CROWD_WP_COUNT, nWaypointCount);
            }
            
            fInterval = GetLocalFloat(oItem, CROWD_UPDATE_INTERVAL);
            nTimerID = CreateEventTimer(oItem, CROWD_EVENT_ON_TIMER_EXPIRED, fInterval);
            SetLocalInt(oItem, CROWD_CHECK_TIMER, nTimerID);
            SetLocalObject(oItem, CROWD_OWNER, oArea);
            StartTimer(nTimerID, TRUE);
        }
        else
            Warning(dbg + "Initializer list item at index " + IntToString(i) + " is invalid " +
                "for " + GetName(oArea));
    }
}

void ClearCrowds(object oArea = OBJECT_SELF)
{
    dbg = sDebugPlugin + "ClearCrowds:: ";
    Debug(dbg);

    string sRoster, sCrowd, sCrowds = GetLocalString(OBJECT_SELF, CROWD_CSV);
    object oItem, oMember;

    int i, nIndex, nCount = CountObjectList(AREA_CROWDS, AREA_CROWD_ITEM_OBJECT_LIST);
    int j, nRoster, nTimerID;

    for (i = 0; i < nCount; i++)
    {
        oItem = GetListObject(AREA_CROWDS, i, AREA_CROWD_ITEM_OBJECT_LIST);
        
        nRoster = CountObjectList(oItem, CROWD_ROSTER);
        for (j = 0; j < nRoster; j++)
        {
            oMember = GetListObject(oItem, j, CROWD_ROSTER);
            DestroyObject(oMember);
        }

        Debug(dbg + IntToString(j) + " objects removed from CROWD_ROSTER on " + GetName(oItem));
        DeleteObjectList(oItem, CROWD_ROSTER);
        
        nTimerID = GetLocalInt(oItem, CROWD_CHECK_TIMER);
        if (nTimerID)
        {
            KillTimer(nTimerID);
            DeleteLocalInt(oItem, CROWD_CHECK_TIMER);
            Debug(dbg + "Killed timer " + IntToString(nTimerID) + " on " + GetName(oItem));
        }
        else
            Warning(dbg + "Timer for crowd item '" + GetName(oItem) + "' in " +
                GetName(oArea) + " not found");
    }
}

float GetSpawnDelay(object oItem)
{
    dbg = sDebugPlugin + "GetSpawnDelay:: ";
    Debug(dbg);

    float fMin = GetLocalFloat(oItem, CROWD_SPAWN_DELAY_MIN);
    float fMax = GetLocalFloat(oItem, CROWD_SPAWN_DELAY_MAX);

    float precision = 10.0f;
    int iMin = FloatToInt(fMin * precision);
    int iMax = FloatToInt(fMax * precision);
    int iRandom = Random(iMax - iMin) + iMin;

    return IntToFloat(iRandom) / precision;
}

int GetCrowdLimit(object oItem)
{
    dbg = sDebugPlugin + "GetCrowdLimit:: ";
    Debug(dbg);

    object oArea = GetLocalObject(oItem, CROWD_OWNER);
    
    int nMax = GetLocalInt(oItem, CROWD_POPULATION_DAY);
    if (GetIsNight())
        nMax = GetLocalInt(oItem, CROWD_POPULATION_NIGHT);

    int weather = GetWeather(oArea);
    if (weather == WEATHER_RAIN || weather == WEATHER_SNOW)
        nMax = min(nMax, GetLocalInt(oItem, CROWD_POPULATION_WEATHER));

    return nMax;
}

int GetCrowdWaypointCount(object oArea, string sTag)
{
    dbg = sDebugPlugin + "GetCrowdWaypointCount:: ";
    Debug(dbg);

    object oWaypoint, oPC = GetListObject(oArea, 0, AREA_ROSTER);
    if (!GetIsObjectValid(oPC))
    {
        Error(dbg + "PC not detected in " + GetName(oArea));
        return FALSE;
    }

    oWaypoint = GetNearestObjectByTag(sTag, oPC, 1);
    int i;
    
    while (GetIsObjectValid(oWaypoint))
    {
        i++;
        oWaypoint = GetNearestObjectByTag(sTag, oPC, i + 1);
    }

    return i;
}

void DerosterCrowdMember(object oMember)
{
    dbg = sDebugPlugin + "DerosterCrowdMember:: ";
    Debug(dbg);

    object oOwner = GetLocalObject(oMember, CROWD_OWNER);
    RemoveListObject(oOwner, oMember, CROWD_ROSTER);
}

void WalkCrowdMember(object oMember, object oOrigin, object oItem)
{
    dbg = sDebugPlugin + "WalkCrowdMember:: ";
    Debug(dbg);

    int nWaypointCount = GetLocalInt(oItem, CROWD_WP_COUNT);
    string sWaypointTag = GetLocalString(oItem, CROWD_WAYPOINT_TAG);

    object oDestination = GetNearestObjectByTag(sWaypointTag, oOrigin, Random(nWaypointCount - 1) + 1);
    if (oDestination == OBJECT_INVALID || oDestination == oOrigin)
    {
        Error(dbg + "Crowd member's destination waypoint is " + 
            (oDestination == oOrigin ? "the same as member's origin waypoint." : "invalid"));
        return;
    }

    SetLocalObject(oMember, CROWD_DESTINATION, oDestination);
    AssignCommand(oMember, ActionForceMoveToObject(oDestination, FALSE, 1.0f, GetLocalFloat(oItem, CROWD_WALKTIME_LIMIT)));
    AssignCommand(oMember, ActionDoCommand(DerosterCrowdMember(oMember)));
    AssignCommand(oMember, ActionDoCommand(DestroyObject(oMember)));
}

void SpawnCrowdMember(object oItem)
{
    dbg = sDebugPlugin + "SpawnCrowdMember:: ";
    Debug(dbg);

    object oArea = GetLocalObject(oItem, CROWD_OWNER);
    string sItem = GetName(oItem);

    int nCount, nCrowdWaypointCount = GetLocalInt(oItem, CROWD_WP_COUNT);
    
    object oPC = GetListObject(oArea, 0, AREA_ROSTER);
    if (!GetIsObjectValid(oPC))
    {
        Error(dbg + "PC not detected in " + GetName(oArea));
        return;
    }

    object oOrigin = GetNearestObjectByTag(GetLocalString(oItem, CROWD_WAYPOINT_TAG), oPC, Random(nCrowdWaypointCount) + 1);
    if (!GetIsObjectValid(oOrigin))
    {
        Error(dbg + "Valid origin waypoint for " + sItem + 
            "not found in " + GetName(oArea));
        return;
    }

    string sCrowd = GetLocalString(oItem, CROWD_MEMBER_RESREF);
    if (!(nCount = CountList(sCrowd)))
    {
        Error(dbg + "Crowd templates not found for " + sItem + " in " + GetName(oArea));
        return;
    }    

    string sExceptions, sMember = GetListItem(sCrowd, Random(CountList(sCrowd)));
    object oMember = CreateObject(OBJECT_TYPE_CREATURE, sMember, GetLocation(oOrigin), FALSE, GetLocalString(oItem, CROWD_MEMBER_TAG));
    AddListObject(oItem, oMember, CROWD_ROSTER);
    SetLocalObject(oMember, CROWD_OWNER, oItem);

    SetName(oMember, GetLocalString(oItem, CROWD_MEMBER_NAME));

    if (GetLocalInt(oItem, CROWD_CLOTHING_RANDOM))
    {
        string sWardrobe = GetLocalString(oItem, CROWD_CLOTHING_RESREF);
        string sOutfit = GetListItem(sWardrobe, Random(CountList(sWardrobe)));
        object oOutfit = CreateItemOnObject(sOutfit, oMember);
        if (GetIsObjectValid(oOutfit))
            AssignCommand(oMember, ActionEquipItem(oOutfit, INVENTORY_SLOT_CHEST));
        else
        {
            Error(dbg + "Clothing object '" + sOutfit + "' required, but not found - " +
                "removing crowd member");
            DerosterCrowdMember(oMember);
            DestroyObject(oMember);
            return;
        }
    }

    SetLocalInt(oItem, CROWD_QUEUE, GetLocalInt(oItem, CROWD_QUEUE) - 1);
    SetLocalString(oMember, CROWD_CONVERSATION, GetLocalString(oItem, CROWD_CONVERSATION));
    SetLocalString(oMember, CREATURE_EVENT_ON_DEATH, CROWD_CREATURE_DEATH_SCRIPT);

    //sExceptions = CREATURE_EVENT_ON_DEATH + "," + CREATURE_EVENT_ON_CONVERSATION;
    //Debug(dbg + "sExceptions = " + sExceptions);
    //SetDispatchExceptions(oMember, sExceptions, TRUE);

    if (!GetLocalInt(oItem, CROWD_STATIONARY))
        WalkCrowdMember(oMember, oOrigin, oItem);
}

void DelayAndSpawnCrowdMember(object oItem)
{
    dbg = sDebugPlugin + "DelayAndSpawnCrowdMember:: ";
    Debug(dbg); 

    object oArea = GetLocalObject(oItem, CROWD_OWNER);
    float fDelay = GetSpawnDelay(oItem);
    DelayCommand(fDelay, SpawnCrowdMember(oItem));
    SetLocalInt(oItem, CROWD_QUEUE, GetLocalInt(oItem, CROWD_QUEUE) + 1);
}

void UpdateCrowds(object oItem)
{
    dbg = sDebugPlugin + "UpdateCrowds:: ";
    Debug(dbg);

    object oArea = GetLocalObject(oItem, CROWD_OWNER);
    int nPopulation = GetCrowdLimit(oItem);
    int nMembers = CountObjectList(oItem, CROWD_ROSTER);

    while (nMembers < nPopulation - GetLocalInt(oItem, CROWD_QUEUE))
    {
        DelayAndSpawnCrowdMember(oItem);
        nMembers = CountObjectList(oItem, CROWD_ROSTER);
    }
}

void ResumeCrowdMemberActivity(object oMember = OBJECT_SELF)
{
    dbg = sDebugPlugin + "ResumeCrowdMemberActivity:: ";
    Debug(dbg);

    object oDestination = GetLocalObject(oMember, CROWD_DESTINATION);
    if (!GetIsObjectValid(oDestination))
    {
        Error(dbg + "Unable to find valid destination waypoint for " + 
            GetLocalString(oMember, CROWD_ITEM) + " in " + GetName(GetArea(oMember)));
        return;
    }
    else
        AssignCommand(oMember, ActionForceMoveToObject(oDestination));
    
    AssignCommand(oMember, ActionDoCommand(DerosterCrowdMember(oMember)));
    AssignCommand(oMember, ActionDoCommand(DestroyObject(oMember)));
}
