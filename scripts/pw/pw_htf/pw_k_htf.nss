/// ----------------------------------------------------------------------------
/// @file   pw_k_htf.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Hunger, Thirst, Fatigue Library (constants)
/// ----------------------------------------------------------------------------

#include "util_i_color"

/// ----------------------------------------------------------------------------
///                                     CONSTANTS
/// ----------------------------------------------------------------------------

const string H2_HT_CANTEEN = "h2_canteen";
const string H2_HT_FOODITEM = "h2_fooditem";
const string H2_HT_IS_DEHYDRATED = "H2_HT_IS_DEHYDRATED";
const string H2_HT_IS_STARVING = "H2_HT_IS_STARVING";
const string H2_HT_CURR_THIRST = "H2_HT_CURR_THIRST";
const string H2_HT_CURR_HUNGER = "H2_HT_CURR_HUNGER";
const string H2_HT_CURR_ALCOHOL = "H2_HT_CURR_ALCOHOL";
//const string H2_HT_TIMER_SCRIPT = "h2_httimer";
const string H2_HT_TIMER_SCRIPT = "ds_htf_httimer";
const string H2_HT_INFO_BAR = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
const string H2_HT_HUNGER_HOUR_COUNT = "H2_HT_HUNGER_HOUR_COUNT";
const string H2_HT_THIRST_NONLETHAL_DAMAGE = "H2_HT_THIRST_NONLETHAL_DAMAGE";
const string H2_HT_HUNGER_NONLETHAL_DAMAGE = "H2_HT_HUNGER_NONLETHAL_DAMAGE";
const string H2_HT_THIRST_SAVE_COUNT = "H2_HT_THIRST_SAVE_COUNT";
const string H2_HT_HUNGER_SAVE_COUNT = "H2_HT_HUNGER_SAVE_COUNT";
const string H2_HT_THIRST_VALUE = "H2_HT_THIRST_VALUE";
const string H2_HT_HUNGER_VALUE = "H2_HT_HUNGER_VALUE";
const string H2_HT_ALCOHOL_VALUE = "H2_HT_ALCOHOL_VALUE";
const string H2_HT_DELAY = "H2_HT_DELAY";
const string H2_HT_POISON = "H2_HT_POISON";
const string H2_HT_DISEASE = "H2_HT_DISEASE";
const string H2_HT_SLEEP = "H2_HT_SLEEP";
const string H2_HT_HPBONUS = "H2_HT_HPBONUS";
const string H2_HT_FEEDBACK = "H2_HT_FEEDBACK";
const string H2_HT_DRUNK_TIMERID = "H2_HT_DRUNK_TIMERID";
const string H2_HT_DRUNK_TIMER_SCRIPT = "h2_htdrunktimer";
const string H2_HT_TRIGGER = "H2_HT_TRIGGER";
const string H2_HT_MAX_CHARGES = "H2_HT_MAX_CHARGES";
const string H2_HT_CURR_CHARGES = "H2_HT_CURR_CHARGES";
const string H2_HT_CANTEEN_SOURCE = "H2_HT_CANTEEN_SOURCE";
const string H2_HT_ON_TIMER_EXPIRE = "HT_OnTimerExpire";
const string H2_HT_DRUNK_ON_TIMER_EXPIRE = "HT_Drunk_OnTimerExpire";

const int H2_HT_COLOR_RED = COLOR_RED;
const int H2_HT_COLOR_GREEN = COLOR_GREEN;


const string H2_CURR_FATIGUE = "H2_CURR_FATIGUE";
const string H2_IS_FATIGUED = "H2_IS_FATIGUED";
const string H2_FATIGUE_INFO_BAR = "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
const string H2_FATIGUE_EFFECTS = "H2_FATIGUE_EFFECTS";
//const string H2_FATIGUE_TIMER_SCRIPT = "h2_fatiguetimer";
const string H2_FATIGUE_TIMER_SCRIPT = "ds_htf_ftimer";
const string H2_FATIGUE_SAVE_COUNT = "H2_FATIGUE_SAVE_COUNT";
const string H2_FATIGUE_ON_TIMER_EXPIRE = "F_OnTimerExpire";

/// ----------------------------------------------------------------------------
///                                     TEXT
/// ----------------------------------------------------------------------------

const string H2_TEXT_THIRST = "Thirst:    ";
const string H2_TEXT_HUNGER = "Hunger:  ";

const string H2_TEXT_DEHYDRATION_SAVE = "Fortitude save vs. dehydration effects";
const string H2_TEXT_STARVATION_SAVE = "Fortitude save vs. starvation effects";

const string H2_TEXT_ALCOHOL_STUMBLES = "*stumbles about in a drunken stupor*";
const string H2_TEXT_ALCOHOL_BELCHES = "*belches loudly*";
const string H2_TEXT_ALCOHOL_HICCUPS = "*hiccups*";
const string H2_TEXT_ALCOHOL_PASSED_OUT = "*passes out*";
const string H2_TEXT_ALCOHOL_FALLS_DOWN = "*wobbles about then falls down*";
const string H2_TEXT_ALCOHOL_DRY_HEAVES = "*dry heaves*";

const string H2_TEXT_CANTEEN_EMPTY = "This is empty, you will have to fill it from someplace.";
const string H2_TEXT_FILL_CANTEEN = "You fill the "; //+ GetName(oCanteen)
const string H2_TEXT_EMPTY_CANTEEN = "You empty out the "; //GetName(oCanteen)
const string H2_TEXT_NO_PLACE_TO_FILL = "There is no place to fill this in the immediate area.";
const string H2_TEXT_TAKE_A_DRINK = "You take a drink.";
const string H2_TEXT_NOT_THIRSTY = "You are no longer thirsty.";
const string H2_TEXT_NOT_HUNGRY = "You are no longer hungry.";

//fatigue

const string H2_TEXT_FATIGUE = "Fatigue: ";

const string H2_TEXT_TIRED1 = "You are getting tired...";
const string H2_TEXT_YAWNS = "*yawns*";
const string H2_TEXT_NEAR_COLLAPSE = "You are so tired you can barely stand.";
const string H2_TEXT_COLLAPSE = "*collpases from exhaustion*";
