// -----------------------------------------------------------------------------
//    File: ds_htf_i_main.nss
//  System: Hunger Thirst Fatigue (Dark Sun) (core)
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

#include "ds_i_const"
#include "ds_c_htf"
#include "pw_i_htf"
#include "pw_i_core"
#include "util_i_color"

//Variable Names
const string DS_HTF_VARIABLE_LAST_PC_FINDWATER_TIME = "ds_htf_last_PC_findwater_time";
const string DS_HTF_VARIABLE_AREATYPE = "ds_htf_areatype";
const string DS_HTF_AREATIMER_SCRIPT = "ds_htf_areatimer";
const string DS_HTF_VARIABLE_AREATIMER = "ds_htf_areatimer";
const string DS_HTF_VARIABLE_KILLTIMER = "ds_htf_killtimer";
const string DS_HTF_VARIABLE_COSTTRIGGER = "ds_htf_costtrigger";
const string DS_HTF_KILLTIMER_SCRIPT = "ds_htf_killtimer";
const string DS_HTF_LAST_TRAVEL_COST_PAID = "ds_htf_last_travel_cost_paid";

//Custom Events
const string DS_HTF_AREA_ON_TIMER_EXPIRE = "Area_OnTimerExpire";

//Custom HTF decrement factors
const int DS_HOUR_START_HEAT = 10;
const int DS_HOUR_STOP_HEAT = 7;

const float DS_FATIGUE_MULTIPLIER_THRIKREEN = 0.0;
const float DS_FATIGUE_MULTIPLIER_MUL = 0.5;
const float DS_FATIGUE_MULTIPLIER_RUN = 2.0;

const float DS_THIRST_MULTIPLIER_HEAT = 2.0;
const float DS_THIRST_MULTIPLIER_HALFGIANT = 2.0;

const float DS_HUNGER_MULTIPLIER_HALFGIANT = 2.0;

//String constants for colored text on associates
const string DS_HTF_BRACKET_L = "[";
const string DS_HTF_BRACKET_R = "]";
const string DS_HTF_DELIMITER = "|";
const string DS_HTF_BARS = "|||||";

const string DS_TEXT_BRACKET_L = "[";
const string DS_TEXT_BRACKET_R = "]";
const string DS_TEXT_DELIMITER = "|";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< ds_CreateAreaTravelTimer >---
//Creates a timer on the PC object using the modified HCR2 timer functions.  The timer duration
//  is set as DS_HTF_AREATRAVELCOST_DELAY in ds_htf_c.
void ds_CreateAreaTravelTimer(object oPC);

// ---< ds_DestroyAreaTravelTimer >---
//Destroy the timer created by ds_CreateAreaTravelTimer.
void ds_DestroyAreaTravelTimer(object oPC);

// ---< ds_ModifyFatigueDecrementUnit >---
// ---< ds_ModifyThirstDecrementUnit >---
// ---< ds_ModifyHungerDecrementUnit >---
//Functions to modify the various decrement units based on custom factors such as race,
//  time of day, etc.  Can be expanded to do almost anything.  Will only be called if
//  DS_USE_CUSTOM_DECREMENT_FACTORS in ds_htf_c is set to TRUE.
float ds_ModifyFatigueDecrementUnit(object oPC, float fDecrement);
float ds_ModifyThirstDecrementUnit(object oPC, float fDecrement);
float ds_ModifyHungerDecrementUnit(object oPC, float fDecrement);

// ---< ds_DisplayAssociateHTFValues >---
//Calculates and displays HTF values for associates of any non-DM PC.
void ds_DisplayAssociateHTFValues(object oCreature, float fThirst, float fHunger, float fFatigue);

// ---< ds_GetAreaTravelCost >---
//Looks up the area travel costs based on the type of area the PC is travelling in.  The area types
//  are held in a variable on the area object.  This is a holdover from how the system was
//  previously implemented.  If this behavior is not desired, this can be easily modified to use a set
//  value.  The area type constants are DS_AREATYPE_* in ds_constants_i.
int ds_GetAreaTravelCost(int iAreaType);

