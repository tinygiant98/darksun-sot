/*******************************************************************************
* Description:  Constant Values for all Dark Sun HTF scripts.
  Usage:        Include for use with any Dark Sun HTF scripts that require constants.
********************************************************************************
* Created By:   tinygiant
* Created On:   20200125
*******************************************************************************/

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

const string DS_TEXT_NO_WATER_TO_BE_FOUND = "Unfortunately, there doesn't seem to be any water here.";
const string DS_TEXT_PC_FAILED_TO_FIND_WATER = "You failed to find water!";
const string DS_TEXT_CANTEEN_NOT_FOUND_PREFIX = "You are not carrying a canteen, so the ";
const string DS_TEXT_CANTEEN_NOT_FOUND_SUFFIX = " units of water you found are reabsorbed into the ground at your feet.";
const string DS_TEXT_CANTEEN_FULL_PREFIX = "You have no remaining canteen space, so the extra ";
const string DS_TEXT_CANTEEN_FULL_SUFFIX = " units of water you found are reabsorbed into the ground at your feet.";
const string DS_TEXT_PC_FIND_WATER_PREFIX = "Success! You found ";
const string DS_TEXT_PC_FIND_WATER_SUFFIX = " units of water!";