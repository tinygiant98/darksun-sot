// -----------------------------------------------------------------------------
//    File: util_i_data.nss
//  System: PW Administration (identity and data management)
// -----------------------------------------------------------------------------
// Description:
//  Include for primary data control functions.
// -----------------------------------------------------------------------------
// Builder Use:
//  This include should be "included" in just about every script in the system.
// -----------------------------------------------------------------------------

#include "core_i_constants"
#include "util_i_debug" 
#include "util_i_csvlists" 

// Module-wide replcement object for variables meant to be put on GetModule()
const string PLAYER_DATAPOINT = "util_playerdata";
const string MODULE_DATAPOINT = "MODULE_DATAPOINT";
object       MODULE           = GetDatapoint(MODULE_DATAPOINT);
object       oModule          = GetModule();

const string PLAYER_DATAPOINT_NOT_CREATED = "Player datapoint could not be created.";
const string PLAYER_DATAPOINT_CREATED = "Player datapoint sucessfully created.";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< Identity >---

// ---< _GetIsDM >---
// A module-level function intended to replace the game's GetIsDM() function.
//  Checks for GetIsDM and GetIsDMPossessed.
int _GetIsDM(object oPC);

// ---< _GetIsPC >---
// A module-level function intended to repalce the game's IsPC() function.
//  Checks to see if oPC is a player character that is not DM-controlled.
int _GetIsPC(object oPC);

// ---< _GetIsPartyMember >---
// A module-level function intended to determine if oPC is a member of
//  oKnownPartyMember's party/faction.
int _GetIsPartyMember(object oPC, object oKnownPartyMember);

// ---< Variable Management >---

// ---< [_Get|_Set|_Delete]Local[Int|Float|String|Object|Location|Vector] >---
// Custom module-level functions intended to replace Bioware's variable handling
//  functions.  oObject will be checked for specific conditions, such as
//  == GetModule() or GetIsPC() to route the variable to the correct location
//  and ensure we're always loading the variable to the correct location.
// nFlag will modify the routing.  
// sData is not currently planned for use but is in place for future expansion.
// _SetLocal* will return TRUE/FALSE based on whether the operation was completed.
//  This is in place solely for future expansion to denote an error condition.
//  Although a value is currently returned, it has no meaning WRT an error condition.
int      _GetLocalInt        (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
float    _GetLocalFloat      (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
string   _GetLocalString     (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
object   _GetLocalObject     (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
location _GetLocalLocation   (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
vector   _GetLocalVector     (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");

int      _SetLocalInt        (object oObject, string sVarName, int      nValue, int nFlag = 0x0000, string sData = "");
int      _SetLocalFloat      (object oObject, string sVarName, float    fValue, int nFlag = 0x0000, string sData = "");
int      _SetLocalString     (object oObject, string sVarName, string   sValue, int nFlag = 0x0000, string sData = "");
int      _SetLocalObject     (object oObject, string sVarName, object   oValue, int nFlag = 0x0000, string sData = "");
int      _SetLocalLocation   (object oObject, string sVarName, location lValue, int nFlag = 0x0000, string sData = "");
int      _SetLocalVector     (object oObject, string sVarName, vector   vValue, int nFlag = 0x0000, string sData = "");

void     _DeleteLocalInt     (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
void     _DeleteLocalFloat   (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
void     _DeleteLocalString  (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
void     _DeleteLocalObject  (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
void     _DeleteLocalLocation(object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");
void     _DeleteLocalVector  (object oObject, string sVarName,                  int nFlag = 0x0000, string sData = "");

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

string __LocationToString(location lLocation)
{
    object oArea        = GetAreaFromLocation(lLocation);
    vector vPosition    = GetPositionFromLocation(lLocation);
    float  fOrientation = GetFacingFromLocation(lLocation);
    return "#AREA#"        + GetTag(oArea) +
           "#POSITION_X#"  + FloatToString(vPosition.x)  +
           "#POSITION_Y#"  + FloatToString(vPosition.y)  +
           "#POSITION_Z#"  + FloatToString(vPosition.z)  +
           "#ORIENTATION#" + FloatToString(fOrientation) + "#END#";
}

// ---< Identity >---

int _GetIsDM(object oPC)
{
    return _GetLocalInt(oPC, IS_DM) || (GetIsDM(oPC) || GetIsDMPossessed(oPC));
}

int _GetIsPC(object oPC)
{
    return _GetLocalInt(oPC, IS_PC) || (GetIsPC(oPC) && !_GetIsDM(oPC));
}

int _GetIsPartyMember(object oPC, object oKnownPartyMember)
{
    object oPartyMember = GetFirstFactionMember(oKnownPartyMember);

    while (GetIsObjectValid(oPartyMember))
    {
        if (oPartyMember == oPC)
            return TRUE;

        oPartyMember = GetNextFactionMember(oKnownPartyMember);
    }

    return FALSE;
}

// ---< Variable Management >---
object DetermineObject(object oObject)
{
    if (oObject == oModule || oObject == OBJECT_INVALID)
        return MODULE;

    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return oData;
    }

    return oObject;
}

void CreatePlayerDatapoint(object oPC)
{
    if (!GetIsObjectValid(oPC))
        return;

    object oPlayerDataItem =  GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (!GetIsObjectValid(oPlayerDataItem))
    {
        oPlayerDataItem = CreateItemOnObject(PLAYER_DATAPOINT, oPC);
        if (!GetIsObjectValid(oPlayerDataItem))
        {
            SendMessageToPC(oPC, PLAYER_DATAPOINT_NOT_CREATED);
            return;
        }
        
        SendMessageToPC(oPC, PLAYER_DATAPOINT_CREATED);
    }
}

// These copy functions are temporary functions that serve to transition saved variables
//  from the PC object to the player data item.  This allows systems that did not previously
//  use HCR2 functions for module management to transition to storing variables on the
//  player data item.  Limitation:  if a module did use HCR2, will have to add functionality
//  to transition from h2_playerdata to util_playerdata.
void _ReportDataMovement(object oObject, string sVarName)
{
    Debug("Moving data from PC Object to Player Data Item." +
        "\n   oObject  --> " + GetName(oObject) + 
        "\n   sVarName --> " + sVarName); 
}

void _CopyInt(object oObject, string sVarName)
{
    int n = GetLocalInt(oObject, sVarName);
    if (n)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalInt(oData, sVarName, n);
            DeleteLocalInt(oObject, sVarName);
            _ReportDataMovement(oObject, sVarName);
        }        
    }
}  

void _CopyFloat(object oObject, string sVarName)
{
    float f = GetLocalFloat(oObject, sVarName);
    if (f != 0.0)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalFloat(oData, sVarName, f);
            DeleteLocalFloat(oObject, sVarName);
            _ReportDataMovement(oObject, sVarName);
        }
    }
}

void _CopyString(object oObject, string sVarName)
{
    string s = GetLocalString(oObject, sVarName);
    if (s != "")
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalString(oData, sVarName, s);
            DeleteLocalString(oObject, sVarName);
            _ReportDataMovement(oObject, sVarName);
        }
    }
}

void _CopyObject(object oObject, string sVarName)
{
    object o = GetLocalObject(oObject, sVarName);
    if (GetIsObjectValid(o))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalObject(oData, sVarName, o);
            DeleteLocalObject(oObject, sVarName);
            _ReportDataMovement(oObject, sVarName);
        }
    }
}

void _CopyLocation(object oObject, string sVarName)
{
    location l = GetLocalLocation(oObject, sVarName);

    //TODO this may not work in EE with all the destroy area crap
    if (GetIsObjectValid(GetAreaFromLocation(l)))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalLocation(oData, sVarName, l);
            DeleteLocalLocation(oObject, sVarName);
            _ReportDataMovement(oObject, sVarName);
        }
    }
}

