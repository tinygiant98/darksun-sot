/// ----------------------------------------------------------------------------
/// @file   pw_i_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (core).
/// ----------------------------------------------------------------------------

#include "pw_i_sql"
#include "pw_c_metrics"
#include "util_i_strings"
#include "util_i_debug"
#include "util_i_unittest"
#include "util_i_argstack"
#include "nwnx_schema"

#include "core_i_framework"

/// @todo To make this into a valid utility and genericize it, we'd need to do the following
/// 1) Modify the timer to use util_i_timers instead of core_i_framework
/// 1.1) Add a config function to do let the builder do someting when the timer expires.
/// 2) Modify the queries to be able to reference whatever non-metrics tables were already
///     in use by the module.  This could be difficult!  No idea what type of system they
///     are using and whether fks and such are used.
/// 2.1) Rename this file to util_i_metrics.
/// 3) Modify the queries to reference a generic query function, probably in util_c_metrics.

// -----------------------------------------------------------------------------
//                              System Constants
// -----------------------------------------------------------------------------

/// @note METRICS_TYPE_* constants are provided to help with accuracy in determining the
///     target type for metrics object.
const string METRICS_TYPE_PLAYER = "player";
const string METRICS_TYPE_CHARACTER = "character";
const string METRICS_TYPE_SERVER = "server";

