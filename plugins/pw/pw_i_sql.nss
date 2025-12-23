/// ----------------------------------------------------------------------------
/// @file   pw_i_sql.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Persistent World Administration (database).
/// ----------------------------------------------------------------------------

#include "pw_c_core"

string pw_GetDatabaseName()
{
    return PW_CAMPAIGN_DB_NAME;
}

sqlquery pw_PrepareQuery(string sQuery, object o = OBJECT_INVALID)
{
    if (o == OBJECT_INVALID)
        return SqlPrepareQueryCampaign(pw_GetDatabaseName(), sQuery);
    else if (o == GetModule() || GetIsPC(o))
        return SqlPrepareQueryObject(o, sQuery);

    sqlquery q;
    return q;
}

sqlquery pw_PrepareCampaignQuery(string s)
{
    return pw_PrepareQuery(s);
}

sqlquery pw_PrepareModuleQuery(string s)
{
    return pw_PrepareQuery(s, GetModule());
}

sqlquery pw_PreparePlayerQuery(object oPC, string s)
{
    return pw_PrepareQuery(s, oPC);
}

void pw_ExecuteQuery(string s, object o = OBJECT_INVALID)
{
    SqlStep(pw_PrepareQuery(s, o));
}

void pw_ExecuteCampaignQuery(string s)
{
    SqlStep(pw_PrepareCampaignQuery(s));
}

void pw_ExecuteModuleQuery(string s)
{
    SqlStep(pw_PrepareModuleQuery(s));
}

void pw_ExecutePlayerQuery(object oPC, string s)
{
    SqlStep(pw_PreparePlayerQuery(oPC, s));
}

void pw_BeginTransaction(object o = OBJECT_INVALID)
{
    string s = "BEGIN TRANSACTION;";
    pw_ExecuteQuery(s, o);
}

void pw_CommitTransaction(object o = OBJECT_INVALID)
{
    string s = "COMMIT TRANSACTION;";

    if (o == OBJECT_INVALID)
        SqlStep(pw_PrepareCampaignQuery(s));
    else if (o == GetModule())
        SqlStep(pw_PrepareModuleQuery(s));
}

void pw_CreateCampaignTable(string sTable, string sTableDef, int bForce)
{
    if (bForce)
        pw_ExecuteCampaignQuery("DROP TABLE IF EXISTS " + sTable + ";");

    pw_ExecuteCampaignQuery("CREATE TABLE IF NOT EXISTS " + sTable + "(" + sTableDef + ");");
}

void pw_CreateModuleTable(string sTable, string sTableDef, int bForce = FALSE)
{
    if (bForce)
        pw_ExecuteModuleQuery("DROP TABLE IF EXISTS " + sTable + ";");

    pw_ExecuteModuleQuery("CREATE TABLE IF NOT EXISTS " + sTable + "(" + sTableDef + ");");
}
