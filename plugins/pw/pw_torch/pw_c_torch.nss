/// ----------------------------------------------------------------------------
/// @file   pw_c_torch.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Torch System (configuration).
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Configuration
// -----------------------------------------------------------------------------

/// @brief Set this value to FALSE to prevent the torch system plugin from
///     intializing.  If FALSE, no torch functionality will be available.
const int TORCH_SYSTEM_ENABLED = TRUE;

/// @brief Set this value to the real-world time, in seconds, that a torch
///     object will burn before becoming useless.
const int TORCH_TORCH_DURATION = 3600;

/// @brief Set this value to the real-world time, in seconds, that a lantern
///     object will burn before running out of fuel and requiring recharge.
const int TORCH_LANTERN_DURATION = 21600;

/// @brief Set this value to the resref of the lantern item.
const string TORCH_LANTERN_RESREF = "torch_lantern";

/// @brief Set this value to the resref of the oilflask item.
const string TORCH_OILFLASK_RESREF = "torch_oilflask";

/// @brief Set this value to the resref of the torch item.
const string TORCH_TORCH_RESREF = "torch_torch";

/// @brief Comma-delimited list of non-plugin light sources that are considered
///     torches.  When a player logs in, any items in their inventory that
///     match these resrefs will be destroyed and replaced with a plugin-managed
///     torch object.
const string TORCH_INVALID_RESREFS = "nw_it_torch001,nw_it_torch002";

// -----------------------------------------------------------------------------
//                             Translatable Text
// -----------------------------------------------------------------------------

const string TORCH_TEXT_TORCH_BURNED_OUT = "This torch has burned out";
const string TORCH_TEXT_LANTERN_OUT = "This lantern has run out of oil.";
const string TORCH_TEXT_DOES_NOT_NEED_OIL = "This lantern does not yet need more oil.";
const string TORCH_TEXT_FILL_LANTERN = "You fill the lantern.";
const string TORCH_TEXT_OIL_FLASK_FAILED_TO_IGNITE = "The oil flask failed to ignite.";
const string TORCH_TEXT_REMAINING_BURN = "Remaining burn time: "; //+ ##%