// ---< ds_GetAreaTravelMessage >---
//Looks up the custom area travel message as a text constant DS_AREATRAVELMESSAGE_* in ds_constants_i.
string ds_GetAreaTravelMessage(int iAreaType);

// ---< ds_SearchForWater >---
//Currently disabled due to circular reference I didn't have time to fix.  The hook into the HCR2 is amateur
//  at best, which is causing this circular reference.  I'll have to code a better hook to we don't have to
//  worry about the compilation problems.
void ds_SearchForWater(object oPC, int iAreaType);

// ---< ds_htf_AddAssociate >---
// Initializes an associate into the HTF system.  Timers and displays will work
//  just as on PCs, however, the displays will be part of the NPC's name
//  bubble when hovering over their avatar or using the tab key.
void ds_htf_AddAssociate();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

//Internal function to calculate the Travel Cost unit in place of a normal HTF decrement
//  unit.  Called only from dsModify***DecrementUnit functions.  No error checking, do not
//  call from outside of this include file.
float _calculateTravelCostUnit(object oCreature)
{
    int nAreaType = GetLocalInt(GetArea(oCreature), DS_HTF_VARIABLE_AREATYPE);
    int nCost = ds_GetAreaTravelCost(nAreaType);

    return IntToFloat(nCost)/100.0;
}

void ds_CreateAreaTravelTimer(object oPC)
{
    int timerID = CreateTimer(oPC, DS_HTF_AREA_ON_TIMER_EXPIRE, DS_HTF_AREATRAVELCOST_DELAY, 1, 0.0);
    //int timerID = h2_CreateTimer(oPC, DS_HTF_AREATIMER_SCRIPT, DS_HTF_AREATRAVELCOST_DELAY, FALSE, 1);
    SetLocalInt(oPC, DS_HTF_VARIABLE_AREATIMER, timerID);
    StartTimer(timerID, FALSE);
    //h2_StartTimer(timerID);
}

void ds_DestroyAreaTravelTimer(object oPC)
{
    int timerID = GetLocalInt(oPC, DS_HTF_VARIABLE_AREATIMER);
    DeleteLocalInt(oPC, DS_HTF_VARIABLE_AREATIMER);
    KillTimer(timerID);
    //h2_KillTimer(timerID);
}

float ds_ModifyFatigueDecrementUnit(object oCreature, float fDecrement)
{
    if (GetLocalInt(oCreature, DS_HTF_VARIABLE_COSTTRIGGER) == TRUE) {
        fDecrement = _calculateTravelCostUnit(oCreature);
        return fDecrement;
    }

    if (GetRacialType(oCreature) == DS_RACIAL_TYPE_THRIKREEN) fDecrement = fDecrement * DS_FATIGUE_MULTIPLIER_THRIKREEN;
    if (GetRacialType(oCreature) == DS_RACIAL_TYPE_MUL)       fDecrement = fDecrement * DS_FATIGUE_MULTIPLIER_MUL;
    return fDecrement;
}

float ds_ModifyThirstDecrementUnit(object oCreature, float fDecrement)
{
    if (GetLocalInt(oCreature, DS_HTF_VARIABLE_COSTTRIGGER) == TRUE)
        return _calculateTravelCostUnit(oCreature);

    if ((GetTimeHour() >= DS_HOUR_START_HEAT) &&
        (GetTimeHour() <  DS_HOUR_STOP_HEAT)  &&
        (GetLocalInt(GetArea(oCreature), DS_HTF_VARIABLE_AREATYPE) > 0))
            fDecrement *= DS_THIRST_MULTIPLIER_HEAT;

    if (GetRacialType(oCreature) == DS_RACIAL_TYPE_HALFGIANT)
        fDecrement *= DS_THIRST_MULTIPLIER_HALFGIANT;

    return fDecrement;
}

