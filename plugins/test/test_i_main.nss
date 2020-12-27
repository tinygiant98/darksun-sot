// -----------------------------------------------------------------------------
//    File: test_i_main.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Core functions
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "test_i_config"
#include "test_i_const"
#include "test_i_text"

#include "util_i_data"
#include "x3_inc_string"

/*
string RemoveCharacter(string sSource, string sChar = " ")
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

    return sResult;
}

string Tokenizes(string sMessage, string sDelimiter = " ")
{
    // Returns a comma-delimited list of tokens
    if (FindSubString(sMessage, sDelimiter, 0) == -1)
        return sMessage;

    sMessage = RemoveCharacters(sMessage, ",");

    int n;
    string sResult = "";

    while ((n = FindSubString(sMessage, sDelimiter, 0)) != -1)
    {
        sResult = AddListItem(sResult, GetSubString(sMessage, 0, n));
        sMessage = GetSubString(sMessage, ++n, 1000);
    }

    return AddListItem(sResult, sMessage);
}
*/

string Filter(string sArguments, string sCommands)
{
    // returns whether any entries in sArguments are not in sCommands
    // sArguments and sCommands are both comma-separated lists
    int n, nCount = CountList(sArguments);
    int c, cCount = CountList(sCommands);
    return "";
}