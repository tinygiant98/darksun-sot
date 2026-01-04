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
#include "util_i_libraries"
#include "core_i_framework"

#include "chat_i_main"

const int TYPE_INTEGER = 1;
const int TYPE_FLOAT = 2;
const int TYPE_STRING = 3;
const int TYPE_OBJECT = 4;
const int TYPE_VECTOR = 5;
const int TYPE_LOCATION = 6;

void ReloadLibraries(string sLibraries)
{
    if (CountList(sLibraries) > 1)
        LoadLibraries(sLibraries, TRUE);
    else
        LoadLibrary(sLibraries, TRUE);
}

string GetVariable(object oPC, object oTarget, string sOverride = "")
{
//    int nInternal = (sOverride == "" ? FALSE : TRUE);
//    int i, n, nFound, nCount = (!nInternal ? CountChatArguments(oPC) : 1);
//    string s, sVarName, sType, sResult, sTitle = (GetIsPC(oPC) ? GetName(oTarget) : GetTag(oTarget));
//    string sKeys, sValues;
//    float f;
//    location l;
//    vector v;
//    object o;    
//
//    for (n = 0; n < nCount; n++)
//    {
//        sVarName = (!nInternal ? GetChatArgument(oPC, n) : sOverride);
//
//        i = GetLocalInt(oTarget, sVarName);
//        if (i)
//        {
//            if (HasChatOption(oPC, "bool,b,boolean"))
//                sResult = i ? "TRUE" : "FALSE";
//            else
//                sResult = IntToString(i);
//
//            sKeys = AddListItem(sKeys, "Integer");
//            sValues = AddListItem(sValues, sResult);
//        }
//
//        s = GetLocalString(oTarget, sVarName);
//        if (s != "")
//        {
//            sResult = s;
//            sKeys = AddListItem(sKeys, "String");
//            sValues = AddListItem(sValues, sResult);
//        }
//
//        f = GetLocalFloat(oTarget, sVarName);
//        if (f != 0.0)
//        {
//            sResult = FloatToString(f, 0);
//            sKeys = AddListItem(sKeys, "Float");
//            sValues = AddListItem(sValues, sResult);
//        }
//
//        o = GetLocalObject(oTarget, sVarName);
//        if (GetIsObjectValid(o))
//        {
//            sResult = "{tag} " + GetTag(o) + " {Name} " + GetName(o);
//            sKeys = AddListItem(sKeys, "Object");
//            sValues = AddListItem(sValues, sResult);
//        }
//
//        l = GetLocalLocation(oTarget, sVarName);
//        if (GetAreaFromLocation(l) != OBJECT_INVALID)
//        {
//            sType = "Location";
//            vector v = GetPositionFromLocation(l);
//            sResult = "{area} " + GetTag(GetAreaFromLocation(l)) + " " +
//                      "{position} [" + FloatToString(v.x, 0, 2) + "  " +
//                                        FloatToString(v.y, 0, 2) + "  " +
//                                        FloatToString(v.z, 0, 2) + "] " +
//                      "{facing} " + FloatToString(GetFacingFromLocation(l), 0, 2);
//
//            sKeys = AddListItem(sKeys, "Location");
//            sValues = AddListItem(sKeys, sResult);
//        }
///*
//        v = GetLocalVector(oTarget, sVarName);
//        if (v != Vector())
//        {
//            sResult = "[" + FloatToString(v.x, 0, 2) + "  " +
//                            FloatToString(v.y, 0, 2) + "  " +
//                            FloatToString(v.z, 0, 2) + "]";
//            sKeys = AddListItem(sKeys, "Vector");
//            sValues = AddListItem(sValues, sResult);
//        }
//*/
//
//        if (nCount = CountList(sKeys))
//        {
//            if (nInternal && nCount > 0)
//                return sKeys;
//
//            for (n = 0; n < nCount; n++)
//                SendChatResult(GetListItem(sKeys, n) + " " + sVarName + " on " + sTitle + " -> " + GetListItem(sValues, n), oPC);
//        }
//        else if (!nInternal)
//            SendChatResult("Variable " + sVarName + " not found on " + sTitle + " (or is default value)", oPC, CHAT_FLAG_ERROR);
//
//        sKeys = "";
//        sValues = "";
//    }

    return "";
}

