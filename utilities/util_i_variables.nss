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

// This file is a misguided attempt to provide a clearing house for handling all
// variables assigned to all game objects.  It allows for selecting either
// persistent or temporary storage by object type when using generic functions,
// or allowing the user to specify persistence through alias functions.

// Usage Warning:  There are multiple options to store variable data in this file.
// It is best practice to retrieve and delete variables using the same funtions
// that were used to set them.  For example, if you Set a variable on a player
// object with SetPlayerInt, you should use GetPlayerInt to retrieve it, not
// _GetLocalInt or any of the other available aliases.

// Usage Warning:  Once the configuration options below have been selected, changing
// them after variables have been persistently saved could cause unintended
// behavior.  Several maintenance functions have been included to wipe
// persistent storage location should the user choose to cleanup the data locations.

// _[Get|Set|Delete]Local* functions are generic in nature and meant to replace
// bioware's original variable handling system.  These functions will make an
// educated guess on where to store variables based on the settings in the
// configuration section below and the type of object passed.  Alias functions
// can be used to force alternate behavior for specific variables, regardless of
// the configuration settings below.

// [Get|Set|Delete]Player* functions are designed to store player object-specific
// variables.  By default, these variables will be stored in the player object's
// organic sqlite database, which is saved into the character's .bic file.
// If player variables are to be stored temporarily instead of persistently, they
// will be stored on the player object.

// [Get|Set|Delete]Module* functions are designed to store module object-specific
// variables.  If these variable are configured to be stored persistently, they
// will be saved to the campaign database.  If temporary, they will be saved to
// the module object's organic sqlite database

// [Get|Set|Delete]Database* functions interface with any existing NWNX external
// database, if it exists.  If an external database does not exist, all calls
// made to these functions will revert to persistent storage in a campaign
// database.  The NWNX database can be either SQLITE or MYSQL.

// *Database* functions are not yet implemented.  Use SquattingMonk's core_i_database
// file from his awesome Core Framework.

// [Get|Set|Delete]Campaign* functions are designed to persistently store variable
// data assigned to any game object.  These functions will always store the
// passed variable to the campaign database using NWN organic sqlite functionality.

// -----------------------------------------------------------------------------
//                              Configuration
// -----------------------------------------------------------------------------

// Variables assigned to the module object (GetModule()) are usually meant for
// single-session use and are wiped at each restart.  To save module object
// variables in a persistent database, set this to TRUE.  This setting only affects
// the use of _[Set|Get|Delete]Local* functions.  Regardless of this setting,
// persistence can be forced by passing the module object to [Set|Get|Delete]Module*
// functions.  If this is TRUE, default behavior is to save the variable data into
// the campaign database.  To force a different location, use an alias function.
const int MODULE_VARIABLES_PERSIST = FALSE;

    // Persistent variables assigned to the module object and other non-player game
    // objects will be assigned to the game's campaign database via the game's
    // organic sqlite functionality, unless users opt to store data in an NWNX-
    // attached database.  This option is the name of the campaign database to
    // use for persistent variable storage.
    const string MODULE_VARIABLES_DATABASE = "module_variables";

    // Persistent variables will be kept in special variable-only tables in the
    // appropriate database.  Set this constant to the name of the table that
    // all module variables will be saved to.  This will likely be the same as
    // PLAYER_VARIABLES_TABLE below.
    const string MODULE_VARIABLES_TABLE = "pw_variables";

    // Previous incarnations of module variable handling, including methods used
    // by HCR2 and other event management systems, utilized a specified object
    // to temporarily store the module variable instead of storing them directly
    // on the GetModule() object.  Current computer performance generally negates
    // this issues, however, if the user would prefer to keep the module variables
    // temporary and not within the organic sqlite database, a datapoint can
    // be specified here to hold the module data.
    const string MODULE_VARIABLES_DATAPOINT = "";

