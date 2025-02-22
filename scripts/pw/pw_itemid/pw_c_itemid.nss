/// ----------------------------------------------------------------------------
/// @file   pw_c_itemid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Item Identification Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the item identification system.
const int ITEMID_ACTIVE = TRUE;

/// @brief For automated un-identification when an item is unqcquired, set this
///     value to the amount of time in seconds after which the item will be
///     un-identified unless it's picked up before the time expires.
/// @note If an item has a the variable PW_ITEMID_NO_UNID, the item will not be
///     automatically un-identified after it is unacquired.
const int ITEMID_UNID_DELAY = 300;

/// @brief Total gold cost value an item must exceed for the item to be unidentified
///     after it is unacquired.  Items valued less than this will not be affected
///     by this system.
/// @note Setting a value below 5 is not recommended as a Level 1 PC with a Lore
///     skill of 0 can identify items with values less than 5.
const int ITEMID_UNID_MINIMUM_VALUE = 5;
