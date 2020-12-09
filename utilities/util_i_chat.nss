
// -----------------------------------------------------------------------------
//    File: util_i_chat.nss
//  System: Chat Command System
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

/*
Note: util_i_chat will not function without other utility includes from squattingmonk's
sm-utils.  These utilities can be obtained from
https://github.com/squattingmonk/nwn-core-framework/tree/master/src/utils.

Specificially, the following files are required:  util_i_color.nss, util_i_csvlists.nss,
util_i_datapoint.nss, util_i_debug.nss, util_i_math.nss, util_i_string.nss, util_dataitem.uti,
util_datapoint.utp

NWN allows players to chat on several channels.  Using nwscript, builders can intercept
these chat messages and perform several functions.  This utility allows builders to
intercept chat messages that are similar to command line inputs and parse those messages
down to the argument level.

The parsed output will include:
- The entire original chat line as recieved through GetPCChatMessage() (whitespace trimmed)
- The command designator (the first character, which usually denotes a special function)
- The command (the character group attached to the command designator)
- All long and short non-paired options (--force, -q, etc.)
- All key:value pairs (--force:true, -q:no, etc.)

Usage Notes:
- This system uses comma-delimited lists, so commas are not allowed in any position in the
    chat line except the first position (command designator).  Commas will be stripped
    from the chat line when sent through the tokenizer.
- Command designator characters are limited to that characters passed to ParseCommandLine in
    the sGroup argument.  Generally, command designators should be limited to !@#$%^&*;.,/?`~|\.
    Some characters must be escaped such a `\\`, so including the backslash would looke like
    !@#$%^&*;.,/?`~|\\.  See the grouped character note for additional character possibilities.
- The delimiter between tokens must be only one character and defaults to a single space.
    The system handles multiple consecutive delimiters by ignoring them.  The delimiter can
    be passed to ParseCommandLine through the sDelimiter argument.
- Characters can be grouped with paired grouping symbols such as "", {}, [], <>.  These pairs
    can be passed to ParseCommandLine in the sGroups argument.  Grouping symbols mus passed in
    pairs and certain characters must be escapes, such as \"\" to send two double quotes.  The
    default is \"\"{}[]<>,  This allows any characters within groups designated by these
    characters to be treated as a single token.  So, "this is a string" is passed as a single
    token instead of four different tokens, same as [this is a group], {this is a group} and
    <this is a group>.  If you remove any grouping characters, those characters become available
    for use as command designators.  DMFI uses [ as a command, so if you change the grouping
    characters to \"\"{}<>, [ and ] become available as command designators.  Technically, any
    two characters can be sent as grouping symbols, but you will run into issues if you use
    standard alphabetic characters.
- You can opt to return grouped characters with the grouping symbols still attached.  For example,
    if a user enters [one two three], by default, the system will return `one two three` as a single
    token, however, if you pass the argument nRemoveGroups = FALSE, the system will return
    `[one two three]` instead.
- Long options should start with "--".  The characters following a "--" will be treated as a single
    option whether one their own (--force) or as part of a pair (--force:false).
- Short options should start with "-".  The characters following a "-" will be treated as individual
    options unless they are part of a part.  -kwtuv is equivalent to -k -w -t -u -v, while -k:true will
    result in one pair set and -kwtuv:true will result in one pair set with key kwtuv.
- Case is never changed in parsing the chat line to prevent errors in NWN, which is almost always
    case-sensitive
- Pairs can use either : or = to separate key from value.  --key:jabra is equivalent to --key=jabra

The following usage examples assume defaults as set int he configuration section below.  A common use-case
would be to allow specific command designators for dms and others for players.  To accomplish this, set
the most common use-case as the default and, when a different use-case is required, pass the appropriate
character string

Example:  Default Usage
    if (ParseCommandLine(oPC, sChat))
        ...

Example:  Usage with special designators
    if (GetIsDM(oPC))
    {
        if (ParseCommandLine(oPC, sChat, DESIGNATORS + "%^"))
            ...
    }

Usage Examples (not checked for compilation errors):

Chat Line -> <designator><command> [options]
Example   -> !get [options]
Result -> Routing function

void main()
{
    object oPC = GetPCChatSpeaker();
    string sChat = GetPCChatMessage();

    if (ParseCommandLine(oPC, sChat))
    {
        string sDesignator = GetChatDesignator(oPC);
        string sCommand = GetChatCommand(oPC);

        if (sDesignator == "!")
        {
            if (VerifyChatTarget(oPC))  // used a preparatory function for all !-associated command
            {
                if (sCommand == "get")
                    chat_get(oPC);  // or ExecuteScript("scriptname", oPC);
                else if (sCommand == "go"")
                    chat_go(oPC);
                else if (sCommand == "say")
                    chat_say(oPC);
                else if (sCommand == ...)
                    ...
                else
                    Error("Could not find command '" + sCommand + "'");
            }
        }
    }
}

Chat Line -> !get x2_duergar02 commoner_001 -k
Result -> Gets object with designated tags and either gets it or destroys it

void chat_get(object oPC)
{
    object o;
    string sArgument;
    int n, nCount = CountChatArguments(oPC);

    for (n = 0; n < nCount; n++)
    {
        sArgument = GetChatArgument(oPC, n);
        o = GetObjectByTag(sArgument);
        
        if (GetIsObjectValid(o))
        {
            if (HasChatOption(oPC, "k"))
                DestroyObject(o);
            else
                AssignCommand(o, ActionJumpToObject(oPC))
        }
    }
}

Chat Line -> !go StartArea --object:info_sign
Result -> Send player to the info_sign object in area StartArea

void chat_go(object oPC)
{
    object o, oPC = GetPCChatSpeaker();

    string sArea = GetChatArgument(oPC);
    object oArea = GetObjectByTag(sArea);
    if (GetIsObjectValid(oArea))
    {
        object o = GetFirstObjectInArea(oArea);
        string sTag = GetChatKeyValue(oPC, "object");
        if (sTag != "")
        {
            object oDest = GetNearestObjectByTag(sTag, o, 1);
            if (GetIsObjectValid(oDest))
                AssignCommand(oPC, ActionJumpToObject(oDest));
            else
                AssignCommand(oPC, ActionJumpToObject(o));
        }
    }
    else
        Error("Could not find area with tag '" + sArea + "'");
}

Chat Line -> !say x2_duergar02 --line:"This is what I want to say" --whisper
Result -> Object with tag x2_duergar02 speaks "This is what I want to say"

void chat_say(object oPC)
{
    int nVolume = TALKVOLUME_TALK;

    object o = GetObjectByTag(GetChatArgument(oPC));
    if (GetIsObjectValid(o))
    {
        if (HasChatOption(oPC, "whisper"))
            nVolume = TALKVOLUME_WHISPER;

        AssignCommand(o, ActionSpeakString(GetChatOption(oPC, "line"), nVolume));
    }
}
*/

