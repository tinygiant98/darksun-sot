/// ----------------------------------------------------------------------------
/// @file   pw_i_audit.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Audit System (core).
/// ----------------------------------------------------------------------------

#include "pw_c_audit"
#include "pw_i_sql"
#include "util_i_strings"
#include "util_i_debug"

#include "core_i_framework"

// -----------------------------------------------------------------------------
//                              System Constants
// -----------------------------------------------------------------------------

/// @note AUDIT_TYPE_* constants are provided to help with accuracy in determining the
///     target type for audit records.
const string AUDIT_TYPE_BUFFER = "buffer";
const string AUDIT_TYPE_TRAIL = "trail";

/// @note jAuditTypes is a json object composed of the string values of each of the
///     AUDIT_TYPE_* values.  The purpose of this object is to make future expansion
///     easier by allowing quick error checking for appropriate values of sType.
/// @warning If a AUDIT_TYPE_* is added, ensure its string value is added to
///     jAuditTypes.
json jAuditTypes = JsonParse(r"
    [
        ""buffer"",
        ""trail""
    ]
");

const string AUDIT_EVENT_FLUSH_ON_TIMER_EXPIRE = "AUDIT_EVENT_FLUSH_ON_TIMER_EXPIRE";
const string AUDIT_FLUSH_TIMER_ID = "AUDIT_FLUSH_TIMER_ID";

// -----------------------------------------------------------------------------
//                       Public Function Prototypes
// -----------------------------------------------------------------------------

void audit_CreateTables();

/// @brief Create a standard audit data object with the minimum required fields.
/// @param sEventType The high-level category or specific code for the event.
/// @param oActor The entity performing the action.
/// @param oTarget The entity being acted upon.
/// @param sSource The system or plugin originating the audit.
/// @returns A JSON object containing the base audit data.
json audit_CreateData(string sEventType, object oActor, object oTarget = OBJECT_INVALID, string sSource = "");

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
void audit_RegisterSchema(string sSource, string sName, json jData);

/// @brief Unregister (delete) a metrics schema.
/// @param sSource Source of the registered schema.
/// @param sName Name of the registered schema.
void audit_UnregisterSchema(string sSource, string sName);

/// @brief Retrieve a list of schema names registered by a source.
/// @param sSource Source of the registered schemas.
/// @return A json array of strings containing the names of registered schemas.
json audit_ViewSchemas(string sSource);

/// @brief Retrieve the definition of a specific registered schema.
/// @param sSource Source of the registered schema.
/// @param sName Name of the registered schema.
/// @return The schema definition object.
json audit_ViewSchema(string sSource, string sName);

/// @brief Allows submission of a single record directly into the persistent `audit_trail`
///     table.  It should be rare to require immediate audit insertion into the persistent
///     tables as this is a much heavier opertion that using the buffer flushing process.
/// @param jData Audit record.
void audit_SubmitRecord(json jData);

/// @brief Submits an audit record to the buffer for eventual syncing.
/// @param jData Audit record.
void audit_BufferRecord(json jData);

// -----------------------------------------------------------------------------
//                          Private Function Definitions
// -----------------------------------------------------------------------------

/// @private Start the audit flush timer.  Expiration of this timer will start the buffer
///     flush process.
/// @param fInterval Time, in seconds, between timer expirations.
void audit_StartFlushTimer(float fInterval = AUDIT_FLUSH_INTERVAL)
{
    int nTimerID = CreateEventTimer(GetModule(), AUDIT_EVENT_FLUSH_ON_TIMER_EXPIRE, fInterval);
    SetLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID, nTimerID);
    StartTimer(nTimerID, FALSE);

    string s = "Audit flush timer started:";
    s+= "\n  Interval: " + FormatFloat(fInterval, "%!f") + " seconds";
    s+= "\n  TimerID: " + IntToString(nTimerID);

    Debug(s);
}

