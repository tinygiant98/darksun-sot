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

// [Get|Set|Delete]Module* functions are designed to store module object-specific
// variables.  These variables will be stored in the module's volatile sqlite
// database.  This database will be lost when the module shuts down.

// [Get|Set|Delete]Persistent* functions are designed to persistently store variable
// data assigned to any game object.  These functions will always store the
// passed variable to the campaign database using organic sqlite functionality.

// [Get|Set|Delete]Object* functions are designed to store object-specific
// variables.  These variables will be stored in the module's volatile sqlite
// database.  This database will be lost when the module shuts down.

// ***NOTE*** Variables should not be saved to persistent database tables if those
//  variables are associated with a game object which is not the module itself.
//  Game object ids may not be the same from session to session and variables
//  saved to persistent database tables may not be retrieved reliably in other
//  than the current session.  Game object-specific data should be saved to the
//  module's volatile database using *Object* functions.

// Delete[Player|Module|Persistent|Object]Variables{By}[Tag|Type] functions allow
// variables to be deleted in groups.  When setting a variable, an optional tag
// can be applied which could later be used to delete a group of variables.
// Additionally, variables groups can be deleted by type (integer, string, etc.)
// or by object.

// -----------------------------------------------------------------------------
//                                Configuration
// -----------------------------------------------------------------------------

// This volatile table will be created on the GetModule() object the first time
// a module variable is set.
const string VARIABLE_TABLE_MODULE      = "module_variables";

// This persitent table will be created on the PC object the first time a player
// variable is set.  This table will be stored in the player's .bic file.
const string VARIABLE_TABLE_PC          = "player_variables";

// A persistent table will be created in a campaign datase with the following
// name.  The table name will be VARIABLE_TABLE_MODULE above.
const string VARIABLE_CAMPAIGN_DATABASE = "campaign_variables";

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
const int VARIABLE_TYPE_JSON         = 64;

// Query mode; used when preparing queries to reduce the number of
// required functions.
const int VARIABLE_MODE_GET            = 1;
const int VARIABLE_MODE_SET            = 2;
const int VARIABLE_MODE_DELETE         = 3;
const int VARIABLE_MODE_DELETE_ALL     = 4;
const int VARIABLE_MODE_DELETE_BY_TAG  = 5;
const int VARIABLE_MODE_DELETE_BY_TYPE = 6;

// -----------------------------------------------------------------------------
//                              Private Functions
// -----------------------------------------------------------------------------

json _GetVectorObject(vector vPosition = [0.0, 0.0, 0.0])
{
    json jPosition = JsonObject();
         jPosition = JsonObjectSet(jPosition, "x", JsonFloat(vPosition.x));
         jPosition = JsonObjectSet(jPosition, "y", JsonFloat(vPosition.y));
    return           JsonObjectSet(jPosition, "z", JsonFloat(vPosition.z));
}

vector _GetObjectVector(json jPosition)
{
    float x = JsonGetFloat(JsonObjectGet(jPosition, "x"));
    float y = JsonGetFloat(JsonObjectGet(jPosition, "y"));
    float z = JsonGetFloat(JsonObjectGet(jPosition, "z"));

    return Vector(x, y, z);
}

json _GetLocationObject(location lLocation)
{
    json jLocation = JsonObject();
         jLocation = JsonObjectSet(jLocation, "area", JsonString(ObjectToString(GetAreaFromLocation(lLocation))));
         jLocation = JsonObjectSet(jLocation, "position", _GetVectorObject(GetPositionFromLocation(lLocation)));
    return           JsonObjectSet(jLocation, "facing", JsonFloat(GetFacingFromLocation(lLocation)));
}

