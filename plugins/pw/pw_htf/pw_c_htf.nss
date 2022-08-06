// -----------------------------------------------------------------------------
//    File: htf_i_config.nss
//  System: Hunger, Thirst, Fatigue (configuration)
// -----------------------------------------------------------------------------
// Description:
//  Configuration File for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  Set the variables below as directed in the comments for each variable.
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------

// With HCR2 integration into the core-framework, the hunger-thirst system and
//  the fatigue system were combined into the HTF system.  The primary HCR2
//  functionality still exists, but some additional function have been added to
//  allow external hooks.  Other functions have been modified or combined to
//  prevent duplication.  Either way, the original functionality of the system
//  remains intact.

// Although the systems are now combined, you can elect to use only one or the
//  other.
const int H2_USE_HUNGERTHIRST_SYSTEM = FALSE;
const int H2_USE_FATIGUE_SYSTEM = FALSE;

//This value plus the base constitution score of a player, is the number
//of in-game hours they can go without drinking water with no chance of ill effects.
//After this time peroid is up, failing a DC 10 +(numer of previous checks) fortitude
//save causes them to become fatigued.
const int H2_HT_BASE_THIRST_HOURS = 24;

//This value is the base number of hours a player can go without eating food
//with no chance of ill effects.
//After this time period is up, failing a DC 10 +(number of previous checks) fortitude
//save, (which is made only once per 24 in-game hours) causes them to become fatigued.
const int H2_HT_BASE_HUNGER_HOURS = 72;

//Determines whether or not the info bars for displaying
//hunger and thirst levels  will be shown to the PC.
//These occur every in-game hour.
const int H2_HT_DISPLAY_INFO_BARS = TRUE;

//Set this value to the name of a script that you want to be executed
//if the PC's nonlethaldamage from hunger or thirst exceeds their max hitpoints.
//The script object will be the PC that is dehydrated and/or starving.
//Use this script to customize what effects you feel are appropriate for
//you module, be in uconciousness or death etc. Note that the PC
//will already be fatigued by the time they reach this point.
const string H2_HT_DAMAGE_SCRIPT = "";

//The number of game hours a character can go without risk of
//enduring negative effects of not resting.
//After this time period elapses, fortidue checks of increasing difficulty are made.
//Failing this causes the character to become fatigued.
//10 hours after the below number of hours, the character is automatically fatigued
//and failing a fortitude check results in collapse.
const int H2_FATIGUE_HOURS_WITHOUT_REST = 24;

//Set to true to turn on the fatigue info bar which is displayed each game hour.
//Set to false to turn it off.
const int H2_FATIGUE_DISPLAY_INFO_BAR = TRUE;

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

//ht

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