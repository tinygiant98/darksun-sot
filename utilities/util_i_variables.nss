// -----------------------------------------------------------------------------
//    File: util_i_data.nss
//  System: PW Administration (data management)
// -----------------------------------------------------------------------------
// Description:
//  Include for primary data control functions.
// -----------------------------------------------------------------------------
// Builder Use:
//  This include should be "included" in just about every script in the system.
// -----------------------------------------------------------------------------

// [Get|Set|Delete]Player* functions are designed to store player object-specific
// variables.  By default, these variables will be stored in the player object's
// organic sqlite database, which is saved into the character's .bic file.
// If player variables are to be stored temporarily instead of persistently, they
// will be stored on the player object.

// [Get|Set|Delete]Module* functions are designed to store module object-specific
// variables.  If these variable are configured to be stored persistently, they
// will be saved to the campaign database.  If temporary, they will be saved to
// the module object's organic sqlite database.

// [Get|Set|Delete]Persistent* functions are designed to persistently store variable
// data assigned to any game object.  These functions will always store the
// passed variable to the campaign database using organic sqlite functionality.

// -----------------------------------------------------------------------------
//                                  Constants
// -----------------------------------------------------------------------------

// Variables types; used to reduce the number of required functions as well
// as store the variable type in variable data tables.
const int VARIABLE_TYPE_ALL          = 0;
const int VARIABLE_TYPE_INT          = 1;
const int VARIABLE_TYPE_FLOAT        = 2;
const int VARIABLE_TYPE_STRING       = 4;
const int VARIABLE_TYPE_OBJECT       = 8;
const int VARIABLE_TYPE_VECTOR       = 16;
const int VARIABLE_TYPE_LOCATION     = 32;

// Query mode; used when preparing queries to reduce the number of
// required functions.
const int VARIABLE_MODE_GET          = 1;
const int VARIABLE_MODE_SET          = 2;
const int VARIABLE_MODE_DELETE       = 3;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< [Get|Set|Delete]Player[Int|Float|String|Object|Location|Vector] >---
// These functions will force variables to be saved to the player's internal
// sqlite database.  If oObject is not a PC object, these methods will fail.
int      GetPlayerInt        (object oObject, string sVarName);
float    GetPlayerFloat      (object oObject, string sVarName);
string   GetPlayerString     (object oObject, string sVarName);
object   GetPlayerObject     (object oObject, string sVarName);
location GetPlayerLocation   (object oObject, string sVarName);
vector   GetPlayerVector     (object oObject, string sVarName);

void     SetPlayerInt        (object oObject, string sVarName, int      nValue);
void     SetPlayerFloat      (object oObject, string sVarName, float    fValue);
void     SetPlayerString     (object oObject, string sVarName, string   sValue);
void     SetPlayerObject     (object oObject, string sVarName, object   oValue);
void     SetPlayerLocation   (object oObject, string sVarName, location lValue);
void     SetPlayerVector     (object oObject, string sVarName, vector   vValue);

void     DeletePlayerInt     (object oObject, string sVarName);
void     DeletePlayerFloat   (object oObject, string sVarName);
void     DeletePlayerString  (object oObject, string sVarName);
void     DeletePlayerObject  (object oObject, string sVarName);
void     DeletePlayerLocation(object oObject, string sVarName);
void     DeletePlayerVector  (object oObject, string sVarName);

// ---< [Get|Set|Delete]Module[Int|Float|String|Object|Location|Vector] >---
// These functions will force variables to be saved to the module's internal
// sqlite database.
int      GetModuleInt        (object oObject, string sVarName);
float    GetModuleFloat      (object oObject, string sVarName);
string   GetModuleString     (object oObject, string sVarName);
object   GetModuleObject     (object oObject, string sVarName);
location GetModuleLocation   (object oObject, string sVarName);
vector   GetModuleVector     (object oObject, string sVarName);

void     SetModuleInt        (object oObject, string sVarName, int      nValue);
void     SetModuleFloat      (object oObject, string sVarName, float    fValue);
void     SetModuleString     (object oObject, string sVarName, string   sValue);
void     SetModuleObject     (object oObject, string sVarName, object   oValue);
void     SetModuleLocation   (object oObject, string sVarName, location lValue);
void     SetModuleVector     (object oObject, string sVarName, vector   vValue);

void     DeleteModuleInt     (object oObject, string sVarName);
void     DeleteModuleFloat   (object oObject, string sVarName);
void     DeleteModuleString  (object oObject, string sVarName);
void     DeleteModuleObject  (object oObject, string sVarName);
void     DeleteModuleLocation(object oObject, string sVarName);
void     DeleteModuleVector  (object oObject, string sVarName);

