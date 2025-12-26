/// ----------------------------------------------------------------------------
/// @file   pw_i_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (core).
/// ----------------------------------------------------------------------------

#include "pw_i_sql"
#include "pw_c_metrics"
#include "util_i_strings"
#include "util_i_debug"
#include "util_i_strings"

#include "core_i_framework"

const string METRICS_TYPE_PLAYER = "player";
const string METRICS_TYPE_CHARACTER = "character";
const string METRICS_TYPE_SERVER = "server";

const string METRICS_EVENT_SYNC_ON_TIMER_EXPIRE = "METRICS_EVENT_SYNC_ON_TIMER_EXPIRE";
const string METRICS_SYNC_TIMER_ID = "METRICS_SYNC_TIMER_ID";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Register a metrics schema to the metrics source.  Registering a metrics
///     schema allows a source to provide metrics to the metrics database and define
///     how those metrics are integrated during syncing operations.
/// @param sSource The name of the source providing the metrics schema.
/// @param sName The name of the metrics schema.
/// @param jData The metrics schema object.
/// @warning If a metrics schema is registered using a source/name combination that
///     already exists, the existing metrics schema will be replaced with the schema
///     contained in jData.
/// @note When creating source-defined schema, if custom data is being tracked that
///     will never be accessed by other sources and may be deleted at some point,
///     ensure unique keys are used.  Namespaces, such as <source_*> work well in
///     these cases.
void metrics_RegisterSchema(string sSource, string sName, json jData);

/// @brief Convenience function for submitting player-focused metrics.
/// @param sTarget player_id of the target player.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_SubmitPlayerMetric(string sTarget, string sSource, string sSchema, json jData);

/// @brief Convenience function for submitting character-focused metrics.
/// @param sTarget character_id of the target character.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_SubmitCharacterMetric(string sTarget, string sSource, string sSchema, json jData);

/// @brief Convenience function for submitting server-focused metrics.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_SubmitServerMetric(string sSource, string sSchema, json jData);

/// @brief Convenience function for buffering player-focused metrics.
/// @param sTarget player_id of the target player.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_BufferPlayerMetric(string sTarget, string sSource, string sSchema, json jData);

/// @brief Convenience function for buffering character-focused metrics.
/// @param sTarget character_id of the target character.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_BufferCharacterMetric(string sTarget, string sSource, string sSchema, json jData);

/// @brief Convenience function for buffering server-focused metrics.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_BufferServerMetric(string sSource, string sSchema, json jData);

/// @brief Retrieve a player metric by sqlite path.
/// @param sTarget player_id of the target player.
/// @param sPath Sqlite path to the desired metric.
/// @note sPath should be in the form $.path.to.key
json metrics_GetPlayerMetricByPath(string sTarget, string sPath);

/// @brief Retrieve a character metric by sqlite path.
/// @param sTarget character_id of the target character.
/// @param sPath Sqlite path to the desired metric.
/// @note sPath should be in the form $.path.to.key
json metrics_GetCharacterMetricByPath(string sTarget, string sPath);

/// @brief Retrieve a server metric by sqlite path.
/// @param sPath Sqlite path to the desired metric.
/// @note sPath should be in the form $.path.to.key
json metrics_GetServerMetricByPath(string sPath);

/// @brief Retrieve a player metric by json pointer.
/// @param sTarget player_id of the target player.
/// @param sPointer Json pointer to the desired metric.
/// @note sPointer should be in the form /pointer/to/key
json metrics_GetPlayerMetricByPointer(string sTarget, string sPointer);

/// @brief Retrieve a character metric by json pointer.
/// @param sTarget character_id of the target character.
/// @param sPointer Json pointer to the desired metric.
/// @note sPointer should be in the form /pointer/to/key
json metrics_GetCharacterMetricByPointer(string sTarget, string sPointer);

/// @brief Retrieve a server metric by json pointer.
/// @param sPointer Json pointer to the desired metric.
/// @note sPointer should be in the form /pointer/to/key
json metrics_GetServerMetricByPointer(string sPointer);

/// @brief Retrieve a player metric by key.
/// @param sTarget player_id of the target player.
/// @param sKey Key of the desired metric.
/// @param sHint Optional hint to assist in locating the desired metric. This
///     hint should be any portion of the path to the desired key.
/// @warning If multiple metrics share the same key, which key is returned
///     is undefined.  To ensure retrieval of the desired key, provide a hint
///     or use other retrieval functions.
json metrics_GetPlayerMetricByKey(string sTarget, string sKey, string sHint = "");

/// @brief Retrieve a character metric by key.
/// @param sTarget character_id of the target character.
/// @param sKey Key of the desired metric.
/// @param sHint Optional hint to assist in locating the desired metric. This
///     hint should be any portion of the path to the desired key.
/// @warning If multiple metrics share the same key, which key is returned
///     is undefined.  To ensure retrieval of the desired key, provide a hint
///     or use other retrieval functions. 
json metrics_GetCharacterMetricByKey(string sTarget, string sKey, string sHint = "");

/// @brief Retrieve a server metric by key.
/// @param sKey Key of the desired metric.
/// @param sHint Optional hint to assist in locating the desired metric. This
///     hint should be any portion of the path to the desired key.
/// @warning If multiple metrics share the same key, which key is returned
///     is undefined.  To ensure retrieval of the desired key, provide a hint
///     or use other retrieval functions. 
json metrics_GetServerMetricByKey(string sKey, string sHint = "");