/// @note jMetricTypes is a json object composed of the string values of each of the
///     METRICS_TYPE_* values.  The purpose of this object is to make future expansion
///     easier by allowing quick error checking for appropriate values of sType.
/// @warning If a METRICS_TYPE_* is added, ensure its string value is added to
///     jMetricsTypes.
json jMetricsTypes = JsonParse(r"
    [
        ""player"",
        ""character"",
        ""server""
    ]
");

const string METRICS_EVENT_FLUSH_ON_TIMER_EXPIRE = "METRICS_EVENT_FLUSH_ON_TIMER_EXPIRE";
const string METRICS_FLUSH_TIMER_ID = "METRICS_FLUSH_TIMER_ID";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Called only during module startup from the metrics source.  Ensures all
///     metrics-tracking tables are created in the on-disk campaign database and
///     creates the in-memory module database table used for buffering metrics data.
void metrics_CreateTables();

/// @brief Register a metrics schema to the metrics source.  Registering a metrics
///     schema allows a source to provide metrics to the metrics database and define
///     how those metrics are integrated during syncing operations.
/// @param sSource The name of the source providing the metrics schema.
/// @param sName The name of the metrics schema.
/// @param jSchema The metrics schema object.
/// @warning If a metrics schema is registered using a source/name combination that
///     already exists, the existing metrics schema will be replaced with the schema
///     contained in jData.
/// @note When creating source-defined schema, if custom data is being tracked that
///     will never be accessed by other sources and may be deleted at some point,
///     ensure unique keys are used.  Namespaces, such as <source_*> work well in
///     these cases.
void metrics_RegisterSchema(string sSource, string sName, json jSchema);

/// @brief Unregister (delete) a metrics schema.
/// @param sSource Source of the registered schema.
/// @param sName Name of the registered schema.
void metrics_UnregisterSchema(string sSource, string sName);

/// @brief Retrieve a list of schema names registered by a source.
/// @param sSource Source of the registered schemas.
/// @return A json array of strings containing the names of registered schemas.
json metrics_ViewSchemas(string sSource);

/// @brief Retrieve the definition of a specific registered schema.
/// @param sSource Source of the registered schema.
/// @param sName Name of the registered schema.
/// @return The schema definition object.
json metrics_ViewSchema(string sSource, string sName);

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

/// @private Primary debugging function for metrics system.
/// @param sFunction Name of the function generating the debug message.
/// @param sMessage Debug message.
void metrics_Debug(string sFunction, string sMessage)
{
    sFunction = HexColorString("[" + sFunction + "]", COLOR_BLUE_LIGHT);
    Debug(sFunction + " " + sMessage);
}

void metrics_Success(string sFunction, string sMessage)
{
    sMessage = HexColorString(sMessage, COLOR_GREEN_LIGHT);
    metrics_Debug(sFunction, sMessage);
}

void metrics_Fail(string sFunction, string sMessage)
{
    sMessage = HexColorString(sMessage, COLOR_RED_LIGHT);
    metrics_Debug(sFunction, sMessage);}


/// @private Determine if the metrics flush timer is valid (running).
int metrics_IsFlushTimerValid()
{
    return GetIsTimerValid(GetLocalInt(GetModule(), METRICS_FLUSH_TIMER_ID));
}

/// @private Stop and delete the metrics flush timer.
/// @param nTimerID ID of the metrics flush timer.  If not provided, the function will
///     attempt to discover the timer ID.
void metrics_DeleteFlushTimer(int nTimerID = -1)
{
    if (nTimerID < 0)
        nTimerID = GetLocalInt(GetModule(), METRICS_FLUSH_TIMER_ID);
    
    if (nTimerID > 0)
    {
        KillTimer(nTimerID);
        DeleteLocalInt(GetModule(), METRICS_FLUSH_TIMER_ID);

        metrics_Debug(__FUNCTION__, "Metrics flush timer deleted");
    }
}

/// @private Create the metrics flush timer.
/// @param fInterval Time, in seconds, between timer expirations.
void metrics_CreateFlushTimer(float fInterval = METRICS_FLUSH_INTERVAL)
{
    int nTimerID = CreateEventTimer(GetModule(), METRICS_EVENT_FLUSH_ON_TIMER_EXPIRE, fInterval);
    
    if (metrics_IsFlushTimerValid())
        metrics_DeleteFlushTimer();
    
    SetLocalInt(GetModule(), METRICS_FLUSH_TIMER_ID, nTimerID);
    StartTimer(nTimerID, FALSE);

    metrics_Debug(__FUNCTION__, "Metrics flush timer created :: Interval = " + FormatFloat(fInterval, "%!f") + "s");
}

/// @private Stop and delete the current metrics flush timer, then create a new timer
///     with the specific interval.
/// @param fInterval Time, in seconds, between timer expirations.
void metrics_SetFlushTimerInterval(float fInterval = METRICS_FLUSH_INTERVAL)
{
    metrics_DeleteFlushTimer();
    metrics_CreateFlushTimer(fInterval);
}

int metrics_GetBufferSize()
{
    string s = "SELECT COUNT(*) FROM metrics_buffer";
    sqlquery q = pw_PrepareModuleQuery(s);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

/// @private Merge a metrics group into the appropriate metrics tables for persistent
///     storage.
/// @param jGroup Metrics group object:
///     {
///         "type": "player|character|server",
///         "source": "<schema_source>",
///         "schema": "<schema_name>",
///         "metrics": [
///             {
///                 "target": "<target_id>",
///                 "data": {
///                     ...
///                 }
///             },
///             ...
///         ]
///     }
/// @warning This function should not be called directly without extensive knowledge of
///     how metrics group objects are constructed as it has no validity checks.
///     Instead, route through caller functions that build the required metrics group:
///         metrics_FlushBuffer()
///         metrics_SubmitMetric()
/// @warning @warning Absolutely do not modify the query contained in this function if
///     you do not fully understand every part of it.
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
            schema_tree AS (
                SELECT fullkey AS path, atom AS op
                FROM metrics_schema ms, json_tree(ms.metrics_schema)
                WHERE ms.source = @source AND ms.name = @schema AND atom IS NOT NULL
            ),
            data_tree AS (
                SELECT b.batch_idx, b.target_id, jt.fullkey AS path, jt.atom AS new_val
                FROM batch_inputs b, json_tree(b.metric_data) jt
                WHERE jt.atom IS NOT NULL
            ),
            updates AS (
                SELECT 
                    d.batch_idx, d.target_id, d.path, s.op, d.new_val,
                    ROW_NUMBER() OVER (PARTITION BY d.target_id ORDER BY d.batch_idx, d.path) AS seq
                FROM data_tree d
                JOIN schema_tree s ON d.path = s.path
                WHERE s.op IS NOT NULL
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
                            WHEN 'MUL' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) * u.new_val
                            WHEN 'DIV' THEN CASE WHEN u.new_val != 0 THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) / u.new_val ELSE 0 END
                            WHEN 'MOD' THEN CASE WHEN u.new_val != 0 THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) % u.new_val ELSE 0 END
                            WHEN 'MAX' THEN MAX(COALESCE(jsonb_extract(a.current_data, u.path), u.new_val), u.new_val)
                            WHEN 'MIN' THEN MIN(COALESCE(jsonb_extract(a.current_data, u.path), u.new_val), u.new_val)
                            WHEN 'KEEP' THEN COALESCE(jsonb_extract(a.current_data, u.path), u.new_val)
                            WHEN 'INCREMENT' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) + 1
                            WHEN 'DECREMENT' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) - 1
                            WHEN 'REPLACE' THEN u.new_val
                            WHEN 'AVG' THEN
                                CASE
                                    WHEN jsonb_extract(a.current_data, u.path) IS NULL THEN
                                        jsonb_object('sum', u.new_val, 'count', 1, 'value', u.new_val)
                                    ELSE
                                        jsonb_set(
                                            jsonb_set(
                                                jsonb_set(
                                                    jsonb_extract(a.current_data, u.path),
                                                    '$.sum',
                                                    COALESCE(jsonb_extract(a.current_data, u.path || '.sum'), 0) + u.new_val
                                                ),
                                                '$.count',
                                                COALESCE(jsonb_extract(a.current_data, u.path || '.count'), 0) + 1
                                            ),
                                            '$.value',
                                            (COALESCE(jsonb_extract(a.current_data, u.path || '.sum'), 0) + u.new_val) / (COALESCE(jsonb_extract(a.current_data, u.path || '.count'), 0) + 1)
                                        )
                                END
                            WHEN 'BIT_OR' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) | u.new_val
                            WHEN 'BIT_AND' THEN COALESCE(jsonb_extract(a.current_data, u.path), 0) & u.new_val
                            WHEN 'NON_ZERO' THEN CASE WHEN u.new_val != 0 THEN u.new_val ELSE jsonb_extract(a.current_data, u.path) END
                            WHEN 'CONCAT' THEN COALESCE(jsonb_extract(a.current_data, u.path), '') || u.new_val
                            WHEN 'APPEND' THEN jsonb_insert(COALESCE(jsonb_extract(a.current_data, u.path), jsonb_array()), '$[#]', u.new_val)
                            WHEN 'MERGE' THEN json_patch(COALESCE(jsonb_extract(a.current_data, u.path), jsonb_object()), u.new_val)
                            WHEN 'TOGGLE' THEN CASE WHEN COALESCE(jsonb_extract(a.current_data, u.path), 0) = 0 THEN 1 ELSE 0 END
                            WHEN 'MIN_NZ' THEN CASE WHEN COALESCE(jsonb_extract(a.current_data, u.path), 0) = 0 THEN u.new_val ELSE MIN(jsonb_extract(a.current_data, u.path), u.new_val) END
                            WHEN 'ROUND' THEN ROUND(COALESCE(jsonb_extract(a.current_data, u.path), 0), u.new_val)
                            ELSE jsonb_extract(a.current_data, u.path)
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
    ///     SqlGetJson() doesn't understand jsonb, records have to be parsed to json
    ///     first, which is a bit of a bottleneck, but it's the only non-binary
    ///     operation in the system.
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

    metrics_Debug(__FUNCTION__, "Flushing metrics from module buffer: " + IntToString(JsonGetLength(jBuffer)) + " groups found");

    if (JsonGetType(jBuffer) == JSON_TYPE_ARRAY && JsonGetLength(jBuffer) > 0)
    {
        pw_BeginTransaction();

        int n; for (; n < JsonGetLength(jBuffer); n++)
            metrics_MergeGroup(JsonArrayGet(jBuffer, n));

        pw_CommitTransaction();

        /// @note All metrics syncing is complete.  Because the records are sourced from
        ///     the module's buffer, the flushed records need to be deleted from the buffer
        ///     to prevent double-counting metrics.
        s = r"
            DELETE FROM metrics_buffer 
            WHERE id IN (
                SELECT m.value ->> '$.id'
                FROM json_each(jsonb(@buffer)) AS grp,
                    json_each(grp.value ->> '$.metrics') AS m
            );
        ";
        q = pw_PrepareModuleQuery(s);
        SqlBindJson(q, "@buffer", jBuffer);
        SqlStep(q);
    }

    if (metrics_GetBufferSize() == 0)
        metrics_DeleteFlushTimer();
}

