/// ----------------------------------------------------------------------------
/// @file   pw_i_audit.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Audit System (core).
/// ----------------------------------------------------------------------------

#include "pw_c_audit"
#include "pw_i_sql"
#include "util_i_strings"
#include "util_i_debug"
#include "util_i_unittest"

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

/// @private Debugging function for audit system.
/// @param sFunction Name of the function generating the debug message.
/// @param sMessage Debug message.
void audit_Debug(string sFunction, string sMessage)
{
    sFunction = HexColorString("[" + sFunction + "]", COLOR_BLUE_LIGHT);
    Debug(sFunction + " " + sMessage);
}

/// @private Determine if the audit flush timer is valid (running).
int audit_IsFlushTimerValid()
{
    return GetIsTimerValid(GetLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID));
}

/// @private Delete the current audit flush timer.
/// @param nTimerID ID of the audit flush timer, if known.
void audit_DeleteFlushTimer(int nTimerID = -1)
{
    if (nTimerID < 0)
        nTimerID = GetLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID);

    if (nTimerID > 0)
    {
        KillTimer(nTimerID);
        DeleteLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID);

        audit_Debug(__FUNCTION__, "Audit flush timer deleted");
    }
}

/// @private Create the audit flush timer.
/// @param fInterval Time, in seconds, between timer expirations.
void audit_CreateFlushTimer(float fInterval = AUDIT_FLUSH_INTERVAL)
{
    int nTimerID = CreateEventTimer(GetModule(), AUDIT_EVENT_FLUSH_ON_TIMER_EXPIRE, fInterval);

    if (audit_IsFlushTimerValid())
        audit_DeleteFlushTimer(nTimerID);

    SetLocalInt(GetModule(), AUDIT_FLUSH_TIMER_ID, nTimerID);
    StartTimer(nTimerID, FALSE);

    audit_Debug(__FUNCTION__, "Audit flush timer created :: Interval = " + FormatFloat(fInterval, "%!f") + "s");
}

/// @private Delete the current audit flush timer, then create a new timer
///     with the specified interval.
/// @param fInterval Time, in seconds, between timer expirations.
void audit_SetFlushTimerInterval(float fInterval = AUDIT_FLUSH_INTERVAL)
{
    audit_DeleteFlushTimer();
    audit_CreateFlushTimer(fInterval);
}

int audit_GetBufferSize()
{
    sqlquery q = pw_PrepareModuleQuery("SELECT COUNT(*) FROM audit_buffer");
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

    int nRecords = JsonGetLength(jBuffer);
    audit_Debug(__FUNCTION__, "Flushing audit records - " + IntToString(nRecords) + " record" + (nRecords == 1 ? "" : "s") + " found");

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
        SqlStep(q);

        s = r"
            DELETE FROM audit_buffer 
            WHERE id IN (
                SELECT jsonb_extract(value, '$.id') FROM json_each(@buffer)
            );
        ";
        q = pw_PrepareModuleQuery(s);
        SqlBindJson(q, "@buffer", jBuffer);
        SqlStep(q);
    }
    else if (JsonGetType(jBuffer) != JSON_TYPE_ARRAY)
        audit_Debug(__FUNCTION__, "jBuffer is not a valid json object");

    if (audit_GetBufferSize() == 0)
        audit_DeleteFlushTimer();
}