location _GetObjectLocation(json jLocation)
{
    object oArea = StringToObject(JsonGetString(JsonObjectGet(jLocation, "area")));
    vector vPosition = _GetObjectVector(JsonObjectGet(jLocation, "position"));
    float fFacing = JsonGetFloat(JsonObjectGet(jLocation, "facing"));
    
    return Location(oArea, vPosition, fFacing);
}

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< [Get|Set|Delete]Player[Int|Float|String|Object|Location|Vector|Json] >---
// These functions will force variables to be saved to the player's internal
// sqlite database.  If oObject is not a PC object, these methods will fail.
int      GetPlayerInt        (object oObject, string sVarName);
float    GetPlayerFloat      (object oObject, string sVarName);
string   GetPlayerString     (object oObject, string sVarName);
object   GetPlayerObject     (object oObject, string sVarName);
location GetPlayerLocation   (object oObject, string sVarName);
vector   GetPlayerVector     (object oObject, string sVarName);
json     GetPlayerJson       (object oObject, string sVarName);

void     SetPlayerInt        (object oObject, string sVarName, int      nValue, string sTag = "");
void     SetPlayerFloat      (object oObject, string sVarName, float    fValue, string sTag = "");
void     SetPlayerString     (object oObject, string sVarName, string   sValue, string sTag = "");
void     SetPlayerObject     (object oObject, string sVarName, object   oValue, string sTag = "");
void     SetPlayerLocation   (object oObject, string sVarName, location lValue, string sTag = "");
void     SetPlayerVector     (object oObject, string sVarName, vector   vValue, string sTag = "");
void     SetPlayerJson       (object oObject, string sVarName, json     jValue, string sTag = "");

void     DeletePlayerInt     (object oObject, string sVarName);
void     DeletePlayerFloat   (object oObject, string sVarName);
void     DeletePlayerString  (object oObject, string sVarName);
void     DeletePlayerObject  (object oObject, string sVarName);
void     DeletePlayerLocation(object oObject, string sVarName);
void     DeletePlayerVector  (object oObject, string sVarName);
void     DeletePlayerJson    (object oObject, string sVarName);

// ---< [Get|Set|Delete]Module[Int|Float|String|Object|Location|Vector|Json] >---
// These functions will force variables to be saved to the module's internal
// sqlite database.  This database is volatile.
int      GetModuleInt        (string sVarName);
float    GetModuleFloat      (string sVarName);
string   GetModuleString     (string sVarName);
object   GetModuleObject     (string sVarName);
location GetModuleLocation   (string sVarName);
vector   GetModuleVector     (string sVarName);
json     GetModuleJson       (string sVarName);

void     SetModuleInt        (string sVarName, int      nValue, string sTag = "");
void     SetModuleFloat      (string sVarName, float    fValue, string sTag = "");
void     SetModuleString     (string sVarName, string   sValue, string sTag = "");
void     SetModuleObject     (string sVarName, object   oValue, string sTag = "");
void     SetModuleLocation   (string sVarName, location lValue, string sTag = "");
void     SetModuleVector     (string sVarName, vector   vValue, string sTag = "");
void     SetModuleJson       (string sVarName, json     jValue, string sTag = "");

void     DeleteModuleInt     (string sVarName);
void     DeleteModuleFloat   (string sVarName);
void     DeleteModuleString  (string sVarName);
void     DeleteModuleObject  (string sVarName);
void     DeleteModuleLocation(string sVarName);
void     DeleteModuleVector  (string sVarName);
void     DeleteModuleJson    (string sVarName);

// ---< [Get|Set|Delete]Persistent[Int|Float|String|Object|Location|Vector|Json] >---
// These functions will force variables to be saved to the module's external
// campaign sqlite database.  They are essentially duplicates of the *Module*
// functions above, but force variables to the campaign database.
int      GetPersistentInt        (object oObject, string sVarName);
float    GetPersistentFloat      (object oObject, string sVarName);
string   GetPersistentString     (object oObject, string sVarName);
object   GetPersistentObject     (object oObject, string sVarName);
location GetPersistentLocation   (object oObject, string sVarName);
vector   GetPersistentVector     (object oObject, string sVarName);
json     GetPersistentJson       (object oObject, string sVarName);