void _CopyVector(object oObject, string sVarName)
{
    location l = GetLocalLocation(oObject, sVarName);
    if (GetPositionFromLocation(l) != Vector())
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalLocation(oData, sVarName, l);
            DeleteLocalLocation(oObject, sVarName);
            _ReportDataMovement(oObject, sVarName);
        }
    }
}

// ---< _Get* Variable Procedures >---

int _GetLocalInt(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{
    if (GetIsPC(oObject))
        _CopyInt(oObject, sVarName);

    oObject = DetermineObject(oObject);
    return GetLocalInt(oObject, sVarName);
}

float _GetLocalFloat(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{
    if (GetIsPC(oObject))
        _CopyFloat(oObject, sVarName);

    oObject = DetermineObject(oObject);
    return GetLocalFloat(oObject, sVarName);
}

string _GetLocalString(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{
    if (GetIsPC(oObject))
        _CopyString(oObject, sVarName);

    oObject = DetermineObject(oObject);
    return GetLocalString(oObject, sVarName);
}

object _GetLocalObject(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{
    if (GetIsPC(oObject))
        _CopyObject(oObject, sVarName);

    oObject = DetermineObject(oObject);
    return GetLocalObject(oObject, sVarName);
}

location _GetLocalLocation(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{
    if (GetIsPC(oObject))
        _CopyLocation(oObject, sVarName);

    oObject = DetermineObject(oObject);
    return GetLocalLocation(oObject, sVarName);
}

vector _GetLocalVector(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{
    sVarName = "V_" + sVarName;
    if (GetIsPC(oObject))
        _CopyVector(oObject, sVarName);
    
    oObject = DetermineObject(oObject);
    return GetPositionFromLocation(_GetLocalLocation(oObject, sVarName));
}

// ---< _Set* Variable Procedures >---

int _SetLocalInt(object oObject, string sVarName, int nValue, int nFlag = 0x0000, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalInt(oObject, sVarName, nValue);
    return TRUE;
}

int _SetLocalFloat(object oObject, string sVarName, float fValue, int nFlag = 0x0000, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalFloat(oObject, sVarName, fValue);
    return TRUE;
}

int _SetLocalString(object oObject, string sVarName, string sValue, int nFlag = 0x0000, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalString(oObject, sVarName, sValue);
    return TRUE;
}

int _SetLocalObject(object oObject, string sVarName, object oValue, int nFlag = 0x0000, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalObject(oObject, sVarName, oValue);
    return TRUE;
}

int _SetLocalLocation(object oObject, string sVarName, location lValue, int nFlag = 0x0000, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalLocation(oObject, sVarName, lValue);
    return TRUE;
}

int _SetLocalVector(object oObject, string sVarName, vector vValue, int nFlag = 0x0000, string sData = "")
{
    location l = Location(OBJECT_INVALID, vValue, 0.0f);
        
    oObject = DetermineObject(oObject);
    sVarName = "V_" + sVarName;
    _SetLocalLocation(oObject, sVarName, l);
    return TRUE;
}

// ---< _Delete* Variable Procedures >---

void _DeleteLocalInt(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalInt(oObject, sVarName);
}

void _DeleteLocalFloat(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalFloat(oObject, sVarName);
}

void _DeleteLocalString(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalString(oObject, sVarName);
}

void _DeleteLocalObject(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalObject(oObject, sVarName);
}

void _DeleteLocalLocation(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalLocation(oObject, sVarName);
}

void _DeleteLocalVector(object oObject, string sVarName, int nFlag = 0x0000, string sData = "")
{
    oObject = DetermineObject(oObject);
    sVarName = "V_" + sVarName;
    _DeleteLocalLocation(oObject, sVarName);
}
