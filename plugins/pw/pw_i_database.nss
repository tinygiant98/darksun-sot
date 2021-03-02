// -----------------------------------------------------------------------------
//    File: pw_i_const.nss
//  System: Administration
// -----------------------------------------------------------------------------
// Description:
//  Constant for PW Management
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "core_i_database"

string sQuery;
sqlquery sql;

const string CHARACTER_REGISTRATION_TABLE = "pw_characters";
const string PLAYER_STATUS_TABLE = "pw_player_status";

const int PLAYER_STATUS_BANNED = -1;
const int PLAYER_STATUS_VALID = 0;
const int PLAYER_STATUS_DM = 1;
const int PLAYER_STATUS_DEVELOPER = 2;
const int PLAYER_STATUS_ADMIN = 3;

void CreateDatabaseTables()
{
    // Create the primary character registration table
    string sCharacterRegistration = "CREATE TABLE IF NOT EXISTS " + PW_CHARACTER_REGISTRATION_TABLE + " (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "player_name TEXT NOT NULL, " +
        "character_name TEXT NOT NULL, " +
        "uuid TEXT NOT NULL, " +
        "is_retired INTEGER NOT NULL default '0' " +
        "is_banned INTEGER NOT NULL default '0', " +
        "UNIQUE (player_name, character_name) ON CONFLICT ABORT);";

    string sPlayerStatus = "CREATE TABLE IF NOT EXISTS " + PW_PLAYER_STATUS_TABLE + " (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "identifier TEXT NOT NULL UNIQUE ON CONFLICT REPLACE, " +
        "status INTEGER NOT NULL)";


}

// Returns a PLAYER_STATUS_* constant from the status table.  Players/CDKeys/IPAddresses should
// only be in this table is they're banned or they're DM/DEVELOPER/ADMIN
int GetPlayerStatus(object oPC)
{
    sQuery = "SELECT status FROM " + PW_PLAYER_STATUS_TABLE + " " +
        "WHERE identifier IN (@player_name, @cd_key, @ip_address);";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sql);
    SqlBindString(sql, "@player_name", GetPCPlayerName(oPC));
    SqlBindString(sql, "@cd_key", GetPCPublicCDKey(oPC));
    SqlBindString(sql, "@ip_address", GetPCIPAddress(oPC));

    return SqlStep(sql) ? SqlGetInt(sql, 0) : PLAYER_STATUS_VALID;
}

void SetPlayerStatus(object oPC, int nStatus)
{
    DeletePlayerStatus(oPC);

    string sIdentifier, sIdentifiers = GetPCPlayerName(oPC);
    sIdentifiers = AddListItem(sIdentifiers, GetPCPublicCDKey(oPC));
    sIdentifiers = AddListItem(sIdentifiers, GetPCIPAddress(oPC));

    int n, nCount = (nStatus == PLAYER_STATUS_BANNED ? 3 : 1);
    for (n = 0; n < nCount; n++)
    {
        sIdentifier = GetListItem(sIdentifiers, n);
        sQuery = "INSERT INTO " + PW_PLAYER_STATUS_TABLE + " " +
            "(identifier, status) " + 
            "VALUES (@identifier, @status);";
        sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sQuery);
        SqlBindString(sql, "@identifier", sIdentifier);
        SqlBindString(sql, "@status", nStatus);

        SqlStep(sql);
    }
}

// TODO, probably need to change what's sent in here, likely won't have a PC
// object to work with for un-banning
void SetCharacterBan(object oPC, int bBanned = FALSE)
{
    sQuery = "UPDATE " + PW_CHARACTER_REGISTRATION_TABLE + " " +
        "SET is_banned = @is_banned " +
        "WHERE player_name = @player_name;";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sql);
    SqlBindInt(sql, "@is_banned", bBanned);
    SqlBindString(sql, "@player_name", GetPCPlayerName(oPC));

    SqlStep(sql);   
}

void DeletePlayerStatus(object oPC)
{
    sQuery = "DELETE FROM " + PW_PLAYER_STATUS_TABLE + " " +
        "WHERE identifier IN (@player_name, @cd_key, @ip_address);";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sql);
    SqlBindString(sql, "@player_name", GetPCPlayerName(oPC));
    SqlBindString(sql, "@cd_key", GetPCPublicCDKey(oPC));
    SqlBindString(sql, "@ip_address", GetPCIPAddress(oPC));

    SqlStep(sql);
}

void BanPlayer(object oPC)
{
    SetPlayerStatus(oPC, PLAYER_STATUS_BANNED);
    SetCharacterBan(oPC, TRUE);
}

void RegisterDM(object oPC)
{
    SetPlayerStatus(oPC, PLAYER_STATUS_DM);
}

