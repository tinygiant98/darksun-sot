/// ----------------------------------------------------------------------------
/// @file   pw_i_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (core).
/// ----------------------------------------------------------------------------

#include "pw_c_audit"
#include "pw_i_sql"

void audit_CreateTables()
{
    /// @brief The following tables are persistent and reside in the campaign/on-disk
    ///     persistent database.  All audit tables are namespaced with `audit_`.

    pw_BeginTransaction();

    /// @note The `audit_logs` table holds all audit trail data for the server.  This table
    ///     supports structured logging in the data BLOB and can contain any audit data
    ///     as defined by various plugins.  The audit plugin has function to help define
    ///     basic object keys that should be included with every structured logging entry.
    string s = r"
        CREATE TABLE IF NOT EXISTS audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            data BLOB NOT NULL DEFAULT jsonb('{}') CHECK (json_valid(data, 8)),
            event_type TEXT GENERATED ALWAYS AS (jsonb_extract(data, '$.event_type')) VIRTUAL,
            actor_id INTEGER GENERATED ALWAYS AS (jsonb_extract(data, '$.actor_id')) VIRTUAL,
            target_id INTEGER GENERATED ALWAYS AS (jsonb_extract(data, '$.target_id')) VIRTUAL
        );
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_log_event_type ON audit_log(event_type);
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_actor ON audit_log(actor_id) 
        WHERE actor_id IS NOT NULL;
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_target ON audit_log(target_id) 
        WHERE target_id IS NOT NULL;
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_created_at ON audit_log(created_at);
    ";
    pw_ExecuteCampaignQuery(s);
    pw_CommitTransaction();

    /// @brief The following tables are temporary and reside in the module/in-memory
    ///     database.  They are used as a high-speed buffer and synced to the
    ///     matching table in the campaign/on-disk database.

    pw_BeginTransaction(GetModule());

    /// @note The `audit_buffer` table holds temporary audit data for all players,
    ///     characters and the server, identified by the `type` column.  Periodically,
    ///     this table will be sync'd with the on-disk tables defined above and the
    ///     temporary records deleted.
    s = r"
        CREATE TABLE IF NOT EXISTS audit_buffer (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data BLOB NOT NULL DEFAULT jsonb('{}') CHECK (json_valid(data, 8))
        );
    ";
    pw_ExecuteModuleQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_buffer_queue ON audit_buffer(id ASC);
    ";
    pw_ExecuteModuleQuery(s);
    pw_CommitTransaction(GetModule());
}

/// @brief Register a metrics schema to the metrics plugin.  Registering a metrics
///     schema allows a plugin to provide metrics to the metrics database and define
///     how those metrics are integrated during syncing operations.
/// @param sPlugin The name of the plugin providing the metrics schema.
/// @param sName The name of the metrics schema.
/// @param jData The metrics schema object.
/// @warning If a metrics schema is registered using a plugin/name combination that
///     already exists, the existing metrics schema will be replaced with the schema
///     contained in jData.
/// @note When creating plugin-defined schema, if custom data is being tracked that
///     will never be accessed by other plugins and may be deleted at some point,
///     ensure unique keys are used.  Namespaces, such as <plugin_*> work well in
///     these cases.
void audit_RegisterSchema(string sPlugin, string sName, json jData)
{
    /// @todo provide actual errors here instead of just returning.
    if (sPlugin == "" || sName == "")
        return;

    if (JsonGetType(jData) != JSON_TYPE_OBJECT)
        return;

    string s = r"
        INSERT INTO metrics_schema (plugin, name, data)
        SELECT @plugin, @name, 
            (SELECT jsonb_group_object(fullkey, value) 
             FROM jsonb_tree(jsonb(@data)) 
             WHERE atom IS NOT NULL);
    ";
    
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@plugin", sPlugin);
    SqlBindString(q, "@name", sName);
    SqlBindJson(q, "@data", jData);

    SqlStep(q);
}

void audit_SyncModuleBuffer(int nChunk = 500)
{
    string s = r"
        SELECT jsonb_group_array(
            jsonb_object('id', id, 'data', data)
        ) 
        FROM (
            SELECT id, data FROM audit_buffer 
            ORDER BY id ASC 
            LIMIT @limit
        ) AS batch;
    ";
    sqlquery q = pw_PrepareModuleQuery(s);
    SqlBindInt(q, "@limit", nChunk);

    json jBuffer = SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();

    if (JsonGetType(jBuffer) == JSON_TYPE_ARRAY && JsonGetLength(jBuffer) > 0)
    {
        string s = r"
            INSERT INTO audit_log (data)
            SELECT jsonb_extract(value, '$.data') FROM jsonb_each(@buffer);
        ";
        sqlquery q = pw_PrepareCampaignQuery(s);
        SqlBindJson(q, "@buffer", jBuffer);
        
        if (SqlStep(q))
        {
            string s = r"
                DELETE FROM audit_buffer 
                WHERE id IN (
                    SELECT jsonb_extract(value, '$.id') FROM jsonb_each(@buffer)
                );
            ";
            sqlquery q = pw_PrepareModuleQuery(s);
            SqlBindJson(q, "@buffer", jBuffer);
            SqlStep(q);
        }
    }
}

/// @todo
void audit_RegisterSchemas()
{
    /// @note Register core metrics schemas here.
}