#include "util_i_datapoint"
#include "util_i_data"

// -----------------------------------------------------------------------------
//                          Configuration/Defaults
// -----------------------------------------------------------------------------

// Note:  Change these defaults to suit the needs or your module

// Delimiters must be single characters, multiple consecutive delimiters will be ignored
// If a delimiter is passed that is greater than one character, the first character will
// be used.
const string DELIMITER = " ";

// These are the command designators for chat commands, if one of the characters in
// this string isn't the first character in the chat line recieved by ParseCommandLine(),
// the function will fail and return FALSE.  Do not use "-", "=", ":", any charcters in
// GROUPS below, or any normal alphabetic characters.
const string DESIGNATORS = "!@#$%^&*;,./?`~|\\";

// Grouping characters must be paired and, if necessary, escaped.  Unpaired grouping
// characters will result in grouping functions being lost and error provided in log.
// Do not use "-", "=", ":", any charcters in DESIGNATORS above, or any normal
// alphabetic characters.
const string GROUPS = "\"\"{}[]()<>";

// To keep grouping symbols as part of the returned data, set this to FALSE
const int    REMOVE_GROUPING_SYMBOLS = TRUE;

// -----------------------------------------------------------------------------
//                      LEAVE EVERYTHING BELOW HERE ALONE!
// -----------------------------------------------------------------------------

// Used by calling scripts for various functions
const string CHAT_PREFIX = "CHAT_";

// Used by Tokenizer to return errors
const string TOKEN_INVALID = "TOKEN_INVALID";