void     SetPersistentInt        (object oObject, string sVarName, int      nValue, string sTag = "");
void     SetPersistentFloat      (object oObject, string sVarName, float    fValue, string sTag = "");
void     SetPersistentString     (object oObject, string sVarName, string   sValue, string sTag = "");
void     SetPersistentObject     (object oObject, string sVarName, object   oValue, string sTag = "");
void     SetPersistentLocation   (object oObject, string sVarName, location lValue, string sTag = "");
void     SetPersistentVector     (object oObject, string sVarName, vector   vValue, string sTag = "");
void     SetPersistentJson       (object oObject, string sVarName, json     jValue, string sTag = "");

void     DeletePersistentInt     (object oObject, string sVarName);
void     DeletePersistentFloat   (object oObject, string sVarName);
void     DeletePersistentString  (object oObject, string sVarName);
void     DeletePersistentObject  (object oObject, string sVarName);
void     DeletePersistentLocation(object oObject, string sVarName);
void     DeletePersistentVector  (object oObject, string sVarName);
void     DeletePersistentJson    (object oObject, string sVarName);

// ---< [Get|Set|Delete]Object[Int|Float|String|Object|Location|Vector|Json] >---
// These functions will save variables to the module's volatile database.
// These variables will be identified by the object's ID.
int      GetObjectInt        (object oObject, string sVarName);
float    GetObjectFloat      (object oObject, string sVarName);
string   GetObjectString     (object oObject, string sVarName);
object   GetObjectObject     (object oObject, string sVarName);
location GetObjectLocation   (object oObject, string sVarName);
vector   GetObjectVector     (object oObject, string sVarName);
json     GetObjectJson       (object oObject, string sVarName);

void     SetObjectInt        (object oObject, string sVarName, int      nValue, string sTag = "");
void     SetObjectFloat      (object oObject, string sVarName, float    fValue, string sTag = "");
void     SetObjectString     (object oObject, string sVarName, string   sValue, string sTag = "");
void     SetObjectObject     (object oObject, string sVarName, object   oValue, string sTag = "");
void     SetObjectLocation   (object oObject, string sVarName, location lValue, string sTag = "");
void     SetObjectVector     (object oObject, string sVarName, vector   vValue, string sTag = "");
void     SetObjectJson       (object oObject, string sVarName, json     jValue, string sTag = "");

void     DeleteObjectInt     (object oObject, string sVarName);
void     DeleteObjectFloat   (object oObject, string sVarName);
void     DeleteObjectString  (object oObject, string sVarName);
void     DeleteObjectObject  (object oObject, string sVarName);
void     DeleteObjectLocation(object oObject, string sVarName);
void     DeleteObjectVector  (object oObject, string sVarName);
void     DeleteObjectJson    (object oObject, string sVarName);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void CreateVariablesTable(object oObject, int bCampaign = FALSE)
{
    int bPC = GetIsPC(oObject);
    string sTable = (bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE);

    string query = "CREATE TABLE IF NOT EXISTS " + sTable + " (" +
        (bPC ? "" : "object TEXT, ") +
        "type INTEGER, " +
        "varname TEXT, " +
        "value TEXT, " +
        "tag TEXT, " +
        "timestamp INTEGER, " +
        "PRIMARY KEY(" + (bPC ? "" : "object, ") + "type, varname));";

    sqlquery sql;
    if (!bCampaign && (bPC || oObject == GetModule()))
        sql = SqlPrepareQueryObject((bPC ? oObject : GetModule()), query);
    else
        sql = SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, query);
    
    SqlStep(sql);
}