// Variables assigned to the player object (oPC) are usually meant to be persistent
// to allow for multi-session use and storing specific states to prevent cheating.
// To change this behavior and force all player object variables to be temporary,
// set this to FALSE.  If this is TRUE, default behavior is to save the variable
// data into the player's sqlite database.  To force a different location, use an
// alias function or include an item resref in the next option.
const int PLAYER_VARIABLES_PERSIST = TRUE;

    // Persistent player varibales can be stored on a specified item instead of the
    // player's organic sqlite database.  This approach to persistent storage was
    // popular in the 1.69 edition of the game due to lack of conveniently accessible
    // character-specific persistent storage.  To use this type of storage, specify
    // the resref of the item that will be used for persistent variable storage.  This
    // item will be become a permanent part of the player's inventory.
    const string PLAYER_VARIABLES_ITEM = "";

    // Persistent variables will be kept in special variable-only tables in the
    // appropriate database.  Set this constant to the name of the table that
    // all module variables will be saved to.  This will likely be the same as
    // MODULE_VARIABLES_TABLE above.
    const string PLAYER_VARIABLES_TABLE = "pw_variables";

// Variables assigned to other game objects (not the module object or a player) are
// usally meant for single-session use and are wiped at each restart.  To save game
// object variables in a persistent database, set this to TRUE.  This setting does
// not affect variables assigned to objects via the Aurora toolset.  Variables
// assigned through the Aurora toolset may only be modified using the bioware
// variable handling functions and any deleted variables will be restored on a module
// reset.  Persistent object variables will be kept in the same database and table
// as set in MODULE_VARIABLES_DATABASE and MODULE_VARIABLES_TABLE above.
const int OBJECT_VARIABLES_PERSIST = FALSE;

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

// ---< Variable Management >---

// ---< [_Get|_Set|_Delete]Local[Int|Float|String|Object|Location|Vector] >---
/* Module-level functions intended to replace and/or supplement Bioware's
    variable handling functions.  These functions will save all variable
    set to any PC or to the GetModule() object persistently in organic
    SQLite databases.  Optionally, variables set on other game objects can
    be saved persistently.
*/
int      _GetLocalInt        (object oObject, string sVarName);
float    _GetLocalFloat      (object oObject, string sVarName);
string   _GetLocalString     (object oObject, string sVarName);
object   _GetLocalObject     (object oObject, string sVarName);
location _GetLocalLocation   (object oObject, string sVarName);
vector   _GetLocalVector     (object oObject, string sVarName);

void     _SetLocalInt        (object oObject, string sVarName, int      nValue);
void     _SetLocalFloat      (object oObject, string sVarName, float    fValue);
void     _SetLocalString     (object oObject, string sVarName, string   sValue);
void     _SetLocalObject     (object oObject, string sVarName, object   oValue);
void     _SetLocalLocation   (object oObject, string sVarName, location lValue);
void     _SetLocalVector     (object oObject, string sVarName, vector   vValue);

void     _DeleteLocalInt     (object oObject, string sVarName);
void     _DeleteLocalFloat   (object oObject, string sVarName);
void     _DeleteLocalString  (object oObject, string sVarName);
void     _DeleteLocalObject  (object oObject, string sVarName);
void     _DeleteLocalLocation(object oObject, string sVarName);
void     _DeleteLocalVector  (object oObject, string sVarName);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// TODO use the ones from core_i_database?

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
    string sTable = (bPC ? PLAYER_VARIABLES_TABLE : MODULE_VARIABLES_TABLE);


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
    string query, sTable = (bPC ? PLAYER_VARIABLES_TABLE : MODULE_VARIABLES_TABLE);
    sqlquery sql;

    switch (nMode)
    {
        case VARIABLE_MODE_SELECT:
            query = "SELECT value FROM " + sTable + " " +
                "WHERE " + (bPC ? "" : "object = @object AND ") + "type = @type AND varname = @varname;";
            break;
        case VARIABLE_MODE_INSERT:
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
        sql = SqlPrepareQueryCampaign(MODULE_VARIABLES_DATABASE, query);

    SqlBindInt(sql, "@type", nVarType);
    SqlBindString(sql, "@varname", sVarName);
    
    if (!bPC)
        SqlBindString(sql, "@object", ObjectToString(oObject));

    return sql;
}

