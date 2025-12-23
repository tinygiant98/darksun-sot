/// ----------------------------------------------------------------------------
/// @file   pw_i_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (core).
/// ----------------------------------------------------------------------------

#include "pw_i_sql"

const string METRICS_TYPE_PLAYER = "player";
const string METRICS_TYPE_CHARACTER = "character";
const string METRICS_TYPE_SERVER = "server";

void metrics_CreateTables()
{
    /// @brief The following tables are persistent and reside in the campaign/on-disk
    ///     persistent database.  All metrics tables are namespaced with `metrics_`.

    pw_BeginTransaction();

    /// @note This is unlikely to be used, but in case we want to fully remove a player
    ///     from the database, this will allow cascading deletes.
    pw_ExecuteCampaignQuery("PRAGMA foreign_keys = ON;");

    /// @note Many of these tables have a `data` jsonb BLOB.  This is intended to carry
    ///     structured json data or, potentially, new data we did not plan for.  This
    ///     methodology prevents having to ALTER TABLE the definition and deal with
    ///     versioning issues.

    /// @note The `metrics_player` table holds all player metrics, which can be
    ///     defined by various plugins.  These metrics are not pre-defined.  All
    ///     metrics are held in jsob BLOBs and are synced from similar tables
    ///     held by the in-memory module database.
    string s = r"
        CREATE TABLE IF NOT EXISTS metrics_player (
            player_id TEXT PRIMARY KEY,
            data BLOB NOT NULL DEFAULT jsonb('{}'),
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (player_id) REFERENCES player(player_id)
                ON DELETE CASCADE
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `metrics_character` table holds all character metrics, which can be
    ///     defined by various plugins.  These metrics are not pre-defined.  All
    ///     metrics are held in jsob BLOBs and are synced from similar tables
    ///     held by the in-memory module database.
    s = r"
        CREATE TABLE IF NOT EXISTS metrics_character (
            character_id INTEGER PRIMARY KEY,
            data BLOB NOT NULL DEFAULT jsonb('{}'),
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (character_id) REFERENCES character(character_id)
                ON DELETE CASCADE
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `metrics_server` table holds all server metrics, which can be
    ///     defined by various plugins.  These metrics are not pre-defined.  All
    ///     metrics are held in jsob BLOBs and are synced from similar tables
    ///     held by the in-memory module database.
    s = r"
        CREATE TABLE IF NOT EXISTS metrics_server (
            server_id INTEGER PRIMARY KEY CHECK (server_id = 1),
            data BLOB NOT NULL DEFAULT jsonb('{}'),
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `metrics_schema` table holds all defined metrics schema provided by
    ///     any metrics provider.  This allows plugins to define their own metrics,
    ///     define metrics behaviors, and allow seamless syncing with previously-
    ///     existing metrics without having to build the sync architecture within each
    ///     plugin.
    /// @note Plugins will be required to register their metric schema with the metrics
    ///     plugin to ensure their sync behavior can be controlled reliably.

    s = r"
        CREATE TABLE IF NOT EXISTS metrics_schema (
            plugin TEXT NOT NULL COLLATE NOCASE,
            name TEXT NOT NULL COLLATE NOCASE,
            data BLOB NOT NULL DEFAULT jsonb('{}') CHECK (json_valid(data, 8)),
            PRIMARY KEY (plugin, name) ON CONFLICT REPLACE
        ) WITHOUT ROWID;
    ";
    pw_ExecuteCampaignQuery(s);
    pw_CommitTransaction();

    /// @brief The following tables are temporary and reside in the module/in-memory
    ///     database.  They are used as a high-speed buffer and synced to the
    ///     matching table in the campaign/on-disk database.

    pw_BeginTransaction(GetModule());

    /// @note The `metrics_buffer` table holds temporary metrics data for all players,
    ///     characters and the server, identified by the `type` column.  Periodically,
    ///     this table will be sync'd with the on-disk tables defined above and the
    ///     temporary records deleted.
    s = r"
        CREATE TABLE IF NOT EXISTS metrics_buffer (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL COLLATE NOCASE,
            target TEXT NOT NULL COLLATE NOCASE,
            plugin TEXT NOT NULL COLLATE NOCASE,
            schema TEXT NOT NULL COLLATE NOCASE,
            data BLOB NOT NULL DEFAULT jsonb('{}') CHECK (json_valid(data, 8))
        );
    ";
    pw_ExecuteModuleQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_metrics_buffer_queue ON metrics_buffer(id ASC);
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
void metrics_RegisterSchema(string sPlugin, string sName, json jData)
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

void metrics_SyncModuleBuffer(int nChunk = 500)
{
    /// @note To try to make this as efficient as possible, we're going to do this
    ///     in chunks, but we'll work with similar schema to prevent having to
    ///     retrieve and parse the same schema file a hundred times for each
    ///     batch.
    /// @note Starting with the first/oldest record in the buffer, we'll group the
    ///     recordset by type, plugin and schema, then return enough groups to
    ///     maximize the number of records we'll process while still remaining under
    ///     nChunk records.  If the first group is greater than nChunk records, then
    ///     we'll limit that group to nChunk.

    string s = r"
        WITH metrics_groups AS (
            SELECT type, plugin, schema, COUNT(*) AS group_size, MIN(id) AS oldest_id
            FROM metrics_buffer GROUP BY type, plugin, schema
        ),
        metrics_totals AS (
            SELECT type, plugin, schema, group_size,
                SUM(group_size) OVER (ORDER BY oldest_id ASC) AS cumulative_count
            FROM metrics_groups
        ),
        metrics_selected AS (
            SELECT type, plugin, schema, group_size, 
                (cumulative_count - group_size) as preceding_count
            FROM metrics_totals 
            WHERE preceding_count < @limit
        )
        SELECT jsonb_group_array(
            jsonb_object(
                'type', type,
                'plugin', plugin,
                'schema', schema,
                'metrics', (
                    SELECT jsonb_group_array(
                        jsonb_object('id', id, 'target', target, 'data', data)
                    ) FROM (
                        SELECT id, target, data 
                        FROM metrics_buffer mb 
                        WHERE mb.type = ms.type AND mb.plugin = ms.plugin AND mb.schema = ms.schema
                        ORDER BY id ASC
                        LIMIT (@limit - ms.preceding_count)
                    )
                )
            )
        ) FROM metrics_selected ms;
    ";
    sqlquery q = pw_PrepareModuleQuery(s);
    SqlBindInt(q, "@limit", nChunk);

    json jBuffer = SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();

    /// @note Once we have the metrics dump from the module's metrics_buffer table, we need to
    ///     route and process the data to the appropriate location.  Since the metrics dump
    ///     is organized into groups, it's pretty easy to do this as long as the plugins have
    ///     registered their metrics schema.

    if (JsonGetType(jBuffer) == JSON_TYPE_ARRAY && JsonGetLength(jBuffer) > 0)
    {
        int n; for (; n < JsonGetLength(jBuffer); n++)
        {
            json jGroup = JsonArrayGet(jBuffer, n);
            string sType = JsonGetString(JsonObjectGet(jGroup, "type"));
            string sPlugin = JsonGetString(JsonObjectGet(jGroup, "plugin"));
            string sSchema = JsonGetString(JsonObjectGet(jGroup, "schema"));
            json jMetrics = JsonObjectGet(jGroup, "metrics");

            json jSubstitute = JsonObject();
            jSubstitute = JsonObjectSet(jSubstitute, "metrics_table", JsonString("metrics_" + sType));
            jSubstitute = JsonObjectSet(jSubstitute, "metrics_pk", JsonString(sType + "_id"));

            if (sType == "server")
            {
                jSubstitute = JsonObjectSet(jSubstitute, "target_table", JsonString("(SELECT 1 AS id, '1' AS server_ref)"));
                jSubstitute = JsonObjectSet(jSubstitute, "target_id", JsonString("server_ref"));
            }
            else
            {
                jSubstitute = JsonObjectSet(jSubstitute, "target_table", JsonString(sType));
                jSubstitute = JsonObjectSet(jSubstitute, "target_id", JsonString(sType + "_id"));
            }

            string s = r"
                INSERT INTO $metrics_table ($metrics_pk, data, last_updated)
                SELECT 
                    target_table.id,
                    (
                    WITH RECURSIVE
                    -- 1. Unpack incoming records and discover all JSON paths
                    raw_paths AS (
                        SELECT batch.tg_ref, tree.fullkey, tree.value as mem_v
                        FROM (
                            SELECT value ->> '$.target' as tg_ref, value ->> '$.data' as data 
                            FROM jsonb_each(@group_records)
                        ) AS batch
                        JOIN jsonb_tree(jsonb(batch.data)) tree ON tree.atom IS NOT NULL
                    ),
                    -- 2. The Universal Merge Engine (Applying schema-defined operations)
                    merged_nodes AS (
                        SELECT 
                            rp.tg_ref, rp.fullkey,
                            CASE 
                                WHEN op = 'ADD'      THEN COALESCE(disk_v, 0) + rp.mem_v
                                WHEN op = 'SUB'      THEN COALESCE(disk_v, 0) - rp.mem_v
                                WHEN op = 'MAX'      THEN MAX(COALESCE(disk_v, 0), rp.mem_v)
                                WHEN op = 'MIN'      THEN MIN(COALESCE(disk_v, 0), rp.mem_v)
                                WHEN op = 'KEEP'     THEN COALESCE(disk_v, rp.mem_v)
                                WHEN op = 'BIT_OR'   THEN COALESCE(disk_v, 0) | rp.mem_v
                                WHEN op = 'NON_ZERO' THEN CASE WHEN rp.mem_v != 0 THEN rp.mem_v ELSE disk_v END
                                WHEN op = 'APPEND'   THEN jsonb_insert(COALESCE(disk_v, jsonb('[]')), '$[#]', rp.mem_v)
                                WHEN op = 'DELETE'   THEN NULL
                                ELSE rp.mem_v -- Default: REPLACE
                            END as val
                        FROM (
                            SELECT 
                                rp.*,
                                jsonb_extract(m.data, rp.fullkey) as disk_v,
                                jsonb_extract(ms.data, rp.fullkey) as op
                            FROM raw_paths rp
                            JOIN $target_table target_table ON rp.tg_ref = target_table.$target_id
                            LEFT JOIN $metrics_table m ON target_table.id = m.$metrics_pk
                            LEFT JOIN metrics_schema ms ON ms.plugin = @plugin_name AND ms.name = @schema_name
                        ) rp
                    ),
                    -- 3. Tree Reconstruction (Recursive jsonb_set auto-builds missing parents)
                    finisher(tg_ref, current_json, node_idx) AS (
                        SELECT DISTINCT tg_ref, COALESCE(m.data, jsonb('{}')), 0
                        FROM raw_paths rp
                        JOIN $target_table target_table ON rp.tg_ref = target_table.$target_id
                        LEFT JOIN $metrics_table m ON target_table.id = m.$metrics_pk
                        UNION ALL
                        SELECT 
                            f.tg_ref, 
                            jsonb_set(f.current_json, m.fullkey, m.val),
                            f.node_idx + 1
                        FROM finisher f
                        JOIN merged_nodes m ON f.tg_ref = m.tg_ref
                        WHERE m.val IS NOT NULL -- Essential for DELETE logic
                            AND m.rowid = (SELECT rowid FROM merged_nodes WHERE tg_ref = f.tg_ref LIMIT 1 OFFSET f.node_idx)
                    )
                    SELECT current_json FROM finisher ORDER BY node_idx DESC LIMIT 1
                    ),
                    CURRENT_TIMESTAMP
                FROM (
                    SELECT DISTINCT value ->> '$.target' as tg_ref FROM jsonb_each(@group_records)
                ) AS batch_targets
                JOIN $target_table target_table ON batch_targets.tg_ref = target_table.$target_id
                ON CONFLICT($metrics_pk) DO UPDATE SET
                    data = excluded.data,
                    last_updated = excluded.last_updated;
            ";
            s = SubstituteStrings(s, jSubstitute);
            sqlquery q = pw_PrepareCampaignQuery(s);
            SqlBindJson(q, "@group_records", jMetrics);
            SqlBindString(q, "@plugin_name", sPlugin);
            SqlBindString(q, "@schema_name", sSchema);

            SqlStep(q);
        }

        /// @note All metrics syncing is complete.  The records just sync'd need to be deleted from the
        ///     module's sqlite metrics table.
        s = r"
            DELETE FROM metrics_buffer 
            WHERE id IN (
                SELECT m.value ->> '$.id'
                FROM jsonb_each(@metrics) AS grp,
                    jsonb_each(grp.value ->> '$.metrics') AS m
            );
        ";
        q = pw_PrepareModuleQuery(s);
        SqlBindJson(q, "@metrics", jBuffer);
        SqlStep(q);
    }
}

/// @todo
void metrics_RegisterSchemas()
{
    /// @note Register core metrics schemas here.
}

