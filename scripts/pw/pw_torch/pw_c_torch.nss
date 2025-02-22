/// ----------------------------------------------------------------------------
/// @file   pw_c_torch.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Torch Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the torch system.
const int TORCH_ACTIVE = TRUE;

/// @brief Set this value to the time in real-world seconds the torch will
///     burn before it is automatically extinguished.
/// @note 3600 = 1 hour of real-world time.
const int TORCH_BURN_COUNT = 3600;

/// @brief Set this value to the time in real-world seconds the lantern will
///     burn before it runs out of oil/fuel.
/// @note 3600 = 1 hour of real-world time.
const int LANTERN_BURN_COUNT = 21600;

/// @brief Set this value to the tag of the lantern object.
/// @note If there are multiple objects that can act as lanterns, add all
///     tags as a comma-delimited list.
const string LANTERN_TAG = "h2_lantern";

/// @brief Set this value to the tag of the oilflask object.
/// @note If there are multiple objects that can act as oilflasks, add all
///     tags as a comma-delimited list.
const string OILFLASK_TAG = "h2_oilflask";

/// @brief Set this value to the tag of the torch object.
/// @note If there are multiple objects that can act as torches, add all
///     tags as a comma-delimited list.
/// @note During client login, if the client has a "standard" torch in
///     their inventory, it will be replaced with the first torch object
///     in this list; this means that the torch resrefs and tags much match.
const string TORCH_TAG = "h2_torch";

// Text Values
const string H2_TEXT_TORCH_BURNED_OUT = "This torch has burned out";
const string H2_TEXT_LANTERN_OUT = "This lantern has run out of oil.";
const string H2_TEXT_DOES_NOT_NEED_OIL = "This lantern does not yet need more oil.";
const string H2_TEXT_FILL_LANTERN = "You fill the lantern.";
const string H2_TEXT_OIL_FLASK_FAILED_TO_IGNITE = "The oil flask failed to ignite.";
const string H2_TEXT_REMAINING_BURN = "Remaining burn time: "; //+ ##%