sqlquery PrepareQuery(object oObject, string sVarName, int nVarType, int nMode, int bCampaign = FALSE)
{
    int bPC = GetIsPC(oObject);    
    string query, sTable = (bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE);
    sqlquery sql;

    if (!bCampaign)
    {
        object oTarget = (bPC ? oObject : GetModule());
        if (GetLocalInt(oTarget, "VARIABLES_INITIALIZED") == FALSE)
        {
            CreateVariablesTable(oTarget);
            SetLocalInt(oTarget, "VARIABLES_INITIALIZED", TRUE);
        }
    }
    else 
    {
        if (GetLocalInt(GetModule(), "CAMPAIGN_VARIABLES_INITIALIZED") == FALSE)
        {
            CreateVariablesTable(OBJECT_INVALID, TRUE);
            SetLocalInt(GetModule(), "CAMPAIGN_VARIABLES_INITIALIZED", TRUE);
        }
    }
    
    switch (nMode)
    {
        case VARIABLE_MODE_GET:
            query = "SELECT value FROM " + sTable + " " +
                "WHERE " + (bPC ? "" : "object = @object AND ") + "type = @type AND varname = @varname;";
            break;
        case VARIABLE_MODE_SET:
            query = "INSERT INTO " + sTable + " " +
                "(" + (bPC ? "" : "object, ") + "type, varname, value, tag, timestamp) " +
                "VALUES (" + (bPC ? "" : "@object, ") + "@type, @varname, @value, @tag, strftime('%s','now')) " +
                "ON CONFLICT (" + (bPC ? "" : "object, ") + "type, varname, tag) DO UPDATE SET value = @value, timestamp = strftime('%s','now');";
            break;
        case VARIABLE_MODE_DELETE:
            query = "DELETE FROM " + sTable + " " +
                "WHERE " + (bPC ? "" : "object = @object AND ") + "type = @type AND varname = @varname;";
            break;
        case VARIABLE_MODE_DELETE_ALL:
            query = "DELETE FROM " + sTable +
                (bPC ? "" : "WHERE object = @object") + ";";
            break;
        case VARIABLE_MODE_DELETE_BY_TAG:
            query = "DELETE FROM " + sTable + " " +
                "WHERE " + (bPC ? "" : "object = @object AND ") + "tag = @tag;";
            break;
        case VARIABLE_MODE_DELETE_BY_TYPE:
            query = "DELETE FROM " + sTable + " " +
                "WHERE " + (bPC ? "" : "object = @object AND ") + "type = @type;";
            break;
    }
    
    if (!bCampaign && (bPC || oObject == GetModule()))
        sql = SqlPrepareQueryObject((bPC ? oObject : GetModule()), query);
    else
        sql = SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, query);

    if (nMode != VARIABLE_MODE_DELETE_ALL && nMode != VARIABLE_MODE_DELETE_BY_TAG)
        SqlBindInt(sql, "@type", nVarType);

    if (nMode <= VARIABLE_MODE_DELETE)
        SqlBindString(sql, "@varname", sVarName);
    
    if (!bPC)
        SqlBindString(sql, "@object", ObjectToString(oObject));

    return sql;
}

void SetSQLiteInt(object oObject, string sVarName, int nValue, string sTag = "", int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_INT, VARIABLE_MODE_SET, bCampaign);
    SqlBindInt(sql, "@value", nValue);
    SqlBindString(sql, "@tag", sTag);

    SqlStep(sql);
}

void SetSQLiteFloat(object oObject, string sVarName, float fValue, string sTag = "", int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_SET, bCampaign);
    SqlBindFloat(sql, "@value", fValue);
    SqlBindString(sql, "@tag", sTag);

    SqlStep(sql);
}

void SetSQLiteString(object oObject, string sVarName, string sValue, string sTag = "", int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, nType, VARIABLE_MODE_SET, bCampaign);
    SqlBindString(sql, "@value", sValue);
    SqlBindString(sql, "@tag", sTag);

    SqlStep(sql);
}

void SetSQLiteVector(object oObject, string sVarName, vector vValue, string sTag = "", int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_SET, bCampaign);
    SqlBindVector(sql, "@value", vValue);
    SqlBindString(sql, "@tag", sTag);

    SqlStep(sql);
}

void SetSQLiteJson(object oObject, string sVarName, json jValue, string sTag = "", int nType = VARIABLE_TYPE_JSON, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_JSON, VARIABLE_MODE_SET, bCampaign);
    SqlBindJson(sql, "@value", jValue);
    SqlBindString(sql, "@tag", sTag);

    SqlStep(sql);
}

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

