
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

#include "util_i_varlists"

const string ARGS_DEFAULT_STACK = "ARGS_DEFAULT_STACK";
const string ARGS_DEFAULT_RETURN = "ARGS_DEFAULT_RETURN";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< PushArgumentInt >---
// Pushes int argument nValue onto varlist sListName on oTarget
int PushArgumentInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentInt >---
// Returns the first int argument from varlist sListName on oTarget.
// Paramaters bDelete and nIndex are for internal use and should not be manually
// entered.  See CopyArgumentInt().
int GetArgumentInt(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0);

// ---< CopyArgumentInt >---
// Returns the int argument at index nIndex from varlist sListName on oTarget.  Does
// not delete the argument from the stack.  ClearArgumentStacks() must be called
// after using all CopyArgument* functions to ensure the stacks are cleared.
int CopyArgumentInt(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentString >---
// Pushes string argument sValue onto varlist sListName on oTarget
int PushArgumentString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentString >---
// Returns the first string argument from varlist sListName on oTarget.
// Paramaters bDelete and nIndex are for internal use and should not be manually
// entered.  See CopyArgumentString().
string GetArgumentString(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0);

// ---< CopyArgumentString >---
// Returns the string argument at index nIndex from varlist sListName on oTarget.  Does
// not delete the argument from the stack.  ClearArgumentStacks() must be called
// after using all CopyArgument* functions to ensure the stacks are cleared.
string CopyArgumentString(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentFloat >---
// Pushes float argument fValue onto varlist sListName on oTarget
int PushArgumentFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentFloat >---
// Returns the first float argument from varlist sListName on oTarget.
// Paramaters bDelete and nIndex are for internal use and should not be manually
// entered.  See CopyArgumentFloat().
float GetArgumentFloat(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0);

// ---< CopyArgumentFloat >---
// Returns the float argument at index nIndex from varlist sListName on oTarget.  Does
// not delete the argument from the stack.  ClearArgumentStacks() must be called
// after using all CopyArgument* functions to ensure the stacks are cleared.
float CopyArgumentFloat(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentObject >---
// Pushes object argument oValue onto varlist sListName on oTarget
int PushArgumentObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentObject >---
// Returns the first object argument from varlist sListName on oTarget.
// Paramaters bDelete and nIndex are for internal use and should not be manually
// entered.  See CopyArgumentObject().
object GetArgumentObject(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0);

// ---< CopyArgumentObject >---
// Returns the object argument at index nIndex from varlist sListName on oTarget.  Does
// not delete the argument from the stack.  ClearArgumentStacks() must be called
// after using all CopyArgument* functions to ensure the stacks are cleared.
object CopyArgumentObject(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentLocation >---
// Pushes location argument lValue onto varlist sListName on oTarget
int PushArgumentLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentLocation >---
// Returns the first location argument from varlist sListName on oTarget.
// Paramaters bDelete and nIndex are for internal use and should not be manually
// entered.  See CopyArgumentLocation().
location GetArgumentLocation(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0);

// ---< CopyArgumentLocation >---
// Returns the location argument at index nIndex from varlist sListName on oTarget.  Does
// not delete the argument from the stack.  ClearArgumentStacks() must be called
// after using all CopyArgument* functions to ensure the stacks are cleared.
location CopyArgumentLocation(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< PushArgumentVector >---
// Pushes vector argument vValue onto varlist sListName on oTarget
int PushArgumentVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID);

// ---< GetArgumentVector >---
// Returns the first vector argument from varlist sListName on oTarget.
// Paramaters bDelete and nIndex are for internal use and should not be manually
// entered.  See CopyArgumentVector().
vector GetArgumentVector(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0);

// ---< CopyArgumentVector >---
// Returns the vector argument at index nIndex from varlist sListName on oTarget.  Does
// not delete the argument from the stack.  ClearArgumentStacks() must be called
// after using all CopyArgument* functions to ensure the stacks are cleared.
vector CopyArgumentVector(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID);

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

int PushArgumentInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    AddListInt(oTarget, nValue, sListName, FALSE);
    return CountIntList(oTarget, sListName);
}

int GetArgumentInt(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    int nResult = GetListInt(oTarget, nIndex, sListName);
    
    if (bDelete)
        DeleteListInt(oTarget, nIndex, sListName, TRUE);

    return nResult;
}

int CopyArgumentInt(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetArgumentInt(sListName, oTarget, FALSE, nIndex);
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

string GetArgumentString(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    string sResult = GetListString(oTarget, nIndex, sListName);

    if (bDelete)
        DeleteListString(oTarget, nIndex, sListName, TRUE);

    return sResult;
}

string CopyArgumentString(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetArgumentString(sListName, oTarget, FALSE, nIndex);
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

float GetArgumentFloat(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    float fResult = GetListFloat(oTarget, nIndex, sListName);

    if (bDelete)
        DeleteListFloat(oTarget, nIndex, sListName, TRUE);

    return fResult;
}

float CopyArgumentFloat(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetArgumentFloat(sListName, oTarget, FALSE, nIndex);
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

object GetArgumentObject(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    object oResult = GetListObject(oTarget, nIndex, sListName);

    if (bDelete)
        DeleteListObject(oTarget, nIndex, sListName, TRUE);

    return oResult;
}

object CopyArgumentObject(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetArgumentObject(sListName, oTarget, FALSE, nIndex);
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

location GetArgumentLocation(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    location lResult = GetListLocation(oTarget, nIndex, sListName);

    if (bDelete)
        DeleteListLocation(oTarget, nIndex, sListName, TRUE);

    return lResult;
}

location CopyArgumentLocation(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetArgumentLocation(sListName, oTarget, FALSE, nIndex);
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

vector GetArgumentVector(string sListName = "", object oTarget = OBJECT_INVALID, int bDelete = TRUE, int nIndex = 0)
{
    if (sListName == "")
        sListName = ARGS_DEFAULT_STACK;

    if (oTarget == OBJECT_INVALID || GetIsObjectValid(oTarget) == FALSE)
        oTarget = GetModule();

    vector vResult = GetListVector(oTarget, nIndex, sListName);

    if (bDelete)
        DeleteListVector(oTarget, nIndex, sListName, TRUE);

    return vResult;
}

vector CopyArgumentVector(int nIndex = 0, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetArgumentVector(sListName, oTarget, FALSE, nIndex);
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