// Variables names for saving chat struct to dataobject
const string LINE = "CHAT_LINE";
const string DESIGNATOR = "CHAT_DESIGNATOR";
const string COMMAND = "CHAT_COMMAND";
const string ARGUMENTS = "CHAT_ARGUMENTS";
const string OPTIONS = "CHAT_OPTIONS";
const string PAIRS = "CHAT_PAIRS";

// Bitwise integers for chat struct components
const int CHAT_ARGUMENTS = 0x01;
const int CHAT_OPTIONS   = 0x02;
const int CHAT_PAIRS     = 0x04;

struct COMMAND_LINE
{
    string chatLine;
    string cmdChar;
    string cmd;
    string options;
    string pairs;
    string args;
};

// -----------------------------------------------------------------------------
//                          Public Function Prototypes
// -----------------------------------------------------------------------------

// ---< RemoveCharacters >---
// Removes individual sChar characters from sSource.  sChar is not a string, but
//  a sequence of characters and are analyzed independently.  Returns sSource with
//  all characters from sChar removed.
string RemoveCharacters(string sSource, string sChar = " ");

// ---< Tokenize >---
// Tokenizes sLine based on sDelimiter.  Groups defined by sGroups are kept together and if
// nRemoveGroups, the grouping symbols will be removed from the returned value.  Tokens are
// returned as a comma-delimited string, so commas are not allowed in any part of the string,
// including grouped characters.  Returns TOKEN_INVALID if it can't tokenize sLine.  Defaults
// set in the configuration settings above can be overriden on a per-call basis by passing
// the appropriate arguments into this function.
string Tokenize(string sLine, string sDelimiter = DELIMITER, string sGroups = GROUPS,
                int nRemoveGroups = REMOVE_GROUPING_SYMBOLS);

// ---< ParseCommandLine >---
// Parses chat line sLine, keeps character groups together as defined by sGroup symbols,
// removes character grouping symbols if nRemoveGroups = TRUE, and allows user to pass
// a specified single-character sDelimiter.  Returns TRUE if parsing was successful.  Passing
// Defaults set in the configuration settings above can be overriden on a per-call basis
// by passing the appropriate arguments into this function.
int ParseCommandLine(object oPC = OBJECT_INVALID, string sLine = "", string sDesignators = DESIGNATORS,
                     string sGroups = GROUPS, int nRemoveGroups = TRUE, string sDelimiter = DELIMITER);

// ---< GetKey >---
// Given a key[:|=]value sPair, returns the key portion.
string GetKey(string sPair);

// ---< GetValue >---
// Given a key[:|=]value pair, returns the value portion.
string GetValue(string sPair);

// ---< FindKey >---
// Given a comma-delimited list of key[:|=] pairs and desired key sKey, returns the base 0 index 
//  of sKey within the series.  If the key does not exist in the series, returns -1.
int FindKey(string sPairs, string sKey);

// ---< HasParsedChatCommand >---
// Given a PC object, returns whether a parsed chat command exists.
int HasParsedChatCommand(object oPC);

// ---< GetChat[Line|Designator|Command] >---
// Given a PC object, returns the chat line|designator|command, if they exist in the most recent parsed command line.
string GetChatLine(object oPC);
string GetChatDesignator(object oPC);
string GetChatCommand(object oPC);

// ---< CountChat[Arguments|Options|Pairs] >---
// Given a PC object, returns the total number of arguments, options, or pairs in the most recent parsed command line.
int CountChatArguments(object oPC);
int CountChatOptions(object oPC);
int CountChatPairs(object oPC);

// ---< HasChat[Argument|Option|Key] >---
// Given a PC object and desired argument|option|key, returns whether that argument or key exists in the most recent
//  parsed command line.
int HasChatArgument(object oPC, string sKey);
int HasChatOption(object oPC, string sKey);
int HasChatKey(object oPC, string sKey);

// ---< FindChat[Argument|Option|Key] >---
// Given a PC object and desired argument|option|key, returns the index of that argument within the series of arguments.
// If the argument does not exist, returns -1.
int FindChatArgument(object oPC, string sKey);
int FindChatOption(object oPC, string sKey);
int FindChatKey(object oPC, string sKey);

// ---< GetChat[Argument|Option|Pair|Key|Value] >---
// Given a PC object and index, returns the argument|option|pair|key|value at that index
string GetChatArgument(object oPC, int nIndex = 0);
string GetChatOption(object oPC, int nIndex = 0);
string GetChatPair(object oPC, int nIndex = 0);
string GetChatKey(object oPC, int nIndex = 0);
string GetChatValue(object oPC, int nIndex = 0);

