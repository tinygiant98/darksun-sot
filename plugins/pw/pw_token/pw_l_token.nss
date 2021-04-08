// -----------------------------------------------------------------------------
//    File: ds_l_area.nss
//  System: Event Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_argstack"
#include "util_i_library"
#include "util_i_data"

#include "core_i_framework"

const string DLG_TOKEN         = "*Token";
const string DLG_TOKEN_VALUES  = "*TokenValues";

string NormalizeDialogToken(string sToken)
{
    if (GetModuleInt(MODULE, DLG_TOKEN + "*" + sToken))
        return sToken;

    string sLower = GetStringLowerCase(sToken);
    if (sToken == sLower || !GetModuleInt(MODULE, DLG_TOKEN + "*" + sLower))
        return "";

    return sLower;
}

void AddDialogToken(string sToken, string sEvalScript, string sValues = "")
{
    SetModuleInt   (MODULE, DLG_TOKEN + "*" + sToken, TRUE);
    SetModuleString(MODULE, DLG_TOKEN + "*" + sToken, sEvalScript);
    SetModuleString(MODULE, DLG_TOKEN_VALUES + "*" + sToken, sValues);
}

void AddDialogTokens()
{
    if (!GetIsLibraryLoaded("dlg_l_tokens"))
        LoadLibrary("dlg_l_tokens");

    string sPrefix = "DialogToken_";
    AddDialogToken("alignment",       sPrefix + "Alignment");
    AddDialogToken("bitch/bastard",   sPrefix + "Gender", "Bastard, Bitch");
    AddDialogToken("boy/girl",        sPrefix + "Gender", "Boy, Girl");
    AddDialogToken("brother/sister",  sPrefix + "Gender", "Brother, Sister");
    AddDialogToken("class",           sPrefix + "Class");
    AddDialogToken("classes",         sPrefix + "Class");
    AddDialogToken("day/night",       sPrefix + "DayNight");
    AddDialogToken("Deity",           sPrefix + "Deity");
    AddDialogToken("FirstName",       sPrefix + "Name");
    AddDialogToken("FullName",        sPrefix + "Name");
    AddDialogToken("gameday",         sPrefix + "GameDate");
    AddDialogToken("gamedate",        sPrefix + "GameDate");
    AddDialogToken("gamehour",        sPrefix + "GameTime");
    AddDialogToken("gameminute",      sPrefix + "GameTime");
    AddDialogToken("gamemonth",       sPrefix + "GameDate");
    AddDialogToken("gamesecond",      sPrefix + "GameTime");
    AddDialogToken("gametime12",      sPrefix + "GameTime");
    AddDialogToken("gametime24",      sPrefix + "GameTime");
    AddDialogToken("gameyear",        sPrefix + "GameDate");
    AddDialogToken("good/evil",       sPrefix + "Alignment");
    AddDialogToken("he/she",          sPrefix + "Gender", "He, She");
    AddDialogToken("him/her",         sPrefix + "Gender", "Him, Her");
    AddDialogToken("his/her",         sPrefix + "Gender", "His, Her");
    AddDialogToken("his/hers",        sPrefix + "Gender", "His, Hers");
    AddDialogToken("lad/lass",        sPrefix + "Gender", "Lad, Lass");
    AddDialogToken("LastName",        sPrefix + "Name");
    AddDialogToken("lawful/chaotic",  sPrefix + "Alignment");
    AddDialogToken("law/chaos",       sPrefix + "Alignment");
    AddDialogToken("level",           sPrefix + "Level");
    AddDialogToken("lord/lady",       sPrefix + "Gender", "Lord, Lady");
    AddDialogToken("male/female",     sPrefix + "Gender", "Male, Female");
    AddDialogToken("man/woman",       sPrefix + "Gender", "Man, Woman");
    AddDialogToken("master/mistress", sPrefix + "Gender", "Master, Mistress");
    AddDialogToken("mister/missus",   sPrefix + "Gender", "Mister, Missus");
    AddDialogToken("PlayerName",      sPrefix + "PlayerName");
    AddDialogToken("quarterday",      sPrefix + "QuarterDay");
    AddDialogToken("race",            sPrefix + "Race");
    AddDialogToken("races",           sPrefix + "Race");
    AddDialogToken("racial",          sPrefix + "Race");
    AddDialogToken("sir/madam",       sPrefix + "Gender", "Sir, Madam");
    AddDialogToken("subrace",         sPrefix + "SubRace");
    AddDialogToken("area",            sPrefix + "Area");
}

string EvalDialogToken(string sToken, object oPC)
{
    string sNormal = NormalizeDialogToken(sToken);

    // Ensure this is a valid token
    if (sNormal == "")
        return "<" + sToken + ">";

    string sScript = GetModuleString(MODULE, DLG_TOKEN + "*" + sNormal);
    string sValues = GetModuleString(MODULE, DLG_TOKEN_VALUES + "*" + sNormal);

    SetLocalString(oPC, DLG_TOKEN, sNormal);
    SetLocalString(oPC, DLG_TOKEN_VALUES, sValues);
    RunLibraryScript(sScript, oPC);

    string sEval = GetLocalString(oPC, DLG_TOKEN);

    // Token eval scripts should always yield the uppercase version of the
    // token. If the desired value is lowercase, we change it here.
    if (sToken == GetStringLowerCase(sToken))
        sEval = GetStringLowerCase(sEval);

    return sEval;
}

string EvalDialogTokens(string sString, object oPC)
{
    string sRet, sToken;
    int nPos, nClose;
    int nOpen = FindSubString(sString, "<");

    while (nOpen >= 0)
    {
        nClose = FindSubString(sString, ">", nOpen);

        // If no matching bracket, this isn't a token
        // TODO: handle tokens and unmatched brackets in the same string
        if (nClose < 0)
            break;

        // Add everything before the bracket to the return value
        sRet += GetSubString(sString, nPos, nOpen - nPos);

        // Everything between the brackets is our token
        sToken = GetSubString(sString, nOpen + 1, nClose - nOpen - 1);

        if (NormalizeDialogToken(sToken) != "")
        {
            sRet += EvalDialogToken(sToken, oPC);
            nPos = nClose + 1;
        }
        else
        {
            // In case this is an angle bracket before an actual token
            sRet += "<";
            nPos = nOpen + 1;
        }

        // Update position and find the next token
        nOpen = FindSubString(sString, "<", nPos);
    }

    // Add any remaining text to the return value
    sRet += GetStringRight(sString, GetStringLength(sString) - nPos);
    return sRet;
}

void TOKEN_EvaluateTokens()
{
    string sMessage = GetArgumentString();
    object oPC = GetArgumentObject();

    sMessage = EvalDialogTokens(sMessage, oPC);
    PushReturnValueString(sMessage);
}

void token_OnModuleLoad()
{
    AddDialogTokens();
}

void DialogToken_Area()
{
    object oPC = OBJECT_SELF;
    string sArea = GetName(GetArea(oPC));

    SetLocalString(OBJECT_SELF, "*Token", sArea);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("pw");
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "token_OnModuleLoad");

    RegisterLibraryScript("TOKEN_EvaluateTokens", 1);
    RegisterLibraryScript("token_OnModuleLoad", 10);
    RegisterLibraryScript("DialogToken_Area", 11);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  TOKEN_EvaluateTokens(); break;

        case 10: token_OnModuleLoad(); break;
        case 11: DialogToken_Area(); break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