float ds_ModifyHungerDecrementUnit(object oCreature, float fDecrement)
{
    if (GetLocalInt(oCreature, DS_HTF_VARIABLE_COSTTRIGGER) == TRUE)
        return _calculateTravelCostUnit(oCreature);

    if (GetRacialType(oCreature) == DS_RACIAL_TYPE_HALFGIANT) 
        fDecrement *= DS_HUNGER_MULTIPLIER_HALFGIANT;

    return fDecrement;
}

//Internal function to create colored HTF bars for use in displaying HTF values on associates.  No error
//  checking, do not call from outside this include file.
string _createAssociateHTFBar(int nValue)
{
    int nMultiple = 100/GetStringLength(DS_HTF_BARS);

    int nBreakPoint = ((nValue + nMultiple/2)/nMultiple);
    string greenBar = HexColorString(GetSubString(DS_HTF_BARS, 0, nBreakPoint), COLOR_GREEN);
    string redBar = HexColorString(GetSubString(DS_HTF_BARS, nBreakPoint, GetStringLength(DS_HTF_BARS)-nBreakPoint), COLOR_RED);

    return greenBar + redBar;
}

void ds_DisplayAssociateHTFValues(object oCreature, float fThirst, float fHunger, float fFatigue)
{
    if (_GetIsPC(oCreature) || _GetIsDM(oCreature) || GetAssociateType(oCreature) == ASSOCIATE_TYPE_NONE) 
        return;

    if (!H2_USE_HUNGERTHIRST_SYSTEM && !H2_USE_FATIGUE_SYSTEM) 
        return;
     
    int currThirst = FloatToInt(fThirst);
    int currHunger = FloatToInt(fHunger);
    int currFatigue = FloatToInt(fFatigue);

    //TODO color text -> framework color
    string sOpen = HexColorString(DS_TEXT_BRACKET_L, COLOR_WHITE);
    string sClose = HexColorString(DS_TEXT_BRACKET_R, COLOR_WHITE);
    string sDelimiter = HexColorString(DS_TEXT_DELIMITER, COLOR_WHITE);

    string sThirst = "T";
    string sHunger = "H";
    string sFatigue = "F";
    
    string sName;
    string sHTFBar;

    switch (DS_HTF_ASSOCIATE_DISPLAY_TYPE)
    {
        case ASSOCIATE_DISPLAY_NUMBERS:
            if (H2_USE_HUNGERTHIRST_SYSTEM)
            {
                sThirst += IntToString(currThirst);
                sHunger += IntToString(currHunger);
            }

            if (H2_USE_FATIGUE_SYSTEM)
                sFatigue += IntToString(currFatigue);
        case ASSOCIATE_DISPLAY_BARS:
        case ASSOCIATE_DISPLAY_LETTERS:
            if (H2_USE_HUNGERTHIRST_SYSTEM)
            {
                sThirst = currThirst > DS_HTF_THRESHHOLD_CAUTION ? HexColorString(sThirst, COLOR_GREEN) : 
                            currThirst <= DS_HTF_THRESHHOLD_DIRE ? HexColorString(sThirst, COLOR_RED) :
                                                                    HexColorString(sThirst, COLOR_YELLOW);

                sHunger = currHunger > DS_HTF_THRESHHOLD_CAUTION ? HexColorString(sHunger, COLOR_GREEN) : 
                            currHunger <= DS_HTF_THRESHHOLD_DIRE ? HexColorString(sHunger, COLOR_RED) :
                                                                    HexColorString(sHunger, COLOR_YELLOW);
            }

            if (H2_USE_FATIGUE_SYSTEM)
                sFatigue = currFatigue > DS_HTF_THRESHHOLD_CAUTION ? HexColorString(sFatigue, COLOR_GREEN) : 
                                currFatigue <= DS_HTF_THRESHHOLD_DIRE ? HexColorString(sFatigue, COLOR_RED) :
                                                                        HexColorString(sFatigue, COLOR_YELLOW);

            sHTFBar = sOpen; 
            if (H2_USE_HUNGERTHIRST_SYSTEM)
                sHTFBar += sHunger + " " + sDelimiter + " " + sThirst + " ";
            if (H2_USE_FATIGUE_SYSTEM)
                sHTFBar += sFatigue;
            break;
        default:
            break;
    }

    if(DS_HTF_ASSOCIATE_DISPLAY_TYPE == ASSOCIATE_DISPLAY_BARS)
    {
        if (H2_USE_HUNGERTHIRST_SYSTEM)
        {
            sThirst += _createAssociateHTFBar(currThirst) + " ";
            sHunger += _createAssociateHTFBar(currHunger) + " ";
            sHTFBar += sHunger + sThirst;
        }

        if (H2_USE_FATIGUE_SYSTEM)
        {
            sFatigue += _createAssociateHTFBar(currFatigue);
            sHTFBar += sFatigue;
        }
    }

    if (sHTFBar != "") 
    {
        SetName(oCreature, "");
        sName = GetName(oCreature) + "\n" + sHTFBar;
        SetName(oCreature, sName);
    } 
    else
        SetName(oCreature, "");
}

