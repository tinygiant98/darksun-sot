/// ----------------------------------------------------------------------------
/// @file   pw_i_audit.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Audit System (core).
/// ----------------------------------------------------------------------------

#include "pw_c_audit"
#include "pw_i_core"
#include "util_i_strings"
#include "util_i_debug"
#include "util_i_unittest"

#include "core_i_framework"
#include "nwnx_schema"

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

/// @note Each audit record will consist of the following key:value pairs.  The values
///     for these keys are sourced in various ways, however, the `details` key is
///     normally provided by the calling plugin while all other fields are inserted
///     by the audit system to ensure information uniformity.  Any change to this
///     minimum record requires changes to audit_BuildRecord().
json jMinimumRecord = JsonParse(r"
    {
        ""source"": null,
        ""event"": null,
        ""actor"": null,
        ""expiry"": null,
        ""timestamp"": null,
        ""details"": null,
        ""session_id"": null
    }
");

const string AUDIT_EVENT_FLUSH_ON_TIMER_EXPIRE = "AUDIT_EVENT_FLUSH_ON_TIMER_EXPIRE";
const string AUDIT_FLUSH_TIMER_ID = "AUDIT_FLUSH_TIMER_ID";

// -----------------------------------------------------------------------------
//                       Public Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Called only during module startup from the audit source.  Ensures all
///     audit records tables are created in the on-disk campaign database and
///     creates the in-memory module database table used for buffering audit data.
/// @param bForce If TRUE, database tables will be redefined if they do not already
///     exist.  Any tables that already exist and contain data will not be redefined.
void audit_CreateTables(int bForce = FALSE);

/// @brief Gather logging data for game objects.  Used internally to gather `actor` data
///     but accessible by users to collect standardized data for targets and other game
///     objects for inclusion in audit record details.
/// @param o Object to gather logging data for.
json audit_GetObjectData(object o);

/// @brief Register an audit schema to the audit source.  Registering an audit
///     schema allows a source to provide audit records to the audit database and define
///     how those audit records are integrated during syncing operations.
/// @param sSource The name of the source providing the audit schema.
/// @param sEvent The event the audit schema is designed for.
/// @param jSchema The audit schema object.
/// @param bRedefine If TRUE, allows redefinition of an existing schema.  If a audit
///     schema is registered using a source/name combination that already exists, the
///     existing audit schema will be replaced with the schema contained in jSchema.
/// @note jSchema must be a schema that is valid against the audit_details metaschema
///     and json-schema.org's draft 2020-12.  The following is the current metaschema
///     for audit records details objects:
/*
    {
        ""$id"": ""urn:darksun_sot:audit_details:metaschema"",
        ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
        ""allOf"": [
            { ""$ref"": ""https://json-schema.org/draft/2020-12/schema"" },
            {
                ""type"": ""object"",
                ""minProperties"": 1
            }
        ]
    }
*/
/// @note The following limitations should be honored when creating schema for audit
///     records details:
///     - $id is not required and will be overwritten
///     - $schema is not required and will be overwritten
///     - `details` objects must be json objects; any other object type (array, value, etc.)
///         will automatically fail validation
///     - `details` object must have at least 1 property defined in them.  If the user-
///         provided schema include a minProperties setting greater than one, that setting
///         will take precedence.
void audit_RegisterSchema(string sSource, string sEvent, json jSchema, int bRedefine = FALSE);

/// @brief Unregister (delete) an audit schema.
/// @param sSource Source of the registered schema.
/// @param sEvent Name of the registered schema.
void audit_UnregisterSchema(string sSource, string sEvent);

/// @brief Retrieve a list of schema event names registered by a source.
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
/// @param sSource The source of the audit record.
/// @param sEvent The event name of the audit record.
/// @param oActor The actor object responsible for the event; in most game events, this will
///     be OBJECT_SELF, but can be defined as any game object, including the module object.
/// @param jDetails The details json object as defined by the matching source/event schema.
/// @param sExpiry Optional date/time group for when the audit record will be deleted from the
///     database.  If not passed, the standard date modifiers in AUDIT_EXPIRY_DEFAULT_MODIFIER
///     will be used.  Can be either of the following:
///         - Date/time group in any acceptable sqlite format
///         - Comma-sepearated list of date modifiers as defined by sqlite date functionality.
/// @warning If the date (or result of date modification list) is in the past, the expiry will
///     be ignored and the default expiry date modifiers will be used.
void audit_SubmitRecord(string sSource, string sEvent, object oActor, json jDetails, string sExpiry = "");

/// @brief Submits an audit record to the buffer for eventual syncing.
/// @param sSource The source of the audit record.
/// @param sEvent The event name of the audit record.
/// @param oActor The actor object responsible for the event; in most game events, this will
///     be OBJECT_SELF, but can be defined as any game object, including the module object.
/// @param jDetails The details json object as defined by the matching source/event schema.
/// @param sExpiry Optional date/time group for when the audit record will be deleted from the
///     database.  If not passed, the standard date modifiers in AUDIT_EXPIRY_DEFAULT_MODIFIER
///     will be used.  Can be either of the following:
///         - Date/time group in any acceptable sqlite format
///         - Comma-sepearated list of date modifiers as defined by sqlite date functionality.
/// @warning If the date (or result of date modification list) is in the past, the expiry will
///     be ignored and the default expiry date modifiers will be used.
void audit_BufferRecord(string sSource, string sEvent, object oActor, json jDetails, string sExpiry = "");

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

/// @private Retrieve the current size of the audit buffer.
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
    audit_CreateTables();

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

/// @private Register the system schema required by all system functions.
void audit_RegisterSystemSchema(int bForce = FALSE)
{
    if (!bForce)
    {
        if (GetLocalInt(GetModule(), "AUDIT_SYSTEMSCHEMA_INITIALIZED") == TRUE)
            return;
    }

    /// @note This metaschema defines the basic structure of the `details` schema
    ///     that will be defined by various users.  It only validates the `details`
    ///     value of the audit record.
    json jMetaSchema = JsonParse(r"
        {
            ""$id"": ""urn:darksun_sot:audit_details:metaschema"",
            ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
            ""allOf"": [
                { ""$ref"": ""https://json-schema.org/draft/2020-12/schema"" },
                {
                    ""type"": ""object"",
                    ""minProperties"": 1
                }
            ]
        }
        ");

    if (NWNXGetIsAvailable())
        NWNX_Schema_RegisterMetaSchema(jMetaSchema);

    string s = r"
        INSERT INTO audit_schema (source, event, data)
        VALUES ('system', :id, :data)
        ON CONFLICT(source, event) DO UPDATE SET data = excluded.data;
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, ":id", JsonGetString(JsonObjectGet(jMetaSchema, "$id")));
    SqlBindJson(q, ":data", jMetaSchema);
    SqlStep(q);

    /// @note This schema defines the basic structure of a `details` instance that
    ///     will be provided by various users.  It validatese the entire `details`
    ///     instance, includign the optional `expiry` key.
    /// @note When a user-provided `details` schema is registered, that schema is
    ///     patched into this schema to create a custom validation schema for each
    ///     user-defined schema.
    json jInstanceSchema = JsonParse(r"
        {
            ""$id"": ""urn:darksun_sot:audit_details:instance"",
            ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
            ""allOf"": [
                { ""$ref"": ""https://json-schema.org/draft/2020-12/schema"" },
                {
                    ""type"": ""object"",
                    ""properties"": {
                        ""expiry"": { ""type"": [""string"", ""null""] },
                        ""details"": {
                            ""type"": ""object"",
                            ""minProperties"": 1
                        }
                    },
                    ""required"": [ ""details"" ],
                    ""additionalProperties"": false
                }
            ]
        }
    ");

    if (NWNXGetIsAvailable())
        NWNX_Schema_RegisterMetaSchema(jMetaSchema);

    SqlResetQuery(q, TRUE);
    SqlBindString(q, ":id", JsonGetString(JsonObjectGet(jInstanceSchema, "$id")));
    SqlBindJson(q, ":data", jInstanceSchema);
    SqlStep(q);

    /// @note This schema defines the structure of the entire audit record, including the
    ///     user-defined `details` sections and all other fields defined by this
    ///     system.  The user-provided `details` schema is not patched into this schema
    ///     as the `details` instance should be validated before the final record is built.
    json jRecord = JsonParse(r"
        {
            ""$id"": ""urn:darksun_sot:audit_record"",
            ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
            ""type"": ""object"",
            ""properties"": {
                ""source"": { ""type"": ""string"" },
                ""event"": { ""type"": ""string"" },
                ""expiry"": { 
                    ""type"": ""string"",
                    ""format"": ""date-time""
                },
                ""details"": {
                    ""type"": ""object"",
                    ""minProperties"": 1
                },
                ""actor"": {
                    ""type"": ""object"",
                    ""properties"": {
                        ""type"": { ""type"": ""string"" }
                    },
                    ""required"": [ ""type"" ]
                },
                ""timestamp"": { 
                    ""type"": ""string"",
                    ""format"": ""date-time""
                },
                ""session_id"": {
                    ""type"": ""string""
                }
            },
            ""required"": [ ""source"", ""event"", ""expiry"", ""details"", ""actor"", ""timestamp"" ],
            ""additionalProperties"": false
        }
    ");

    if (NWNXGetIsAvailable())
        NWNX_Schema_RegisterMetaSchema(jMetaSchema);

    SqlResetQuery(q, TRUE);
    SqlBindString(q, ":id", JsonGetString(JsonObjectGet(jRecord, "$id")));
    SqlBindJson(q, ":data", jRecord);
    SqlStep(q);

    SetLocalInt(GetModule(), "AUDIT_SYSTEMSCHEMA_INITIALIZED", TRUE);
}

/// @private Add a location's position data to a json object.
/// @param l Location to extract position from.
/// @param jLocation JSON object to add position data to.
/// @warning Only for use within the audit system. Do not call from an
///     external source.  jLocation is modified inplace.
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
///     external source.  jData is modified inplace.
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

json audit_BuildRecord(string sSource, string sEvent, object oActor, json jDetail, string sExpiry = "")
{
    audit_CreateTables();

    if (AUDIT_REQUIRE_NWNX && !NWNXGetIsAvailable())
    {
        audit_Debug(__FUNCTION__, "NWNX is required but not available");
        return JsonNull();
    }

    if (NWNXGetIsAvailable())
    {
        string s = r"
            SELECT json(data)
            FROM audit_schema
            WHERE source = @source
                AND event = @event;
        ";
        sqlquery q = pw_PrepareCampaignQuery(s);
        SqlBindString(q, "@source", sSource);
        SqlBindString(q, "@event", sEvent);
        if (SqlStep(q))
        {
            json jSchema = SqlGetJson(q, 0);
            string sID = JsonGetString(JsonObjectGet(jSchema, "$id"));

            /// @note JIT schema validation for details schema.  This prevents overwhelming the
            ///     schema cache with unused schema.  Schema will only be validated when needed,
            ///     but once validated, will remain immediately available for future use.
            if (!NWNX_Schema_GetIsRegistered(sID))
                NWNX_Schema_ValidateSchema(jSchema);

            if (JsonObjectGet(NWNX_Schema_ValidateInstanceByID(jSchema, sID), "valid") == JSON_FALSE)
            {
                audit_Debug(__FUNCTION__, "jDetail does not validate against schema for source '" + sSource + "' event '" + sEvent + "'");
                return JsonNull();
            }
        }
    }

    /// @note Most of this query has to do with sorting and calculating the expiry date.  The expiry can
    ///     be a "hard" date-time group that defines a specific time, or it can be a list of date/time
    ///     modifiers as defined by sqlite.  If the expiry is a list of modifiers, modifiers will be applied
    ///     in the order they appear and will modify now().
    /// @note Order of priority for expiry:
    ///     1) permanent keyword as defined in AUDIT_EXPIRY_PERMANENT_KEYWORDS
    ///     2) "hard" date/time specified in the details instance
    ///     3) modifier list specified in the details instance
    ///     4) "hard" date/time specified in the call to audit_SubmitRecord or audit_BufferRecord
    ///     5) modifier list specified in the call to audit_SubmitRecord or audit_BufferRecord
    ///     6) default modifier list defined in AUDIT_EXPIRY_DEFAULT_MODIFIER
    string s = r"
        WITH RECURSIVE
            queue(priority, val, logic_tag) AS (
                VALUES 
                (1, json_extract(:audit_record, '$.expiry'), 'permanent_keywords'),
                (2, json_extract(:audit_record, '$.expiry'), 'record_expiry'),
                (4, :desired_expiry,                         'external_expiry'),
                (6, :default_modifier,                       'default_expiry')
            ),
            normalized(priority, str, logic_tag, is_hard_date) AS (
                SELECT 
                priority,
                lower(regexp_replace('\s*,\s*', 
                    regexp_replace('([+-])\s+',
                    regexp_replace('\s{2,}', trim(val), ' ', 0, 0),
                    '$1', 0, 0),
                ',', 0, 0)),
                logic_tag,
                (datetime(val, '+0 seconds') IS NOT NULL)
                FROM queue
                WHERE nullif(trim(val), '') IS NOT NULL
            ),
            walker(priority, current_dt, remaining, is_valid, logic_tag, is_hard_date) AS (
                SELECT 
                priority,
                CASE WHEN is_hard_date THEN str ELSE datetime('now') END,
                CASE WHEN is_hard_date THEN '' ELSE str || ',' END,
                1, logic_tag, is_hard_date
                FROM normalized
                WHERE logic_tag != 'permanent_keywords'
                UNION ALL
                SELECT 
                priority,
                datetime(current_dt, substr(remaining, 1, instr(remaining, ',') - 1)),
                substr(remaining, instr(remaining, ',') + 1),
                (substr(remaining, 1, instr(remaining, ',') - 1) REGEXP '^([+-]?\d*\.?\d+ (days?|hours?|minutes?|seconds?|months?|years?)|[+-]?\d{2,4}-\d{2}-\d{2}(\s\d{2}:\d{2}(:\d{2}(\.\d+)?)?)?|[+-]?\d{2}:\d{2}(:\d{2}(\.\d+)?)?|ceiling|floor|start of (month|year|day)|weekday \d|unixepoch|julianday|auto|localtime|utc|subsecond|subsec)$'),
                logic_tag, is_hard_date
                FROM walker
                WHERE remaining != '' AND is_valid = 1
            ),
            expiry_resolution(final_val) AS (
                SELECT val FROM (
                    -- P1: Keyword Check (e.g., never, none)
                    SELECT 1 as p, 'none' as val FROM normalized 
                    WHERE logic_tag = 'permanent_keywords' 
                    AND str IN (SELECT value FROM json_each(:permanent_keywords))
                    
                    UNION ALL
                    -- P2: Record Expiry - Hard Date (Must be in Future)
                    SELECT 2, strftime('%Y-%m-%d %H:%M:%S+00:00', current_dt) FROM walker 
                    WHERE logic_tag = 'record_expiry' AND is_hard_date = 1 
                    AND remaining = '' AND current_dt > datetime('now')
                    
                    UNION ALL
                    -- P3: Record Expiry - Modifiers (Must be in Future)
                    SELECT 3, strftime('%Y-%m-%d %H:%M:%S+00:00', current_dt) FROM walker 
                    WHERE logic_tag = 'record_expiry' AND is_hard_date = 0 
                    AND remaining = '' AND is_valid = 1 AND current_dt > datetime('now')
                    
                    UNION ALL
                    -- P4: External Expiry - Hard Date (Must be in Future)
                    SELECT 4, strftime('%Y-%m-%d %H:%M:%S+00:00', current_dt) FROM walker 
                    WHERE logic_tag = 'external_expiry' AND is_hard_date = 1 
                    AND remaining = '' AND current_dt > datetime('now')
                    
                    UNION ALL
                    -- P5: External Expiry - Modifiers (Must be in Future)
                    SELECT 5, strftime('%Y-%m-%d %H:%M:%S+00:00', current_dt) FROM walker 
                    WHERE logic_tag = 'external_expiry' AND is_hard_date = 0 
                    AND remaining = '' AND is_valid = 1 AND current_dt > datetime('now')
                    
                    UNION ALL
                    -- P6: Default Expiry Fallback
                    SELECT 6, strftime('%Y-%m-%d %H:%M:%S+00:00', current_dt) FROM walker 
                    WHERE logic_tag = 'default_expiry' AND remaining = '' AND is_valid = 1
                ) ORDER BY p ASC LIMIT 1
            )
        SELECT json_set(
            json(:minimal_record),
            '$.source', :source,
            '$.event', :event,
            '$.actor', json(:actor),
            '$.timestamp', strftime('%Y-%m-%d %H:%M:%S+00:00', 'now'),
            '$.details', json(:audit_record),
            '$.expiry', (SELECT final_val FROM expiry_resolution),
            '$.session_id', :session_id
        ) AS final_json_object;
    ";

    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, ":source", sSource);
    SqlBindString(q, ":event", sEvent);
    SqlBindString(q, ":desired_expiry", sExpiry);
    SqlBindString(q, ":session_id", pw_GetSessionID());
    SqlBindString(q, ":default_modifier", AUDIT_EXPIRY_DEFAULT_MODIFIER);
    SqlBindJson(q, ":actor", audit_GetObjectData(oActor));
    SqlBindJson(q, ":permanent_keywords", AUDIT_EXPIRY_PERMANENT_KEYWORDS);
    SqlBindJson(q, ":minimal_record", jMinimumRecord);
    SqlBindJson(q, ":audit_record", jDetail);
    
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
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
        int t = Timer(); /*audit_SubmitRecord(jData);*/ t = Timer(t);

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
        int t1 = Timer(); /*audit_BufferRecord(jData);*/ t1 = Timer(t1);

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

void audit_CreateTables(int bForce = FALSE)
{
    /// @brief The following tables are persistent and reside in the campaign/on-disk
    ///     persistent database.  All audit tables are namespaced with `audit_`.

    /// @note This database schema is self-initializing, requiring no command from
    ///     the user.  However, this may create multiple calls to create tables
    ///     that may already exist.  Unless a force-redefinition is required, assume
    ///     the tables have been created if the initialization variable is set or
    ///     the table count matches the expectation.
    /// @warning Passed bForce = TRUE will force all table creation queries to
    ///     run, but WILL NOT overwrite current table definitions or delete any
    ///     tables or data that currently exist.  bForce is available for testing
    ///     and development and should not be used during production.
    if (!bForce)
    {
        if (GetLocalInt(GetModule(), "AUDIT_DATABASE_INITIALIZED") == TRUE)
            return;
        else
        {
            string s = r"
                SELECT count(*)
                FROM sqlite_master 
                WHERE type = 'table' 
                    AND name IN ('audit_trail', 'audit_schema');
            ";
            sqlquery q = pw_PrepareCampaignQuery(s);
            if (SqlStep(q) && SqlGetInt(q, 0) == 2)
            {
                SetLocalInt(GetModule(), "AUDIT_DATABASE_INITIALIZED", TRUE);
                audit_RegisterSystemSchema();
                return;
            }
        }
    }

    /// @note The `audit_trail` table holds all audit trail data for the server.  This table
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

        CREATE INDEX IF NOT EXISTS idx_audit_trail_event_type ON audit_trail(event_type);

        CREATE INDEX IF NOT EXISTS idx_audit_trail_actor ON audit_trail(actor_id) 
        WHERE actor_id IS NOT NULL;

        CREATE INDEX IF NOT EXISTS idx_audit_trail_target ON audit_trail(target_id) 
        WHERE target_id IS NOT NULL;

        CREATE INDEX IF NOT EXISTS idx_audit_trail_created_at ON audit_trail(created_at);
    ";
    pw_ExecuteCampaignQuery(s);

    /// @note The `audit_schema` table holds all defined audit schema provided by
    ///     any audit record provider.  This allows plugins to define their own audit
    ///     record detail schema.
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

    /// @brief The following table is temporary and resides in the module/in-memory
    ///     database.  It is used as a high-speed buffer and synced to the
    ///     matching table in the campaign/on-disk database.
    s = r"
        CREATE TABLE IF NOT EXISTS audit_buffer (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data BLOB NOT NULL DEFAULT (jsonb_object()) CHECK (json_valid(data, 4))
        );

        CREATE INDEX IF NOT EXISTS idx_audit_buffer_queue ON audit_buffer(id ASC);
    ";
    pw_ExecuteModuleQuery(s);
    SetLocalInt(GetModule(), "AUDIT_DATABASE_INITIALIZED", TRUE);

    audit_RegisterSystemSchema();
}

json audit_GetObjectData(object o)
{
    if (o == GetModule())
        return JsonParse(r"
            {
                ""type"": ""module""
            }
        ");
    else if (GetIsPC(o))
    {
        /// @note All player character objects, including dungeon masters.
        json jData = JsonObject();
        JsonObjectSetInplace(jData, "type", JsonString("player-character"));
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
        /// @note All valid/existing non-player character game objects.
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

void audit_RegisterSchema(string sSource, string sEvent, json jSchema, int bRedefine = FALSE)
{
    audit_CreateTables();

    if (AUDIT_REQUIRE_NWNX && !NWNXGetIsAvailable())
    {
        audit_Debug(__FUNCTION__, "NWNX is required to register audit schema");
        return;
    }

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

    string s = r"
        SELECT json(data)
        FROM audit_schema
        WHERE source = @source
            AND event = @event;
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@event", sEvent);
    if (SqlStep(q) && !bRedefine)
    {
        audit_Debug(__FUNCTION__, "Schema already registered and redefine not set: " + sSource + "." + sEvent);
        return;
    }

    if (NWNXGetIsAvailable())
    {
        json jResult = NWNX_Schema_ValidateSchema(jSchema);
        if (JsonObjectGet(jResult, "valid") == JSON_FALSE)
        {
            audit_Debug(__FUNCTION__, "Schema validation failed during audit schema registration");
            audit_Debug(__FUNCTION__, JsonDump(jResult, 4));
            return;
        }
    }

    s = r"
        WITH
            base_schema AS (
                SELECT json(data) AS schema
                FROM audit_schema
                WHERE source = 'system'
                AND event = 'urn:darksun_sot:audit_details:instance'
            ),
            normalized_user_schema AS (
                SELECT
                    json_set(
                        json_set(
                            json_set(
                                :user_schema,
                                '$.type', 'object'
                            ),
                            '$.minProperties',
                            CASE
                                WHEN json_extract(:user_schema, '$.minProperties') IS NULL
                                    OR json_extract(:user_schema, '$.minProperties') < 1
                                THEN 1
                                ELSE json_extract(:user_schema, '$.minProperties')
                            END
                        ),
                        '$.$id', :new_id
                    ) AS details_schema
            ),
            patched_schema AS (
                SELECT
                    json_set(
                        schema,
                        '$.allOf[1].properties.details',
                        details_schema
                    ) AS final_schema
                FROM base_schema, normalized_user_schema
            )
        SELECT final_schema FROM patched_schema;
    ";
    q = pw_PrepareCampaignQuery(s);
    SqlBindJson(q, ":user_schema", jSchema);
    SqlBindString(q, ":new_id", "urn:darksun_sot:audit_details:" + sSource + "_" + sEvent);
    if (SqlStep(q))
        jSchema = SqlGetJson(q, 0);
    else
    {
        audit_Debug(__FUNCTION__, "Failed to patch user schema into base schema during audit schema registration");
        return;
    }

    s = r"
        INSERT INTO audit_schema (source, event, data)
        VALUES (@source, @event, jsonb(@data))
        ON CONFLICT(source, event) DO UPDATE SET
            data = jsonb(excluded.data);
    ";
    q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, "@source", sSource);
    SqlBindString(q, "@event", sEvent);
    SqlBindJson(q, "@data", jSchema);
    SqlStep(q);
}

void audit_UnregisterSchema(string sSource, string sEvent)
{
    audit_CreateTables();

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

    if (NWNXGetIsAvailable())
        NWNX_Schema_RemoveSchema("urn:darksun_sot:audit_details:" + sSource + "_" + sEvent);
}

json audit_ViewSchemas(string sSource)
{
    audit_CreateTables();

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
    audit_CreateTables();

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

void audit_SubmitRecord(string sSource, string sEvent, object oActor, json jDetails, string sExpiry = "")
{
    audit_InsertRecord(AUDIT_TYPE_TRAIL, audit_BuildRecord(sSource, sEvent, oActor, jDetails, sExpiry));
}

void audit_BufferRecord(string sSource, string sEvent, object oActor, json jDetails, string sExpiry = "")
{
    audit_InsertRecord(AUDIT_TYPE_BUFFER, audit_BuildRecord(sSource, sEvent, oActor, jDetails, sExpiry));
}