/// @brief Retrieve a player metric by schema.
/// @param sTarget player_id of the target player.
/// @param jSchema Metrics schema object.
/// @note jSchema can be any valid json object containing the keys to be retrieved.
///     All keys contained in jSchema, if found in the metrics tables, will be returned.
/// @warning The structure of jSchema must match the structure of the metrics data.
json metrics_GetPlayerMetricBySchema(string sTarget, json jSchema);

/// @brief Retrieve a character metric by schema.
/// @param sTarget character_id of the target character.
/// @param jSchema Metrics schema object.
/// @note jSchema can be any valid json object containing the keys to be retrieved.
///     All keys contained in jSchema, if found in the metrics tables, will be returned.
/// @warning The structure of jSchema must match the structure of the metrics data.
json metrics_GetCharacterMetricBySchema(string sTarget, json jSchema);

/// @brief Retrieve a server metric by schema.
/// @param jSchema Metrics schema object.
/// @note jSchema can be any valid json object containing the keys to be retrieved.
///     All keys contained in jSchema, if found in the metrics tables, will be returned.
/// @warning The structure of jSchema must match the structure of the metrics data.
json metrics_GetServerMetricBySchema(json jSchema);

/// @brief Retrieve a player metrics by registered schema.
/// @param sTarget player_id of the target player.
/// @param sSource Source of the registered schema.
/// @param sSchema Name of the registered schema.
/// @note All keys found in the registered schema will be returned if they exist in
///     the metrics tables.
json metrics_GetPlayerMetricByRegisteredSchema(string sTarget, string sSource, string sSchema);

/// @brief Retrieve a character metrics by registered schema.
/// @param sTarget character_id of the target character.
/// @param sSource Source of the registered schema.
/// @param sSchema Name of the registered schema.
/// @note All keys found in the registered schema will be returned if they exist in
///     the metrics tables.
json metrics_GetCharacterMetricByRegisteredSchema(string sTarget, string sSource, string sSchema);

/// @brief Retrieve a server metrics by registered schema.
/// @param sSource Source of the registered schema.
/// @param sSchema Name of the registered schema.
/// @note All keys found in the registered schema will be returned if they exist in
///     the metrics tables.
json metrics_GetServerMetricByRegisteredSchema(string sSource, string sSchema);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

/// @private Called only during module startup from the metrics source.  Ensures all
///     metrics-tracking tables are created in the on-disk campaign database and
///     creates the in-memory module database table used for buffering metrics data.
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
    ///     metrics are held in jsonb BLOBs and are synced from similar tables
    ///     held by the in-memory module database.
    string s = r"
        CREATE TABLE IF NOT EXISTS metrics_player (
            player_id TEXT PRIMARY KEY COLLATE NOCASE,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4)),
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (player_id) REFERENCES player(player_id)
                ON DELETE CASCADE
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `metrics_character` table holds all character metrics, which can be
    ///     defined by various plugins.  These metrics are not pre-defined.  All
    ///     metrics are held in jsonb BLOBs and are synced from similar tables
    ///     held by the in-memory module database.
    s = r"
        CREATE TABLE IF NOT EXISTS metrics_character (
            character_id TEXT PRIMARY KEY COLLATE NOCASE,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4)),
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (character_id) REFERENCES character(character_id)
                ON DELETE CASCADE
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `metrics_server` table holds all server metrics, which can be
    ///     defined by various plugins.  These metrics are not pre-defined.  All
    ///     metrics are held in jsonb BLOBs and are synced from similar tables
    ///     held by the in-memory module database.
    s = r"
        CREATE TABLE IF NOT EXISTS metrics_server (
            server_id INTEGER PRIMARY KEY CHECK (server_id = 1),
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4)),
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `metrics_schema` table holds all defined metrics schema provided by
    ///     any metrics provider.  This allows plugins to define their own metrics,
    ///     define metrics behaviors, and allow seamless syncing with previously-
    ///     existing metrics without having to build the sync architecture within each
    ///     source.
    /// @note Sources will be required to register their metric schema with the metrics
    ///     schema manager to ensure their sync behavior can be controlled reliably.

    s = r"
        CREATE TABLE IF NOT EXISTS metrics_schema (
            source TEXT NOT NULL COLLATE NOCASE,
            name TEXT NOT NULL COLLATE NOCASE,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4)),
            PRIMARY KEY (source, name) ON CONFLICT REPLACE
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
            source TEXT NOT NULL COLLATE NOCASE,
            schema TEXT NOT NULL COLLATE NOCASE,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4))
        );
    ";
    pw_ExecuteModuleQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_metrics_buffer_queue ON metrics_buffer(id ASC);
    ";
    pw_ExecuteModuleQuery(s);
    pw_CommitTransaction(GetModule());
}

/// @private Start the metrics sync timer.  Expiration of this timer will start the buffer
///     flush process.
/// @param fInterval Time, in seconds, between timer expirations.
void metrics_StartSyncTimer(float fInterval = METRICS_SYNC_INTERVAL)
{
    int nTimerID = CreateEventTimer(GetModule(), METRICS_EVENT_SYNC_ON_TIMER_EXPIRE, fInterval);
    SetLocalInt(GetModule(), METRICS_SYNC_TIMER_ID, nTimerID);
    StartTimer(nTimerID, FALSE);

    string s = "Metrics sync timer started:";
    s+= "\n  Interval: " + FormatFloat(fInterval, "%!f") + " seconds";
    s+= "\n  TimerID: " + IntToString(nTimerID);

    Debug(s);
}