int ds_GetAreaTravelCost(int iAreaType)
{
    int iTravelCost = 0;

    switch (iAreaType)
    {
        case DS_AREATYPE_BOULDERFIELD:
            iTravelCost = DS_AREATRAVELCOST_BOULDERFIELD;
            break;
        case DS_AREATYPE_DUSTSINK:
            iTravelCost = DS_AREATRAVELCOST_DUSTSINK;
            break;
        case DS_AREATYPE_MOUNTAIN:
            iTravelCost = DS_AREATRAVELCOST_MOUNTAIN;
            break;
        case DS_AREATYPE_MUDFLAT:
            iTravelCost = DS_AREATRAVELCOST_MUDFLAT;
            break;
        case DS_AREATYPE_ROCKYBADLAND:
            iTravelCost = DS_AREATRAVELCOST_ROCKYBADLAND;
            break;
        case DS_AREATYPE_SALTFLAT:
            iTravelCost = DS_AREATRAVELCOST_SALTFLAT;
            break;
        case DS_AREATYPE_SALTMARSH:
            iTravelCost = DS_AREATRAVELCOST_SALTMARSH;
            break;
        case DS_AREATYPE_SANDYWASTE:
            iTravelCost = DS_AREATRAVELCOST_SANDYWASTE;
            break;
        case DS_AREATYPE_SCRUBPLAIN:
            iTravelCost = DS_AREATRAVELCOST_SCRUBPLAIN;
            break;
        case DS_AREATYPE_STONYBARREN:
            iTravelCost = DS_AREATRAVELCOST_STONYBARREN;
            break;
        default:
            iTravelCost = DS_AREATRAVELCOST_DEFAULT;
    }

    return iTravelCost;
}

string ds_GetAreaTravelMessage(int iAreaType)
{
    string sMessage = "";

    switch (iAreaType)
    {
        case DS_AREATYPE_BOULDERFIELD:
            sMessage = DS_AREATRAVELMESSAGE_BOULDERFIELD;
            break;
        case DS_AREATYPE_DUSTSINK:
            sMessage = DS_AREATRAVELMESSAGE_DUSTSINK;
            break;
        case DS_AREATYPE_MOUNTAIN:
            sMessage = DS_AREATRAVELMESSAGE_MOUNTAIN;
            break;
        case DS_AREATYPE_MUDFLAT:
            sMessage = DS_AREATRAVELMESSAGE_MUDFLAT;
            break;
        case DS_AREATYPE_ROCKYBADLAND:
            sMessage = DS_AREATRAVELMESSAGE_ROCKYBADLAND;
            break;
        case DS_AREATYPE_SALTFLAT:
            sMessage = DS_AREATRAVELMESSAGE_SALTFLAT;
            break;
        case DS_AREATYPE_SALTMARSH:
            sMessage = DS_AREATRAVELMESSAGE_SALTMARSH;
            break;
        case DS_AREATYPE_SANDYWASTE:
            sMessage = DS_AREATRAVELMESSAGE_SANDYWASTE;
            break;
        case DS_AREATYPE_SCRUBPLAIN:
            sMessage = DS_AREATRAVELMESSAGE_SCRUBPLAIN;
            break;
        case DS_AREATYPE_STONYBARREN:
            sMessage = DS_AREATRAVELMESSAGE_STONYBARREN;
            break;
        default:
            sMessage = DS_AREATRAVELMESSAGE_DEFAULT;
    }

    return sMessage;
}