// ---< GetChat[Arguments|Options|Pairs] >---
// Give a PC object, returns the entire series of arguments|options|pairs associated with the most recent parsed
//  command line, if they exist.
string GetChatArguments(object oPC);
string GetChatOptions(object oPC);
string GetChatPairs(object oPC);

// ---< GetChatKeyValue[Int|Float] >---
// Given a PC object and desired key, returns the value associated with that key as a
// string, int or float, if the value exists.  Error values for ints return 0, and for
// floats 0.0.
string GetChatKeyValue(object oPC, string sKey);
int GetChatKeyValueInt(object oPC, string sKey);
float GetChatKeyValueFloat(object oPC, string sKey);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// private - requires util_i_csvlists
string _AddKeyValue(string sPairs, string sAdd)
{
    string sResult, sKey, sNewKey, sPair;
    int n, nIndex, nFound, nCount = CountList(sPairs);

    if ((nIndex = FindSubString(sAdd, ":")) == -1)
        nIndex = FindSubString(sAdd, "=");

    sNewKey = GetSubString(sAdd, 0, nIndex);

    if (!nCount)
        return sAdd;

    for (n = 0; n < nCount; n++)
    {
        sPair = GetListItem(sPairs, n);
        if ((nIndex = FindSubString(sPair, ":")) == -1)
            nIndex = FindSubString(sPair, "=");

        sKey = GetSubString(sPair, 0, nIndex);
        if (sNewKey == sKey)
        {
            sResult = AddListItem(sResult, sAdd);
            nFound = TRUE;
        }
        else
            sResult = AddListItem(sResult, sPair);
    }

    if (!nFound)
        sResult = AddListItem(sResult, sAdd);

    return sResult;
}

int _GetPrecision(string sValue)
{
    sValue = TrimStringRight(sValue, "f");

    int n = FindSubString(sValue, ".", 0);
    if (n > -1)
    {
        if (n == GetStringLength(sValue) - 1)
            n = 1;
        else
            n = GetStringLength(sValue) - n - 1;
    
        return n;
    }

    return 1;
}

// private - requires util_i_datapoint
object GetChatItem(object oPC)
{
    object CHAT = GetDatapoint("CHAT_DATA");
    string sPC = RemoveCharacters(GetName(oPC));

    object oChat = GetDataItem(CHAT, sPC);

    if (!GetIsObjectValid(oChat))
        oChat = CreateDataItem(CHAT, sPC);

    return oChat;
}

void DestroyChatItem(object oPC)
{
    object CHAT = GetDatapoint("CHAT_DATA");
    string sPC = RemoveCharacters(GetName(oPC));
    object oChat = GetDataItem(CHAT, sPC);

    if (GetIsObjectValid(oChat))
        DestroyObject(oChat);
}

// private
void _SaveParsedChatLine(object oPC, struct COMMAND_LINE cl)
{
    object oChat = GetChatItem(oPC);

    _SetLocalString(oChat, LINE, cl.chatLine);
    _SetLocalString(oChat, DESIGNATOR, cl.cmdChar);
    _SetLocalString(oChat, COMMAND, cl.cmd);
    _SetLocalString(oChat, OPTIONS, cl.options);
    _SetLocalString(oChat, PAIRS, cl.pairs);
    _SetLocalString(oChat, ARGUMENTS, cl.args);
}

// private
struct COMMAND_LINE _GetParsedChatLine(object oPC)
{
    object oChat = GetChatItem(oPC);

    struct COMMAND_LINE cl;
    cl.chatLine = _GetLocalString(oChat, LINE);
    cl.cmdChar = _GetLocalString(oChat, DESIGNATOR);
    cl.cmd = _GetLocalString(oChat, COMMAND);
    cl.options = _GetLocalString(oChat, OPTIONS);
    cl.pairs = _GetLocalString(oChat, PAIRS);
    cl.args = _GetLocalString(oChat, ARGUMENTS);

    return cl;
}

int _CountChatComponent(object oPC, int nComponents)
{
    int nResult;
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENTS)
        nResult += CountList(cl.args);

    if (nComponents & CHAT_OPTIONS)
        nResult += CountList(cl.options);

    if (nComponents & CHAT_PAIRS)
        nResult += CountList(cl.pairs);

    return nResult;
}

