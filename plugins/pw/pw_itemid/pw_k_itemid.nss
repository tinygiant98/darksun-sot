/// ----------------------------------------------------------------------------
/// @file   pw_k_itemid.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Item Identification Library (constants)
/// ----------------------------------------------------------------------------

/// @brief To prevent an unacquired item from being automatically un-identified,
///     set an integer variable on the object named `ITEMID_NO_UNID` to any value
///     other than 0.  If this variable is not set or set to 0, the item will be
///     automatically un-identified after the delay period if not acquired by
///     another player character.
const string ITEMID_NO_UNID = "ITEMID_NO_UNID";