void ds_SaveLastFindWaterTime(object oPC)
{
    int findWaterTime = h2_GetSecondsSinceServerStart();
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    SetModuleInt(MODULE, uniquePCID + DS_HTF_VARIABLE_LAST_PC_FINDWATER_TIME, findWaterTime);
}

void ds_SearchForWater(object oPC, int iAreaType)
{/*
    int iAreaTravelCost = ds_GetAreaTravelCost(iAreaType);
    int nWaterPresent = Random(100);
    float fFailureChance = iAreaTravelCost * 2.0 / 15.0;

    ///Skill check to search for water
    int iSkillRoll = h2_SkillCheck(SKILL_TUMBLE, oPC, 2);

    if (iSkillRoll > 10)
    {
        // Test to see if there is water available to be found.
        if (fFailureChance > IntToFloat(nWaterPresent))
        {
            SendMessageToPC(oPC, DS_TEXT_NO_WATER_TO_BE_FOUND);
        }
        // If successful, display message and give "water" to the PC
        else
        {

            // Determine how much water the PC actually found based on skill check and area type
            int iWaterFound = (iAreaTravelCost + iSkillRoll) / 33;

            if (iWaterFound > 0)
            {
                // Success Message
                SendMessageToPC(oPC, DS_TEXT_PC_FIND_WATER_PREFIX + IntToString(iWaterFound) + DS_TEXT_PC_FIND_WATER_SUFFIX);

                // Get the first item in the player's inventory. It's likely not a canteen, but it could be!
                // We have to cycle through all the inventory items because the player might be carrying
                // multiple canteens and no one at Bioware or Beamdog has been thoughtful enough
                // to help us grab the Nth instance of an item in a player's pack
                object oCanteen = GetFirstItemInInventory(oPC);
                int iCanteenSpace = _GetLocalInt(oCanteen, H2_HT_MAX_CHARGES) - _GetLocalInt(oCanteen, H2_HT_CURR_CHARGES);
                int iCanteenFound = FALSE;

                while ((oCanteen != OBJECT_INVALID) && (iWaterFound != 0))
                {
                    if ((GetTag(oCanteen) == DS_ITEMTAG_CANTEEN) && (iCanteenSpace > 0))
                    {
                        iCanteenFound = TRUE;

                        if (iWaterFound > iCanteenSpace)
                        {
                            _SetLocalInt(oCanteen, H2_HT_CURR_CHARGES, iCanteenSpace);
                            iWaterFound = iWaterFound - iCanteenSpace;
                        }
                        else
                        {
                            _SetLocalInt(oCanteen, H2_HT_CURR_CHARGES, iWaterFound);
                            iWaterFound = 0;
                        }
                    }

                    GetNextItemInInventory(oPC);
                    iCanteenSpace = _GetLocalInt(oCanteen, H2_HT_MAX_CHARGES) - _GetLocalInt(oCanteen, H2_HT_CURR_CHARGES);
                }
                // If the PC has canteens but not enough space for all the water, fill them, and tell the PC how much water they are wasting
                if ((iWaterFound > 0) && (iCanteenFound = TRUE))
                {
                    SendMessageToPC(oPC, DS_TEXT_CANTEEN_FULL_PREFIX + IntToString(iWaterFound) + DS_TEXT_CANTEEN_FULL_SUFFIX);
                }
                // If the PC doesn't have any canteens, tell them how dumb that was and that the water was wasted
                if (iCanteenFound = FALSE)
                {
                    SendMessageToPC(oPC, DS_TEXT_CANTEEN_NOT_FOUND_PREFIX + IntToString(iWaterFound) + DS_TEXT_CANTEEN_NOT_FOUND_SUFFIX);
                }
            }
            else
            {
                SendMessageToPC(oPC, DS_TEXT_NO_WATER_TO_BE_FOUND);
            }
        }
    }

    //If failure, send failure message
    else {
       SendMessageToPC(oPC, DS_TEXT_PC_FAILED_TO_FIND_WATER);
    }*/
}