vector GetSQLiteVector(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetVector(sql, 0) : Vector();
}

string GetSQLiteString(object oObject, string sVarName, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, nType, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

json GetSQLiteJson(object oObject, string sVarName, int nType = VARIABLE_TYPE_JSON, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarName, VARIABLE_TYPE_JSON, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

void DeleteSQLiteInt(object oObject, string sVarName, int bCampaign = FALSE)
{
    SqlStep(PrepareQuery(oObject, sVarName, VARIABLE_TYPE_INT, VARIABLE_MODE_DELETE, bCampaign));
}

void DeleteSQLiteFloat(object oObject, string sVarName, int bCampaign = FALSE)
{
    SqlStep(PrepareQuery(oObject, sVarName, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_DELETE, bCampaign));
}

void DeleteSQLiteVector(object oObject, string sVarName, int bCampaign = FALSE)
{
    SqlStep(PrepareQuery(oObject, sVarName, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_DELETE, bCampaign));
}

void DeleteSQLiteString(object oObject, string sVarName, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    SqlStep(PrepareQuery(oObject, sVarName, nType, VARIABLE_MODE_DELETE, bCampaign));
}

void DeleteSQLiteJson(object oObject, string sVarName, int nType = VARIABLE_TYPE_JSON, int bCampaign = FALSE)
{
    SqlStep(PrepareQuery(oObject, sVarName, VARIABLE_TYPE_JSON, VARIABLE_MODE_DELETE, bCampaign));
}

void DeleteSQLiteVariables(object oObject, int bCampaign = FALSE)
{
    SqlStep(PrepareQuery(oObject, "", -1, VARIABLE_MODE_DELETE_ALL, bCampaign));
}

void DeleteSQLiteVariablesByType(object oObject, int nType, int bCampaign = FALSE)
{
    SqlStep(PrepareQuery(oObject, "", nType, VARIABLE_MODE_DELETE_BY_TYPE, bCampaign));
}

void DeleteSQLiteVariablesByTag(object oObject, string sTag, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sTag, -1, VARIABLE_MODE_DELETE_BY_TAG, bCampaign);
    SqlBindString(sql, "@tag", sTag);
    SqlStep(sql);
}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Player*
// -----------------------------------------------------------------------------
void SetPlayerInt     (object oObject, string sVarName, int      nValue, string sTag = "") {SetSQLiteInt   (oObject, sVarName, nValue,                     sTag);}
void SetPlayerString  (object oObject, string sVarName, string   sValue, string sTag = "") {SetSQLiteString(oObject, sVarName, sValue,                     sTag);}
void SetPlayerFloat   (object oObject, string sVarName, float    fValue, string sTag = "") {SetSQLiteFloat (oObject, sVarName, fValue,                     sTag);}
void SetPlayerVector  (object oObject, string sVarName, vector   vValue, string sTag = "") {SetSQLiteVector(oObject, sVarName, vValue,                     sTag);}
void SetPlayerJson    (object oObject, string sVarName, json     jValue, string sTag = "") {SetSQLiteJson  (oObject, sVarName, jValue,                     sTag);}
void SetPlayerObject  (object oObject, string sVarName, object   oValue, string sTag = "") {SetSQLiteString(oObject, sVarName, ObjectToString    (oValue), sTag, VARIABLE_TYPE_OBJECT);}
void SetPlayerLocation(object oObject, string sVarName, location lValue, string sTag = "") {SetSQLiteJson  (oObject, sVarName, _GetLocationObject(lValue), sTag, VARIABLE_TYPE_LOCATION);}

int      GetPlayerInt     (object oObject, string sVarName) {return GetSQLiteInt      (oObject, sVarName);}
float    GetPlayerFloat   (object oObject, string sVarName) {return GetSQLiteFloat    (oObject, sVarName);}
string   GetPlayerString  (object oObject, string sVarName) {return GetSQLiteString   (oObject, sVarName);}
vector   GetPlayerVector  (object oObject, string sVarName) {return GetSQLiteVector   (oObject, sVarName);}
json     GetPlayerJson    (object oObject, string sVarName) {return GetSQLiteJson     (oObject, sVarName);}
object   GetPlayerObject  (object oObject, string sVarName) {return StringToObject    (GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT));}
location GetPlayerLocation(object oObject, string sVarName) {return _GetObjectLocation(GetSQLiteJson  (oObject, sVarName, VARIABLE_TYPE_LOCATION));}