int _FindChatComponent(object oPC, int nComponents, string sKey)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    sKey = TrimStringLeft(sKey, "-");

    if (nComponents & CHAT_ARGUMENTS)
        return FindListItem(cl.args, sKey);

    if (nComponents & CHAT_OPTIONS)
        return FindListItem(cl.options, sKey);

    if (nComponents & CHAT_PAIRS)
        return FindKey(cl.pairs, sKey);

    return -1;
}

string _GetChatComponent(object oPC, int nComponents, int nIndex = 0)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENTS)
        return GetListItem(cl.args, nIndex);

    if (nComponents & CHAT_OPTIONS)
        return GetListItem(cl.options, nIndex);

    if (nComponents & CHAT_PAIRS)
        return GetListItem(cl.pairs, nIndex);

    return "";
}

string _GetChatComponents(object oPC, int nComponents)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENTS)
        return cl.args;

    if (nComponents & CHAT_OPTIONS)
        return cl.options;

    if (nComponents & CHAT_PAIRS)
        return cl.pairs;

    return "";
}

string RemoveCharacters(string sSource, string sChar = " ")
{
    if (sSource == "" || sChar == "")
        return sSource;

    int n, nSource = GetStringLength(sSource);
    int nChar = GetStringLength(sChar);
    string c, sResult = "";

    for (n = 0; n < nSource; n++)
    {
        c = GetSubString(sSource, n, 1);
        if (FindSubString(sChar, c) == -1)
            sResult += c;
    }

    Debug("RemoveCharacters:" +
          "\n  String received -> " + sSource +
          "\n  String returned -> " + sResult);

    return sResult;
}

// requires util_i_strings, util_i_csvlists
string Tokenize(string sLine, string sDelimiter = DELIMITER, string sGroups = GROUPS,
                int nRemoveGroups = REMOVE_GROUPING_SYMBOLS)
{
    int n, nGroup, nOpen, nCount;
    string c, sClose, sToken, sResult, sOriginal = sLine;
    sLine = TrimString(sLine);

    // We're doing atomic analysis, so sDelimiter can only be one character
    if (GetStringLength(sDelimiter) != 1)
    {
        Error("Tokenize: passed sDelimiter must be one character in length" +
              "\n  sDelimiter -> '" + sDelimiter + "'" +
              "\n  length     -> " + IntToString(GetStringLength(sDelimiter)));
        return TOKEN_INVALID;
    }

    // If only one token, return it
    if (FindSubString(sLine, sDelimiter, 0) == -1)
        return sLine;

    // Commas not allowed
    sLine = RemoveCharacters(sLine, ",");

    nCount = GetStringLength(sLine);
    for (n = 0; n < nCount; n++)
    {
        // Analyze by character
        c = GetSubString(sLine, n, 1);

        if (nGroup && c == sClose)
        {
            // Handle group closures, add character if keeping group identifiers
            if (!nRemoveGroups)
                sToken += c;

            nGroup = FALSE;
        }
        else if ((nOpen = FindSubString(sGroups, c, 0)) > -1)
        {
            // Add special handling for grouped characters
            nGroup = TRUE;
            sClose = GetSubString(sGroups, nOpen + 1, 1);

            // If there is no closing character, throw
            if (FindSubString(sLine, sClose, n + 1) == -1)
            {
                Error("Tokenize: group opened without a closure" +
                      "\n  sLine -> " + sOriginal +
                      "\n  Group Opening Character -> " + GetSubString(sGroups, nOpen, 1) +
                      "\n  Position of Unmatched Grouping -> " + IntToString(n) + " (Character #" + IntToString(n + 1) + ")");
                return TOKEN_INVALID;
            }

            // Add character if keeping group identifiers
            if (!nRemoveGroups)
                sToken += c;
        }
        else if (c == sDelimiter && !nGroup)
        {
            // Handle multiple delimiters
            if (GetSubString(sLine, n - 1, 1) != sDelimiter)
            {
                // Add/reset the token when we find a delimiter
                sResult = AddListItem(sResult, sToken);
                sToken = "";
            }
        }
        else
            // No special handling
            sToken += c;

        // If we're at the end of the command line, add the last token
        if (n == nCount - 1)
            sResult = AddListItem(sResult, sToken);
    }

    Debug("Tokenize:" +
          "\n  Chat received -> " + sOriginal +
          "\n  Tokens returned -> " + (GetStringLength(sResult) ? sResult : TOKEN_INVALID));

    return (GetStringLength(sResult) ? sResult : TOKEN_INVALID);
}