// Intervening functions, called by all sqlite-setting functions
void SetSQLiteInt(object oObject, string sVarName, int nValue, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_INT, VARIABLE_MODE_SET, bCampaign);
    SqlBindInt(sql, "@value", nValue);

    SqlStep(sql);
}

void SetSQLiteFloat(object oObject, string sVarName, float fValue, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_SET, bCampaign);
    SqlBindFloat(sql, "@value", fValue);

    SqlStep(sql);
}

// String, object, location
void SetSQLiteString(object oObject, string sVarName, string sValue, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, nType, VARIABLE_MODE_SET, bCampaign);
    SqlBindString(sql, "@value", sValue);

    SqlStep(sql);
}

void SetSQLiteVector(object oObject, string sVarName, vector vValue, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_SET, bCampaign);
    SqlBindVector(sql, "@value", vValue);

    SqlStep(sql);
}

// Intervening functions, called by all sqlite-setting functions
int GetSQLiteInt(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_INT, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

float GetSQLiteFloat(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetFloat(sql, 0) : 0;
}

// String, object, location
string GetSQLiteString(object oObject, string sVarName, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, nType, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetString(sql, 0) : 0;
}

vector GetSQLiteVector(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_GET, bCampaign);
    return SqlStep(sql) ? SqlGetVector(sql, 0) : 0;
}

// Intervening functions, called by all sqlite-setting functions
int DeleteSQLiteInt(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_INT, VARIABLE_MODE_DELETE, bCampaign);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

float DeleteSQLiteFloat(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_FLOAT, VARIABLE_MODE_DELETE, bCampaign);
    return SqlStep(sql) ? SqlGetFloat(sql, 0) : 0;
}

// String, object, location
string DeleteSQLiteString(object oObject, string sVarName, int nType = VARIABLE_TYPE_STRING, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, nType, VARIABLE_MODE_DELETE, bCampaign);
    return SqlStep(sql) ? SqlGetString(sql, 0) : 0;
}

vector DeleteSQLiteVector(object oObject, string sVarName, int bCampaign = FALSE)
{
    sqlquery sql = PrepareQuery(oObject, sVarname, VARIABLE_TYPE_VECTOR, VARIABLE_MODE_DELETE, bCampaign);
    return SqlStep(sql) ? SqlGetVector(sql, 0) : 0;
}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Player*
// -----------------------------------------------------------------------------
void SetPlayerInt(object oObject, string sVarName, int nValue)
{
    SetSQLiteInt(oObject, sVarName, nValue);
}

void SetPlayerString(object oObject, string sVarName, string sValue)
{
    SetSQLiteString(oObject, sVarName, sValue);
}

void SetPlayerFloat(object oObject, string sVarName, float fValue)
{
    SetSQLiteFloat(oObject, sVarName, fValue);
}

void SetPlayerObject(object oObject, string sVarName, object oValue)
{
    string sObject = ObjectToString(oValue);
    SetSQLiteString(oObject, sVarName, sObject, VARIABLE_TYPE_OBJECT);
}

void SetPlayerVector(object oObject, string sVarName, vector vValue)
{
    SetSQLiteVector(oObject, sVarName, vVector);
}

void SetPlayerLocation(object oObject, string sVarName, location lValue)
{
    string sLocation = __LocationToString(lValue);
    SetSQLiteString(oObject, sVarname, sLocation, VARIABLE_TYPE_LOCATION);
}

int GetPlayerInt(object oObject, string sVarName)
{
    return GetSQLiteInt(oObject, sVarName);
}

float GetPlayerFloat(object oObject, string sVarName)
{
    return GetSQLiteFloat(oObject, sVarName);
}

string GetPlayerString(object oObject, string sVarName)
{
    return GetSQLiteString(oObject, sVarName);
}

object GetPlayerObject(object oObject, string sVarName)
{
    string sObject = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);
    return StringToObject(sObject);
}

vector GetPlayerVector(object oObject, string sVarName)
{
    return GetSQLiteVector(oObject, sVarName);
}