void DeletePlayerInt     (object oObject, string sVarName) {DeleteSQLiteInt   (oObject, sVarName);}
void DeletePlayerFloat   (object oObject, string sVarName) {DeleteSQLiteFloat (oObject, sVarName);}
void DeletePlayerString  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName);}
void DeletePlayerVector  (object oObject, string sVarName) {DeleteSQLiteVector(oObject, sVarName);}
void DeletePlayerJson    (object oObject, string sVarName) {DeleteSQLiteJson  (oObject, sVarName);}
void DeletePlayerObject  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);}
void DeletePlayerLocation(object oObject, string sVarName) {DeleteSQLiteJson  (oObject, sVarName, VARIABLE_TYPE_LOCATION);}

void DeletePlayerVariables      (object oObject)              {DeleteSQLiteVariables      (oObject);}
void DeletePlayerVariablesByTag (object oObject, string sTag) {DeleteSQLiteVariablesByTag (oObject, sTag);}
void DeletePlayerVariablesByType(object oObject, int nType)   {DeleteSQLiteVariablesByType(oObject, nType);}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Module*
// -----------------------------------------------------------------------------
void SetModuleInt     (string sVarName, int      nValue, string sTag = "") {SetSQLiteInt   (GetModule(), sVarName, nValue,                     sTag);}
void SetModuleString  (string sVarName, string   sValue, string sTag = "") {SetSQLiteString(GetModule(), sVarName, sValue,                     sTag);}
void SetModuleFloat   (string sVarName, float    fValue, string sTag = "") {SetSQLiteFloat (GetModule(), sVarName, fValue,                     sTag);}
void SetModuleVector  (string sVarName, vector   vValue, string sTag = "") {SetSQLiteVector(GetModule(), sVarName, vValue,                     sTag);}
void SetModuleJson    (string sVarName, json     jValue, string sTag = "") {SetSQLiteJson  (GetModule(), sVarName, jValue,                     sTag);}
void SetModuleObject  (string sVarName, object   oValue, string sTag = "") {SetSQLiteString(GetModule(), sVarName, ObjectToString    (oValue), sTag, VARIABLE_TYPE_OBJECT);}
void SetModuleLocation(string sVarName, location lValue, string sTag = "") {SetSQLiteJson  (GetModule(), sVarName, _GetLocationObject(lValue), sTag, VARIABLE_TYPE_LOCATION);}

int      GetModuleInt     (string sVarName) {return GetSQLiteInt      (GetModule(), sVarName);}
float    GetModuleFloat   (string sVarName) {return GetSQLiteFloat    (GetModule(), sVarName);}
string   GetModuleString  (string sVarName) {return GetSQLiteString   (GetModule(), sVarName);}
vector   GetModuleVector  (string sVarName) {return GetSQLiteVector   (GetModule(), sVarName);}
json     GetModuleJson    (string sVarName) {return GetSQLiteJson     (GetModule(), sVarName);}
object   GetModuleObject  (string sVarName) {return StringToObject    (GetSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_OBJECT));}
location GetModuleLocation(string sVarName) {return _GetObjectLocation(GetSQLiteJson  (GetModule(), sVarName, VARIABLE_TYPE_LOCATION));}

