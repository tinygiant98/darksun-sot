/// ----------------------------------------------------------------------------
/// @file   pw_c_unid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  UnID System (configuration).
/// ----------------------------------------------------------------------------

/// ----------------------------------------------------------------------------
///                            Configuration Settings
/// ----------------------------------------------------------------------------

/// @brief This setting determines whether the UnID system is loaded
///     during the module load process.
///     TRUE: Enable the system.
///     FALSE: Disable the system.
const int UNID_SYSTEM_ENABLED = TRUE;

/// @brief This is the number of seconds that must elapse after an item is
///     unacquired before it is set as unidentified, unless the item has a
///     local variable set to prevent unidentification.  This setting is in
///     real-world seconds.
const int UNID_DELAY = 300;

/// @brief Total gold cost value an item must exceed for the item to be
///     unidentified when it is unacquired.  Note: setting a value below 5
///     is not recommended as a Level 1 PC with a Lore skill of 0 can ID
///     items with values less than 5.
const int UNID_MINIMUM_VALUE = 5;

/// @brief This is the name of the integer variable to set on an item if the item
///     is not to be unidentified when it is unacquired.  If the variable is not
///     set, or is set to 0, the item will be unidentified when the time delay
///     from UNID_DELAY above is expired.  If this variable is set to any integer
///     value above 0 (normally 1), the item will not be unidentified when unacquired.
const string UNID_NO_UNID = "UNID_DO_NOT_UNID";