// ---< [Get|Set|Delete]Persistent[Int|Float|String|Object|Location|Vector] >---
// These functions will force variables to be saved to the module's external
// campaign sqlite database.  They are essentially duplicates of the *Module*
// functions above, but force variables to the campaign database.
int      GetPersistentInt        (object oObject, string sVarName);
float    GetPersistentFloat      (object oObject, string sVarName);
string   GetPersistentString     (object oObject, string sVarName);
object   GetPersistentObject     (object oObject, string sVarName);
location GetPersistentLocation   (object oObject, string sVarName);
vector   GetPersistentVector     (object oObject, string sVarName);

void     SetPersistentInt        (object oObject, string sVarName, int      nValue);
void     SetPersistentFloat      (object oObject, string sVarName, float    fValue);
void     SetPersistentString     (object oObject, string sVarName, string   sValue);
void     SetPersistentObject     (object oObject, string sVarName, object   oValue);
void     SetPersistentLocation   (object oObject, string sVarName, location lValue);
void     SetPersistentVector     (object oObject, string sVarName, vector   vValue);

void     DeletePersistentInt     (object oObject, string sVarName);
void     DeletePersistentFloat   (object oObject, string sVarName);
void     DeletePersistentString  (object oObject, string sVarName);
void     DeletePersistentObject  (object oObject, string sVarName);
void     DeletePersistentLocation(object oObject, string sVarName);
void     DeletePersistentVector  (object oObject, string sVarName);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

string __LocationToString(location l)
{
    //string sAreaId = ObjectToString(GetAreaFromLocation(l)));
    string sAreaId = GetTag(GetAreaFromLocation(l));
    vector vPosition = GetPositionFromLocation(l);
    float fFacing = GetFacingFromLocation(l);

    return "#A#" + sAreaId +
           "#X#" + FloatToString(vPosition.x, 0, 5) +
           "#Y#" + FloatToString(vPosition.y, 0, 5) +
           "#Z#" + FloatToString(vPosition.z, 0, 5) +
           "#F#" + FloatToString(fFacing, 0, 5) + "#";
}

location __StringToLocation(string sLocation)
{
    location l;
    int nLength = GetStringLength(sLocation);

    if (nLength > 0)
    {
        int nPos, nCount;

        nPos = FindSubString(sLocation, "#A#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        object oArea = StringToObject(GetSubString(sLocation, nPos, nCount));

        nPos = FindSubString(sLocation, "#X#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fX = StringToFloat(GetSubString(sLocation, nPos, nCount));

        nPos = FindSubString(sLocation, "#Y#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fY = StringToFloat(GetSubString(sLocation, nPos, nCount));

        nPos = FindSubString(sLocation, "#Z#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fZ = StringToFloat(GetSubString(sLocation, nPos, nCount));

        vector vPosition = Vector(fX, fY, fZ);

        nPos = FindSubString(sLocation, "#F#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fOrientation = StringToFloat(GetSubString(sLocation, nPos, nCount));

        if (GetIsObjectValid(oArea))
            l = Location(oArea, vPosition, fOrientation);
        else
            l = GetStartingLocation();
    }

    return l;
}

// Should be called from OnModuleLoad and OnClientEnter
void CreateVariablesTable(object oObject)
{
    int bPC = GetIsPC(oObject);
    string sTable = (bPC ? "player_variables" : "module_variables");

    string query = "CREATE TABLE IF NOT EXISTS " + sTable + " (" +
        (bPC ? "" : "object TEXT, ") +
        "type INTEGER, " +
        "varname TEXT, " +
        "value TEXT, " +
        "timestamp INTEGER, " +
        "PRIMARY KEY(" + (bPC ? "" : "object, ") + "type, varname));";

    sqlquery sql = SqlPrepareQueryObject((bPC ? oObject : GetModule()), query);
    SqlStep(sql);
}

sqlquery PrepareQuery(object oObject, string sVarName, int nVarType, int nMode, int bForceCampaign = FALSE)
{
    int bPC = GetIsPC(oObject);    
    string query, sTable = (bPC ? "player_variables" : "module_variables");
    sqlquery sql;

    switch (nMode)
    {
        case VARIABLE_MODE_GET:
            query = "SELECT value FROM " + sTable + " " +
                "WHERE " + (bPC ? "" : "object = @object AND ") + "type = @type AND varname = @varname;";
            break;
        case VARIABLE_MODE_SET:
            query = "INSERT INTO " + sTable + " " +
                "(" + (bPC ? "" : "object, ") + "type, varname, value, timestamp) " +
                "VALUES (" + (bPC ? "" : "@object, ") + "@type, @varname, @value, strftime('%s','now')) " +
                "ON CONFLICT (" + (bPC ? "" : "object, ") + "type, varname) DO UPDATE SET value = @value, timestamp = strftime('%s','now');";
            break;
        case VARIABLE_MODE_DELETE:
            query = "DELETE FROM " + sTable + " " +
                "WHERE " + (bPC ? "" : "object = @object AND ") + "type = @type AND varname = @varname;";
            break;
    }
    
    if (!bForceCampaign && (bPC || oObject == GetModule()))
        sql = SqlPrepareQueryObject((bPC ? oObject : GetModule()), query);
    else
        sql = SqlPrepareQueryCampaign("dssot_variables", query);

    SqlBindInt(sql, "@type", nVarType);
    SqlBindString(sql, "@varname", sVarName);
    
    if (!bPC)
        SqlBindString(sql, "@object", ObjectToString(oObject));

    return sql;
}

// Intervening functions, called by all sqlite-setting functions
void SetSQLiteInt(object oObject, string sVarName, int nValue, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_INT, VARIABLE_MODE_SET, bCampaign);
    SqlBindInt(sql, "@value", nValue);

    SqlStep(sql);
}

void SetSQLiteFloat(object oObject, string sVarName, float fValue, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_SET, bCampaign);
    SqlBindFloat(sql, "@value", fValue);

    SqlStep(sql);
}

// String, object, location
void SetSQLiteString(object oObject, string sVarName, string sValue, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, nType, VARIABLE_MODE_SET, bCampaign);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
}

void SetSQLiteVector(object oObject, string sVarName, vector vValue, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_SET, bCampaign);
    SqlBindVector(sql, "@value", vValue);

    SqlStep(sql);
}

// Intervening functions, called by all sqlite-setting functions
int GetSQLiteInt(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_INT, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

float GetSQLiteFloat(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetFloat(sql, 0) : 0.0;
}

// String, object, location
string GetSQLiteString(object oObject, string sVarName, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, nType, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

vector GetSQLiteVector(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetVector(sql, 0) : Vector();
}

// Intervening functions, called by all sqlite-setting functions
void DeleteSQLiteInt(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_INT, VARIABLE_MODE_DELETE, bCampaign);
    SqlStep(sql);
}

void DeleteSQLiteFloat(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_DELETE, bCampaign);
    SqlStep(sql);
}

// String, object, location
void DeleteSQLiteString(object oObject, string sVarName, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, nType, VARIABLE_MODE_DELETE, bCampaign);
    SqlStep(sql);
}