// requires util_i_debug, util_i_strings, util_i_csvlists
int ParseCommandLine(object oPC = OBJECT_INVALID, string sLine = "", string sDesignators = DESIGNATORS,
                     string sGroups = GROUPS, int nRemoveGroups = TRUE, string sDelimiter = DELIMITER)
{
    // Check for valid inputs
    int nLen;
    string sNotice, sError, sMessage;
    if ((nLen = GetStringLength(sDelimiter)) != 1)
    {
        sMessage = "sDelimiter limited to one character; received " + IntToString(nLen) + ".";
        if (nLen > 0)
            sDelimiter = GetStringLeft(sDelimiter, 1);
        else
            sDelimiter = " ";

        sNotice += (GetStringLength(sError) ? "\n " : "") + sMessage;
    }

    if (!GetStringLength(sGroups))
    {
        sMessage = "Grouping symbols not received; grouped tokens will not be returned.";
        sNotice += (GetStringLength(sError) ? "\n " : "") + sMessage;
    }

    if (GetStringLength(sGroups) % 2)
    {
        sMessage = "Grouping symbols must be paired; received at least one unpaired symbol: " + sGroups +
                   "Character grouping has been disabled for this parsing attempt.";
        sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
        sGroups = "";
    }

    if (oPC == OBJECT_INVALID)
    {
        oPC = GetPCChatSpeaker();
        if (!GetIsObjectValid(oPC))
        {
            sMessage = "Unable to determine appropriate target; invalid object " +
                       "received as oPC and GetPCChatSpeaker() returned invalid object.";
            sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
        }
    }

    if (sLine == "")
    {
        sLine = GetPCChatMessage();
        if (sLine == "")
        {
            sMessage = "Unable to determine parsing string; empty string " +
                       "received and GetPCChatMessage() returned empty string.";
            sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
        }
    }
    else
        sLine = TrimString(sLine);

    if (!GetStringLength(sDesignators))
    {
        sMessage = "Chat designators not received; unable to parse.";
        sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
    }
    else
        if (FindSubString(sDesignators, GetStringLeft(sLine, 1)) == -1)
            return FALSE;

    if (GetStringLength(sNotice))
        Notice("ParseCommandLine info:\n  " + sNotice);

    if (GetStringLength(sError))
    {
        Error("ParseCommandLine errors:\n  " + sError);
        return FALSE;
    }

    // Do the actual work
    string c, sShortOpts, sToken, sTokens = Tokenize(sLine, sDelimiter, sGroups, nRemoveGroups);
    string sOriginal = sLine;
    int n, nPrefix, nCount = CountList(sTokens);
    struct COMMAND_LINE cl;

    if (!nCount || sTokens == TOKEN_INVALID)
    {
        // No tokens received, send the error and return INVALID
        Error("ParseCommandLine: unable to create COMMAND_LINE struct; no tokens received" +
                "\n  sLine   -> " + sLine +
                "\n  sTokens -> " + sTokens);
        return FALSE;
    }

    sToken = GetListItem(sTokens);
    if (GetStringLength(sToken) > 0)
    {
        cl.chatLine = sOriginal;
        cl.cmdChar = GetStringLeft(sOriginal, 1);
    }

    if (GetStringLength(sToken) > 1)
        cl.cmd = GetSubString(sToken, 1, GetStringLength(sToken));

    sTokens = DeleteListItem(sTokens);
    nCount = CountList(sTokens);

    for (n = 0; n < nCount; n++)
    {
        sToken = GetListItem(sTokens, n);
        if (GetStringLeft(sToken, 2) == "--")
            nPrefix = 2;
        else if (GetStringLeft(sToken, 1) == "-")
        {
            if (FindSubString(sToken, ":") == -1 && FindSubString(sToken, "=") == -1)
            {
                int l, len = GetStringLength(sToken);
                for (l = 1; l < len; l++)
                    sShortOpts = AddListItem(sShortOpts, GetSubString(sToken, l, 1));
            }
            nPrefix = 1;
        }
        else
            nPrefix = 0;

        if (!nPrefix)
            cl.args = AddListItem(cl.args, sToken);
        else if (FindSubString(sToken, ":") != -1 || FindSubString(sToken, "=") != -1)
            cl.pairs = _AddKeyValue(cl.pairs, GetSubString(sToken, nPrefix, GetStringLength(sToken)));
        else
        {
            if (sShortOpts == "")
                cl.options = AddListItem(cl.options, GetSubString(sToken, nPrefix, GetStringLength(sToken)));
            else
                cl.options = MergeLists(cl.options, sShortOpts, TRUE);
        }

        sShortOpts = "";
    }

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        Debug("ParseCommandLine:" +
              "\n  Chat received -> " + sLine +
              "\n  Struct returned:" +
              "\n    Chat Line         -> " + (GetStringLength(cl.chatLine) ? cl.chatLine : "<none>") + 
              "\n    Command Character -> " + (GetStringLength(cl.cmdChar) ? cl.cmdChar : "<none>") +
              "\n    Command           -> " + (GetStringLength(cl.cmd) ? cl.cmd : "<none>") +
              "\n    Options           -> " + (GetStringLength(cl.options) ? cl.options : "<none>") +
              "\n    Pairs             -> " + (GetStringLength(cl.pairs) ? cl.pairs : "<none>") +
              "\n    Arguments         -> " + (GetStringLength(cl.args) ? cl.args : "<none>"));

    _SaveParsedChatLine(oPC, cl);
    return GetStringLength(cl.cmdChar);
}
string GetKey(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, 0, nIndex);
}