/// @private Stop and delete the metrics sync timer.
/// @param nTimerID ID of the metrics sync timer.  If not provided, the function will
///     attempt to discover the timer ID.
void metrics_StopSyncTimer(int nTimerID = -1)
{
    if (nTimerID < 0)
        nTimerID = GetLocalInt(GetModule(), METRICS_SYNC_TIMER_ID);
    
    if (nTimerID > 0)
    {
        KillTimer(nTimerID);
        DeleteLocalInt(GetModule(), METRICS_SYNC_TIMER_ID);

        string s = "Metric sync timer stopped:";
        s+= "\n  TimerID: " + IntToString(nTimerID);

        Debug(s);
    }
}

/// @private Stop and delete the current metrics sync timer, then create a new timer
///     with the specific interval.
/// @param fInterval Time, in seconds, between timer expirations.
void metrics_SetSyncTimerInterval(float fInterval = METRICS_SYNC_INTERVAL)
{
    metrics_StopSyncTimer();
    metrics_StartSyncTimer(fInterval);
}

/// @private Merge a metrics group into the appropriate metrics tables for persistent
///     storage.
/// @param jGroup Metrics group object:
///     {
///         "type": "player|character|server",
///         "source": "<schema_source>",
///         "schema": "<schema_name",
///         "metrics": [
///             {
///                 "id": "<group_id",
///                 "target": "<target_id>",
///                 "metrics_key": "metrics_value"
///             },
///             ...
///         ]
///     }
/// @warning This function should not be called directly without extensive knowledge of
///     how metrics group objects are constructed as it has no validity checks.
///     Instead, route through caller functions that build the requried metrics group:
///         metrics_FlushBuffer()
///         metrics_SubmitMetric()
void metrics_MergeGroup(json jGroup)
{
    string sType = JsonGetString(JsonObjectGet(jGroup, "type"));
    string sSource = JsonGetString(JsonObjectGet(jGroup, "source"));
    string sSchema = JsonGetString(JsonObjectGet(jGroup, "schema"));
    json jMetrics = JsonObjectGet(jGroup, "metrics");

    json jSubstitute = JsonObjectSet(JsonObject(), "metrics_table", JsonString("metrics_" + sType));
    jSubstitute = JsonObjectSet(jSubstitute, "metrics_pk", JsonString(sType + "_id"));

    if (sType == METRICS_TYPE_SERVER)
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
        WITH RECURSIVE
            batch_inputs AS (
                SELECT 
                    key AS batch_idx,
                    value ->> '$.target' AS target_id,
                    jsonb(value -> '$.data') AS metric_data
                FROM json_each(jsonb(@metrics))
            ),
            updates AS (
                SELECT 
                    b.batch_idx,
                    b.target_id,
                    tree.fullkey as path,
                    jsonb_extract(ms.data, '$.""' || tree.fullkey || '""') as op,
                    tree.value as new_val,
                    ROW_NUMBER() OVER (PARTITION BY b.target_id ORDER BY b.batch_idx, tree.fullkey) AS seq
                FROM batch_inputs b
                JOIN json_tree(b.metric_data) tree ON tree.atom IS NOT NULL
                JOIN metrics_schema ms ON ms.source = @source AND ms.name = @schema
                WHERE jsonb_extract(ms.data, '$.""' || tree.fullkey || '""') IS NOT NULL
            ),
            initial_state AS (
                SELECT 
                    b.target_id,
                    COALESCE(t.data, jsonb('{}')) AS current_data
                FROM (SELECT DISTINCT target_id FROM batch_inputs) b
                JOIN $target_table tt ON b.target_id = tt.$target_id
                LEFT JOIN $metrics_table t ON tt.$target_id = t.$metrics_pk
            ),
            apply_updates(target_id, current_data, next_seq) AS (
                SELECT target_id, current_data, 1
                FROM initial_state
                UNION ALL
                SELECT 
                    a.target_id,
                    jsonb_set(
                        a.current_data, 
                        u.path, 
                        CASE u.op
                            WHEN 'ADD' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) + u.new_val
                            WHEN 'SUB' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) - u.new_val
                            WHEN 'MAX' THEN MAX(COALESCE(jsonb_extract(a.current_data, u.path), 0), u.new_val)
                            WHEN 'MIN' THEN MIN(COALESCE(jsonb_extract(a.current_data, u.path), 0), u.new_val)
                            WHEN 'KEEP' THEN COALESCE(jsonb_extract(a.current_data, u.path), u.new_val)
                            WHEN 'BIT_OR' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) | u.new_val
                            WHEN 'NON_ZERO' THEN CASE WHEN u.new_val != 0 THEN u.new_val ELSE jsonb_extract(a.current_data, u.path) END
                            WHEN 'APPEND' THEN jsonb_insert(COALESCE(jsonb_extract(a.current_data, u.path), jsonb('[]')), '$[#]', u.new_val)
                            ELSE u.new_val
                        END
                    ),
                    a.next_seq + 1
                FROM apply_updates a
                JOIN updates u ON a.target_id = u.target_id AND a.next_seq = u.seq
            )
        SELECT 
            tt.$target_id,
            final.current_data,
            CURRENT_TIMESTAMP
        FROM (
            SELECT target_id, current_data
            FROM apply_updates
            WHERE (target_id, next_seq) IN (
                SELECT target_id, MAX(next_seq) 
                FROM apply_updates 
                GROUP BY target_id
            )
        ) final
        JOIN $target_table tt ON final.target_id = tt.$target_id
        ON CONFLICT($metrics_pk) DO UPDATE SET
            data = excluded.data,
            last_updated = excluded.last_updated;
    ";
    s = SubstituteStrings(s, jSubstitute);
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindJson(q, "@metrics", jMetrics);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@schema", sSchema);

    SqlStep(q);
}