void RegisterDeveloper(object oPC)
{
    SetPlayerStatus(oPC, PLAYER_STATUS_DEVELOPER);
}

void RegisterAdmin(object oPC)
{
    SetPlayerStatus(oPC, PLAYER_STATUS_ADMIN);
}

void ClearPlayerStatus(object oPC)
{
    DeletePlayerStatus(oPC);
    SetCharacterBan(oPC, FALSE);
}

int GetIsRegisteredDM(object oPC)
{
    return GetPlayerStatus(oPC) == PLAYER_STATUS_DM;
}

int GetIsDeveloper(object oPC)
{
    return GetPlayerStatus(oPC) == PLAYER_STATUS_DEVELOPER;
}

int GetIsAdmin(object oPC)
{
    return GetPlayerStatus(oPC) == PLAYER_STATUS_ADMIN;
}

int GetIsBanned(object oPC)
{
    return GetPlayerStatus(oPC) == PLAYER_STATUS_BANNED;
}

int GetIsStaff(object oPC)
{
    return GetPlayerStatus(oPC) >= PLAYER_STATUS_DM;
}

// Counts a specified status
int CountPlayerStatus(int nStatus)
{
    sQuery = "COUNT (*) FROM " + PW_CHARACTER_REGISTRATION_TABLE + " " +
        "WHERE status = @status;";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sql);
    SqlBindInt(sql, "@status", nstatus);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

// Accessors for CountPlayerStatus
int CountRegisteredDMs()
{
    return CountPlayerStatus(PLAYER_STATUS_DM);
}

int CountDevelopers()
{
    return CountPlayerStatus(PLAYER_STATUS_DEVELOPER);
}

int CountAdmin()
{
    return CountPlayerStatus(PLAYER_STATUS_ADMIN);
}

int CountBannedPlayers()
{
    return CountPlayerStatus(PLAYER_STATUS_BANNED) / 3;
}

int RegisterCharacter(object oPC)
{
    sQuery = "INSERT INTO " + PW_CHARACTER_REGISTRATION_TABLE + " " +
        "(player_name, character_name, uuid) " +
        "VALUES (@player_name, @character_name, @uuid);";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sQuery);

    SqlBindString(sql, "@player_name", GetPCPlayerName(oPC));
    SqlBindString(sql, "@character_name", Getname(oPC));
    SqlBindString(sql, "@uuid", GetObjectUUID(oPC));

    return SqlStep(sql);
}

// Private, used by several functions
int _GetCharacterID(object oPC)
{
    sQuery = "SELECT id FROM " + PW_CHARACTER_REGISTRATION_TABLE + " " +
                "WHERE uuid = @uuid;";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sQuery);
    SqlBindString(sql, "@uuid", GetObjectUUID(oPC));
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

// Private
int _GetSingleFieldInt(object oPC, string sTable, string sField)
{
    int nPC = _GetCharacterID(oPC);

    sQuery = "SELECT " + sField + " FROM " + sTable + " " +
                "WHERE id = @id;";
    sql = SqlPrepareQuerCampaign(FALLBACK_DATABASE, sQuery);
    SqlBindInt(sql, "@id", nPC);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

void _SetSingleFieldInt(object oPC, string sTable, string sField, int nValue)
{
    int nPC = _GetCharacterID(oPC);

    sQuery = "UPDATE " + sTable + " " +
             "SET " + sField + " = @value " +
             "WHERE id = @id;";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sQuery);
    SqlBindInt(sql, "@value", nValue);
    SqlBindInt(sql, "@id", nPC);

    SqlStep(sql);
}

int GetCharacterID(object oPC)
{
    sQuery = "SELECT id FROM " + PW_CHARACTER_REGISTRATION_TABLE + " " +
                "WHERE uuid = @uuid;";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sQuery);
    SqlBindString(sql, "@uuid", GetObjectUUID(oPC));
    
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int GetIsCharacterRegistered(object oPC)
{
    return GetCharacterIDFromDatabase(oPC) != 0;
}

void DeleteCharacter(object oPC)
{
    int nPC = _GetCharacterID(oPC);

    sQuery = "DELETE FROM " + PW_CHARACTER_REGISTRATION_TABLE + " " +
                "WHERE id = @id;";
    sql = SqlPrepareQueryCampaign(FALLBACK_DATABASE, sQuery);
    SqlBindInt(sql, "@id", nPC);

    SqlStep(sql);
}

int GetIsCharacterRetired(object oPC)
{
    return _GetSingleFieldInt(oPC, PW_CHARACTER_REGISTRATION_TABLE, "is_retired");
}

int GetIsCharacterBanned(object oPC)
{
    return _GetSingleFieldInt(oPC, PW_CHARACTER_REGISTRATION_TABLE, "is_banned");
}