void DeleteVariable(object oPC, object oTarget)
{
    int n, nType, nTypes, nSpecify, nCount = CountChatArguments(oPC);
    int bAll;
    string sConfirm, sType, sTypes, sVarName, sTitle = (GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget));

    for (n = 0; n < nCount; n++)
    {
        sVarName = GetChatArgument(oPC, n);
        sTypes = GetVariable(oPC, oTarget, sVarName);

        if (!CountList(sTypes))
        {
            SendChatResult("Variable " + sVarName + " not found on " + sTitle + " (or is default value)", oPC, CHAT_FLAG_ERROR);
            SendChatResult(DeleteVariableHelp(), oPC, CHAT_FLAG_HELP);
            continue;
        }

        nTypes = CountList(sTypes);
        bAll = HasChatOption(oPC, "all");
        
        for (nType = 0; nType < nTypes; nType++)
        {
            sType = GetListItem(sTypes, nType);
            if (sType == "Integer")
            {               
                if (nTypes == 1)
                    DeleteLocalInt(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "i,int,integer")))
                {
                    DeleteLocalInt(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "String")
            {               
                if (nTypes == 1)
                    DeleteLocalString(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "s,str,string")))
                {
                    DeleteLocalString(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "Float")
            {               
                if (nTypes == 1)
                    DeleteLocalFloat(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "f,float")))
                {
                    DeleteLocalFloat(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "Object")
            {               
                if (nTypes == 1)
                    DeleteLocalObject(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "o,obj,object")))
                {
                    DeleteLocalObject(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
            else if (sType == "Location")
            {               
                if (nTypes == 1)
                    DeleteLocalLocation(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "l,loc,location")))
                {
                    DeleteLocalLocation(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
/*
            else if (sType == "Vector")
            {               
                if (nTypes == 1)
                    DeleteLocalVector(oTarget, sVarName);
                else if (nTypes > 1 && (bAll || HasChatOption(oPC, "v,vec,vector")))
                {
                    DeleteLocalVector(oTarget, sVarName);
                    nSpecify = TRUE;
                    continue;
                }
                else
                    sConfirm = AddListItem(sConfirm, sType);
            }
*/
        }

        if (nTypes > 1 && CountList(sConfirm) && !nSpecify)
        {
            SendChatResult("Found multiple types for variable " + sVarName + "; type to delete must be specified" +
                           "\n  Variable types found -> " + sTypes +
                           "\n  Variable types not specified for deletion -> " + sConfirm, oPC, CHAT_FLAG_ERROR);
            SendChatResult(DeleteVariableHelp(), oPC, CHAT_FLAG_HELP);
        }

        for (nType = 0; nType < nTypes; nType++)
        {
            sType = GetListItem(sTypes, nType);
            if (!HasListItem(sConfirm, sType))
                SendChatResult(sType + " variable " + sVarName + " deleted from " + sTitle, oPC);
        }

        nSpecify = FALSE;
    }
}

void SetVariable(object oPC, object oTarget)
{
    string sType, sVarName, sValue, sResult;
    string sTitle = (GetIsPC(oPC) ? GetName(oTarget) : GetTag(oTarget));

    if (CountChatArguments(oPC) > 1)
        SendChatResult("More than one variable name passed; only the first will be used" +
                       "\n  Arguments received -> " + GetChatArguments(oPC), oPC, CHAT_FLAG_ERROR);

    sVarName = GetChatArgument(oPC);

    if (HasChatKey(oPC, "i,int,integer"))
    {
        sValue = GetChatKeyValue(oPC, "i,int,integer");
        if (TestStringAgainstPattern("*n", sValue))
        {
            sType = "Integer";
            SetLocalInt(oTarget, sVarName, StringToInt(sValue));
        }
    }
    else if (HasChatKey(oPC, "s,str,string"))
    {
        sValue = GetChatKeyValue(oPC, "s,str,string");
        sType = "String";
        SetLocalString(oTarget, sVarName, sValue);
    }
    else if (HasChatKey(oPC, "f,float"))
    {
        sValue = GetChatKeyValue(oPC, "f,float");
        if (TestStringAgainstPattern("*n.*n|*n", sValue))
        {
            sType = "Float";
            SetLocalFloat(oTarget, sVarName, StringToFloat(sValue));
        }
    }
    else if (HasChatKey(oPC, "o,obj,object"))
    {
        sValue = GetChatKeyValue(oPC, "o,obj,object");
        if (GetIsObjectValid(GetObjectByTag(sValue)))
        {
            sType = "Object";
            sResult = "{tag} " + sValue;
            SetLocalObject(oTarget, sVarName, GetObjectByTag(sValue));
        }
    }
    else if (HasChatKey(oPC, "l,loc,location"))
    {
        sValue = GetChatKeyValue(oPC, "l,loc,location");
        string sValues = Tokenize(sValue, ";", "", TRUE);

        if (CountList(sValues) != 5)
        {
            SendChatResult("Incorrect number of arguments passed in the --[l|loc|location] value" +
                           "\n  Values received -> " + sValue, oPC, CHAT_FLAG_ERROR);
            SendChatResult(SetVariableHelp(), oPC, CHAT_FLAG_HELP);
            return;
        }

        object oArea = GetObjectByTag(GetListItem(sValues, 0));
        float fX = StringToFloat(GetListItem(sValues, 1));
        float fY = StringToFloat(GetListItem(sValues, 2));
        float fZ = StringToFloat(GetListItem(sValues, 3));
        float fFacing = StringToFloat(GetListItem(sValues, 4));

        if (GetIsObjectValid(oArea))
        {
            sType = "Location";
            sResult = "{area tag} " + GetListItem(sValues, 0) + 
                      "{position} [" + GetListItem(sValues, 1) +
                        "," + GetListItem(sValues, 2) +
                        "," + GetListItem(sValues, 3) + "] " +
                      "{facing} " + GetListItem(sValues, 4);
            SetLocalLocation(oTarget, sVarName, Location(oArea, Vector(fX, fY, fZ), fFacing));
        }
        else
            SendChatResult("Could not find a valid object for passed object tag" +
                           "\n  Tag received -> " + GetListItem(sValues, 0), oPC, CHAT_FLAG_ERROR);
    }
/*    
    else if (HasChatKey(oPC, "v,vec,vector"))
    {
        sValue = GetChatKeyValue(oPC, "v,vec,vector");
        string sValues = Tokenize(sValue, ";", "", TRUE);

        if (CountList(sValues) != 3)
        {
            SendChatResult("Incorrect number of arguments passed in the --[v|vec|vector] value" +
                           "\n  Values received -> " + sValue +
                           "\n\n" +
                           SetVariableHelp(), oPC, FLAG_ERROR);
            return;
        }

        float fX = StringToFloat(GetListItem(sValues, 0));
        float fY = StringToFloat(GetListItem(sValues, 1));
        float fZ = StringToFloat(GetListItem(sValues, 2));

        sType = "Vector";
        sResult = "[" + GetListItem(sValues, 0) +
                    "," + GetListItem(sValues, 1) +
                    "," + GetListItem(sValues, 2) + "]";
        SetLocalVector(oTarget, sVarName, Vector(fX, fY, fZ));
    }
*/
    else
        SendChatResult("Variable type could not be determined from options" +
                       "\n  Key-Value Pairs received -> " + GetChatPairs(oPC), oPC, CHAT_FLAG_ERROR);

    if (sType != "")      
        SendChatResult(sType + " variable " + sVarName + " with value " + (sResult == "" ? sValue : sResult) + " set on " + (GetIsPC(oPC) ? GetName(oTarget) : GetTag(oTarget)), oPC);
}