/// @private Flushes the metrics buffer in chunks to the persistent metrics tables.
/// @param nChunk Number of records to process in this flush operation.
void metrics_FlushBuffer(int nChunk = 500)
{
    /// @note Unfortunately, attaching databases is prohibited in nwn sqlite, so we
    ///     have to use nwscript as a bridge between databases.  We do this by
    ///     retrieving all the records of interest as a json array, then pushing
    ///     that json array into the campaign db sync query as a variable.  Since
    ///     SqlGetJson() doesn't understand jsonb, we have to parse it to json first,
    ///     which is a bit of a bottleneck, but it's the only non-binary operation
    ///     in the system.
    string s = r"
        WITH global_batch AS (
            SELECT id, type, target, source, schema, data
            FROM metrics_buffer
            ORDER BY id ASC
            LIMIT @limit
        ),
        grouped_data AS (
            SELECT 
                type, target, source, schema,
                jsonb_group_array(
                    jsonb_object('id', id, 'target', target, 'data', data)
                ) AS group_records
            FROM global_batch
            GROUP BY type, source, schema
        )
        SELECT json(jsonb_group_array(
            jsonb_object(
                'type', type,
                'source', source,
                'schema', schema,
                'metrics', group_records
            )
        )) 
        FROM grouped_data;
    ";
    sqlquery q = pw_PrepareModuleQuery(s);
    SqlBindInt(q, "@limit", nChunk);

    json jBuffer = SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();

    /// @note jBuffer contains the metrics dump from the module's `metrics_buffer` table
    ///     and holds no more than `nChunk` records.  These records will be flushed to
    ///     the persistent `metrics_*` tables.

    Debug("Flushing metrics from module buffer: " + IntToString(JsonGetLength(jBuffer)) + " groups found");

    if (JsonGetType(jBuffer) == JSON_TYPE_ARRAY && JsonGetLength(jBuffer) > 0)
    {
        int n; for (; n < JsonGetLength(jBuffer); n++)
            metrics_MergeGroup(JsonArrayGet(jBuffer, n))

        /// @note All metrics syncing is complete.  Because the records are sourced from
        ///     the module's buffer, the flushed records need to be deleted from the buffer
        ///     to prevent double-counting metrics.
        s = r"
            DELETE FROM metrics_buffer 
            WHERE id IN (
                SELECT m.value ->> '$.id'
                FROM json_each(jsonb(@metrics)) AS grp,
                    json_each(grp.value ->> '$.metrics') AS m
            );
        ";
        q = pw_PrepareModuleQuery(s);
        SqlBindJson(q, "@metrics", jBuffer);
        SqlStep(q);
    }
}

/// @private Allows submission of a single record directly into the persistent `metrics_*`
///     tables.  It should be rare to require immediate metrics insertion into the persistent
///     tables as this is a much heavier opertion that using the buffer flushing process.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sSource Name of the source registering the metric schema.
/// @param sSchema Name of the metric merge schema.
/// @param jData Metrics data.
void metrics_SubmitMetric(string sType, string sTarget, string sSource, string sSchema, json jData)
{
    json jGroup = JsonObjectSet(JsonObject(), "type", JsonString(sType));
    jGroup = JsonObjectSet(jGroup, "source", JsonString(sSource));
    jGroup = JsonObjectSet(jGroup, "schema", JsonString(sSchema));

    json jMetrics = JsonObjectSet(JsonObject(), "target", JsonString(sTarget));
    jMetrics = JsonObjectSet(jMetrics, "data", jData);

    jGroup = JsonObjectSet(jGroup, "metrics", JsonArrayInsert(JsonArray(), jMetrics));

    metrics_MergeGroup(jGroup);
}

/// @private Submits a metrics data point to the buffer for eventual syncing.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sSource Name of the source registering the metric.
/// @param sSchema Name of the metric merge schema.
/// @param jData Metrics data.
/// @note User should generally use a convenience function and refrain from calling
///     this function directly to prevent potentially errors when routing metrics to
///     the desired target.
void metrics_BufferMetric(string sType, string sTarget, string sSource, string sSchema, json jData)
{
    string s = r"
        INSERT INTO metrics_buffer (type, target, source, schema, data)
        VALUES (@type, @target, @source, @schema, jsonb(@data));
    ";
    
    sqlquery q = pw_PrepareModuleQuery(s);    
    SqlBindString(q, "@type", sType);
    SqlBindString(q, "@target", sTarget);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@schema", sSchema);
    SqlBindJson(q, "@data", jData);
    
    SqlStep(q);
}