/// @private Determine if the passed sType is valid based on its inclusion in
///     jMetricsTypes.
/// @param sType Metrics type: METRICS_TYPE_*.
int metrics_IsTypeValid(string sType)
{
    if (JsonGetType(JsonFind(jMetricsTypes, JsonString(sType))) == JSON_TYPE_NULL)
    {
        metrics_Debug(__FUNCTION__, "Invalid metrics type '" + sType + "'");
        return FALSE;
    }

    return TRUE;
}

/// @private Determine if the passed sTarget is valid for the given sType.  If sType
///     is invalid, sTarget is automatically invalid.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1).
int metrics_IsTargetValid(string sType, string sTarget)
{   
    if (!metrics_IsTypeValid(sType))
        return FALSE;

    if (sType == METRICS_TYPE_SERVER)
        return sTarget == "1";
    else
    {
        string sTable = sType;

        string s = "SELECT 1 FROM " + sTable + " WHERE " + sType + "_id = @target";
        sqlquery q = pw_PrepareCampaignQuery(s);
        SqlBindString(q, "@target", sTarget);
        if (!SqlStep(q))
        {
            metrics_Debug(__FUNCTION__, "Target '" + sTarget + "' not found in table '" + sTable + "'");
            return FALSE;
        }
        else
            return TRUE;
    }
}

/// @private Build common sqlite statement substitutions object.
/// @param sType Metrics type: METRICS_TYPE_*.
json metrics_GetSubstitutions(string sType)
{
    json jSubstitute = JsonObjectSet(JsonObject(), "metrics_table", JsonString("metrics_" + sType));
    return JsonObjectSet(jSubstitute, "target_id", JsonString(sType + "_id"));
}

/// @private Validate a metrics instance against its validation schema
/// @param jInstance Metrics instance.
/// @param sSource Schema source.
/// @param sName Schema name.
int metrics_ValidateInstance(json jInstance, string sSource, string sName)
{
    string s = r"
        SELECT
        CASE
            WHEN json_type(validation_schema, '$.$id') IS NOT NULL THEN json_extract(validation_schema, '$.$id')
            ELSE validation_schema
        END
        FROM metrics_schema
        WHERE source = @source AND name = @name;
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);
    if (!SqlStep(q))
    {
        metrics_Debug(__FUNCTION__, "No registered schema found for source '" + sSource + "' and schema '" + sName + "'");
        return FALSE;
    }

    json jResult = SqlGetJson(q, 0);
    if (JsonGetType(jResult) == JSON_TYPE_STRING)
        return JsonObjectGet(NWNX_Schema_ValidateInstanceByID(jInstance, JsonGetString(jResult)), "valid") == JSON_TRUE;
    else if (JsonGetType(jResult) == JSON_TYPE_OBJECT)
        return JsonObjectGet(NWNX_Schema_ValidateInstance(jInstance, jResult), "valid") == JSON_TRUE;

    return FALSE;
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
    if (METRICS_REQUIRE_NWNX && !NWNXGetIsAvailable())
    {
        metrics_Debug(__FUNCTION__, "NWNX is required to submit metrics");
        return;
    }

    if (!metrics_IsTargetValid(sType, sTarget))
        return;

    if (sSource == "" || sSchema == "")
    {
        metrics_Debug(__FUNCTION__, "sSource and sSchema must not be empty");
        return;
    }

    if (JsonGetType(jData) != JSON_TYPE_OBJECT)
    {
        metrics_Debug(__FUNCTION__, "jData must be a valid json object");
        return;
    }

    if (NWNXGetIsAvailable() && !metrics_ValidateInstance(jData, sSource, sSchema) == FALSE)
    {
        metrics_Debug(__FUNCTION__, "jData does not conform to the registered schema");
        return;
    }

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
///     this function directly to prevent potential errors when routing metrics to
///     the desired target.
void metrics_BufferMetric(string sType, string sTarget, string sSource, string sSchema, json jData)
{
    if (METRICS_REQUIRE_NWNX && !NWNXGetIsAvailable())
    {
        metrics_Debug(__FUNCTION__, "NWNX is required to submit metrics");
        return;
    }

    if (!metrics_IsTargetValid(sType, sTarget))
        return;

    if (sSource == "" || sSchema == "")
    {
        metrics_Debug(__FUNCTION__, "sSource and sSchema must not be empty");
        return;
    }

    if (JsonGetType(jData) != JSON_TYPE_OBJECT)
    {
        metrics_Debug(__FUNCTION__, "jData must be a valid json object");
        return;
    }

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

    if (!metrics_IsFlushTimerValid())
        metrics_CreateFlushTimer();
}