location GetPlayerLocation(object oObject, string sVarName)
{
    string sLocation = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);
    return __StringToLocation(sLocation);
}

void DeletePlayerInt(object oObject, string sVarName)
{
    DeleteSQLiteInt(oObject, sVarName);
}

void DeletePlayerFloat(object oObject, string sVarName)
{
    DeleteSQLiteFloat(oObject, sVarName);
}

void DeletePlayerString(object oObject, string sVarName)
{
    DeleteSQLiteString(oObject, sVarName);
}

void DeletePlayerObject(object oObject, string sVarName)
{
    DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);
}

void DeletePlayerVector(object oObject, string sVarName)
{
    DeleteSQLiteVector(oObject, sVarName);
}

void DeletePlayerLocation(object oObject, string sVarName)
{
    DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);
}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Module*
// -----------------------------------------------------------------------------
void SetModuleInt(object oObject, string sVarName, int nValue)
{
    SetSQLiteInt(GetModule(), sVarName, nValue);
}

void SetModuleString(object oObject, string sVarName, string sValue)
{
    SetSQLiteString(GetModule(), sVarName, sValue);
}

void SetModuleFloat(object oObject, string sVarName, float fValue)
{
    SetSQLiteFloat(GetModule(), sVarName, fValue);
}

void SetModuleObject(object oObject, string sVarName, object oValue)
{
    string sObject = ObjectToString(oValue);
    SetSQLiteString(GetModule(), sVarName, sObject, VARIABLE_TYPE_OBJECT);
}

void SetModuleVector(object oObject, string sVarName, vector vValue)
{
    SetSQLiteVector(GetModule(), sVarName, vVector);
}

void SetModuleLocation(object oObject, string sVarName, location lValue)
{
    string sLocation = __LocationToString(lValue);
    SetSQLiteString(GetModule(), sVarname, sLocation, VARIABLE_TYPE_LOCATION);
}

int GetModuleInt(object oObject, string sVarName)
{
    return GetSQLiteInt(GetModule(), sVarName);
}

float GetModuleFloat(object oObject, string sVarName)
{
    return GetSQLiteFloat(GetModule(), sVarName);
}

string GetModuleString(object oObject, string sVarName)
{
    return GetSQLiteString(GetModule(), sVarName);
}

object GetModuleObject(object oObject, string sVarName)
{
    string sObject = GetSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_OBJECT);
    return StringToObject(sObject);
}

vector GetModuleVector(object oObject, string sVarName)
{
    return GetSQLiteVector(GetModule(), sVarName);
}

location GetModuleLocation(object oObject, string sVarName)
{
    string sLocation = GetSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_LOCATION);
    return __StringToLocation(sLocation);
}

void DeleteModuleInt(object oObject, string sVarName)
{
    DeleteSQLiteInt(GetModule(), sVarName);
}

void DeleteModuleFloat(object oObject, string sVarName)
{
    DeleteSQLiteFloat(GetModule(), sVarName);
}

void DeleteModuleString(object oObject, string sVarName)
{
    DeleteSQLiteString(GetModule(), sVarName);
}

void DeleteModuleObject(object oObject, string sVarName)
{
    DeleteSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_OBJECT);
}

void DeleteModuleVector(object oObject, string sVarName)
{
    DeleteSQLiteVector(GetModule(), sVarName);
}

void DeleteModuleLocation(object oObject, string sVarName)
{
    DeleteSQLiteString(GetModule(), sVarName, VARIABLE_TYPE_LOCATION);
}

// -----------------------------------------------------------------------------
//                          [Set|Get|Delete]Persistent*
// -----------------------------------------------------------------------------
void SetPersistentInt(object oObject, string sVarName, int nValue)
{
    SetSQLiteInt(oObject, sVarName, nValue);
}

void SetPersistentrString(object oObject, string sVarName, string sValue)
{
    SetSQLiteString(oObject, sVarName, sValue);
}

void SetPersistentFloat(object oObject, string sVarName, float fValue)
{
    SetSQLiteFloat(oObject, sVarName, fValue);
}

