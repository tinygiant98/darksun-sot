/// ----------------------------------------------------------------------------
/// @file   pw_c_eventman.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Event Manager (configuration).
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                         Configuration Settings
// -----------------------------------------------------------------------------

/// @brief This setting determines whether the event manager system is loaded
///     during the module load process.
///     TRUE: Enable the event manager system.
///     FALSE: Disable the event manager system.
/// @warning Event Manager is a core plugin and should never be disabled unless
///     another plugin takes over its functionality.
const int EVENTMAN_ENABLE_SYSTEM = FALSE;

/// @brief The core framework completely replaces the normal event handling
///     throughout the module.  However, should the framework run into a situation
///     where no event handlers are registered for a given event, it can fall back
///     to the default Bioware event handling scripts.  Setting this value to TRUE
///     will allow that behavior.
/// @warning Generally, this should always be set to TRUE unless you have a
///     very specific reason to disable it.  Disabling this may cause unexpected
///     behavior in certain systems that rely on Bioware's default event handlers.
const int EVENTMAN_USE_DEFAULT_BIOWARE_EVENTS = TRUE;
