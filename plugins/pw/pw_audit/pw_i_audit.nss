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

/// @brief Called only during module startup from the audit source.  Ensures all
///     audit records tables are created in the on-disk campaign database and
///     creates the in-memory module database table used for buffering audit data.
void audit_CreateTables();

/// @brief Gather logging data for game objects.  Used internally to gather `actor` data
///     but accessible by users to collect appropriate data for targets and other game
///     objects as required.
/// @param o Object to gather logging data for.
json audit_GetObjectData(object o);

/// @brief Create a standard audit data object with the minimum required fields.
/// @todo descriptions for all these have been changed!  Fix...
/// @returns A JSON object containing the base audit data.
json audit_GetMinimalRecord(string sSource, string sEvent, object oActor, json jDetail = JSON_NULL);

/// @brief Register an audit schema to the audit source.  Registering an audit
///     schema allows a source to provide audit records to the audit database and define
///     how those audit records are integrated during syncing operations.
/// @param sSource The name of the source providing the audit schema.
/// @param sName The name of the audit schema.
/// @param jData The audit schema object.
/// @warning If a audit schema is registered using a source/name combination that
///     already exists, the existing audit schema will be replaced with the schema
///     contained in jData.
/// @note When creating source-defined schema, if custom data is being tracked that
///     will never be accessed by other sources and may be deleted at some point,
///     ensure unique keys are used.  Namespaces, such as <source_*> work well in
///     these cases.
void audit_RegisterSchema(string sSource, string sEvent, json jData);

/// @brief Unregister (delete) an audit schema.
/// @param sSource Source of the registered schema.
/// @param sName Name of the registered schema.
void audit_UnregisterSchema(string sSource, string sEvent);

/// @brief Retrieve a list of schema names registered by a source.
/// @param sSource Source of the registered schemas.
/// @return A json array of strings containing the names of registered schemas.
json audit_ViewSchemas(string sSource);

/// @brief Retrieve the definition of a specific registered schema.
/// @param sSource Source of the registered schema.
/// @param sEvent Name of the registered schema.
/// @return The schema definition object.
json audit_ViewSchema(string sSource, string sEvent);

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
        audit_DeleteFlushTimer();

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

/// @private Add a location's position data to a json object.
/// @param l Location to extract position from.
/// @param jLocation JSON object to add position data to.
/// @warning Only for use within the audit system. Do not call from an
///     external source.
void audit_AddPositionToJson(location l, json jLocation)
{
    json jPosition = JsonObject();
    {
        vector vPosition = GetPositionFromLocation(l);
        JsonObjectSetInplace(jPosition, "x", JsonFloat(vPosition.x));
        JsonObjectSetInplace(jPosition, "y", JsonFloat(vPosition.y));
        JsonObjectSetInplace(jPosition, "z", JsonFloat(vPosition.z));
    }

    JsonObjectSetInplace(jLocation, "position", jPosition);
}

/// @private Add an object's location data to a json object.
/// @param o Object whose location is to be converted.
/// @param jData JSON object to add location data to.
/// @warning Only for use within the audit system. Do not call from an
///     external source.
void audit_AddLocationToJson(object o, json jData)
{
    json jLocation = JsonObject();
    {
        location l = GetLocation(o);
        JsonObjectSetInplace(jLocation, "area", JsonString(GetTag(GetAreaFromLocation(l))));
        JsonObjectSetInplace(jLocation, "facing", JsonFloat(GetFacingFromLocation(l)));
        
        audit_AddPositionToJson(l, jLocation);
    }

    JsonObjectSetInplace(jData, "location", jLocation);
}

/// @private Convert an object's type into a human-readable string for inclusion
///     in an audit record's object data.
/// @param o Object to convert type for.
string audit_ObjectTypeToString(object o)
{
    switch (GetObjectType(o))
    {
        case OBJECT_TYPE_CREATURE:       return "creature";
        case OBJECT_TYPE_ITEM:           return "item";
        case OBJECT_TYPE_TRIGGER:        return "trigger";
        case OBJECT_TYPE_DOOR:           return "door";
        case OBJECT_TYPE_AREA_OF_EFFECT: return "area_of_effect";
        case OBJECT_TYPE_WAYPOINT:       return "waypoint";
        case OBJECT_TYPE_PLACEABLE:      return "placeable";
        case OBJECT_TYPE_STORE:          return "store";
        case OBJECT_TYPE_ENCOUNTER:      return "encounter";
        case OBJECT_TYPE_TILE:           return "tile";
        default:                         return "invalid";
    }

    return "invalid";
}