void _initAssociate(object oAssociate)
{
    if(!_GetIsPC(oAssociate) && _GetIsPC(GetMaster(oAssociate)))
    {    
        h2_InitFatigueCheck(oAssociate);
        h2_InitHungerThirstCheck(oAssociate);

        float fThirst = GetLocalFloat(oAssociate, H2_HT_CURR_THIRST) * 100.0;
        float fHunger = GetLocalFloat(oAssociate, H2_HT_CURR_HUNGER) * 100.0;
        float fFatigue = GetLocalFloat(oAssociate, H2_CURR_FATIGUE) * 100.0;

        ds_DisplayAssociateHTFValues(oAssociate, fThirst, fHunger, fFatigue);
    }
}

void ds_htf_AddAssociate()
{
    object oAssociate = OBJECT_SELF;
    
    if(_GetIsPC(GetMaster(oAssociate)))
        DelayCommand(0.2, _initAssociate(oAssociate));
}

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Module Events -----

//When entering an travel area, the PC may be required to pay a travel cost, which is borne by
//  a reducation in HTF capacity.  This script creates a timer on the entering object to allow
//  that to happen.  The purpose of waiting a designated interval is to ensure the PC didn't
//  enter the area on accident, thus allowing the PC to return to the previous area before the
//  timer expires and without incurring the travel cost.

//If the creature has paid a travel cost and then enters a populated area with no designated travel
//  cost, a timer is created to ensure the PC can return to the previous area in which the creature
//  already paid the travel cost without incurring another travel cost, as long as the PC returns
//  to that area before the timer expires.

void ds_htf_OnAreaEnter()
{
    object oCreature = GetEnteringObject();

    if (_GetIsDM(oCreature)) return;

    int nAreaType = GetLocalInt(GetArea(oCreature), DS_HTF_VARIABLE_AREATYPE);
    string sAreaPaid = GetLocalString(oCreature, DS_HTF_LAST_TRAVEL_COST_PAID);

    if(_GetIsPC(oCreature) && !nAreaType)
    {
        string sPCMessage = ds_GetAreaTravelMessage(nAreaType);
        if (sPCMessage != "") 
            SendMessageToPC(oCreature, sPCMessage);
    }

    if (sAreaPaid == GetTag(GetArea(oCreature))) 
    {
        ExecuteScript(DS_HTF_KILLTIMER_SCRIPT, oCreature);
        return;
    }

    if (ds_GetAreaTravelCost(nAreaType) > 0) ds_CreateAreaTravelTimer(oCreature);
        else if(sAreaPaid != "")
        {
            int nTimerID = CreateTimer(oCreature, DS_HTF_AREA_ON_TIMER_EXPIRE, DS_HTF_AREATRAVELCOST_DELAY, 1, 0.0);
            //int nTimerID = h2_CreateTimer(oCreature, DS_HTF_KILLTIMER_SCRIPT, DS_HTF_AREATRAVELCOST_DELAY, FALSE, 1);
            SetLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER, nTimerID);
            StartTimer(nTimerID, FALSE);
            //h2_StartTimer(nTimerID);
        }
}

//PCs entering non-populated areas may incur a travel cost.  This cost is charged through use
//  of a timer instantiated when a PC enters a travel area.  If the PC departs the travel area
//  before the timer expires, the PC is not charged for travelling in that area.  This function
//  kills the travel cost timer to ensure the PC is not charged.

void ds_htf_OnAreaExit()
{
    object oCreature = GetExitingObject();
    if (_GetIsDM(oCreature))
        return;

    int nAreaType = GetLocalInt(GetArea(oCreature), DS_HTF_VARIABLE_AREATYPE);
    
    if (GetLocalInt(oCreature, DS_HTF_VARIABLE_AREATIMER) > 0) ds_DestroyAreaTravelTimer(oCreature);
    if (GetLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER) > 0) KillTimer(GetLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER));
    //if (_GetLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER) > 0) h2_KillTimer(_GetLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER));
}