/// @private Stop and delete the audit flush timer.
/// @param nTimerID ID of the audit flush timer.  If not provided, the function will
///     attempt to discover the timer ID.
void audit_StopFlushTimer(int nTimerID = -1)
{
    if (nTimerID < 0)
        nTimerID = GetLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID);
    
    if (nTimerID > 0)
    {
        KillTimer(nTimerID);
        DeleteLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID);

        string s = "Audit flush timer stopped:";
        s+= "\n  TimerID: " + IntToString(nTimerID);

        Debug(s);
    }
}

/// @private Stop and delete the current audit flush timer, then create a new timer
///     with the specific interval.
/// @param fInterval Time, in seconds, between timer expirations.
void audit_SetFlushTimerInterval(float fInterval = AUDIT_FLUSH_INTERVAL)
{
    audit_StopFlushTimer();
    audit_StartFlushTimer(fInterval);
}

/// @private Determine if the audit flush timer is valid (running).
int audit_IsFlushTimerValid()
{
    return GetIsTimerValid(GetLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID));
}

int audit_GetBufferSize()
{
    string s = "SELECT COUNT(*) FROM audit_buffer";
    sqlquery q = pw_PrepareModuleQuery(s);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

/// @private Flushes the audit buffer in chunks to the persistent audit tables.
/// @param nChunk Number of records to process in this flush operation.
void audit_FlushBuffer(int nChunk = AUDIT_FLUSH_CHUNK_SIZE)
{
    /// @note Unfortunately, attaching databases is prohibited in nwn sqlite, so we
    ///     have to use nwscript as a bridge between databases.  We do this by
    ///     retrieving all the records of interest as a json array, then pushing
    ///     that json array into the campaign db sync query as a variable.  Since
    ///     SqlGetJson() doesn't understand jsonb, we have to parse it to json first,
    ///     which is a bit of a bottleneck, but it's the only non-binary operation
    ///     in the system.
    string s = r"
        SELECT json(jsonb_group_array(
            jsonb_object('id', id, 'data', data)
        )) 
        FROM (
            SELECT id, data FROM audit_buffer 
            ORDER BY id ASC 
            LIMIT @limit
        ) AS batch;
    ";
    sqlquery q = pw_PrepareModuleQuery(s);
    SqlBindInt(q, "@limit", nChunk);

    json jBuffer = SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();

    /// @note jBuffer contains the audit dump from the module's `audit_buffer` table
    ///     and holds no more than `nChunk` records.  These records will be flushed to
    ///     the persistent `audit_*` tables.

    Debug("Flushing audit records from module buffer: " + IntToString(JsonGetLength(jBuffer)) + " records found");

    if (JsonGetType(jBuffer) == JSON_TYPE_ARRAY && JsonGetLength(jBuffer) > 0)
    {
        string s = r"
            INSERT INTO audit_trail (data)
            SELECT 
                jsonb_extract(value, '$.data')
            FROM json_each(@buffer);
        ";
        sqlquery q = pw_PrepareCampaignQuery(s);
        SqlBindJson(q, "@buffer", jBuffer);
        
        if (SqlStep(q))
        {
            string s = r"
                DELETE FROM audit_buffer 
                WHERE id IN (
                    SELECT jsonb_extract(value, '$.id') FROM json_each(@buffer)
                );
            ";
            sqlquery q = pw_PrepareModuleQuery(s);
            SqlBindJson(q, "@buffer", jBuffer);
            SqlStep(q);
        }
    }
}

/// @private Determine if the passed sType is valid based on its inclusion in
///     jAuditTypes.
/// @param sType Audit type: AUDIT_TYPE_*.
int audit_IsTypeValid(string sType)
{
    if (JsonGetType(JsonFind(jAuditTypes, JsonString(sType))) == JSON_TYPE_NULL)
    {
        Debug(__FUNCTION__ + ": Invalid audit type '" + sType + "'");
        return FALSE;
    }

    return TRUE;
}

/// @private Allows submission of a single record directly into either the in-memory
///     buffer or on-disk table, depending on the value of sType.
/// @param sType Audit type: AUDIT_TYPE_*.
/// @param jData Audit record.
void audit_InsertRecord(string sType, json jData)
{
    if (!audit_IsTypeValid(sType))
        return;

    if (JsonGetType(jData) != JSON_TYPE_OBJECT)
    {
        Debug(__FUNCTION__ + ": jData must be a valid json object.");
        return;
    }

    json jSubstitute = JsonObjectSet(JsonObject(), "audit_table", JsonString(sType));

    string s = r"
        INSERT INTO audit_$audit_table (data)
        VALUES (
            jsonb_set(jsonb(@data), 
            '$.created_at', CAST(strftime('%s', 'now') AS INTEGER)));
    ";
    s = SubstituteStrings(s, jSubstitute);

    sqlquery q;
    if (sType == AUDIT_TYPE_BUFFER)
        q = pw_PrepareModuleQuery(s);
    else if (sType == AUDIT_TYPE_TRAIL)
        q = pw_PrepareCampaignQuery(s);
    else
    {
        Debug(__FUNCTION__ + ": Invalid audit target '" + sType + "'");
        return;
    }

    SqlBindJson(q, "@data", jData);
    SqlStep(q);
}

void audit_POST()
{
    Debug("==================================================================");
    Debug("  AUDIT SYSTEM POWER-ON SELF-TEST (POST) INITIATED");
    Debug("==================================================================");

    // 0. Environment Check
    if (audit_GetBufferSize() > 0)
    {
        Debug("[POST] ABORTING: Audit buffer contains pending data.");
        return;
    }

    audit_StopFlushTimer();

    string sSource = "audit_test_source";
    string sEventType = "AUDIT_TEST_EVENT";
    int nErrors = 0;

    // 1. Phase 1: Direct Submission
    Debug("[POST] Phase 1: Direct Submission Tests...");
    
    json jData = JsonObject();
    jData = JsonObjectSet(jData, "event_type", JsonString(sEventType));
    jData = JsonObjectSet(jData, "source", JsonString(sSource));
    jData = JsonObjectSet(jData, "test_id", JsonInt(1));

    audit_SubmitRecord(jData);

    // Verify
    string s = "SELECT COUNT(*) FROM audit_trail WHERE jsonb_extract(data, '$.source') = @source AND jsonb_extract(data, '$.test_id') = 1";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    if (!SqlStep(q) || SqlGetInt(q, 0) != 1)
    {
        Debug("[FAIL] Phase 1: Direct submission failed to find record.");
        nErrors++;
    }
    else
    {
        Debug("[PASS] Phase 1: Direct submission successful.");
    }

    // 2. Phase 2: Buffered Submission
    Debug("[POST] Phase 2: Buffered Submission Tests...");
    
    jData = JsonObjectSet(jData, "test_id", JsonInt(2));
    audit_BufferRecord(jData);

    // Verify in Buffer
    s = "SELECT COUNT(*) FROM audit_buffer WHERE jsonb_extract(data, '$.source') = @source AND jsonb_extract(data, '$.test_id') = 2";
    q = pw_PrepareModuleQuery(s);
    SqlBindString(q, "@source", sSource);
    if (!SqlStep(q) || SqlGetInt(q, 0) != 1)
    {
        Debug("[FAIL] Phase 2: Buffered submission failed to find record in buffer.");
        nErrors++;
    }
    else
    {
        Debug("[PASS] Phase 2: Buffered submission found in buffer.");
    }

    // Flush
    Debug("[POST] Flushing buffer...");
    audit_FlushBuffer();

    // Verify in Trail
    s = "SELECT COUNT(*) FROM audit_trail WHERE jsonb_extract(data, '$.source') = @source AND jsonb_extract(data, '$.test_id') = 2";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    if (!SqlStep(q) || SqlGetInt(q, 0) != 1)
    {
        Debug("[FAIL] Phase 2: Flush failed to move record to trail.");
        nErrors++;
    }
    else
    {
        Debug("[PASS] Phase 2: Flush successful.");
    }

    // Verify Buffer Empty
    if (audit_GetBufferSize() > 0)
    {
        Debug("[FAIL] Phase 2: Buffer not empty after flush.");
        nErrors++;
    }

    // 3. Cleanup
    Debug("[POST] Cleaning up...");
    s = "DELETE FROM audit_trail WHERE jsonb_extract(data, '$.source') = @source";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlStep(q);

    audit_StartFlushTimer();

    Debug("==================================================================");
    if (nErrors > 0)
        Debug("  POST COMPLETED WITH " + IntToString(nErrors) + " ERRORS");
    else
        Debug("  POST COMPLETED SUCCESSFULLY");
    Debug("==================================================================");
}

// -----------------------------------------------------------------------------
//                        Public Function Definitions
// -----------------------------------------------------------------------------

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
        CREATE TABLE IF NOT EXISTS audit_trail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4)),
            event_type TEXT GENERATED ALWAYS AS (jsonb_extract(data, '$.event_type')) VIRTUAL,
            actor_id INTEGER GENERATED ALWAYS AS (jsonb_extract(data, '$.actor_id')) VIRTUAL,
            target_id INTEGER GENERATED ALWAYS AS (jsonb_extract(data, '$.target_id')) VIRTUAL,
            created_at INTEGER GENERATED ALWAYS AS (jsonb_extract(data, '$.created_at')) VIRTUAL
        );
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_log_event_type ON audit_trail(event_type);
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_actor ON audit_trail(actor_id) 
        WHERE actor_id IS NOT NULL;
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_target ON audit_trail(target_id) 
        WHERE target_id IS NOT NULL;
    ";
    pw_ExecuteCampaignQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_created_at ON audit_trail(created_at);
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `audit_schema` table holds all defined metrics schema provided by
    ///     any metrics provider.  This allows plugins to define their own metrics,
    ///     define metrics behaviors, and allow seamless syncing with previously-
    ///     existing metrics without having to build the sync architecture within each
    ///     source.
    /// @note Sources will be required to register their metric schema with the metrics
    ///     schema manager to ensure their sync behavior can be controlled reliably.
    s = r"
        CREATE TABLE IF NOT EXISTS audit_schema (
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

    /// @note The `audit_buffer` table holds temporary audit data for all players,
    ///     characters and the server, identified by the `type` column.  Periodically,
    ///     this table will be sync'd with the on-disk tables defined above and the
    ///     temporary records deleted.
    s = r"
        CREATE TABLE IF NOT EXISTS audit_buffer (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4))
        );
    ";
    pw_ExecuteModuleQuery(s);

    s = r"
        CREATE INDEX IF NOT EXISTS idx_audit_buffer_queue ON audit_buffer(id ASC);
    ";
    pw_ExecuteModuleQuery(s);
    pw_CommitTransaction(GetModule());
}