/// @private Retrieve a metric by sqlite path.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sPath SQLite path to the desired metric.
/// @note sPath should be in the form $.path.to.key, but this function will
///     handle missing leading $ or $.
json metrics_GetMetricByPath(string sType, string sTarget, string sPath)
{
    if (sPath == "")
        sPath = "$";
    else if (GetStringLeft(sPath, 1) != "$")
    {
        if (GetStringLeft(sPath, 1) == "." || GetStringLeft(sPath, 1) == "[")
            sPath = "$" + sPath;
        else
            sPath = "$." + sPath;
    }

    json jSubstitute = JsonObjectSet(JsonObject(), "metrics_table", JsonString("metrics_" + sType));
    jSubstitute = JsonObjectSet(jSubstitute, "target_id", JsonString(sType + "_id"));

    if (sType == METRICS_TYPE_SERVER)
        sTarget = "1";

    string s = r"
        SELECT json(jsonb_extract(data, @path)) 
        FROM $metrics_table WHERE $target_id = @target;
    ";
    s = SubstituteStrings(s, jSubstitute);
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@path", sPath);
    SqlBindString(q, "@target", sTarget);

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

/// @private Retrieve a metric by json pointer.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sPointer Json pointer to the desired metric.
/// @note sPointer should be in the form /pointer/to/key, but this function
///     will handling missing leading /.
json metrics_GetMetricByPointer(string sType, string sTarget, string sPointer)
{
    if (sPointer == "")
        sPointer = "$";

    string sPath = SubstituteSubStrings(sPointer, "/", ".");
    return metrics_GetMetricByPath(sType, sTarget, sPath);
}

/// @private Retrieve a metric by key.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sKey Key of the desired metric.
/// @param sHint Optional hint to assist in locating the desired metric. This
///     hint should be any portion of the path to the desired key.
json metrics_GetMetricByKey(string sType, string sTarget, string sKey, string sHint = "")
{
    if (sKey == "")
        return JsonNull();

    json jSubstitute = JsonObjectSet(JsonObject(), "metrics_table", JsonString("metrics_" + sType));
    jSubstitute = JsonObjectSet(jSubstitute, "target_id", JsonString(sType + "_id"));

    if (sType == METRICS_TYPE_SERVER)
        sTarget = "1";

    string s = r"
        SELECT json(jsonb_extract(data, fullkey)) 
        FROM $metrics_table, json_tree($metrics_table.data) 
        WHERE $target_id = @target 
            AND key = @key 
            AND fullkey LIKE @hint
        LIMIT 1;
    ";
    s = SubstituteStrings(s, jSubstitute);
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@target", sTarget);
    SqlBindString(q, "@key", sKey);
    SqlBindString(q, "@hint", "%" + sHint + "%");

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

/// @private Retrieve a metric by schema.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param jSchema Metrics schema object.
json metrics_GetMetricBySchema(string sType, string sTarget, json jSchema)
{
    if (JsonGetType(jSchema) != JSONT_TYPE_OBJECT)
        return JsonNull();

    json jSubstitute = JsonObjectSet(JsonObject(), "metrics_table", JsonString("metrics_" + sType));
    jSubstitute = JsonObjectSet(jSubstitute, "target_id", JsonString(sType + "_id"));

    if (sType == METRICS_TYPE_SERVER)
        sTarget = "1";

    string s = r"
        WITH RECURSIVE
            target_data AS (
                SELECT data 
                FROM $metrics_table 
                WHERE $target_id = @target
            ),
            updates AS (
                SELECT 
                    tree.fullkey AS path,
                    jsonb_extract(td.data, tree.fullkey) AS new_val,
                    ROW_NUMBER() OVER (ORDER BY tree.fullkey) AS seq
                FROM json_tree(jsonb(@schema)) tree
                JOIN target_data td
                WHERE tree.atom IS NOT NULL 
                  AND jsonb_extract(td.data, tree.fullkey) IS NOT NULL
            ),
            apply_updates(current_data, next_seq) AS (
                SELECT jsonb(@schema), 1
                UNION ALL
                SELECT 
                    jsonb_set(a.current_data, u.path, u.new_val),
                    a.next_seq + 1
                FROM apply_updates a
                JOIN updates u ON a.next_seq = u.seq
            )
        SELECT json(current_data)
        FROM apply_updates
        ORDER BY next_seq DESC
        LIMIT 1;
    ";
    s = SubstituteStrings(s, jSubstitute);
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@target", sTarget);
    SqlBindJson(q, "@schema", jSchema);

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

/// @private Retrieve a metric by registered schema.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sSource Source of the registered schema.
/// @param sSchema Name of the registered schema.
json metrics_GetMetricByRegisteredSchema(string sType, string sTarget, string sSource, string sSchema)
{
    string s = r"
        SELECT json(data) 
        FROM metrics_schema 
        WHERE source = @source
            AND name = @name;
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sSchema);

    return SqlStep(q) ? metrics_GetMetricBySchema(sType, sTarget, SqlGetJson(q, 0)) : JsonNull();
}

/// @private POST for the metrics system.  This function will run through the major functionality
///     of the metrics system and ensure it is working correctly.  This include testing direction
///     metric insertion, buffer flush, and metric retrieval by all methods.
/// @note This function should be called during the module's OnModulePOST, or similar, event.
void metrics_POST()
{
    Debug("==================================================================");
    Debug("  METRICS SYSTEM POWER-ON SELF-TEST (POST) INITIATED");
    Debug("==================================================================");

    // -------------------------------------------------------------------------
    // 0. Environment Check
    // -------------------------------------------------------------------------
    // If the system is currently processing metrics (buffer not empty), we skip
    // the test to prevent interference with live data and to ensure a clean
    // test environment.
    if (SqlStep(pw_PrepareModuleQuery("SELECT 1 FROM metrics_buffer LIMIT 1")))
    {
        Debug("[POST] ABORTING: Metrics buffer contains pending data. Please ensure the buffer is empty before running POST.");
        return;
    }

    // Stop the sync timer to prevent automatic flushing during the test
    metrics_StopSyncTimer();

    // -------------------------------------------------------------------------
    // 1. Setup Fake Data
    // -------------------------------------------------------------------------
    string sPlayerID = "metrics_test_player";
    string sCharID = "metrics_test_character";
    string sSource = "metrics_test";

    Debug("[POST] Creating temporary player and character data...");
    
    // Insert Fake Player
    string s = r"
        INSERT INTO player (player_id) VALUES (@player_id)
        ON CONFLICT(player_id) DO NOTHING;
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@player_id", sPlayerID);
    SqlStep(q);

    // Insert Fake Character
    s = r"
        INSERT INTO character (character_id, player_id) VALUES (@char_id, @player_id)
        ON CONFLICT(character_id) DO NOTHING;
    ";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@char_id", sCharID);
    SqlBindString(q, "@player_id", sPlayerID);
    SqlStep(q);

    // -------------------------------------------------------------------------
    // 2. Register Schemas
    // -------------------------------------------------------------------------
    Debug("[POST] Registering test schemas...");

    // Player Schema: ADD for val1, MAX for val2
    json jSchemaP = JsonParse(r"
        {
            ""test_root"": {
                ""val1"": ""ADD"",
                ""nested"": { ""val2"": ""MAX"" }
            }
        }
    ");
    metrics_RegisterSchema(sSource, "schema_player", jSchemaP);

    // Character Schema: ADD for val1, MIN for val2
    json jSchemaC = JsonParse(r"
        {
            ""test_root"": {
                ""val1"": ""ADD"",
                ""nested"": { ""val2"": ""MIN"" }
            }
        }
    ");
    metrics_RegisterSchema(sSource, "schema_char", jSchemaC);

    // Server Schema: ADD for val1, KEEP for val2
    json jSchemaS = JsonParse(r"
        {
            ""test_root"": {
                ""val1"": ""ADD"",
                ""nested"": { ""val2"": ""KEEP"" }
            }
        }
    ");
    metrics_RegisterSchema(sSource, "schema_server", jSchemaS);

    // -------------------------------------------------------------------------
    // 3. Phase 1: Direct Submission Tests
    // -------------------------------------------------------------------------
    Debug("[POST] Phase 1: Direct Submission Tests...");
    int nErrors;

    // Player: Direct Submit (Initial: 10, 5)
    json jDataP1 = JsonParse(r" { ""test_root"": { ""val1"": 10, ""nested"": { ""val2"": 5 } } } ");
    metrics_SubmitPlayerMetric(sPlayerID, sSource, "schema_player", jDataP1);

    // Player: Direct Submit (Update: +5, MAX 10) -> Expect: 15, 10
    json jDataP2 = JsonParse(r" { ""test_root"": { ""val1"": 5, ""nested"": { ""val2"": 10 } } } ");
    metrics_SubmitPlayerMetric(sPlayerID, sSource, "schema_player", jDataP2);

    // Verify Player Direct
    json jRes = metrics_GetPlayerMetricByPath(sPlayerID, "$.test_root.val1");
    if (JsonGetInt(jRes) != 15) { Debug("[FAIL] Phase 1 Player val1: Expected 15, got " + JsonDump(jRes)); nErrors++; }
    
    jRes = metrics_GetPlayerMetricByPath(sPlayerID, "$.test_root.nested.val2");
    if (JsonGetInt(jRes) != 10) { Debug("[FAIL] Phase 1 Player val2: Expected 10, got " + JsonDump(jRes)); nErrors++; }

    // Character: Direct Submit (Initial: 10, 5)
    json jDataC1 = JsonParse(r" { ""test_root"": { ""val1"": 10, ""nested"": { ""val2"": 5 } } } ");
    metrics_SubmitCharacterMetric(sCharID, sSource, "schema_char", jDataC1);

    // Verify Character Direct
    jRes = metrics_GetCharacterMetricByPath(sCharID, "$.test_root.val1");
    if (JsonGetInt(jRes) != 10) { Debug("[FAIL] Phase 1 Character val1: Expected 10, got " + JsonDump(jRes)); nErrors++; }

    // Server: Direct Submit (Initial: 10, 5)
    json jDataS1 = JsonParse(r" { ""test_root"": { ""val1"": 10, ""nested"": { ""val2"": 5 } } } ");
    metrics_SubmitServerMetric(sSource, "schema_server", jDataS1);

    // Verify Server Direct
    jRes = metrics_GetServerMetricByPath("$.test_root.val1");
    if (JsonGetInt(jRes) != 10) { Debug("[FAIL] Phase 1 Server val1: Expected 10, got " + JsonDump(jRes)); nErrors++; }

    if (nErrors == 0) Debug("[PASS] Phase 1: Direct Submission Tests Passed");

    // -------------------------------------------------------------------------
    // 4. Phase 2: Buffered Submission Tests
    // -------------------------------------------------------------------------
    Debug("[POST] Phase 2: Buffered Submission Tests...");

    // Player: Buffered Submit (Update: +5, MAX 20) -> Expect: 20, 20
    json jDataP3 = JsonParse(r" { ""test_root"": { ""val1"": 5, ""nested"": { ""val2"": 20 } } } ");
    metrics_BufferPlayerMetric(sPlayerID, sSource, "schema_player", jDataP3);

    // Character: Buffered Submit (Update: +5, MIN 2) -> Expect: 15, 2
    json jDataC2 = JsonParse(r" { ""test_root"": { ""val1"": 5, ""nested"": { ""val2"": 2 } } } ");
    metrics_BufferCharacterMetric(sCharID, sSource, "schema_char", jDataC2);

    // Character: Buffered Submit (Update: +5, MIN 8) -> Expect: 20, 2
    json jDataC3 = JsonParse(r" { ""test_root"": { ""val1"": 5, ""nested"": { ""val2"": 8 } } } ");
    metrics_BufferCharacterMetric(sCharID, sSource, "schema_char", jDataC3);

    // Server: Buffered Submit (Update: +5, KEEP 99) -> Expect: 15, 5 (KEEP keeps existing 5)
    json jDataS2 = JsonParse(r" { ""test_root"": { ""val1"": 5, ""nested"": { ""val2"": 99 } } } ");
    metrics_BufferServerMetric(sSource, "schema_server", jDataS2);

    // Server: Buffered Submit (Update: +5, KEEP 100) -> Expect: 20, 5
    json jDataS3 = JsonParse(r" { ""test_root"": { ""val1"": 5, ""nested"": { ""val2"": 100 } } } ");
    metrics_BufferServerMetric(sSource, "schema_server", jDataS3);

    Debug("[POST] Flushing buffer...");
    metrics_FlushBuffer();

    // Verify Results (Retrieval)
    Debug("[POST] Verifying Phase 2 results...");

    // Test 1: GetPlayerMetricByPath (Expect 20)
    jRes = metrics_GetPlayerMetricByPath(sPlayerID, "$.test_root.val1");
    if (JsonGetInt(jRes) != 20) { Debug("[FAIL] Player ByPath: Expected 20, got " + JsonDump(jRes)); nErrors++; }
    else Debug("[PASS] Player ByPath");

    // Test 2: GetCharacterMetricByPointer (Expect 2)
    jRes = metrics_GetCharacterMetricByPointer(sCharID, "/test_root/nested/val2");
    if (JsonGetInt(jRes) != 2) { Debug("[FAIL] Character ByPointer: Expected 2, got " + JsonDump(jRes)); nErrors++; }
    else Debug("[PASS] Character ByPointer");

    // Test 3: GetServerMetricByKey (Expect 20) - Searching for 'val1' in 'test_root'
    jRes = metrics_GetServerMetricByKey("val1", "test_root");
    if (JsonGetInt(jRes) != 20) { Debug("[FAIL] Server ByKey: Expected 20, got " + JsonDump(jRes)); nErrors++; }
    else Debug("[PASS] Server ByKey");

    // Test 4: GetPlayerMetricBySchema
    // We ask for the structure, expect it filled with data
    json jQuerySchema = JsonParse(r" { ""test_root"": { ""nested"": { ""val2"": null } } } ");
    jRes = metrics_GetPlayerMetricBySchema(sPlayerID, jQuerySchema);
    int nVal = JsonGetInt(JsonObjectGet(JsonObjectGet(JsonObjectGet(jRes, "test_root"), "nested"), "val2"));
    if (nVal != 20) { Debug("[FAIL] Player BySchema: Expected 20, got " + IntToString(nVal)); nErrors++; }
    else Debug("[PASS] Player BySchema");

    // Test 5: GetCharacterMetricByRegisteredSchema
    // Should return flat object with all keys
    jRes = metrics_GetCharacterMetricByRegisteredSchema(sCharID, sSource, "schema_char");
    // The registered schema is flat, so the result should be flat keys like "$.test_root.val1"
    int nVal1 = JsonGetInt(JsonObjectGet(jRes, "$.test_root.val1"));
    if (nVal1 != 20) { Debug("[FAIL] Character ByRegisteredSchema: Expected 20, got " + IntToString(nVal1)); nErrors++; }
    else Debug("[PASS] Character ByRegisteredSchema");

    // -------------------------------------------------------------------------
    // 5. Cleanup & Cascading Delete Check
    // -------------------------------------------------------------------------
    Debug("[POST] Cleaning up...");

    // Delete Player (Should cascade to Character and Metrics)
    s = "DELETE FROM player WHERE player_id = @player_id";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@player_id", sPlayerID);
    SqlStep(q);

    // Verify Deletion
    s = "SELECT COUNT(*) FROM metrics_player WHERE player_id = @player_id";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@player_id", sPlayerID);
    if (SqlStep(q) && SqlGetInt(q, 0) > 0) { Debug("[FAIL] Cascading delete failed for Player Metrics"); nErrors++; }
    else Debug("[PASS] Player Metrics Deleted");

    s = "SELECT COUNT(*) FROM metrics_character WHERE character_id = @char_id";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@char_id", sCharID);
    if (SqlStep(q) && SqlGetInt(q, 0) > 0) { Debug("[FAIL] Cascading delete failed for Character Metrics"); nErrors++; }
    else Debug("[PASS] Character Metrics Deleted");

    // Clean Server Data (Remove test_root key)
    s = "UPDATE metrics_server SET data = jsonb_remove(data, '$.test_root') WHERE server_id = 1";
    pw_ExecuteCampaignQuery(s);
    Debug("[PASS] Server Data Cleaned");

    // Clean Schemas
    s = "DELETE FROM metrics_schema WHERE source = @source";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlStep(q);
    Debug("[PASS] Schemas Cleaned");

    // Restart the sync timer
    metrics_StartSyncTimer();

    Debug("==================================================================");
    if (nErrors > 0)
        Debug("  POST COMPLETED WITH " + IntToString(nErrors) + " ERRORS");
    else
        Debug("  POST COMPLETED SUCCESSFULLY");
    Debug("==================================================================");
}

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

void metrics_RegisterSchema(string sSource, string sName, json jData)
{
    Debug("Attempting to register metrics schema: " + sSource + "." + sName);
    
    if (sSource == "" || sName == "")
    {
        string s = "Invalid source or schema name found during metrics schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  MetricsSource: " + sSource == "" ? "<empty>" : sSource;
        s+= "\n  Metrics Schema: " + sName == "" ? "<empty>" : sName;

        Error(s);
        return;
    }

    if (JsonGetType(jData) != JSON_TYPE_OBJECT)
    {
        string s = "Invalid schema data object type found during metrics schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";

        Error(s);
        return;
    }

    string s = r"
        INSERT INTO metrics_schema (source, name, data)
        SELECT @source, @name, 
            (SELECT jsonb_group_object(fullkey, value) 
             FROM json_tree(jsonb(@data)) 
             WHERE atom IS NOT NULL);
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);
    SqlBindJson(q, "@data", jData);

    SqlStep(q);
}

/// @brief Convenience function for submitting player-focused metrics.
/// @param sTarget player_id of the target player.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_SubmitPlayerMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_SubmitMetric(METRICS_TYPE_PLAYER, sTarget, sSource, sSchema, jData);
}

/// @brief Convenience function for submitting character-focused metrics.
/// @param sTarget character_id of the target character.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_SubmitCharacterMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_SubmitMetric(METRICS_TYPE_CHARACTER, sTarget, sSource, sSchema, jData);
}

/// @brief Convenience function for submitting server-focused metrics.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_SubmitServerMetric(string sSource, string sSchema, json jData)
{
    metrics_SubmitMetric(METRICS_TYPE_SERVER, "1", sSource, sSchema, jData);
}

/// @brief Convenience function for buffering player-focused metrics.
/// @param sTarget player_id of the target player.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_BufferPlayerMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_BufferMetric(METRICS_TYPE_PLAYER, sTarget, sSource, sSchema, jData);
}