void DeleteSQLiteVector(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_DELETE, bCampaign);
    SqlStep(sql);
}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Player*
// -----------------------------------------------------------------------------
void SetPlayerInt(object oObject, string sVarName, int nValue)       {SetSQLiteInt   (oObject, sVarName, nValue);}
void SetPlayerString(object oObject, string sVarName, string sValue) {SetSQLiteString(oObject, sVarName, sValue);}
void SetPlayerFloat(object oObject, string sVarName, float fValue)   {SetSQLiteFloat (oObject, sVarName, fValue);}
void SetPlayerVector(object oObject, string sVarName, vector vValue) {SetSQLiteVector(oObject, sVarName, vValue);}

void SetPlayerObject(object oObject, string sVarName, object oValue)
{
    string sObject = ObjectToString(oValue);
    SetSQLiteString(oObject, sVarName, sObject, VARIABLE_TYPE_OBJECT);
}

void SetPlayerLocation(object oObject, string sVarName, location lValue)
{
    string sLocation = __LocationToString(lValue);
    SetSQLiteString(oObject, sVarName, sLocation, VARIABLE_TYPE_LOCATION);
}

int GetPlayerInt(object oObject, string sVarName)       {return GetSQLiteInt   (oObject, sVarName);}
float GetPlayerFloat(object oObject, string sVarName)   {return GetSQLiteFloat (oObject, sVarName);}
string GetPlayerString(object oObject, string sVarName) {return GetSQLiteString(oObject, sVarName);}
vector GetPlayerVector(object oObject, string sVarName) {return GetSQLiteVector(oObject, sVarName);}

object GetPlayerObject(object oObject, string sVarName)
{
    string sObject = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);
    return StringToObject(sObject);
}

location GetPlayerLocation(object oObject, string sVarName)
{
    string sLocation = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);
    return __StringToLocation(sLocation);
}