/// @private Perform unit tests for the entire audit record system including tests for
///     direct submission, buffer submission, buffer sync and buffer timer.
void audit_POST()
{
    DescribeTestSuite("Audit System POST");
    
    int bTimerRunning = audit_IsFlushTimerValid();

    /// @test Environment Preparation
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

    /// @test Direct Submission
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

    /// @test Buffered Submission
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

    /// @test Environment Restoration
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
            actor_id TEXT GENERATED ALWAYS AS (jsonb_extract(data, '$.actor_id')) VIRTUAL,
            target_id TEXT GENERATED ALWAYS AS (jsonb_extract(data, '$.target_id')) VIRTUAL,
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

    /// @note The `audit_schema` table holds all defined audita schema provided by
    ///     any audit provider.  This allows plugins to define their own audit,
    ///     define audit behaviors, and allow seamless syncing with previously-
    ///     existing audit without having to build the sync architecture within each
    ///     source.
    /// @note Sources will be required to register their audit schema with the audit
    ///     schema manager to ensure their sync behavior can be controlled reliably.
    s = r"
        CREATE TABLE IF NOT EXISTS audit_schema (
            source TEXT NOT NULL COLLATE NOCASE,
            event TEXT NOT NULL COLLATE NOCASE,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4)),
            PRIMARY KEY (source, event) ON CONFLICT REPLACE
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

