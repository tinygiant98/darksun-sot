
// -----------------------------------------------------------------------------
//    File: chat_i_main.nss
//  System: Chat Command System (core)
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "util_i_datapoint"

const string CHAT_PREFIX = "CHAT_";

struct COMMAND_LINE
{
    string chatLine;
    string cmdChar;
    string cmd;
    string options;
    string pairs;
    string args;
};

const string COMMAND_INVALID = "COMMAND_INVALID";
const string TOKEN_INVALID = "TOKEN_INVALID";

const int CHAT_ARGUMENTS = 0x01;
const int CHAT_OPTIONS   = 0x02;
const int CHAT_PAIRS     = 0x04;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------




// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

string AddKeyValue(string sPairs, string sAdd)
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

// <----- Tokenize ----->
// Tokenizes sLine based on sDelimiter.  Groups defined by sGroups are kept together and if
// nRemoveGroups, the group identifiers will be removed from the returned value.  Tokens are
// returned as a comma-delimited string, so commas are not allowed in any part of the string,
// including grouped characters.  Private.
string Tokenize(string sLine, string sDelimiter, string sGroups, int nRemoveGroups)
{
    int n, nGroup, nOpen, nCount;
    string c, sClose, sToken, sResult, sOriginal = sLine;

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

// <----- ParseCommandLine ----->
// Parses chat line sLine in COMMAND_LINE struct variable.  Public.
struct COMMAND_LINE ParseCommandLine(string sLine, int nRemoveGroups = TRUE, string sGroups = "\"\"{}[]()<>", string sDelimiter = " ")
{
    string c, sShortOpts, sToken, sTokens = Tokenize(sLine, sDelimiter, sGroups, nRemoveGroups);
    int n, nPrefix, nCount = CountList(sTokens);
    struct COMMAND_LINE cl;

    if (!nCount || sTokens == TOKEN_INVALID)
    {
        // No tokens received, send the error and return INVALID
        Error("ParseCommandLine: unable to create COMMAND_LINE struct; no tokens received" +
                "\n  sLine   -> " + sLine +
                "\n  sTokens -> " + sTokens);
        cl.cmdChar = COMMAND_INVALID;
        return cl;
    }

    sToken = GetListItem(sTokens);
    if (GetStringLength(sToken) > 0)
    {
        cl.chatLine = sLine;
        cl.cmdChar = GetSubString(sToken, 0, 1);
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
            cl.pairs = AddKeyValue(cl.pairs, GetSubString(sToken, nPrefix, GetStringLength(sToken)));
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

    return cl;
}

object GetChatItem(object oPC)
{
    object oChat = GetDataItem(oPC, "CHAT");

    if (!GetIsObjectValid(oChat))
        oChat = CreateDataItem(oPC, "CHAT");

    return oChat;
}

void DestroyChatItem(object oPC)
{
    object oChat = GetDataItem(oPC, "CHAT");

    if (GetIsObjectValid(oChat))
        DestroyObject(oChat);
}

void SaveParsedChatLine(object oPC, struct COMMAND_LINE cl)
{
    object oChat = GetChatItem(oPC);

    _SetLocalString(oChat, "COMMAND_CHAR", cl.cmdChar);
    _SetLocalString(oChat, "COMMAND", cl.cmd);
    _SetLocalString(oChat, "OPTIONS", cl.options);
    _SetLocalString(oChat, "PAIRS", cl.pairs);
    _SetLocalString(oChat, "ARGUMENTS", cl.args);
}

struct COMMAND_LINE GetParsedChatLine(object oPC)
{
    object oChat = GetChatItem(oPC);

    struct COMMAND_LINE cl;
    cl.cmdChar = _GetLocalString(oChat, "COMMAND_CHAR");
    cl.cmd = _GetLocalString(oChat, "COMMAND");
    cl.options = _GetLocalString(oChat, "OPTIONS");
    cl.pairs = _GetLocalString(oChat, "PAIRS");
    cl.args = _GetLocalString(oChat, "ARGUMENTS");

    return cl;
}

string GetKey(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    return GetSubString(sPair, 0, nIndex);
}

string GetValue(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

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

int _CountChatComponent(object oPC, int nComponents)
{
    int nResult;
    struct COMMAND_LINE cl = GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENTS)
        nResult += CountList(cl.args);

    if (nComponents & CHAT_OPTIONS)
        nResult += CountList(cl.options);

    if (nComponents & CHAT_PAIRS)
        nResult += CountList(cl.pairs);

    return nResult;
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

int _FindChatComponent(object oPC, int nComponents, string sKey)
{
    struct COMMAND_LINE cl = GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENTS)
        return FindListItem(cl.args, sKey);

    if (nComponents & CHAT_OPTIONS)
        return FindListItem(cl.options, sKey);

    if (nComponents & CHAT_PAIRS)
        return FindKey(cl.args, sKey);

    return -1;
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

string _GetChatComponent(object oPC, int nComponents, int nIndex = 0)
{
    struct COMMAND_LINE cl = GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENTS)
        return GetListItem(cl.args, nIndex);

    if (nComponents & CHAT_OPTIONS)
        return GetListItem(cl.options, nIndex);

    if (nComponents & CHAT_PAIRS)
    {
        string sPair = GetListItem(cl.pairs, nIndex);
        return GetValue(sPair);
    }

    return "";
}

string GetChatArgument(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_ARGUMENTS, nIndex);
}

string GetChatOption(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_OPTIONS, nIndex);
}

string GetChatValue(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_PAIRS, nIndex);
}

string GetChatKeyValue(object oPC, string sKey)
{
    struct COMMAND_LINE cl = GetParsedChatLine(oPC);
    return GetValue(GetListItem(cl.pairs, FindKey(cl.pairs, sKey)));
}

string GetChatLine(object oPC)
{
    struct COMMAND_LINE cl = GetParsedChatLine(oPC);
    return cl.chatLine;
}
