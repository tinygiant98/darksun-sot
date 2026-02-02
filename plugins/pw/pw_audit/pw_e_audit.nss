/// ----------------------------------------------------------------------------
/// @file   pw_e_audit.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Audit System (events).
/// ----------------------------------------------------------------------------

#include "pw_i_audit"
#include "chat_i_main"

// -----------------------------------------------------------------------------
//                        Event Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

void audit_OnModuleLoad()
{
    audit_CreateTables();
}

void audit_OnClientEnter()
{

}

void audit_OnClientLeave()
{
    /// If no players remaining, flush the entire sync buffer (since there's no other
    ///     processing going on), then stop the timer.

    /// Q: Will GetFirstPC() return a valid object because the player logging out is
    ///     still "present"?  If so, ignore that, maybe if GetFirstPC() == oLeavingObject, and
    ///     no other characters are available.

    object oExiting = GetExitingObject();
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC))
    {
        if (oPC != oExiting)
            return;

        oPC = GetNextPC();
    }

    int nBuffer = audit_GetBufferSize();
    if (nBuffer > 0)
    {
        Debug("[AUDIT] No players remaining in module. Flushing " + IntToString(nBuffer) + " audit records from buffer to persistent storage.");
        audit_FlushBuffer(nBuffer);
    }
}

void audit_Flush_OnTimerExpire()
{
    audit_FlushBuffer(AUDIT_FLUSH_CHUNK_SIZE);
}

void audit_OnModulePOST()
{
    audit_POST();
}

void audit_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    if (HasChatOption(oPC, "test"))
        audit_POST();
    else if (HasChatOption(oPC, "actor"))
    {
        json j = audit_GetObjectData(oPC);
        Debug("[AUDIT] Actor Data: \n" + JsonDump(j, 4));

        j = audit_GetObjectData(GetFirstObjectInArea(GetArea(oPC)));
        Debug("[AUDIT] Area Data: \n" + JsonDump(j, 4));
    }
    else if (HasChatOption(oPC, "testes"))
    {

        // [1] Define a details schema (no $id or $schema)
        json jDetailsSchema = JsonParse(r"
            {
                ""type"": ""object"",
                ""properties"": {
                    ""foo"": { ""type"": ""string"" },
                    ""bar"": { ""type"": ""integer"" }
                },
                ""required"": [ ""foo"" ],
                ""minProperties"": 1
            }
        ");

        // [2] Register the details schema for a test event
        audit_RegisterSchema("test_source", "test_event", jDetailsSchema);

        // [3] Build a valid details instance for the schema
        json jDetailsInstance = JsonParse(r"
            {
                ""foo"": ""hello"",
                ""bar"": 42
            }
        ");

        audit_SubmitRecord("test_source", "test_event", oPC, jDetailsInstance);


    }
    else if (HasChatOption(oPC, "schema"))
    {
        json j = JsonParse(r"
            {
                ""$id"": ""urn:example:valid_audit_details"",
                ""$schema"": ""urn:darksun_sot:audit_details"",
                ""expiry"": ""2026-01-31T12:00:00Z"",
                ""details"": {
                    ""type"": ""object"",
                    ""properties"": {
                        ""foo"": { ""type"": ""string"" }
                    },
                    ""required"": [ ""foo"" ]
                }
            }
        ");

        if (NWNXGetIsAvailable())
        {
            json jResult = NWNX_Schema_ValidateSchema(j);

            if (JsonObjectGet(jResult, "valid") == JSON_TRUE)
                Debug("[1] [AUDIT] Valid audit details schema.");
            else
            {
                Debug("[1] [AUDIT] INVALID audit details schema.");
                Debug(JsonDump(jResult, 4));
            }
        }

        j = JsonParse(r"
            {
                ""$id"": ""urn:example:invalid_audit_details"",
                ""$schema"": ""urn:darksun_sot:audit_details"",
                ""expiry"": ""2026-01-31T12:00:00Z"",
                ""details"": {
                    ""type"": ""object""
                }
            }
        ");

        if (NWNXGetIsAvailable())
        {
            json jResult = NWNX_Schema_ValidateSchema(j);

            if (JsonObjectGet(jResult, "valid") == JSON_TRUE)
                Debug("[2] [AUDIT] Valid audit details schema.");
            else
            {
                Debug("[2] [AUDIT] INVALID audit details schema.");
                Debug(JsonDump(jResult, 4));
            }
        }
    }
}