void DeleteModuleInt     (string sVarName) {DeleteSQLiteInt   (GetModule(), sVarName);}
void DeleteModuleFloat   (string sVarName) {DeleteSQLiteFloat (GetModule(), sVarName);}
void DeleteModuleString  (string sVarName) {DeleteSQLiteString(GetModule(), sVarName);}
void DeleteModuleVector  (string sVarName) {DeleteSQLiteVector(GetModule(), sVarName);}
void DeleteModuleJson    (string sVarName) {DeleteSQLiteJson  (GetModule(), sVarName);}
void DeleteModuleObject  (string sVarName) {DeleteSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_OBJECT);}
void DeleteModuleLocation(string sVarName) {DeleteSQLiteJson  (GetModule(), sVarName, VARIABLE_TYPE_LOCATION);}

void DeleteModuleVariables      ()            {DeleteSQLiteVariables      (GetModule());}
void DeleteModuleVariablesByTag (string sTag) {DeleteSQLiteVariablesByTag (GetModule(), sTag);}
void DeleteModuleVariablesByType(int nType)   {DeleteSQLiteVariablesByType(GetModule(), nType);}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Persistent*
// -----------------------------------------------------------------------------
void SetPersistentInt     (object oObject, string sVarName, int      nValue, string sTag = "") {SetSQLiteInt   (oObject, sVarName, nValue,                     sTag, TRUE);}
void SetPersistentrString (object oObject, string sVarName, string   sValue, string sTag = "") {SetSQLiteString(oObject, sVarName, sValue,                     sTag, TRUE);}
void SetPersistentFloat   (object oObject, string sVarName, float    fValue, string sTag = "") {SetSQLiteFloat (oObject, sVarName, fValue,                     sTag, TRUE);}
void SetPersistentVector  (object oObject, string sVarName, vector   vValue, string sTag = "") {SetSQLiteVector(oObject, sVarName, vValue,                     sTag, TRUE);}
void SetPersistentJson    (object oObject, string sVarName, json     jValue, string sTag = "") {SetSQLiteJson  (oObject, sVarName, jValue,                     sTag, VARIABLE_TYPE_JSON, TRUE);}
void SetPersistentObject  (object oObject, string sVarName, object   oValue, string sTag = "") {SetSQLiteString(oObject, sVarName, ObjectToString    (oValue), sTag, VARIABLE_TYPE_OBJECT, TRUE);}
void SetPersistentLocation(object oObject, string sVarName, location lValue, string sTag = "") {SetSQLiteJson  (oObject, sVarName, _GetLocationObject(lValue), sTag, VARIABLE_TYPE_LOCATION, TRUE);}

int      GetPersistentInt     (object oObject, string sVarName) {return GetSQLiteInt      (oObject, sVarName, TRUE);}
float    GetPersistentFloat   (object oObject, string sVarName) {return GetSQLiteFloat    (oObject, sVarName, TRUE);}
string   GetPersistentString  (object oObject, string sVarName) {return GetSQLiteString   (oObject, sVarName, TRUE);}
vector   GetPersistentVector  (object oObject, string sVarName) {return GetSQLiteVector   (oObject, sVarName, TRUE);}
json     GetPersistentJson    (object oObject, string sVarName) {return GetSQLiteJson     (oObject, sVarName, VARIABLE_TYPE_JSON, TRUE);}
object   GetPersistentObject  (object oObject, string sVarName) {return StringToObject    (GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT,   TRUE));}
location GetPersistentLocation(object oObject, string sVarName) {return _GetObjectLocation(GetSQLiteJson  (oObject, sVarName, VARIABLE_TYPE_LOCATION, TRUE));}

void DeletePersistentInt     (object oObject, string sVarName) {DeleteSQLiteInt   (oObject, sVarName, TRUE);}
void DeletePersistentFloat   (object oObject, string sVarName) {DeleteSQLiteFloat (oObject, sVarName, TRUE);}
void DeletePersistentString  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName, TRUE);}
void DeletePersistentVector  (object oObject, string sVarName) {DeleteSQLiteVector(oObject, sVarName, TRUE);}
void DeletePersistentJson    (object oObject, string sVarName) {DeleteSQLiteJson  (oObject, sVarName, VARIABLE_TYPE_JSON, TRUE);}
void DeletePersistentObject  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT, TRUE);}
void DeletePersistentLocation(object oObject, string sVarName) {GetSQLiteJson     (oObject, sVarName, VARIABLE_TYPE_LOCATION, TRUE);}