/// @private Retrieve a metric by sqlite path.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sPath SQLite path to the desired metric.
/// @note sPath should be in the form `$.path.to.key`, but this function will
///     handle missing leading `$` or `$.`.
json metrics_GetMetricByPath(string sType, string sTarget, string sPath)
{
    if (!metrics_IsTargetValid(sType, sTarget))
        return JsonNull();

    if (sPath == "")
        sPath = "$";
    else if (GetStringLeft(sPath, 1) != "$")
    {
        if (GetStringLeft(sPath, 1) == "." || GetStringLeft(sPath, 1) == "[")
            sPath = "$" + sPath;
        else
            sPath = "$." + sPath;
    }

    /// @note Some metrics store multiple values to maintain the desired metrics,
    ///     such as AVG, which stores a running total and running count to
    ///     calculate the metric.  When retrieving metrics that contains multiple
    ///     values, assume the desired metric is available in the `value` key
    ///     within the object found at sPath.
    string s = r"
        SELECT
            CASE
                WHEN json_type(jsonb_extract(data, @path)) = 'object'
                AND jsonb_extract(data, @path || '.value') IS NOT NULL
                THEN json(jsonb_extract(data, @path || '.value'))
                ELSE json(jsonb_extract(data, @path))
            END
        FROM $metrics_table
        WHERE $target_id = @target;
    ";
    s = SubstituteStrings(s, metrics_GetSubstitutions(sType));
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@path", sPath);
    SqlBindString(q, "@target", sTarget);

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

/// @private Retrieve a metric by json pointer.
/// @param sType Metrics type: METRICS_TYPE_*.
/// @param sTarget Unique ID of the target (player_id, character_id, 1)
/// @param sPointer Json pointer to the desired metric.
/// @note sPointer should be in the form `/pointer/to/key`, but this function
///     will handling missing leading `/`.
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
    if (!metrics_IsTargetValid(sType, sTarget))
        return JsonNull();

    if (sKey == "")
        return JsonNull();

    string s = r"
        SELECT
            CASE
                WHEN json_type(jsonb_extract(data, fullkey)) = 'object'
                AND jsonb_extract(data, fullkey || '.value') IS NOT NULL
                THEN json(jsonb_extract(data, fullkey || '.value'))
                ELSE json(jsonb_extract(data, fullkey))
            END
        FROM $metrics_table, json_tree($metrics_table.data)
        WHERE $target_id = @target
        AND key = @key
        AND fullkey LIKE @hint
        LIMIT 1;
    ";
    s = SubstituteStrings(s, metrics_GetSubstitutions(sType));
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
/// @warning This is an advanced-use function.  Any metrics that contain
///     multiple values, such as AVG, will return the entire object with
///     all values, not only the expected metrics.  It is the user's/plugin's
///     responsibility to ensure the retrieved values are being used or
///     displayed properly.  Displayed returned values as-is may not achieve
///     the desired result.
json metrics_GetMetricBySchema(string sType, string sTarget, json jSchema)
{
    if (!metrics_IsTargetValid(sType, sTarget))
        return JsonNull();

    if (JsonGetType(jSchema) != JSON_TYPE_OBJECT)
        return JsonNull();

    string s = r"
        WITH RECURSIVE
            source_metrics AS (
                SELECT data FROM $metrics_table 
                WHERE $target_id = @target 
                LIMIT 1
            ),
            request_paths AS (
                SELECT 
                    tree.fullkey AS path,
                    json_extract(sm.data, tree.fullkey) AS metrics_val,
                    ROW_NUMBER() OVER (ORDER BY tree.id) AS seq
                FROM json_tree(@schema) tree
                CROSS JOIN source_metrics sm
                -- FIX: Use type NOT IN ('object', 'array') to find all leaf slots
                -- This includes JSON 'null', which has a tree.type of 'null'
                WHERE tree.type NOT IN ('object', 'array')
                AND json_type(sm.data, tree.fullkey) IS NOT NULL
            ),
            populated_json AS (
                SELECT 0 AS seq, json(@schema) AS current_result
                UNION ALL
                SELECT 
                    rp.seq,
                    json_set(pj.current_result, rp.path, rp.metrics_val)
                FROM request_paths rp
                JOIN populated_json pj ON rp.seq = pj.seq + 1
            )
        SELECT current_result
        FROM populated_json
        ORDER BY seq DESC
        LIMIT 1;
    ";

    s = SubstituteStrings(s, metrics_GetSubstitutions(sType));
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
    if (!metrics_IsTargetValid(sType, sTarget))
        return JsonNull();

    if (sSource == "" || sSchema == "")
    {
        metrics_Debug(__FUNCTION__, "sSource and sSchema must not be empty.");
        return JsonNull();
    }

    string s = r"
        SELECT json(metrics_schema) 
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
    DescribeTestSuite("Metrics System POST");

    int bTimerRunning = metrics_IsFlushTimerValid();

    /// @test 1: Environment preparation.
    {
        int t = Timer();

        /// @test Test 1: Check if metrics_buffer table is empty.
        /// @note e1 = expected buffer record size
        int e1 = 0, r1;
        int t1 = Timer(); r1 = metrics_GetBufferSize(); t1 = Timer(t1);

        if (r1 > 0)
        {
            metrics_Debug(__FUNCTION__, "Flushing " + _i(r1) + " records");
            metrics_FlushBuffer(r1);
            r1 = metrics_GetBufferSize();
        }

        /// @test Test 2: Check if metrics flush timer is running.  If it is running,
        ///     note it and stop the timer for the duration of the POST.
        /// @note e2 = time running status
        int e2 = FALSE, r2;

        int t2 = Timer();
        {
            if (bTimerRunning)
            {
                metrics_DeleteFlushTimer();
                r2 = metrics_IsFlushTimerValid();
            }
            else
                r2 = bTimerRunning;
        } t2 = Timer(t2);
        t = Timer(t);

        int b, b1, b2;
        b = (b1 = r1 == e1) &
            (b2 = r2 == e2);

        if (!AssertGroup("Environment Preparation", b))
        {
            if (!Assert("Metrics Buffer Empty", b1))
                DescribeTestParameters("", _i(e1), _i(r1));
            DescribeTestTime(t1);

            if (!Assert("Metrics Flush Timer Not Running", b2))
                DescribeTestParameters("", _i(e2), _i(r2));
            DescribeTestTime(t2);
        } DescribeGroupTime(t); Outdent();
    }

    string sPlayerID = "metrics_test_player";
    string sCharID = "metrics_test_character";
    string sSource = "metrics_test";

    /// @test 2: Setup fake data.
    {
        int t = Timer();

        /// @test Test 1: Insert fake player.
        /// @note e1 = expected player record count
        int e1 = 1, r1;

        int t1 = Timer();
        {
            string s = r"
                INSERT INTO player (player_id)
                VALUES (:player_id)
                ON CONFLICT(player_id) DO NOTHING;
            ";
            sqlquery q = pw_PrepareCampaignQuery(s);
            SqlBindString(q, ":player_id", sPlayerID);
            SqlStep(q);

            s = "SELECT COUNT(*) FROM player WHERE player_id = :player_id";
            q = pw_PrepareCampaignQuery(s);
            SqlBindString(q, ":player_id", sPlayerID);
            
            if (SqlStep(q))
                r1 = SqlGetInt(q, 0);
        } t1 = Timer(t1);

        /// @test Test 2: Insert fake character.
        /// @note e2 = expected character record count
        int e2 = 1, r2;

        int t2 = Timer();
        {
            string s = r"
                INSERT INTO character (character_id, player_id, name)
                SELECT :char_id, :player_id, :name
                ON CONFLICT(character_id) DO NOTHING;
            ";
            sqlquery q = pw_PrepareCampaignQuery(s);
            SqlBindString(q, ":char_id", sCharID);
            SqlBindString(q, ":player_id", sPlayerID);
            SqlBindString(q, ":name", "Metrics Test Character");
            SqlStep(q);

            s = r"
                SELECT COUNT(*)
                FROM character
                WHERE character_id = :char_id
            ";
            q = pw_PrepareCampaignQuery(s);
            SqlBindString(q, ":char_id", sCharID);
            if (SqlStep(q))
                r2 = SqlGetInt(q, 0);
        } t2 = Timer(t2);

        t = Timer(t);

        int b, b1, b2;
        b = (b1 = r1 == e1) &
            (b2 = r2 == e2);

        if (!AssertGroup("Setup Fake Data", b))
        {
            if (!Assert("Fake Player Inserted", b1))
                DescribeTestParameters("", _i(e1), _i(r1));
            DescribeTestTime(t1);

            if (!Assert("Fake Character Inserted", b2))
                DescribeTestParameters("", _i(e2), _i(r2));
            DescribeTestTime(t2);
        } DescribeGroupTime(t); Outdent();
    }

    /// @test 3: Register schemas.
    {
        int t = Timer();

        /// @test Test 1: Register player, character, and server schemas.
        /// @note e1 = expected schema count
        int e1 = 3, r1;

        int t1 = Timer();
        {
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

            string s = r"
                SELECT COUNT(*)
                FROM metrics_schema
                WHERE source = :source
            ";
            sqlquery q = pw_PrepareCampaignQuery(s);
            SqlBindString(q, ":source", sSource);
            if (SqlStep(q))
                r1 = SqlGetInt(q, 0);
        } t1 = Timer(t1);
        t = Timer(t);

        if (!AssertGroup("Register Schemas", r1 == e1))
        {
            if (!Assert("Schemas Registered", r1 == e1))
                DescribeTestParameters("", _i(e1), _i(r1));
            DescribeTestTime(t1);
        } DescribeGroupTime(t); Outdent();
    }

    /// @test 4: Direct submission tests.
    {
        int t = Timer();

        /// @test Test 1: Player direct submission.
        /// @note e1 = expected player val1
        /// @note e2 = expected player val2
        int e1 = 15, r1;
        int e2 = 10, r2;
        int t1 = Timer();
        {
            // Player: Direct Submit (Initial: 10, 5)
            json jDataP1 = JsonParse(r" { ""test_root"": { ""val1"": 10, ""nested"": { ""val2"": 5 } } } ");
            metrics_SubmitPlayerMetric(sPlayerID, sSource, "schema_player", jDataP1);

            // Player: Direct Submit (Update: +5, MAX 10) -> Expect: 15, 10
            json jDataP2 = JsonParse(r" { ""test_root"": { ""val1"": 5, ""nested"": { ""val2"": 10 } } } ");
            metrics_SubmitPlayerMetric(sPlayerID, sSource, "schema_player", jDataP2);

            json jRes = metrics_GetPlayerMetricByPath(sPlayerID, "$.test_root.val1");
            r1 = JsonGetInt(jRes);
            
            jRes = metrics_GetPlayerMetricByPath(sPlayerID, "$.test_root.nested.val2");
            r2 = JsonGetInt(jRes);
        } t1 = Timer(t1);

        /// @test Test 2: Character direct submission.
        /// @note e3 = expected character val1
        int e3 = 10, r3;
        int t3 = Timer();
        {
            // Character: Direct Submit (Initial: 10, 5)
            json jDataC1 = JsonParse(r" { ""test_root"": { ""val1"": 10, ""nested"": { ""val2"": 5 } } } ");
            metrics_SubmitCharacterMetric(sCharID, sSource, "schema_char", jDataC1);

            json jRes = metrics_GetCharacterMetricByPath(sCharID, "$.test_root.val1");
            r3 = JsonGetInt(jRes);
        } t3 = Timer(t3);

        /// @test Test 3: Server direct submission.
        /// @note e4 = expected server val1
        int e4 = 10, r4;
        int t4 = Timer();
        {
            // Server: Direct Submit (Initial: 10, 5)
            json jDataS1 = JsonParse(r" { ""test_root"": { ""val1"": 10, ""nested"": { ""val2"": 5 } } } ");
            metrics_SubmitServerMetric(sSource, "schema_server", jDataS1);

            json jRes = metrics_GetServerMetricByPath("$.test_root.val1");
            r4 = JsonGetInt(jRes);
        } t4 = Timer(t4);
        t = Timer(t);

        int b, b1, b2, b3;
        b = (b1 = (r1 == e1) & (r2 == e2)) &
            (b2 = r3 == e3) &
            (b3 = r4 == e4);

        if (!AssertGroup("Direct Submission Tests", b))
        {
            if (!Assert("Player Direct Submission", b1))
                DescribeTestParameters("", _i(e1) + "/" + _i(e2), _i(r1) + "/" + _i(r2));
            DescribeTestTime(t1);

            if (!Assert("Character Direct Submission", b2))
                DescribeTestParameters("", _i(e3), _i(r3));
            DescribeTestTime(t3);

            if (!Assert("Server Direct Submission", b3))
                DescribeTestParameters("", _i(e4), _i(r4));
            DescribeTestTime(t4);
        } DescribeGroupTime(t); Outdent();
    }

    /// @test 5: Buffered submission tests.
    {
        int t = Timer();

        /// @test Test 1: Buffered submission and flush.
        int t1 = Timer();
        {
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

            metrics_FlushBuffer();
        } t1 = Timer(t1);

        /// @test Test 2: Verify results.
        /// @note e1 = expected player val1
        int e1 = 20, r1;

        /// @note e2 = expected character val2
        int e2 = 2, r2;

        /// @note e3 = expected server val1
        int e3 = 20, r3;

        /// @note e4 = expected player val2 (via schema)
        int e4 = 20, r4;

        /// @note e5 = expected character val1 (via registered schema)
        int e5 = 20, r5;

        int t2 = Timer();
        {
            // Test 1: GetPlayerMetricByPath (Expect 20)
            json jRes = metrics_GetPlayerMetricByPath(sPlayerID, "$.test_root.val1");
            r1 = JsonGetInt(jRes);

            // Test 2: GetCharacterMetricByPointer (Expect 2)
            jRes = metrics_GetCharacterMetricByPointer(sCharID, "/test_root/nested/val2");
            r2 = JsonGetInt(jRes);

            // Test 3: GetServerMetricByKey (Expect 20) - Searching for 'val1' in 'test_root'
            jRes = metrics_GetServerMetricByKey("val1", "test_root");
            r3 = JsonGetInt(jRes);

            // Test 4: GetPlayerMetricBySchema
            json jQuerySchema = JsonParse(r" { ""test_root"": { ""nested"": { ""val2"": null } } } ");
            jRes = metrics_GetPlayerMetricBySchema(sPlayerID, jQuerySchema);

            //r4 = JsonGetInt(JsonObjectGet(JsonObjectGet(JsonObjectGet(jRes, "test_root"), "nested"), "val2"));
            r4 = JsonGetInt(JsonPointer(jRes, "/test_root/nested/val2"));

            // Test 5: GetCharacterMetricByRegisteredSchema
            jRes = metrics_GetCharacterMetricByRegisteredSchema(sCharID, sSource, "schema_char");
            r5 = JsonGetInt(JsonPointer(jRes, "/test_root/val1"));
        } t2 = Timer(t2);
        t = Timer(t);

        int b, b1, b2, b3, b4, b5;
        b = (b1 = r1 == e1) &
            (b2 = r2 == e2) &
            (b3 = r3 == e3) &
            (b4 = r4 == e4) &
            (b5 = r5 == e5);

        if (!AssertGroup("Buffered Submission Tests", b))
        {
            if (!Assert("Player ByPath", b1))
                DescribeTestParameters("", _i(e1), _i(r1));
            
            if (!Assert("Character ByPointer", b2))
                DescribeTestParameters("", _i(e2), _i(r2));
            
            if (!Assert("Server ByKey", b3))
                DescribeTestParameters("", _i(e3), _i(r3));
            
            if (!Assert("Player BySchema", b4))
                DescribeTestParameters("", _i(e4), _i(r4));
            
            if (!Assert("Character ByRegisteredSchema", b5))
                DescribeTestParameters("", _i(e5), _i(r5));
            
            DescribeTestTime(t2);
        } DescribeGroupTime(t); Outdent();
    }

    /// @test 6: Cleanup and cascading delete check.
    {
        int t = Timer();

        /// @test Test 1: Delete player and check cascading delete.
        /// @note e1 = expected player metrics count
        int e1 = 0, r1;

        /// @note e2 = expected character metrics count
        int e2 = 0, r2;

        int t1 = Timer();
        {
            string s = "DELETE FROM player WHERE player_id = :player_id";
            sqlquery q = pw_PrepareCampaignQuery(s);
            SqlBindString(q, ":player_id", sPlayerID);
            SqlStep(q);

           s = "SELECT COUNT(*) FROM metrics_player WHERE player_id = :player_id";
           q = pw_PrepareCampaignQuery(s);
           SqlBindString(q, ":player_id", sPlayerID);
           if (SqlStep(q))
               r1 = SqlGetInt(q, 0);

           s = "SELECT COUNT(*) FROM metrics_character WHERE character_id = :char_id";
           q = pw_PrepareCampaignQuery(s);
           SqlBindString(q, ":char_id", sCharID);
           if (SqlStep(q))
               r2 = SqlGetInt(q, 0);
        } t1 = Timer(t1);

        /// @test Test 2: Clean server data.
        /// @note e3 = expected server data cleaned
        int e3 = 0, r3;

        int t2 = Timer();
        {
            string s = "UPDATE metrics_server SET data = jsonb_remove(data, '$.test_root') WHERE server_id = 1";
            pw_ExecuteCampaignQuery(s);
            
            // Verify clean
            json jRes = metrics_GetServerMetricByPath("$.test_root");
            if (JsonGetType(jRes) == JSON_TYPE_NULL)
                r3 = 0;
            else
                r3 = 1;
        } t2 = Timer(t2);

        /// @test Test 3: Unregister schemas.
        /// @note e4 = expected schema count
        int e4 = 0, r4;

        int t3 = Timer();
        {
            metrics_UnregisterSchema(sSource, "schema_player");
            metrics_UnregisterSchema(sSource, "schema_char");
            metrics_UnregisterSchema(sSource, "schema_server");

            string s = "SELECT COUNT(*) FROM metrics_schema WHERE source = @source";
            sqlquery q = pw_PrepareCampaignQuery(s);
            SqlBindString(q, "@source", sSource);
            if (SqlStep(q))
                r4 = SqlGetInt(q, 0);
        } t3 = Timer(t3);
        t = Timer(t);

        int b, b1, b2, b3, b4;
        b = (b1 = r1 == e1) &
            (b2 = r2 == e2) &
            (b3 = r3 == e3) &
            (b4 = r4 == e4);

        if (!AssertGroup("Cleanup & Cascading Delete", b))
        {
            if (!Assert("Player Metrics Deleted", b1))
                DescribeTestParameters("", _i(e1), _i(r1));
            
            if (!Assert("Character Metrics Deleted", b2))
                DescribeTestParameters("", _i(e2), _i(r2));
            DescribeTestTime(t1);

            if (!Assert("Server Data Cleaned", b3))
                DescribeTestParameters("", _i(e3), _i(r3));
            DescribeTestTime(t2);

            if (!Assert("Schemas Unregistered", b4))
                DescribeTestParameters("", _i(e4), _i(r4));
            DescribeTestTime(t3);
        } DescribeGroupTime(t); Outdent();
    }

    // Restart the flush timer
    if (bTimerRunning && !metrics_IsFlushTimerValid())
        metrics_CreateFlushTimer();
}

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

/// @private Register the metrics meta-schema to define authorized metrics
///     operations.  If a plugin attempts to use a metrics operations not defined
///     here, the instance will be rejected.
void metrics_RegisterMetaSchema()
{
    json j = JsonParse(r"
        {
            ""$id"": ""urn:darksun_sot:metrics"",
            ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
            ""type"": ""object"",
            ""patternProperties"": {
                "".*"": {
                ""anyOf"": [
                    { ""$ref"": ""#"" },
                    {
                    ""type"": ""string"",
                    ""enum"": [
                        ""ADD"", ""SUB"", ""MUL"", ""DIV"", ""MOD"",
                        ""MAX"", ""MIN"", ""KEEP"", ""INCREMENT"", ""DECREMENT"",
                        ""REPLACE"", ""AVG"", ""BIT_OR"", ""BIT_AND"", ""NON_ZERO"",
                        ""CONCAT"", ""APPEND"", ""MERGE"", ""TOGGLE"", ""MIN_NZ"", ""ROUND""
                    ]
                    }
                ]
                }
            },
            ""additionalProperties"": false
        }
    ");

    if (NWNXGetIsAvailable())
        NWNX_Schema_RegisterMetaSchema(j);
}

int metrics_ValidateSchema(json jSchema)
{
    if (!NWNXGetIsAvailable())
        return FALSE;

    json j = JsonObjectGet(jSchema, "$schema");
    if (JsonGetType(j) == JSON_TYPE_STRING && JsonGetString(j) == "")
        JsonObjectSet(jSchema, "$schema", JsonString("https://json-schema.org/draft/2020-12/schema"));

    return JsonObjectGet(NWNX_Schema_ValidateSchema(jSchema), "valid") == JSON_TRUE;
}

int metrics_ValidateInstanceByID(json jInstance, string sID = "urn:darksun_sot:metrics")
{
    if (!NWNXGetIsAvailable())
        return FALSE;

    return JsonObjectGet(NWNX_Schema_ValidateInstanceByID(jInstance, sID), "valid") == JSON_TRUE;
}

/// @private Create a validation schema from the metrics schema passed by the plugin.
///     This schema will be used to validate each instance that's passed to the metrics
///     system to ensure bad data is not being ingested into the metrics objects.
json metrics_TransformSchema(json jSchema, string sSchema = "")
{
    if (JsonGetType(jSchema) == JSON_TYPE_NULL || jSchema == JsonObject())
        return JsonNull();

    if (sSchema != "")
        sSchema = "urn:darksun_sot:metrics:" + sSchema;

    string s = r"
        WITH RECURSIVE
            raw_tree AS (
                SELECT * FROM json_tree(@schema)
                WHERE fullkey != '$'
            ),
            transformed AS (
                SELECT 
                    t.id,
                    CASE 
                        WHEN t.type NOT IN ('object', 'array') THEN
                            CASE 
                                -- Integer Ops
                                WHEN t.value IN ('BIT_OR', 'BIT_AND', 'INCREMENT', 'DECREMENT', 'MOD', 'ROUND', 'TOGGLE', 'MIN_NZ') 
                                    THEN json_object('type', 'integer')
                                -- Number Ops
                                WHEN t.value IN ('ADD', 'SUB', 'MUL', 'DIV', 'MAX', 'MIN', 'KEEP', 'REPLACE', 'AVG', 'NON_ZERO') 
                                    THEN json_object('type', 'number')
                                -- String Ops
                                WHEN t.value = 'CONCAT' 
                                    THEN json_object('type', 'string')
                                -- Collection Ops
                                WHEN t.value = 'APPEND' 
                                    THEN json_object('type', 'array', 'unevaluatedItems', json('false'))
                                WHEN t.value = 'MERGE' 
                                    THEN json_object('type', 'object', 'unevaluatedProperties', json('false'))
                                ELSE json_quote(t.value)
                            END
                        WHEN t.type = 'object' THEN
                            json_object('type', 'object', 'unevaluatedProperties', json('false'), 'minProperties', 1, 'properties', json_object())
                        WHEN t.type = 'array' THEN
                            json_object('type', 'array', 'unevaluatedItems', json('false'), 'prefixItems', json_array())
                    END AS new_value,
                    -- Handles nesting: .key -> .properties.key and [0] -> .prefixItems[0]
                    REPLACE(REPLACE(t.fullkey, '.', '.properties.'), '[', '.prefixItems[') AS schema_path,
                    ROW_NUMBER() OVER (ORDER BY t.id ASC) AS seq
                FROM raw_tree t
            ),
            schema_folded AS (
                SELECT 0 as seq, 
                    json_patch(
                        json_object(
                            '$schema', 'https://json-schema.org/draft/2020-12/schema', 
                            'type', 'object', 
                            'unevaluatedProperties', json('false'),
                            'minProperties', 1,
                            'properties', json_object()
                        ),
                        CASE WHEN @id != '' THEN json_object('$id', @id) ELSE json_object() END
                    ) AS result
                UNION ALL
                SELECT nr.seq, json_set(sf.result, nr.schema_path, json(nr.new_value))
                FROM transformed nr
                JOIN schema_folded sf ON nr.seq = sf.seq + 1
            )
        SELECT result FROM schema_folded ORDER BY seq DESC LIMIT 1;
    ";

    sqlquery q = pw_PrepareModuleQuery(s);
    SqlBindJson(q, "@schema", jSchema);
    SqlBindString(q, "@id", sSchema);

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void metrics_CreateTables()
{
    /// @brief The following tables are persistent and reside in the campaign/on-disk
    ///     persistent database.  All metrics tables are namespaced with `metrics_`.

    pw_BeginTransaction();

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
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note Cascade delete player metrics when a player record is deleted from
    ///     the module's primary player database table.
    s = r"
        CREATE TRIGGER IF NOT EXISTS trg_delete_metrics_player
        AFTER DELETE ON player
        FOR EACH ROW
        BEGIN
            DELETE FROM metrics_player WHERE player_id = OLD.player_id;
        END;
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
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note Cascade delete character metrics when a character record is deleted from
    ///     the module's primary character database table.
    s = r"
        CREATE TRIGGER IF NOT EXISTS trg_delete_metrics_character
        AFTER DELETE ON character
        FOR EACH ROW
        BEGIN
            DELETE FROM metrics_character WHERE character_id = OLD.character_id;
        END;
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
            metrics_schema BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(metrics_schema, 4)),
            validation_schema BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(validation_schema, 4)),
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

    metrics_RegisterMetaSchema();
}

void metrics_RegisterSchema(string sSource, string sName, json jSchema)
{
    if (METRICS_REQUIRE_NWNX && !NWNXGetIsAvailable())
    {
        string s = "NWNX is required for metrics schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";

        Error(s);
        return;
    }

    metrics_Debug(__FUNCTION__, "Attempting to register metrics schema: " + sSource + "." + sName);
    
    if (sSource == "" || sName == "")
    {
        string s = "Invalid source or schema name found during metrics schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  MetricsSource: " + sSource == "" ? "<empty>" : sSource;
        s+= "\n  Metrics Schema: " + sName == "" ? "<empty>" : sName;

        Error(s);
        return;
    }

    if (JsonGetType(jSchema) != JSON_TYPE_OBJECT)
    {
        string s = "Invalid schema argument found during metrics schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  jSchema: " + JsonDump(jSchema);

        Error(s);
        return;
    }

    json jTransform = metrics_TransformSchema(jSchema, sSource + ":" + sName);
    if (JsonGetType(jTransform) == JSON_TYPE_NULL)
    {
        string s = "Failed to transform schema during metrics registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  jSchema: " + JsonDump(jSchema);
        
        Error(s);
        return;
    }

    if (NWNXGetIsAvailable())
    {
        /// @note Treat the incoming schema as an instance to be validated by the
        ///     metrics metaschema.
        if (!metrics_ValidateInstanceByID(jSchema))
        {
            string s = "Schema instance does not conform to metrics meta-schema during metrics schema registration";
            s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
            s+= "\n  jSchema: " + JsonDump(jSchema);
            
            Error(s);
            return;
        }

        /// @note The transformed schema should be a valid schema as defined by
        ///     json-schema.org; validate it as a normal schema.
        if (!metrics_ValidateSchema(jTransform))
        {
            string s = "Invalid schema found during metrics schema registration";
            s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
            s+= "\n  jSchema: " + JsonDump(jSchema);
            
            Error(s);
            return;
        }
    }

    string s = r"
        INSERT INTO metrics_schema (source, name, metrics_schema, validation_schema)
        VALUES (@source, @name, jsonb(@metrics_schema), jsonb(@validation_schema));
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);
    SqlBindJson(q, "@metrics_schema", jSchema);
    SqlBindJson(q, "@validation_schema", jTransform);

    SqlStep(q);
}

void metrics_UnregisterSchema(string sSource, string sName)
{
    if (sSource == "" || sName == "")
        return;

    string s = "DELETE FROM metrics_schema WHERE source = @source AND name = @name";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);
    SqlStep(q);
}

