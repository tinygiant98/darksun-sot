/// ----------------------------------------------------------------------------
/// @file:  hcr_c_htf.nss
/// @brief: HCR2 Hunger Thirst Fatigue System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 HTF Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the htf plugin is loaded or not. If you
/// want to control the htf system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the htf plugin will not be available to the module.
const int H2_HTF_LOAD_PLUGIN = TRUE;

/// These values allow individual system to be loaded.  Neither of these systems
/// will be loaded if H2_HTF_LOAD_PLUGIN above is FALSE.
const int H2_USE_HUNGERTHIRST_SYSTEM = TRUE;
const int H2_USE_FATIGUE_SYSTEM = TRUE;

/// This value plus the base constitution score of a player is the number of
/// in-game hours the player can go without drinking water with no chance of
/// negative effects.  After this time period has expired, failing a DC 10 +
/// (number of previous checks) fortitude save causes the player to become
/// fatigued.
const int H2_HT_BASE_THIRST_HOURS = 24;

/// This value is the base number of in-game hours a player can go without
/// consuming a food item with no chance of negative effects.  After this time
/// period has expired, failing a DC 10 + (number of previous checks) fortitude
/// save causes them to become fatigued.  The fortitude save occurs only once
/// per 24-hour period.
const int H2_HT_BASE_HUNGER_HOURS = 72;

/// This value determines whether the text-based ht value bars are displayed
/// for players.  These bars are updated every game hour.
const int H2_HT_DISPLAY_INFO_BARS = TRUE;

/// Set this value to the script resref that will be executed if a player's
/// non-lethal damage from hunger or thirst exceeds their maximum hit points.
/// The script's OBJECT_SELF will be the player object that is dehydrated
/// and/or starving.
/// @note The player will already be considered fatigued when this script
///     is run.
const string H2_HT_DAMAGE_SCRIPT = "";

/// This value is the base number of in-game hours a player can go without resting
/// with no chance of negative effects.  After this time period has expired,
/// fortitude checks of increasing difficulty are made.  Failing one of these
/// check causes the character to become fatigued.  10 hours after this value, the
/// character is automatically fatigued and failing a fortitude check results in
/// collapse.
const int H2_FATIGUE_HOURS_WITHOUT_REST = 24;

/// This value determines whether the text-based fatigue valuel bars are
/// displayed for players.  These bars are updated every game hour.
const int H2_FATIGUE_DISPLAY_INFO_BAR = TRUE;

/// This value determines whether the info bars will be displayed on an NUI
/// form instead of via vertical bars in the chat window.  Set to TRUE to
/// use the NUI form, FALSE to use the legacy chat window values.
const int H2_HTF_DISPLAY_INFO_BARS_ON_NUI = TRUE;

// -----------------------------------------------------------------------------
//                         HCR2 HTF Translatable Text
// -----------------------------------------------------------------------------
/// @warning If modifying these values to use languages that are encoded using
///     other than Windows-1252, the file must be saved and compiled with the
///     appropriate encoding.

/// @note To use tlk entries for these values, you can modify the construction
///     using the following example:
/// string H2_TEXT_THIRST = GetStringByStrRef(###);

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

const string H2_TEXT_FATIGUE = "Fatigue: ";

const string H2_TEXT_TIRED1 = "You are getting tired...";
const string H2_TEXT_YAWNS = "*yawns*";
const string H2_TEXT_NEAR_COLLAPSE = "You are so tired you can barely stand.";
const string H2_TEXT_COLLAPSE = "*collpases from exhaustion*";
