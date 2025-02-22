// -----------------------------------------------------------------------------
//    File: test_i_text.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Text constants
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

string GlobalHelp()
{
    return "Chat Command !var [global] help:" +
           "\nResult Communication -> [-d|dm] [-l|log] [-p|party]" +
           "\n  Results of the operation, if any, are only sent to the PC making the chat command " +
           "\n  To send to additional destinations, use the following options:" +
           "\n" +
           "\n  [-d|--dm] (optional) -> send result of operation to all online DMs" +
           "\n  [-l|--log] (optional) -> send result of operation to the log" +
           "\n  [-p|--party] (optional) -> send result of the operation to all party members";
}

string ScriptHelp()
{
    return "Chat Command !script help:" +
           "\nFormat -> !script <scriptname> [--target:<tag>]" +
           "\n  <scriptname> (required) -> name of the library script or .nss to run" +
           "\n  [--target:<tag>] (optional) -> object to use as OBJECT_SELF when script is run; if no" +
           "\n                                 target is specified, the PC will be used";
}

string GetVariableHelp()
{
    return "Chat Command !var [get] help:" +
           "\nFormat -> !var <variablename> [<variablename> ...] [--b|bool|boolean] [--target:<tag>]" +
           "\n  <variablename> (required) -> case sensitive and can be repeated, delimited with spaces" + 
           "\n  [--b|bool|boolean] (optional) -> will return integer variables greater than 0 as TRUE"+
           "\n  [--target:tag] (optional) -> searches variables on the target defined by tag; if no" +
           "\n                               target is specified, the PC is used";
}

string DeleteVariableHelp()
{
    return "Chat Command !var [delete] help:" +
           "\nFormat -> !var -[d|del|delete] <variablename> [<variablename> ...] [--target:tag] [-i|s|f|o|l|v]" +
           "\n  -[d|del|delete] (required) -> specifies a variable deletion operation" +
           "\n  <variablename> (required) -> case sensitive and can be repeated, delimited with spaces" + 
           "\n  [--target:tag] (optional) -> searches variables on the target defined by tag; if no" +
           "\n                               target is specified, the PC is used";
           "\n  [-i|s|f|o|l|v] (optional) -> when multiple variables exist of different types with the same variable" +
           "\n                               name, specify the type of variable to be deleted";
}

string SetVariableHelp()
{    
    return "Chat Command !var [delete] help:" +
           "\nFormat -> !var -[d|del|delete] <variablename> --<type>:<value> [--target:tag]" +
           "\n  -[s|set] (required) -> specifies a variable set operation" +
           "\n  <variablename> (required) -> case sensitive and cannot be repeated" + 
           "\n  --<type>:<value> (required) -> variable type and value" +
           "\n  [--target:tag] (optional) -> searches variables on the target defined by tag; if no" +
           "\n                               target is specified, the PC is used" +
           "\n" +
           "\n  Strings -> --[s|str|string]:`<stringvalue>` (1.69 cannot parse double quotation marks)" +
           "\n  Integers -> --[i|int|integer]:#" +
           "\n  Floats -> --[f|float]:#.#" +
           "\n  Objects -> --[o|obj|object]:<tag> (Object must be valid)" +
           "\n  Location -> --[l|loc|location]:<areatag>;x.x;y.y;z.z;facing.facing" +
           "\n  Vector -> --[v|vec|vector]:x.x;y.y;z.z";
}