json metrics_ListSchemas(string sSource)
{
    if (sSource == "")
        return JsonArray();

    string s = "SELECT json_group_array(name) FROM metrics_schema WHERE source = @source";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

json metrics_GetSchema(string sSource, string sName)
{
    if (sSource == "" || sName == "")
        return JsonNull();

    string s = "SELECT json(metrics_schema) FROM metrics_schema WHERE source = @source AND name = @name";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);
    
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void metrics_SubmitPlayerMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_SubmitMetric(METRICS_TYPE_PLAYER, sTarget, sSource, sSchema, jData);
}

void metrics_SubmitCharacterMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_SubmitMetric(METRICS_TYPE_CHARACTER, sTarget, sSource, sSchema, jData);
}

void metrics_SubmitServerMetric(string sSource, string sSchema, json jData)
{
    metrics_SubmitMetric(METRICS_TYPE_SERVER, "1", sSource, sSchema, jData);
}

void metrics_BufferPlayerMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_BufferMetric(METRICS_TYPE_PLAYER, sTarget, sSource, sSchema, jData);
}

void metrics_BufferCharacterMetric(string sTarget, string sSource, string sSchema, json jData)
{
    metrics_BufferMetric(METRICS_TYPE_CHARACTER, sTarget, sSource, sSchema, jData);
}

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
    return metrics_GetMetricByPath(METRICS_TYPE_SERVER, "1", sPath);
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
    return metrics_GetMetricByPointer(METRICS_TYPE_SERVER, "1", sPointer);
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
    return metrics_GetMetricByKey(METRICS_TYPE_SERVER, "1", sKey, sHint);
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
    return metrics_GetMetricBySchema(METRICS_TYPE_SERVER, "1", jSchema);
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
    return metrics_GetMetricByRegisteredSchema(METRICS_TYPE_SERVER, "1", sSource, sSchema);
}
