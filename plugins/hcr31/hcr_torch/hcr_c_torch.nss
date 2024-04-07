/// ----------------------------------------------------------------------------
/// @file:  hcr_c_torch.nss
/// @brief: HCR2 Torch System (configuration)
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                     HCR2 Torch Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the torch plugin is loaded or not. If you
/// want to control the torch system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the torch plugin will not be available to the module.
const int H2_TORCH_LOAD_PLUGIN = TRUE;

/// Set this value to the time in real-world seconds that a torch can burn
/// before it no longer burns.
const int H2_TORCH_BURN_COUNT = 3600;

/// Set this value to the time in real-world seconds that a lantern can burn
/// before its fuel source runs out.
const int H2_LANTERN_BURN_COUNT = 21600;

/// Set this value to the tag of any item that can act as a lantern.
const string H2_LANTERN = "h2_lantern";

/// Set this value to the tag of any item that can act as an oil flask and/or
/// a fuel source for a lantern.
const string H2_OILFLASK = "h2_oilflask";

/// Set this value to the tag of any item that can act as a torch.
const string H2_TORCH = "h2_torch";

// -----------------------------------------------------------------------------
//                         HCR2 Torch Translatable Text
// -----------------------------------------------------------------------------
/// @warning If modifying these values to use languages that are encoded using
///     other than Windows-1252, the file must be saved and compiled with the
///     appropriate encoding.

/// @note To use tlk entries for these values, you can modify the construction
///     using the following example:
/// string H2_TEXT_TORCH_BURNED_OUT = GetStringByStrRef(###);

const string H2_TEXT_TORCH_BURNED_OUT = "This torch has burned out";
const string H2_TEXT_LANTERN_OUT = "This lantern has run out of oil.";
const string H2_TEXT_DOES_NOT_NEED_OIL = "This lantern does not yet need more oil.";
const string H2_TEXT_FILL_LANTERN = "You fill the lantern.";
const string H2_TEXT_OIL_FLASK_FAILED_TO_IGNITE = "The oil flask failed to ignite.";
const string H2_TEXT_REMAINING_BURN = "Remaining burn time: "; //+ ##%
