// -----------------------------------------------------------------------------
//    File: res_i_const.nss
//  System: Base Game Resource Management
// -----------------------------------------------------------------------------
// Description:
//  Constants
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

/// @todo change to resman and rewrite the entire plugin.  As the module gets
///     larger, we're going to start running out of instructions unless
///     NWNXEE gets involved, which it should (?).

///     Also this methodology isn't great.  Let's use a different methodology
///     maybe override spawn scripts that automatically register resources as
///     they're created in the module?  Great for creatures, what about all the
///     other resource types?

const string FRAMEWORK_OUTSIDER = "FRAMEWORK_OUTSIDER";
const string FRAMEWORK_REGISTERED = "FRAMEWORK_REGISTERED";

const string HOOK_SCRIPT_PREFIX = "hook_";
const string HOOK_SKIP = "*SkipRegistration";

const string HOOK_PRIORITY = ":last";
