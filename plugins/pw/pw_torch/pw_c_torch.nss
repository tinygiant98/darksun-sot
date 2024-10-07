// -----------------------------------------------------------------------------
//    File: pw_c_torch.nss
//  System: Torch and Lantern (configuration)
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

// Set this to false if you don't want to use the torch system.
const int H2_USE_TORCH_SYSTEM = TRUE;

//Time in real-life seconds before a torch burns out.
//PHB rules is 1 hours of burn time.
//You could set this to Minutes per game hour * 60 to be purely by the PHB.
//That is rather short though if the default minutes per hour is 2.
//(which means a torch would burn out in 2 RL minutes)
//3600 = 1 RL hour.
const int H2_TORCH_BURN_COUNT = 3600;

//Time in real-life seconds before a lantern's oil runs out.
//21600 = 6 RL hours.
//You could set this to Minutes per game hour * 360 to be purely by the PHB.
//That is rather short though if the default minutes per hour is 2.
//(which means a lantern would run out of oil in 12 RL minutes)
const int H2_LANTERN_BURN_COUNT = 21600;

//TODO add lantern item to system?
//The tag of your lantern object
//If you change this be sure to save a new copy of h2_lantern
//as the new tag name to preserve functionality
const string H2_LANTERN = "h2_lantern";

//The tag of your oilflask object
//If you change this be sure to save a new copy of h2_oilflask
//as the new tag name to preserve functionality
const string H2_OILFLASK = "h2_oilflask";

//The tag of your torch object
const string H2_TORCH = "h2_torch";

// Text Values
const string H2_TEXT_TORCH_BURNED_OUT = "This torch has burned out";
const string H2_TEXT_LANTERN_OUT = "This lantern has run out of oil.";
const string H2_TEXT_DOES_NOT_NEED_OIL = "This lantern does not yet need more oil.";
const string H2_TEXT_FILL_LANTERN = "You fill the lantern.";
const string H2_TEXT_OIL_FLASK_FAILED_TO_IGNITE = "The oil flask failed to ignite.";
const string H2_TEXT_REMAINING_BURN = "Remaining burn time: "; //+ ##%