json audit_GetObjectData(object o)
{
    if (o == GetModule())
        /// @note Module object
        return JsonParse(r"
            {
                ""type"": ""module""
            }
        ");
    else if (GetIsPC(o))
    {
        /// @note All player character objects, including dungeon masters.
        json jData = JsonObject();
        JsonObjectSetInplace(jData, "type", JsonString("player"));
        JsonObjectSetInplace(jData, "player_id", JsonString(GetPCPlayerName(o)));
        JsonObjectSetInplace(jData, "character_name", JsonString(GetName(o)));
        JsonObjectSetInplace(jData, "character_id", JsonString(GetObjectUUID(o)));
        JsonObjectSetInplace(jData, "cd_key", JsonString(GetPCPublicCDKey(o)));
        JsonObjectSetInplace(jData, "ip_address", JsonString(GetPCIPAddress(o)));
        JsonObjectSetInplace(jData, "is_dm", JsonBool(GetIsDM(o)));
        audit_AddLocationToJson(o, jData);
        
        return jData;
    }
    else if (GetIsObjectValid(o))
    {
        /// @note All valid/existing non-player charcter game objects.
        /// @todo Create a conversion function to change object_type to a human-
        ///     readable object type.  Don't use constants ... too heavy.
        json jData = JsonObject();
        JsonObjectSetInplace(jData, "type", JsonString("object"));
        JsonObjectSetInplace(jData, "object_type", JsonString(audit_ObjectTypeToString(o)));
        JsonObjectSetInplace(jData, "object_tag", JsonString(GetTag(o)));
        JsonObjectSetInplace(jData, "object_resref", JsonString(GetResRef(o)));
        audit_AddLocationToJson(o, jData);
        
        return jData;
    }
    else
        /// @note This case will be reached only if the object is not a player and is
        ///     invalid.  This case should never be reached and if found in an audit
        ///     record should be cause for concern.  This means either:
        ///         1) Invalid objects are being referenced in audit records
        ///         2) The scripter responsible for creating the record is lazy
        ///         3) Bad data was injected into the system on accident or by a bad actor
        /// @note Consider throwing an error or other alert if this case is returned.
        return JsonParse(r"
            {
                ""type"": ""unknown"",
                ""reason"": ""invalid object""
            }
        ");
}

json audit_GetMinimalRecord(string sSource, string sEvent, object oActor, json jDetail = JSON_NULL)
{
    /// @todo modify all this logic to not get a minimal record for modification, but to
    ///     instead create the final record for submission.

    /// @todo let's build convenience functions for each of the types of events that
    ///     will return a well-form details section.  This query will be for building the
    ///     final record to prevent users from modifying the final form before submission,
    ///     thus ensuring we always have the minimal data within each record.

    string s = r"
        WITH RECURSIVE
        -- 1. Fetch schemas as before
        schemas AS (
            SELECT 
                (SELECT data FROM audit_schema WHERE source = 'system' AND event = 'minimal_record') as skeleton,
                (SELECT data FROM audit_schema WHERE source = :source AND event = :event) as event_schema
        ),
        -- 2. Parallel timeline for modifiers
        timeline(type, idx, val, skeleton, event_schema) AS (
            SELECT 'EVENT', -1, datetime('now'), s.skeleton, s.event_schema FROM schemas s
            UNION ALL
            SELECT 'SKELETON', -1, datetime('now'), s.skeleton, s.event_schema FROM schemas s
            UNION ALL
            SELECT t.type, m.id, datetime(t.val, m.value), t.skeleton, t.event_schema
            FROM timeline t
            JOIN json_each(
                CASE WHEN t.type = 'EVENT' 
                    THEN json_extract(t.event_schema, '$.expiry_modifier') 
                    ELSE json_extract(t.skeleton, '$.expiry_modifier') 
                END
            ) m ON m.id = t.idx + 1
        ),
        -- 3. Consolidate results
        candidates AS (
            SELECT 
                skeleton, event_schema,
                json_extract(event_schema, '$.expiry') as e_abs,
                json_extract(skeleton, '$.expiry') as s_abs,
                (SELECT val FROM timeline WHERE type = 'EVENT' ORDER BY idx DESC LIMIT 1) as e_mod_final,
                (SELECT val FROM timeline WHERE type = 'SKELETON' ORDER BY idx DESC LIMIT 1) as s_mod_final
            FROM timeline LIMIT 1
        )
        -- 4. Final Winner Logic with Variable Keywords
        SELECT 
            jsonb_patch(
                jsonb_patch(jsonb(skeleton), jsonb(event_schema)),
                jsonb_object(
                    'source', :source,
                    'event', :event,
                    'timestamp', NULL,
                    'expiry', CASE 
                        -- Priority 1: Event Absolute (Check against dynamic variable list)
                        WHEN EXISTS (SELECT 1 FROM json_each(:perm_keywords) WHERE value = e_abs) THEN NULL
                        WHEN datetime(e_abs, '+0 seconds') IS e_abs AND datetime(e_abs) > datetime('now') THEN datetime(e_abs)
                        
                        -- Priority 2 & 3: Modifiers (Future-validated)
                        WHEN e_mod_final > datetime('now') THEN e_mod_final
                        WHEN s_mod_final > datetime('now') THEN s_mod_final
                        
                        -- Priority 4: Skeleton Absolute (Lowest priority)
                        WHEN EXISTS (SELECT 1 FROM json_each(:perm_keywords) WHERE value = s_abs) THEN NULL
                        WHEN datetime(s_abs, '+0 seconds') IS s_abs AND datetime(s_abs) > datetime('now') THEN datetime(s_abs)
                        
                        -- Default Fallback (Using variable)
                        ELSE datetime('now', :default_modifier)
                    END
                )
            ) AS final_default_object
        FROM candidates;
    ";

    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, ":source", sSource);
    SqlBindString(q, ":event", sEvent);
    SqlBindString(q, ":default_modifier", AUDIT_EXPIRY_DEFAULT_MODIFIER);
    SqlBindJson(q, ":perm_keywords", AUDIT_EXPIRY_PERMANENT_KEYWORDS);

    if (SqlStep(q))
    {
        json jRecord = SqlGetJson(q, 0);
        return JsonObjectSet(jRecord, "actor", audit_GetObjectData(oActor));
    }

    return JsonNull();
}

/// @todo Need to do schema validation here to ensure it's all valid against my primary structured logging schema.
/// sSource should be the plugin/system where  the schema is sourced. Cannot be empty.
///     sEvent should be the logging event the schema is assigned to.  This event name will be included as the
///     `event` key in the structured log record.  It cannot be empty.
///  jData should be the json object that will be checked against the standard schema
///  *Can* contain:
///     source
///     event
///     expiry (date/modifiers)
///  *Must* contain:
///     details object
/// Each record will also contain a timestamp and actor, but those will be provided at the time of logging, not
///     during schema registration.
/// Here we'll check jdata against two schema, the first will be the overall, with a details section, in case the
///     user wants to specify source, event, expiry and other options, along with details.  The second will
///     the schema against just a details section, in case they want to use defaults and only provide the details
///     section of the schema.
void audit_RegisterSchema(string sSource, string sEvent, json jData)
{
    audit_Debug(__FUNCTION__, "Attempting to register audit schema: " + sSource + "." + sEvent);
    
    if (sSource == "" || sEvent == "")
    {
        string s = "Invalid source or schema name found during audit schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  Audit Source: " + (sSource == "" ? "<empty>" : sSource);
        s+= "\n  Audit Event: " + (sEvent == "" ? "<empty>" : sEvent);

        Error(s);
        return;
    }

    if (JsonGetType(jData) != JSON_TYPE_OBJECT)
    {
        string s = "Invalid schema data object type found during audit schema registration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";

        Error(s);
        return;
    }

    string s = r"
        INSERT INTO audit_schema (source, event, data)
        SELECT @source, @event, 
            (SELECT jsonb_group_object(fullkey, value) 
             FROM json_tree(jsonb(@data)) 
             WHERE atom IS NOT NULL);
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@name", sEvent);
    SqlBindJson(q, "@data", jData);

    SqlStep(q);
}

void audit_UnregisterSchema(string sSource, string sEvent)
{
    if (sSource == "" || sEvent == "")
    {
        string s = "Invalid source or schema name found during audit schema unregistration";
        s+= "\n  Error Source: " + __FILE__ + " (" + __FUNCTION__ + ")";
        s+= "\n  Audit Source: " + (sSource == "" ? "<empty>" : sSource);
        s+= "\n  Audit Event: " + (sEvent == "" ? "<empty>" : sEvent);

        Error(s);
        return;
    }

    string s = r"
        DELETE FROM audit_schema
        WHERE source = @source
            AND event = @event
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@event", sEvent);
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

json audit_ViewSchema(string sSource, string sEvent)
{
    string s = r"
        SELECT json(data)
        FROM audit_schema
        WHERE source = @source
            AND event = @event
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@event", sEvent);
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