/// @private Determine if the passed sType is valid based on its inclusion in
///     jAuditTypes.
/// @param sType Audit type: AUDIT_TYPE_*.
int audit_IsTypeValid(string sType)
{
    if (JsonGetType(JsonFind(jAuditTypes, JsonString(sType))) == JSON_TYPE_NULL)
    {
        audit_Debug(__FUNCTION__, "Invalid audit type '" + sType + "'");
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
        audit_Debug(__FUNCTION__, "jData must be a valid json object.");
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
    {
        q = pw_PrepareModuleQuery(s);
        if (!audit_IsFlushTimerValid())
            audit_CreateFlushTimer();
    }
    else if (sType == AUDIT_TYPE_TRAIL)
        q = pw_PrepareCampaignQuery(s);
    else
    {
        audit_Debug(__FUNCTION__, "Invalid audit target '" + sType + "'");
        return;
    }

    SqlBindJson(q, "@data", jData);
    SqlStep(q);
}

void audit_POST()
{
    DescribeTestSuite("Audit System POST");
    
    int bTimerRunning = audit_IsFlushTimerValid();

    /// @test Environment preparation
    {
        int t = Timer();

        /// @test Test 1: Check if audit_buffer table is empty.
        /// @note e1 = expected buffer record size
        int e1 = 0, r1;
        int t1 = Timer(); r1 = audit_GetBufferSize(); t1 = Timer(t1);

        if (r1 > 0)
        {
            audit_Debug(__FUNCTION__, "Flushing " + _i(r1) + " records");
            audit_FlushBuffer(r1);
            r1 = audit_GetBufferSize();
        }

        /// @test Test 2: Check if audit flush timer is running.  If it is running,
        ///     note it and stop the timer for the duration of the POST.
        /// @note e2 = time running status
        int e2 = FALSE, r2;

        int t2 = Timer();
        {
            if (bTimerRunning)
            {
                audit_DeleteFlushTimer();
                r2 = audit_IsFlushTimerValid();
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
            if (!Assert("Audit Buffer Empty", b1))
                DescribeTestParameters("", _i(e1), _i(r1));
            DescribeTestTime(t1);

            if (!Assert("Audit Flush Timer Not Running", b2))
                DescribeTestParameters("", _i(e2), _i(r2));
            DescribeTestTime(t2);
        } DescribeGroupTime(t); Outdent();
    }

    string sSource = "audit_test_source";
    string sEventType = "AUDIT_TEST_EVENT";

    json jData = JsonObjectSet(JsonObject(), "event_type", JsonString(sEventType));
    jData = JsonObjectSet(jData, "source", JsonString(sSource));

    /// @test Direct submission
    {
         /// @note e1 = expected record count in audit_trail after submission
        int e1 = 1, r1;

        jData = JsonObjectSet(jData, "test_id", JsonInt(1));

        /// @test Test 1: Submit audit records directly to audit_trail.
        int t = Timer(); audit_SubmitRecord(jData); t = Timer(t);

        string s = r"
            SELECT COUNT(*)
            FROM audit_trail
            WHERE jsonb_extract(data, '$.source') = @source
                AND jsonb_extract(data, '$.test_id') = 1
        ";
        sqlquery q = pw_PrepareCampaignQuery(s);
        SqlBindString(q, "@source", sSource);
        if (SqlStep(q))
            r1 = SqlGetInt(q, 0);

        if (!Assert("Direct Submission Test", r1 == e1))
            DescribeTestParameters("", _i(e1), _i(r1));
        DescribeTestTime(t);
    }

    /// @test Buffered submission
    {
        jData = JsonObjectSet(jData, "test_id", JsonInt(2));
        
        int t = Timer();

        /// @test Test 1: Check audit_trail for record submitted via buffer flush.
        /// @note e1 = expected record count in audit_trail after flush
        int e1 = 1, r1;
        int t1 = Timer(); audit_BufferRecord(jData); t1 = Timer(t1);

        string s = r"
            SELECT COUNT(*)
            FROM audit_buffer
            WHERE jsonb_extract(data, '$.source') = @source
                AND jsonb_extract(data, '$.test_id') = 2
        ";
        sqlquery q = pw_PrepareModuleQuery(s);
        SqlBindString(q, "@source", sSource);
        if (SqlStep(q))
            r1 = SqlGetInt(q, 0);

        /// @test Test 2: Check audit buffer timer has started.
        /// @note e2 = expceted timer status
        int e2 = TRUE, r2;
        int t2 = Timer(); r2 = audit_IsFlushTimerValid(); t2 = Timer(t2);

        /// @test Test 3: Check audit_buffer is empty after flush.
        /// @note e3 = expected record count in audit_buffer after flush
        int e3 = 0, r3;

        int t3 = Timer();
        {
            audit_FlushBuffer();
            r3 = audit_GetBufferSize();
        } t3 = Timer(t3);

        /// @test Test 4: Check audit buffer timer stopped.
        /// @note e4 = expected timer status
        int e4 = FALSE, r4;
        int t4 = Timer(); r4 = audit_IsFlushTimerValid(); t4 = Timer(t4);

        t = Timer(t);

        int b, b1, b2;
        b = (b1 = r1 == e1) &
            (b2 = r2 == e2) &
            (b2 = r3 == e3) &
            (b2 = r4 == e4);

        if (!AssertGroup("Buffered Submission Testing", b))
        {
            if (!Assert("Buffered Submission Test", b1))
                DescribeTestParameters("", _i(e1), _i(r1));
            DescribeTestTime(t1);

            if (!Assert("Audit Flush Timer Started", b2))
                DescribeTestParameters("", _i(e2), _i(r2));
            DescribeTestTime(t2);

            if (!Assert("Buffer Empty After Flush", b2))
                DescribeTestParameters("", _i(e3), _i(r3));
            DescribeTestTime(t3);

            if (!Assert("Audit Flush Timer Stopped", b2))
                DescribeTestParameters("", _i(e4), _i(r4));
            DescribeTestTime(t4);
        } DescribeGroupTime(t); Outdent();
    }

    /// @test Environment restoration
    {
        /// @test Test 1: Delete all test records from audit_trail.
        /// @note e1 = expected records deleted from audit_trail.
        int e1 = 2, r1;

        int t = Timer();
        int t1 = Timer();

        string s = r"
            DELETE FROM audit_trail
            WHERE jsonb_extract(data, '$.source') = @source
            RETURNING id;
        ";
        sqlquery q = pw_PrepareCampaignQuery(s);
        SqlBindString(q, "@source", sSource);

        while (SqlStep(q))
            r1++;

        t1 = Timer(t1);

        /// @test Test 2: Restore audit flush timer to previous state.
        /// @note e2 = timer running status
        int e2 = bTimerRunning, r2;

        int t2 = Timer();
        {
            if (bTimerRunning && !audit_IsFlushTimerValid())
                audit_CreateFlushTimer();
            
            r2 = audit_IsFlushTimerValid();
        } t2 = Timer(t2);
        t = Timer(t);

        int b, b1, b2;
        b = (b1 = r1 == e1) &
            (b2 = r2 == e2);

        if (!AssertGroup("Environment Restoration", b))
        {
            if (!Assert("Audit Records Deleted", b1))
                DescribeTestParameters("", _i(e1), _i(r1));
            DescribeTestTime(t1);

            if (!Assert("Audit Flush Timer Restored", b2))
                DescribeTestParameters("", _i(e2), _i(r2));
            DescribeTestTime(t2);
        } DescribeGroupTime(t); Outdent();
    }
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
    /// @todo need convenience functions to allow users to instantly retrieve a minimally-acceptable
    ///     json object containing the data required for every structured logging event.

    return JsonNull();
}

void audit_RegisterSchema(string sSource, string sName, json jData)
{
    audit_Debug(__FUNCTION__, "Attempting to register audit schema: " + sSource + "." + sName);
    
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

    string s = r"
        DELETE FROM audit_schema
        WHERE source = @source
            AND name = @name
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sName);
    SqlStep(q);
}

json audit_ViewSchemas(string sSource)
{
    string s = r"
        SELECT json_group_array(name)
        FROM audit_schema
            WHERE source = @source
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

json audit_ViewSchema(string sSource, string sName)
{
    string s = r"
        SELECT json(data)
        FROM audit_schema
        WHERE source = @source
            AND name = @name
    ";
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