string GetValue(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, ++nIndex, GetStringLength(sPair));
}

int FindKey(string sPairs, string sKey)
{
    int n, nCount = CountList(sPairs);
    string sPair;

    for (n = 0; n < nCount; n++)
    {
        sPair = GetListItem(sPairs, n);
        if (sKey == GetKey(sPair))
            return n;
    }

    return -1;    
}

int HasParsedChatCommand(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.cmdChar != "";
}

string GetChatLine(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.chatLine;
}

string GetChatDesignator(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.cmdChar;
}

string GetChatCommand(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.cmd;
}

int CountChatArguments(object oPC)
{
    return _CountChatComponent(oPC, CHAT_ARGUMENTS);
}

int CountChatOptions(object oPC)
{
    return _CountChatComponent(oPC, CHAT_OPTIONS);
}

int CountChatPairs(object oPC)
{
    return _CountChatComponent(oPC, CHAT_PAIRS);
}

int HasChatArgument(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_ARGUMENTS, sKey) > -1;
}

int HasChatOption(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_OPTIONS, sKey) > -1;
}

int HasChatKey(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_PAIRS, sKey) > -1;
}

int FindChatArgument(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_ARGUMENTS, sKey);
}

int FindChatOption(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_OPTIONS, sKey);
}

int FindChatKey(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_PAIRS, sKey);
}

string GetChatArgument(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_ARGUMENTS, nIndex);
}

string GetChatOption(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_OPTIONS, nIndex);
}

string GetChatPair(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_PAIRS, nIndex);
}

string GetChatKey(object oPC, int nIndex = 0)
{
    return GetKey(_GetChatComponent(oPC, CHAT_PAIRS, nIndex));
}

string GetChatValue(object oPC, int nIndex = 0)
{
    return GetValue(_GetChatComponent(oPC, CHAT_PAIRS, nIndex));
}

string GetChatArguments(object oPC)
{
    return _GetChatComponents(oPC, CHAT_ARGUMENTS);
}

string GetChatOptions(object oPC)
{
    return _GetChatComponents(oPC, CHAT_OPTIONS);
}

string GetChatPairs(object oPC)
{
    return _GetChatComponents(oPC, CHAT_PAIRS);
}

string GetChatKeyValue(object oPC, string sKey)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return GetValue(GetListItem(cl.pairs, FindKey(cl.pairs, TrimString(sKey, "-"))));
}

int GetChatKeyValueInt(object oPC, string sKey)
{
    return StringToInt(GetChatKeyValue(oPC, sKey));
}

float GetChatKeyValueFloat(object oPC, string sKey)
{
    string sValue = GetChatKeyValue(oPC, sKey);
    return StringToFloat(sValue);
}