void DeletePersistentVariables      (object oObject)              {DeleteSQLiteVariables      (oObject, TRUE);}
void DeletePersistentVariablesByTag (object oObject, string sTag) {DeleteSQLiteVariablesByTag (oObject, sTag, TRUE);}
void DeletePersistentVariablesByType(object oObject, int nType)   {DeleteSQLiteVariablesByType(oObject, nType, TRUE);}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Object*
// -----------------------------------------------------------------------------
void SetObjectInt     (object oObject, string sVarName, int      nValue, string sTag = "") {SetSQLiteInt   (oObject, sVarName, nValue,                     sTag);}
void SetObjectString  (object oObject, string sVarName, string   sValue, string sTag = "") {SetSQLiteString(oObject, sVarName, sValue,                     sTag);}
void SetObjectFloat   (object oObject, string sVarName, float    fValue, string sTag = "") {SetSQLiteFloat (oObject, sVarName, fValue,                     sTag);}
void SetObjectVector  (object oObject, string sVarName, vector   vValue, string sTag = "") {SetSQLiteVector(oObject, sVarName, vValue,                     sTag);}
void SetObjectJson    (object oObject, string sVarName, json     jValue, string sTag = "") {SetSQLiteJson  (oObject, sVarName, jValue,                     sTag);}
void SetObjectObject  (object oObject, string sVarName, object   oValue, string sTag = "") {SetSQLiteString(oObject, sVarName, ObjectToString    (oValue), sTag, VARIABLE_TYPE_OBJECT);}
void SetObjectLocation(object oObject, string sVarName, location lValue, string sTag = "") {SetSQLiteJson  (oObject, sVarName, _GetLocationObject(lValue), sTag, VARIABLE_TYPE_LOCATION);}

int      GetObjectInt     (object oObject, string sVarName) {return GetSQLiteInt      (oObject, sVarName);}
float    GetObjectFloat   (object oObject, string sVarName) {return GetSQLiteFloat    (oObject, sVarName);}
string   GetObjectString  (object oObject, string sVarName) {return GetSQLiteString   (oObject, sVarName);}
vector   GetObjectVector  (object oObject, string sVarName) {return GetSQLiteVector   (oObject, sVarName);}
json     GetObjectJson    (object oObject, string sVarName) {return GetSQLiteJson     (oObject, sVarName);}
object   GetObjectObject  (object oObject, string sVarName) {return StringToObject    (GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT));}
location GetObjectLocation(object oObject, string sVarName) {return _GetObjectLocation(GetSQLiteJson  (oObject, sVarName, VARIABLE_TYPE_LOCATION));}

void DeleteObjectInt     (object oObject, string sVarName) {DeleteSQLiteInt   (oObject, sVarName);}
void DeleteObjectFloat   (object oObject, string sVarName) {DeleteSQLiteFloat (oObject, sVarName);}
void DeleteObjectString  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName);}
void DeleteObjectVector  (object oObject, string sVarName) {DeleteSQLiteVector(oObject, sVarName);}
void DeleteObjectJson    (object oObject, string sVarName) {DeleteSQLiteJson  (oObject, sVarName);}
void DeleteObjectObject  (object oObject, string sVarName) {DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);}
void DeleteObjectLocation(object oObject, string sVarName) {DeleteSQLiteJson  (oObject, sVarName, VARIABLE_TYPE_LOCATION);}

void DeleteObjectVariables      (object oObject)              {DeleteSQLiteVariables      (oObject);}
void DeleteObjectVariablesByTag (object oObject, string sTag) {DeleteSQLiteVariablesByTag (oObject, sTag);}
void DeleteObjectVariablesByType(object oObject, int nType)   {DeleteSQLiteVariablesByType(oObject, nType);}