/// @brief Convenience function for buffering character-focused metrics.
/// @param sTarget character_id of the target character.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_BufferCharacterMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_BufferMetric(METRICS_TYPE_CHARACTER, sTarget, sSource, sSchema, jData);
}

/// @brief Convenience function for buffering server-focused metrics.
/// @param sSource Source of the metric schema.
/// @param sSchema Name of the metric schema.
/// @param jData Metrics data.
void metrics_BufferServerMetric(string sSource, string sSchema, json jData)
{
    metrics_BufferMetric(METRICS_TYPE_SERVER, "1", sSource, sSchema, jData);
}

json metrics_GetPlayerMetricByPath(string sTarget, string sPath)
{
    return metrics_GetMetricByPath(METRICS_TYPE_PLAYER, sTarget, sPath);
}

json metrics_GetCharacterMetricByPath(string sTarget, string sPath)
{
    return metrics_GetMetricByPath(METRICS_TYPE_CHARACTER, sTarget, sPath);
}

json metrics_GetServerMetricByPath(string sPath)
{
    return metrics_GetMetricByPath(METRICS_TYPE_SERVER, "", sPath);
}

json metrics_GetPlayerMetricByPointer(string sTarget, string sPointer)
{
    return metrics_GetMetricByPointer(METRICS_TYPE_PLAYER, sTarget, sPointer);
}