void DeletePlayerInt(object oObject, string sVarName)      {DeleteSQLiteInt   (oObject, sVarName);}
void DeletePlayerFloat(object oObject, string sVarName)    {DeleteSQLiteFloat (oObject, sVarName);}
void DeletePlayerString(object oObject, string sVarName)   {DeleteSQLiteString(oObject, sVarName);}
void DeletePlayerVector(object oObject, string sVarName)   {DeleteSQLiteVector(oObject, sVarName);}
void DeletePlayerObject(object oObject, string sVarName)   {DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);}
void DeletePlayerLocation(object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Module*
// -----------------------------------------------------------------------------
void SetModuleInt(object oObject, string sVarName, int nValue)       {SetSQLiteInt(GetModule(), sVarName, nValue);}
void SetModuleString(object oObject, string sVarName, string sValue) {SetSQLiteString(GetModule(), sVarName, sValue);}
void SetModuleFloat(object oObject, string sVarName, float fValue)   {SetSQLiteFloat(GetModule(), sVarName, fValue);}
void SetModuleVector(object oObject, string sVarName, vector vValue) {SetSQLiteVector(GetModule(), sVarName, vValue);}

void SetModuleObject(object oObject, string sVarName, object oValue)
{
    string sObject = ObjectToString(oValue);
    SetSQLiteString(GetModule(), sVarName, sObject, VARIABLE_TYPE_OBJECT);
}

void SetModuleLocation(object oObject, string sVarName, location lValue)
{
    string sLocation = __LocationToString(lValue);
    SetSQLiteString(GetModule(), sVarName, sLocation, VARIABLE_TYPE_LOCATION);
}

int GetModuleInt(object oObject, string sVarName)       {return GetSQLiteInt   (GetModule(), sVarName);}
float GetModuleFloat(object oObject, string sVarName)   {return GetSQLiteFloat (GetModule(), sVarName);}
string GetModuleString(object oObject, string sVarName) {return GetSQLiteString(GetModule(), sVarName);}
vector GetModuleVector(object oObject, string sVarName) {return GetSQLiteVector(GetModule(), sVarName);}

object GetModuleObject(object oObject, string sVarName)
{
    string sObject = GetSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_OBJECT);
    return StringToObject(sObject);
}

location GetModuleLocation(object oObject, string sVarName)
{
    string sLocation = GetSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_LOCATION);
    return __StringToLocation(sLocation);
}

void DeleteModuleInt(object oObject, string sVarName)      {DeleteSQLiteInt   (GetModule(), sVarName);}
void DeleteModuleFloat(object oObject, string sVarName)    {DeleteSQLiteFloat (GetModule(), sVarName);}
void DeleteModuleString(object oObject, string sVarName)   {DeleteSQLiteString(GetModule(), sVarName);}
void DeleteModuleVector(object oObject, string sVarName)   {DeleteSQLiteVector(GetModule(), sVarName);}
void DeleteModuleObject(object oObject, string sVarName)   {DeleteSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_OBJECT);}
void DeleteModuleLocation(object oObject, string sVarName) {DeleteSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_LOCATION);}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Persistent*
// -----------------------------------------------------------------------------
void SetPersistentInt     (object oObject, string sVarName, int nValue)    {SetSQLiteInt   (oObject, sVarName, nValue);}
void SetPersistentrString (object oObject, string sVarName, string sValue) {SetSQLiteString(oObject, sVarName, sValue);}
void SetPersistentFloat   (object oObject, string sVarName, float fValue)  {SetSQLiteFloat (oObject, sVarName, fValue);}
void SetPersistentVector  (object oObject, string sVarName, vector vValue) {SetSQLiteVector(oObject, sVarName, vValue);}

void SetPersistentObject  (object oObject, string sVarName, object oValue) 
{
    string sObject = ObjectToString(oValue);
    SetSQLiteString(oObject, sVarName, sObject, VARIABLE_TYPE_OBJECT);
}

void SetPersistentLocation(object oObject, string sVarName, location lValue)
{
    string sLocation = __LocationToString(lValue);
    SetSQLiteString(oObject, sVarName, sLocation, VARIABLE_TYPE_LOCATION);
}

int    GetPersistentInt       (object oObject, string sVarName) {return GetSQLiteInt   (oObject, sVarName);}
float  GetPersistentFloat     (object oObject, string sVarName) {return GetSQLiteFloat (oObject, sVarName);}
string GetPersistentString    (object oObject, string sVarName) {return GetSQLiteString(oObject, sVarName);}
vector GetPersistentVector    (object oObject, string sVarName) {return GetSQLiteVector(oObject, sVarName);}

object GetPersistentObject    (object oObject, string sVarName)
{
    string sObject = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);
    return StringToObject(sObject);
}

location GetPersistentLocation(object oObject, string sVarName)
{
    string sLocation = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);
    return __StringToLocation(sLocation);
}

void DeletePersistentInt     (object oObject, string sVarName) {DeleteSQLiteInt   (oObject, sVarName);}
void DeletePersistentFloat   (object oObject, string sVarName) {DeleteSQLiteFloat (oObject, sVarName);}
void DeletePersistentString  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName);}
void DeletePersistentVector  (object oObject, string sVarName) {DeleteSQLiteVector(oObject, sVarName);}
void DeletePersistentObject  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);}
void DeletePersistentLocation(object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);}