void SetPersistentObject(object oObject, string sVarName, object oValue)
{
    string sObject = ObjectToString(oValue);
    SetSQLiteString(oObject, sVarName, sObject, VARIABLE_TYPE_OBJECT);
}

void SetPersistentVector(object oObject, string sVarName, vector vValue)
{
    SetSQLiteVector(oObject, sVarName, vVector);
}

void SetPersistentLocation(object oObject, string sVarName, location lValue)
{
    string sLocation = __LocationToString(lValue);
    SetSQLiteString(oObject, sVarname, sLocation, VARIABLE_TYPE_LOCATION);
}

int GetPersistentInt(object oObject, string sVarName)
{
    return GetSQLiteInt(oObject, sVarName);
}

float GetPersistentFloat(object oObject, string sVarName)
{
    return GetSQLiteFloat(oObject, sVarName);
}

string GetPersistentString(object oObject, string sVarName)
{
    return GetSQLiteString(oObject, sVarName);
}

object GetPersistentObject(object oObject, string sVarName)
{
    string sObject = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);
    return StringToObject(sObject);
}

vector GetPersistentVector(object oObject, string sVarName)
{
    return GetSQLiteVector(oObject, sVarName);
}

location GetPersistentLocation(object oObject, string sVarName)
{
    string sLocation = GetSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);
    return __StringToLocation(sLocation);
}

void DeletePersistentInt(object oObject, string sVarName)
{
    DeleteSQLiteInt(oObject, sVarName);
}

void DeletePersistentFloat(object oObject, string sVarName)
{
    DeleteSQLiteFloat(oObject, sVarName);
}

void DeletePersistentString(object oObject, string sVarName)
{
    DeleteSQLiteString(oObject, sVarName);
}

void DeletePersistentObject(object oObject, string sVarName)
{
    DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_OBJECT);
}

void DeletePersistentVector(object oObject, string sVarName)
{
    DeleteSQLiteVector(oObject, sVarName);
}

void DeletePersistentLocation(object oObject, string sVarName)
{
    DeleteSQLiteString(oObject, sVarName, VARIABLE_TYPE_LOCATION);
}

int _HandleInts(object oObject, string sVarName, int nValue, int nMode)
{
    int bPC = GetIsPC(oObject);
    int bModule = oObject == OBJECT_INVALID || oObject == GetModule();

    int SET, GET;
    switch (nMode)
    {
        case VARIABLE_MODE_SET: SET = TRUE; break;
        case VARIABLE_MODE_GET: GET = TRUE; break;
    }

    if (bPC)
    {
        if (PLAYER_VARIABLES_PERSIST)
        {
            if (PLAYER_VARIABLES_ITEM != "")
            {
                object oData = GetItemPossessedBy(oObject, PLAYER_VARIABLES_ITEM);
                if (GetIsObjectValid(oData))
                    if (SET) SetLocalInt(oData, sVarName, nValue);
                    else if (GET) return GetLocalInt(oData, sVarName);
                    else DeleteLocalInt(oData, sVarName);
                else
                    if (SET) SetPlayerInt(oObject, sVarName, nValue);
                    else if (GET) return GetPlayerInt(oObject, sVarName);
                    else DeletePlayerInt(oData, sVarName);
            }
            else
                if (SET) SetPlayerInt(oObject, sVarName, nValue);
                else if (GET) return GetPlayerInt(oObject, sVarName);
                else DeletePlayerInt(oData, sVarName);
        }
        else
            if (SET) SetLocalInt(oObject, sVarName, nValue);
            else if (GET) return GetLocalInt(oObject, sVarName);
            else DeleteLocalInt(oObject, sVarName);
    }
    else if (bModule)
    {
        if (MODULE_VARIABLES_PERSIST)
            if (SET) SetPersistentInt(oObject, sVarName, nValue);
            else if (GET) return GetPersistentInt(oObject, sVarName);
            else DeletePersistentInt(oObject, sVarName);
        else
        {
            if (MODULE_VARIABLES_DATAPOINT != "")
            {
                object MODULE = GetDatapoint(MODULE_VARIABLES_DATAPOINT);
                if (GetIsObjectValid(MODULE))
                    if (SET) SetLocalInt(MODULE, sVarName, nValue);
                    else if (GET) return GetLocalInt(MODULE, sVarName);
                    else DeleteLocalInt(MODULE, sVarName);
                else if (MODULE_VARIABLES_TABLE != "")
                    if (SET) SetModuleInt(OBJECT_INVALID, sVarName, nValue);
                    else if (GET) return GetModuleInt(OBJECT_INVALID, sVarName);
                    else DeleteModuleInt(OBJECT_INVALID, sVarName);                    
                else
                    if (SET) SetLocalInt(GetModule(), sVarName, nValue);
                    else if (GET) return GetLocalInt(GetModule(), sVarName);
                    else DeleteLocalInt(GetModule(), sVarName);
            }
            else if (MODULE_VARIABLES_TABLE != "")
                if (SET) SetModuleInt(OBJECT_INVALID, sVarName, nValue);
                else if (GET) return GetModuleInt(OBJECT_INVALID, sVarName);
                else DeleteModuleInt(OBJECT_INVALID, sVarName);  
            else
                if (SET) SetLocalInt(GetModule(), sVarName, nValue);
                else if (GET) return GetLocalInt(GetModule(), sVarName);
                else DeleteLocalInt(GetModule(), sVarName);
        }
    }
    else if (OBJECT_VARIABLES_PERSIST)
        if (SET) SetPersistentInt(oObject, sVarName, nValue);
        else if (GET) return GetPersistentInt(oObject, sVarName);
        else DeletePersistentInt(oObject, sVarName);
    else
        if (SET) SetLocalInt(oObject, sVarName, nValue);
        else if (GET) return GetLocalInt(oObject, sVarName);
        else DeleteLocalInt(oObject, sVarName);

    return FALSE;
}

































