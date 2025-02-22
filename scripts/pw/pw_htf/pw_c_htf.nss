/// ----------------------------------------------------------------------------
/// @file   pw_c_htf.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Hunger, Thirst, Fatigue Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Although the Hunger/Thirst and Fatigue systems are housed in this
///     library, they can be enabled separately.  Set one or both of these
///     settings to TRUE to enable the respective system.
const int HUNGERTHIRST_ACTIVE = FALSE;
const int FATIGUE_ACTIVE = FALSE;

/// @brief Set this setting to a value that, when combined with a player
///     character's constitution score, represents the number of in-game hours
///     a player character can go without dirking water with no change of
///     ill effects.  After this time period, failing a DC 10 + (number of
///     previous checks) Fortitude save causes the player character to become
///     fatigued.
const int HT_BASE_THIRST_HOURS = 24;

/// @brief Set this setting to a value that represents the number of in-game
///     hours a player character can go without eating food with no chance of
///     ill effects.  After this time period, failing a DC 10 + (number of
///     previous checks) Fortitude save causes the player character to become
///     fatigued.
/// @note The Fortitude save is made only once per 24 in-game hours.
const int HT_BASE_HUNGER_HOURS = 72;

/// @brief Set this setting to TRUE to display hunger/thirst info bars to the
///     player character's chat log every in-game hour.
const int HT_DISPLAY_INFO_BARS = TRUE;

/// @brief Set this setting to the name of the script (without the ".nss" extension)
///     that will be executed when a player character's nonlethal damage from
///     hunger or thirst exceeds their maximum hit points.  The script's OBJECT_SELF
///     will be the player character that is dehydrated and/or starving.
/// @note Use this script to customize the effects of dehydration and starvation
///     in your module, such as unconsciousness or death.
/// @note The player character will already be fatigued by the time this script is
///     executed.
const string HT_DAMAGE_SCRIPT = "";

/// @brief Set this setting to a value that represents the number of in-game hours
///     a player character can go without resting with no change of ill effects.
///     After this time period, failing periodic Fortitude checks of increasing
///     difficult will cause the player character to become fatigued.
/// @note 10 in-game hours after this value is reached, the player character will
///     automatically become fatigued and failing a Fortitude check will cause the
///     player character to collapse.
const int FATIGUE_HOURS_WITHOUT_REST = 24;

/// @brief Set this setting to TRUE to display a fatigue info bar to the player
///     character's chat log every in-game hour.
const int FATIGUE_DISPLAY_INFO_BAR = TRUE;
