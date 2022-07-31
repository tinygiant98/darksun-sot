
// -----------------------------------------------------------------------------
//    File: util_i_argstack.nss
//  System: Library Argument Stacks
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_lists"

const string ARGS_DEFAULT_STACK = "ARGS_DEFAULT_STACK";
const string ARGS_DEFAULT_RETURN = "ARGS_DEFAULT_RETURN";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< PushArgumentInt >---
// Pushes int argument nValue onto varlist sListName on oTarget
int PushArgumentInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentInt >---
// Returns the first int argument from varlist sListName on oTarget
int GetArgumentInt(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentString >---
// Pushes string argument sValue onto varlist sListName on oTarget
int PushArgumentString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentString >---
// Returns the first string argument from varlist sListName on oTarget
string GetArgumentString(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentFloat >---
// Pushes float argument fValue onto varlist sListName on oTarget
int PushArgumentFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentFloat >---
// Returns the first float argument from varlist sListName on oTarget
float GetArgumentFloat(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentObject >---
// Pushes object argument oValue onto varlist sListName on oTarget
int PushArgumentObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentObject >---
// Returns the first object argument from varlist sListName on oTarget
object GetArgumentObject(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentLocation >---
// Pushes location argument lValue onto varlist sListName on oTarget
int PushArgumentLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentLocation >---
// Returns the first location argument from varlist sListName on oTarget
location GetArgumentLocation(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentVector >---
// Pushes vector argument vValue onto varlist sListName on oTarget
int PushArgumentVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentVector >---
// Returns the first vector argument from varlist sListName on oTarget
vector GetArgumentVector(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< ClearArgumentStacks >---
// Clears all values from all varlists sListName on oTarget
void ClearArgumentStacks(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushReturnValuetInt >---
// Pushes int argument nValue onto varlist sListName on oTarget
int PushReturnValuetInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetReturnValueInt >---
// Returns the first int argument from varlist sListName on oTarget
int GetReturnValueInt(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushReturnValueString >---
// Pushes string argument nValue onto varlist sListName on oTarget
int PushReturnValueString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetReturnValueString >---
// Returns the first string argument from varlist sListName on oTarget
string GetReturnValueString(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushReturnValueFloat >---
// Pushes float argument fValue onto varlist sListName on oTarget
int PushReturnValueFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetReturnValueFloat >---
// Returns the float vector argument from varlist sListName on oTarget
float GetReturnValueFloat(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushReturnValueObject >---
// Pushes object argument oValue onto varlist sListName on oTarget
int PushReturnValueObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetReturnValueObject >---
// Returns the first object argument from varlist sListName on oTarget
object GetReturnValueObject(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushReturnValueLocation >---
// Pushes location argument lValue onto varlist sListName on oTarget
int PushReturnValueLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetReturnValueLocation >---
// Returns the first location argument from varlist sListName on oTarget
location GetReturnValueLocation(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushReturnValueVector >---
// Pushes vector argument vValue onto varlist sListName on oTarget
int PushReturnValueVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetReturnValueVector >---
// Returns the first vector argument from varlist sListName on oTarget
vector GetReturnValueVector(string sListName = "", object oTarget = OBJECT_INVALID);

// ---< ClearReturnValues >---
// Clears all values from all varlists sListName on oTarget
void ClearReturnValues(string sListName = "", object oTarget = OBJECT_INVALID);

// Clears all argument stacks and return values for all varlists sListName on oTarget
void ClearRegisters(string sListName = "", object oTarget = OBJECT_INVALID);

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

string _GetStackListName(string sListName)
{
    if (sListName == "")
        return ARGS_DEFAULT_STACK;
    else
        return sListName;
}

string _GetReturnListName(string sListName)
{
    if (sListName == "")
        return ARGS_DEFAULT_RETURN;
    else 
        return sListName;
}

object _GetTargetObject(object oTarget)
{
    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        return GetModule();
    else 
        return oTarget;
}

int PushArgumentInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    sListName = _GetStackListName(sListName);
    oTarget = _GetTargetObject(oTarget);

    AddListInt(oTarget, nValue, sListName, FALSE);
    return CountIntList(oTarget, sListName);
}

int GetArgumentInt(string sListName = "", object oTarget = OBJECT_INVALID)
{
    sListName = _GetStackListName(sListName);
    oTarget = _GetTargetObject(oTarget);

    int nResult = GetListInt(oTarget, 0, sListName);
    DeleteListInt(oTarget, 0, sListName, TRUE);

    return nResult;
}

int PopArgumentInt(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;
    
    return 0;
}

int PushArgumentString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListString(oTarget, sValue, sListName, FALSE);
    return CountStringList(oTarget, sListName);
}

string GetArgumentString(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    string sResult = GetListString(oTarget, 0, sListName);
    DeleteListString(oTarget, 0, sListName, TRUE);

    return sResult;
}

int PushArgumentFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListFloat(oTarget, fValue, sListName, FALSE);
    return CountFloatList(oTarget, sListName);
}

float GetArgumentFloat(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    float fResult = GetListFloat(oTarget, 0, sListName);
    DeleteListFloat(oTarget, 0, sListName, TRUE);

    return fResult;
}

int PushArgumentObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListObject(oTarget, oValue, sListName, FALSE);
    return CountObjectList(oTarget, sListName);
}

object GetArgumentObject(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    object oResult = GetListObject(oTarget, 0, sListName);
    DeleteListObject(oTarget, 0, sListName, TRUE);

    return oResult;
}

int PushArgumentLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListLocation(oTarget, lValue, sListName, FALSE);
    return CountLocationList(oTarget, sListName);
}

location GetArgumentLocation(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    location lResult = GetListLocation(oTarget, 0, sListName);
    DeleteListLocation(oTarget, 0, sListName, TRUE);

    return lResult;
}

int PushArgumentVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListVector(oTarget, vValue, sListName, FALSE);
    return CountVectorList(oTarget, sListName);
}

vector GetArgumentVector(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    vector vResult = GetListVector(oTarget, 0, sListName);
    DeleteListVector(oTarget, 0, sListName, TRUE);

    return vResult;
}

void ClearArgumentStacks(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    DeleteIntList(oTarget, sListName);
    DeleteStringList(oTarget, sListName);
    DeleteFloatList(oTarget, sListName);
    DeleteObjectList(oTarget, sListName);
    DeleteLocationList(oTarget, sListName);
    DeleteVectorList(oTarget, sListName);
}

int PushReturnValueInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListInt(oTarget, nValue, sListName, FALSE);
    return CountIntList(oTarget, sListName);
}

int GetReturnValueInt(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    int nResult = GetListInt(oTarget, 0, sListName);
    DeleteListInt(oTarget, 0, sListName, TRUE);

    return nResult;
}

int PushReturnValueString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListString(oTarget, sValue, sListName, FALSE);
    return CountStringList(oTarget, sListName);
}

string GetReturnValueString(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    string sResult = GetListString(oTarget, 0, sListName);
    DeleteListString(oTarget, 0, sListName, TRUE);

    return sResult;
}

int PushReturnValueFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListFloat(oTarget, fValue, sListName, FALSE);
    return CountFloatList(oTarget, sListName);
}

float GetReturnValueFloat(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    float fResult = GetListFloat(oTarget, 0, sListName);
    DeleteListFloat(oTarget, 0, sListName, TRUE);

    return fResult;
}

int PushReturnValueObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListObject(oTarget, oValue, sListName, FALSE);
    return CountObjectList(oTarget, sListName);
}

object GetReturnValueObject(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    object oResult = GetListObject(oTarget, 0, sListName);
    DeleteListObject(oTarget, 0, sListName, TRUE);

    return oResult;
}

int PushReturnValueLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListLocation(oTarget, lValue, sListName, FALSE);
    return CountLocationList(oTarget, sListName);
}

location GetReturnValueLocation(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    location lResult = GetListLocation(oTarget, 0, sListName);
    DeleteListLocation(oTarget, 0, sListName, TRUE);

    return lResult;
}

int PushReturnValueVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListVector(oTarget, vValue, sListName, FALSE);
    return CountVectorList(oTarget, sListName);
}

vector GetReturnValueVector(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    vector vResult = GetListVector(oTarget, 0, sListName);
    DeleteListVector(oTarget, 0, sListName, TRUE);

    return vResult;
}

void ClearReturnValues(string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_RETURN;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    DeleteIntList(oTarget, sListName);
    DeleteStringList(oTarget, sListName);
    DeleteFloatList(oTarget, sListName);
    DeleteObjectList(oTarget, sListName);
    DeleteLocationList(oTarget, sListName);
    DeleteVectorList(oTarget, sListName);
}

void ClearRegisters(string sListName = "", object oTarget = OBJECT_INVALID)
{
    ClearArgumentStacks(sListName, oTarget);
    ClearReturnValues(sListName, oTarget);
}