float _GetLocalFloat(object oObject, string sVarName)
{
    if (sVarName == "")
        return 0.0;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;
    
    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_FLOAT, sVarName, VARIABLE_MODE_SELECT);

        if (SqlStep(sql))
            return SqlGetFloat(sql, 0);
        else
            return 0.0;
    }
    else
        return GetLocalFloat(oObject, sVarName);
}

string _GetLocalString(object oObject, string sVarName)
{
    if (sVarName == "")
        return "";

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;
    
    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_STRING, sVarName, VARIABLE_MODE_SELECT);

        if (SqlStep(sql))
            return SqlGetString(sql, 0);
        else
            return "";
    }
    else
        return GetLocalString(oObject, sVarName);
}

object _GetLocalObject(object oObject, string sVarName)
{
    if (sVarName == "")
        return OBJECT_INVALID;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;
    
    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_OBJECT, sVarName, VARIABLE_MODE_SELECT);

        if (SqlStep(sql))
            return StringToObject(SqlGetString(sql, 0));
        else
            return OBJECT_INVALID;
    }
    else
        return GetLocalObject(oObject, sVarName);
}

location _GetLocalLocation(object oObject, string sVarName)
{
    if (sVarName == "")
        return GetStartingLocation();

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;
    
    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_LOCATION, sVarName, VARIABLE_MODE_SELECT);

        if (SqlStep(sql))
            return __StringToLocation(SqlGetString(sql, 0));
        else
            return GetStartingLocation();
    }
    else
        return GetLocalLocation(oObject, sVarName);
}

vector _GetLocalVector(object oObject, string sVarName)
{
    if (sVarName == "")
        return Vector();

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;
    
    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_VECTOR, sVarName, VARIABLE_MODE_SELECT);

        if (SqlStep(sql))
            return SqlGetVector(sql, 0);
        else
            return Vector();
    }
    else
        return GetPositionFromLocation(GetLocalLocation(oObject, "V:" + sVarName));
}

// ---< _SetLocal* Variable Procedures >---

void _SetLocalInt(object oObject, string sVarName, int nValue)
{
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_INT, sVarName, VARIABLE_MODE_INSERT);
        SqlBindInt(sql, "@value", nValue);
        SqlStep(sql);
    }
    else
        SetLocalInt(oObject, sVarName, nValue);
}