json metrics_GetCharacterMetricByPointer(string sTarget, string sPointer)
{
    return metrics_GetMetricByPointer(METRICS_TYPE_CHARACTER, sTarget, sPointer);
}

json metrics_GetServerMetricByPointer(string sPointer)
{
    return metrics_GetMetricByPointer(METRICS_TYPE_SERVER, "", sPointer);
}

json metrics_GetPlayerMetricByKey(string sTarget, string sKey, string sHint = "")
{
    return metrics_GetMetricByKey(METRICS_TYPE_PLAYER, sTarget, sKey, sHint);
}

json metrics_GetCharacterMetricByKey(string sTarget, string sKey, string sHint = "")
{
    return metrics_GetMetricByKey(METRICS_TYPE_CHARACTER, sTarget, sKey, sHint);
}

json metrics_GetServerMetricByKey(string sKey, string sHint = "")
{
    return metrics_GetMetricByKey(METRICS_TYPE_SERVER, "", sKey, sHint);
}

json metrics_GetPlayerMetricBySchema(string sTarget, json jSchema)
{
    return metrics_GetMetricBySchema(METRICS_TYPE_PLAYER, sTarget, jSchema);
}

json metrics_GetCharacterMetricBySchema(string sTarget, json jSchema)
{
    return metrics_GetMetricBySchema(METRICS_TYPE_CHARACTER, sTarget, jSchema);
}

json metrics_GetServerMetricBySchema(json jSchema)
{
    return metrics_GetMetricBySchema(METRICS_TYPE_SERVER, "", jSchema);
}

json metrics_GetPlayerMetricByRegisteredSchema(string sTarget, string sSource, string sSchema)
{
    return metrics_GetMetricByRegisteredSchema(METRICS_TYPE_PLAYER, sTarget, sSource, sSchema);
}

json metrics_GetCharacterMetricByRegisteredSchema(string sTarget, string sSource, string sSchema)
{
    return metrics_GetMetricByRegisteredSchema(METRICS_TYPE_CHARACTER, sTarget, sSource, sSchema);
}

json metrics_GetServerMetricByRegisteredSchema(string sSource, string sSchema)
{
    return metrics_GetMetricByRegisteredSchema(METRICS_TYPE_SERVER, "", sSource, sSchema);
}