json audit_CreateData(string sEventType, object oActor, object oTarget = OBJECT_INVALID, string sSource = "")
{


    return JsonNull();
}

void audit_RegisterSchema(string sSource, string sName, json jData)
{
    Debug("Attempting to register audit schema: " + sSource + "." + sName);
    
    if (sSource == "" || sName == "")
    {
        string s = "Invalid source or schema name found during audit schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  Audit Source: " + (sSource == "" ? "<empty>" : sSource);
        s+= "\n  Audit Schema: " + (sName == "" ? "<empty>" : sName);

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
        INSERT INTO audit_schema (source, name, data)
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

void audit_UnregisterSchema(string sSource, string sName)
{
    if (sSource == "" || sName == "")
    {
        string s = "Invalid source or schema name found during audit schema unregistration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  Audit Source: " + (sSource == "" ? "<empty>" : sSource);
        s+= "\n  Audit Schema: " + (sName == "" ? "<empty>" : sName);

        Error(s);
        return;
    }

    string s = "DELETE FROM audit_schema WHERE source = @source AND name = @name";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);
    SqlStep(q);
}

json audit_ViewSchemas(string sSource)
{
    string s = "SELECT json_group_array(name) FROM audit_schema WHERE source = @source";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

json audit_ViewSchema(string sSource, string sName)
{
    string s = "SELECT json(data) FROM audit_schema WHERE source = @source AND name = @name";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void audit_SubmitRecord(json jData)
{
    audit_InsertRecord(AUDIT_TYPE_TRAIL, jData);
}

void audit_BufferRecord(json jData)
{
    audit_InsertRecord(AUDIT_TYPE_BUFFER, jData);
}