void _SetLocalFloat(object oObject, string sVarName, float fValue)
{
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_FLOAT, sVarName, VARIABLE_MODE_INSERT);
        SqlBindFloat(sql, "@value", fValue);
        SqlStep(sql);
    }
    else
        SetLocalFloat(oObject, sVarName, fValue);
}

void _SetLocalString(object oObject, string sVarName, string sValue)
{
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_STRING, sVarName, VARIABLE_MODE_INSERT);
        SqlBindString(sql, "@value", sValue);
        SqlStep(sql);
    }
    else
        SetLocalString(oObject, sVarName, sValue);
}

void _SetLocalObject(object oObject, string sVarName, object oValue)
{
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_OBJECT, sVarName, VARIABLE_MODE_INSERT);
        SqlBindString(sql, "@value", ObjectToString(oValue));
        SqlStep(sql);
    }
    else
        SetLocalObject(oObject, sVarName, oValue);
}

void _SetLocalLocation(object oObject, string sVarName, location lValue)
{
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_LOCATION, sVarName, VARIABLE_MODE_INSERT);
        SqlBindString(sql, "@value", __LocationToString(lValue));
        SqlStep(sql);
    }
    else
        SetLocalLocation(oObject, sVarName, lValue);
}

void _SetLocalVector(object oObject, string sVarName, vector vValue)
{
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_LOCATION, sVarName, VARIABLE_MODE_INSERT);
        SqlBindVector(sql, "@value", vValue);
        SqlStep(sql);
    }
    else
        SetLocalLocation(oObject, "V:" + sVarName, Location(OBJECT_INVALID, vValue, 0.0f));
}

// ---< _DeleteLocal* Variable Procedures >---

void _DeleteLocalInt(object oObject, string sVarName)
{    
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_INT, sVarName, VARIABLE_MODE_DELETE);
        SqlStep(sql);
    }
    else
        DeleteLocalInt(oObject, sVarName);
}

void _DeleteLocalFloat(object oObject, string sVarName)
{    
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_FLOAT, sVarName, VARIABLE_MODE_DELETE);
        SqlStep(sql);
    }
    else
        DeleteLocalFloat(oObject, sVarName);
}

void _DeleteLocalString(object oObject, string sVarName)
{    
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_STRING, sVarName, VARIABLE_MODE_DELETE);
        SqlStep(sql);
    }
    else
        DeleteLocalString(oObject, sVarName);
}

void _DeleteLocalObject(object oObject, string sVarName)
{    
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_OBJECT, sVarName, VARIABLE_MODE_DELETE);
        SqlStep(sql);
    }
    else
        DeleteLocalObject(oObject, sVarName);
}

void _DeleteLocalLocation(object oObject, string sVarName)
{    
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_LOCATION, sVarName, VARIABLE_MODE_DELETE);
        SqlStep(sql);
    }
    else
        DeleteLocalLocation(oObject, sVarName);
}

void _DeleteLocalVector(object oObject, string sVarName)
{    
    if (sVarName == "")
        return;

    if (oObject == OBJECT_INVALID)
        oObject = oModule1;

    if (VARIABLE_GAME_OBJECT_SQLITE || GetIsPC(oObject) || oObject == oModule1)
    {
        sqlquery sql = PrepareQuery(oObject, VARIABLE_TYPE_VECTOR, sVarName, VARIABLE_MODE_DELETE);
        SqlStep(sql);
    }
    else
        DeleteLocalLocation(oObject, "V:" + sVarName);
}

/*  Maybe accessors
SetDatabaseInt -> NWNX/External Database (any object)
SetPersistentInt -> Internal Persistent (any object) (SqlPrepareQueryCampaign)
    if (GetIsPC -> goto SetPlayerInt)
SetModuleInt -> Internal Non-persistent (module object) (SqlPrepareQueryObject)
SetPlayerInt -> Internal Persistent (player objects) (SqlPrepareQueryObject)
SetLocalInt -> Internal Non-persistent (any object)