// ----- Timer Events -----

//The primary purpose of this script is to apply the Area Travel Cost to the player's
//  HTF stats.  Once the travel cost is applied, the Area Travel Time is destroyed
//  to ensure the Travel Cost is not incurred a second time in the same area on the same
//  visit.
void ds_htf_area_OnTimerExpire()
{
    object oCreature = OBJECT_SELF;

    //Set a flag to let our custom decrement modificaton function know if we're looking
    //  for an area travel cost or allowing the function to work normally.
    SetLocalInt(oCreature, DS_HTF_VARIABLE_COSTTRIGGER, TRUE);

    float fatigueDrop = ds_ModifyFatigueDecrementUnit(oCreature, 0.0);
    float thirstDrop = ds_ModifyThirstDecrementUnit(oCreature, 0.0);
    float hungerDrop = ds_ModifyHungerDecrementUnit(oCreature, 0.0);

    DeleteLocalInt(oCreature, DS_HTF_VARIABLE_COSTTRIGGER);

    h2_PerformFatigueCheck(oCreature, fatigueDrop);
    h2_PerformHungerThirstCheck(oCreature, thirstDrop, hungerDrop);

    SetLocalString(oCreature, DS_HTF_LAST_TRAVEL_COST_PAID, GetTag(GetArea(oCreature)));
    ds_DestroyAreaTravelTimer(oCreature);
}

void ds_htf_KillTravelCostTimer()
{
    object oCreature = OBJECT_SELF;
    DeleteLocalString(oCreature, DS_HTF_LAST_TRAVEL_COST_PAID);
    KillTimer(GetLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER));
    //h2_KillTimer(_GetLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER));
    DeleteLocalInt(oCreature, DS_HTF_VARIABLE_KILLTIMER);
}

void ds_htf_TravelCostTimerExpirationHT()
{
    object oCreature = OBJECT_SELF;

    float thirstDrop = h2_GetThirstDecrement(oCreature);
    float hungerDrop = h2_GetHungerDecrement();

    float fThirstDecrement = ds_ModifyThirstDecrementUnit(oCreature, thirstDrop);
    float fHungerDecrement = ds_ModifyHungerDecrementUnit(oCreature, hungerDrop);

    h2_PerformHungerThirstCheck(oCreature, fThirstDecrement, fHungerDecrement);

    if(!_GetIsPC(oCreature) && _GetIsPC(GetMaster(oCreature)))
    {
        float fThirst = GetLocalFloat(oCreature, H2_HT_CURR_THIRST) * 100.0;
        float fHunger = GetLocalFloat(oCreature, H2_HT_CURR_HUNGER) * 100.0;
        float fFatigue = GetLocalFloat(oCreature, H2_CURR_FATIGUE) * 100.0;

        ds_DisplayAssociateHTFValues(oCreature, fThirst, fHunger, fFatigue);
    }
}

void ds_htf_TravelCostTimerExpirationF()
{
    object oCreature = OBJECT_SELF;

    float fatigueDrop = h2_GetFatigueDecrement();
    float fDecrement = ds_ModifyFatigueDecrementUnit(oCreature, fatigueDrop);

    h2_PerformFatigueCheck(oCreature, fDecrement);

    if(!_GetIsPC(oCreature) && !_GetIsDM(oCreature) && _GetIsPC(GetMaster(oCreature)))
    {
        float fThirst = GetLocalFloat(oCreature, H2_HT_CURR_THIRST) * 100.0;
        float fHunger = GetLocalFloat(oCreature, H2_HT_CURR_HUNGER) * 100.0;
        float fFatigue = GetLocalFloat(oCreature, H2_CURR_FATIGUE) * 100.0;

        ds_DisplayAssociateHTFValues(oCreature, fThirst, fHunger, fFatigue);
    }
}
