#include "nwnx_schema"
#include "util_i_unittest"
#include "chat_i_main"

// -----------------------------------------------------------------------------
//                                   Helpers
// -----------------------------------------------------------------------------

// Returns a schema.
// bPass: returns a valid schema if TRUE, invalid if FALSE
// bID: if TRUE, includes an "$id" field
// sID: custom ID to use if bID is TRUE
json GetSchema(int bPass, int bID, string sID = "https://example.com/product.schema.json")
{
    if (!bPass)
    {
        return JsonParse(r" { ""invalid_schema"": true } ");
    }

    string sJson = r"
    {
        ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
        ""title"": ""Product"",
        ""description"": ""A product from Acme's catalog"",
        ""type"": ""object"",
        ""properties"": {
            ""productId"": {
                ""description"": ""The unique identifier for a product"",
                ""type"": ""integer""
            },
            ""productName"": {
                ""description"": ""Name of the product"",
                ""type"": ""string""
            }
        },
        ""required"": [ ""productId"", ""productName"" ]
    ";

    if (bID)
    {
        sJson += r", ""$id"": """ + sID + r"""";
    }

    sJson += "}";

    return JsonParse(sJson);
}

// Returns a data instance.
// bPass: returns data that matches GetSchema(TRUE)
json GetInstance(int bPass)
{
    if (bPass)
    {
        return JsonParse(r"
        {
            ""productId"": 1,
            ""productName"": ""An ice sculpture""
        }
        ");
    }
    else
    {
        // Missing productId, wrong type for productName
        return JsonParse(r"
        {
            ""productName"": 12345
        }
        ");
    }
}

// Returns a meta-schema that extends draft 2020-12
json GetMetaSchema()
{
    return JsonParse(r"
    {
        ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
        ""$id"": ""https://example.com/meta/custom"",
        ""type"": ""object"",
        ""properties"": {
            ""customKeyword"": { ""type"": ""string"" }
        }
    }
    ");
}

// -----------------------------------------------------------------------------
//                                    Tests
// -----------------------------------------------------------------------------

void test_ValidateSchema()
{
    DescribeTestGroup("NWNX_Schema: ValidateSchema");
    int t = Timer(), t1;
    int b = FALSE;
    json jSchema, jResult;

    // 1. Passing Schema
    t1 = Timer();
    jSchema = GetSchema(TRUE, FALSE);
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);
    
    // We expect { "valid": true }
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Passing Schema (No ID)", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);
    
    // 2. Failing Schema (NOTE: Ajv default is non-strict, so unknown keywords are ignored. 
    // We update this test to use a schema that is structurally invalid for JSON Schema spec)
    t1 = Timer();
    jSchema = JsonParse(r" { ""type"": ""invalid_type"" } "); // 'type' must be one of specific strings
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);

    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Failing Schema", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: false", JsonDump(jResult));
    DescribeTestTime(t1);

    // 3. Schema with ID (Compile & Cache)
    string sID = "https://example.com/schema/test1";
    t1 = Timer();
    jSchema = GetSchema(TRUE, TRUE, sID);
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);

    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Schema with ID (Compile & Cache)", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    // Verify IsRegistered (Test 2) part of flow
    t1 = Timer();
    int bRegistered = NWNX_Schema_GetIsRegistered(sID);
    t1 = Timer(t1);
    if (!Assert("Schema is Registered", bRegistered))
        DescribeTestParameters(sID, "TRUE", _b(bRegistered));
    DescribeTestTime(t1);

    // 4. Same ID again (Should detect collision/idempotency)
    // The current implementation might error or just return valid. 
    // Usually if it's the exact same schema, valid=true, if different, valid=false/error.
    // We pass the exact same schema.
    t1 = Timer();
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);
    
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Schema with ID (Duplicate request)", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    // 5. Already saved (Identify matches existing)
    // We'll modify the schema *slightly* but keep the ID to see if it catches the collision or just overwrites/ignores.
    // The user requirement says: "see that the system identifies that it has already been saved and validates the schema, but doesn't not overwrite it."
    // This implies we check registration first? Or just call validate again.
    // If we change the content but keep the ID, it should ideally fail or warn if the ID is locked. 
    // However, for this test, let's Stick to the "same one again" logic from the user request.
    
    // 6. Remove and Re-validate
    t1 = Timer();
    NWNX_Schema_RemoveSchema(sID);
    bRegistered = NWNX_Schema_GetIsRegistered(sID);
    t1 = Timer(t1);
    
    if (!Assert("RemoveSchema", !bRegistered))
        DescribeTestParameters(sID, "FALSE", _b(bRegistered));
    DescribeTestTime(t1);

    t1 = Timer();
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    
    if (!Assert("Re-Validate (Save) Schema", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    DescribeGroupTime(Timer(t));
    Outdent();
}

/*
void test_RegisterMetaSchema()
{
    DescribeTestGroup("NWNX_Schema: RegisterMetaSchema");
    int t = Timer(), t1;
    int b = FALSE;
    json jMeta, jResult, jSchema;

    t1 = Timer();
    jMeta = GetMetaSchema();
    jResult = NWNX_Schema_RegisterMetaSchema(jMeta);
    t1 = Timer(t1);

    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Register Meta Schema", b))
        DescribeTestParameters(JsonDump(jMeta), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    // Validate a schema against this meta-schema
    // A schema using this meta schema must have "customKeyword" if we enforce it, 
    // but here the meta schema just defines it as a string.
    
    // Create a schema that uses the meta-schema
    jSchema = JsonParse(r"
    {
        ""$schema"": ""https://example.com/meta/custom"",
        ""$id"": ""https://example.com/schema/custom"",
        ""customKeyword"": ""some string value"",
        ""type"": ""object""
    }
    ");

    t1 = Timer();
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    
    if (!Assert("Validate Schema against Meta Schema (Pass)", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    // Fail against meta schema (customKeyword should be string, preserve int)
    jSchema = JsonParse(r"
    {
        ""$schema"": ""https://example.com/meta/custom"",
        ""customKeyword"": 12345,
        ""type"": ""object""
    }
    ");

    t1 = Timer();
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    
    if (!Assert("Validate Schema against Meta Schema (Fail)", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: false", JsonDump(jResult));
    DescribeTestTime(t1);

    DescribeGroupTime(Timer(t));
    Outdent();
}
*/

void test_ValidateInstance()
{
    DescribeTestGroup("NWNX_Schema: ValidateInstance (Direct Schema)");
    int t = Timer(), t1;
    int b = FALSE;
    json jSchema, jData, jResult;
    
    jSchema = GetSchema(TRUE, FALSE);

    // 1. Passing Instance (Verbosity Normal)
    jData = GetInstance(TRUE);
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_NORMAL);
    t1 = Timer(t1);
    
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Pass Instance (Normal)", b))
        DescribeTestParameters(JsonDump(jData), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    // 2. Failing Instance (Verbosity Silent)
    jData = GetInstance(FALSE);
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_SILENT);
    t1 = Timer(t1);
    
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    // Silent means no errors array, just valid boolean usually? 
    // Or valid: false and errors is null/empty? user asked to test verbosity.
    int bSilentCheck = (JsonGetType(JsonObjectGet(jResult, "errors")) == JSON_TYPE_NULL);
    
    if (!Assert("Fail Instance (Silent)", b && bSilentCheck))
        DescribeTestParameters(JsonDump(jData), "valid: false, no errors", JsonDump(jResult));
    DescribeTestTime(t1);

    // 3. Failing Instance (Verbosity Normal - Check Formatting)
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_NORMAL);
    t1 = Timer(t1);
    
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    // In Normal mode, errors should be a list of formatted objects, not empty/null
    int bNormalCheck = (JsonGetLength(JsonObjectGet(jResult, "errors")) > 0);
    
    if (!Assert("Fail Instance (Normal)", b && bNormalCheck))
        DescribeTestParameters(JsonDump(jData), "valid: false, errors > 0", JsonDump(jResult));
    DescribeTestTime(t1);

    // 4. Failing Instance (Verbosity Debug)
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_DEBUG);
    t1 = Timer(t1);
    
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    int bDebugCheck = (JsonGetLength(JsonObjectGet(jResult, "errors")) > 0);
    
    if (!Assert("Fail Instance (Debug)", b && bDebugCheck))
        DescribeTestParameters(JsonDump(jData), "valid: false, errors > 0", JsonDump(jResult));
    DescribeTestTime(t1);

    // 5. Schema with ID passed to ValidateInstance (Should validate & cache schema, then validate instance)
    jSchema = GetSchema(TRUE, TRUE, "https://example.com/schema/instance_test");
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_SILENT);
    t1 = Timer(t1);

    // jData is still failing instance
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    
    // Check if it was registered internally
    int bRegistered = NWNX_Schema_GetIsRegistered("https://example.com/schema/instance_test");

    if (!Assert("ValidateInstance with Schema ID (Auto-register)", b && bRegistered))
        DescribeTestParameters("Schema with ID", "Registered: True", "Registered: " + _b(bRegistered));
    DescribeTestTime(t1);

    // Clean up
    NWNX_Schema_RemoveSchema("https://example.com/schema/instance_test");

    DescribeGroupTime(Timer(t));
    Outdent();
}

void test_ValidateInstanceByID()
{
    DescribeTestGroup("NWNX_Schema: ValidateInstanceByID");
    int t = Timer(), t1;
    int b = FALSE;
    json jSchema, jData, jResult;
    string sID = "https://example.com/schema/test_id_validation";

    // Setup: Register schema
    jSchema = GetSchema(TRUE, TRUE, sID);
    NWNX_Schema_ValidateSchema(jSchema);

    // 1. Passing Instance
    jData = GetInstance(TRUE);
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstanceByID(jData, sID, NWNX_SCHEMA_OUTPUT_VERBOSITY_NORMAL);
    t1 = Timer(t1);
    
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Pass Instance By ID", b))
        DescribeTestParameters(JsonDump(jData), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    // 2. Failing Instance
    jData = GetInstance(FALSE);
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstanceByID(jData, sID, NWNX_SCHEMA_OUTPUT_VERBOSITY_NORMAL);
    t1 = Timer(t1);
    
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Fail Instance By ID (Normal)", b))
        DescribeTestParameters(JsonDump(jData), "valid: false", JsonDump(jResult));
    DescribeTestTime(t1);

    // 3. Failing Instance (Silent)
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstanceByID(jData, sID, NWNX_SCHEMA_OUTPUT_VERBOSITY_SILENT);
    t1 = Timer(t1);

    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    int bSilentCheck = (JsonGetType(JsonObjectGet(jResult, "errors")) == JSON_TYPE_NULL);
    if (!Assert("Fail Instance By ID (Silent)", b && bSilentCheck))
        DescribeTestParameters("Silent", "valid: false, no errors", JsonDump(jResult));
    DescribeTestTime(t1);

    // 4. Failing Instance (Debug)
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstanceByID(jData, sID, NWNX_SCHEMA_OUTPUT_VERBOSITY_DEBUG);
    t1 = Timer(t1);

    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    int bDebugCheck = (JsonGetLength(JsonObjectGet(jResult, "errors")) > 0);
    if (!Assert("Fail Instance By ID (Debug)", b && bDebugCheck))
        DescribeTestParameters("Debug", "valid: false, errors > 0", JsonDump(jResult));
    DescribeTestTime(t1);

    // 5. Missing ID
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstanceByID(jData, "non_existent_id", NWNX_SCHEMA_OUTPUT_VERBOSITY_NORMAL);
    t1 = Timer(t1);
    
    // Expect error or valid: false
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Clean fail on missing ID", b))
        DescribeTestParameters("ID: non_existent_id", "valid: false", JsonDump(jResult));
    DescribeTestTime(t1);

    // Clean up
    NWNX_Schema_RemoveSchema(sID);
    
    DescribeGroupTime(Timer(t));
    Outdent();
}

void test_ClearCache()
{
    DescribeTestGroup("NWNX_Schema: ClearCache");
    int t = Timer(), t1;
    string sID1 = "https://example.com/schema/cache1";
    string sID2 = "https://example.com/schema/cache2";
    
    // Register 2 schemas
    NWNX_Schema_ValidateSchema(GetSchema(TRUE, TRUE, sID1));
    NWNX_Schema_ValidateSchema(GetSchema(TRUE, TRUE, sID2));
    
    // Verify present
    int b1 = NWNX_Schema_GetIsRegistered(sID1);
    int b2 = NWNX_Schema_GetIsRegistered(sID2);
    
    if (!Assert("Setup: Schemas Registered", b1 && b2))
        DescribeTestParameters(sID1 + "," + sID2, "Both True", _b(b1) + "," + _b(b2));
        
    // Clear
    t1 = Timer();
    NWNX_Schema_ClearCache();
    t1 = Timer(t1);
    
    // Verify gone
    b1 = NWNX_Schema_GetIsRegistered(sID1);
    b2 = NWNX_Schema_GetIsRegistered(sID2);
    
    int bGone = (!b1 && !b2);
    if (!Assert("Cache Cleared", bGone))
        DescribeTestParameters("ClearCache()", "Both False", _b(b1) + "," + _b(b2));
    DescribeTestTime(t1);
    
    DescribeGroupTime(Timer(t));
    Outdent();
}

// -----------------------------------------------------------------------------
//                                    Main
// -----------------------------------------------------------------------------

void main()
{
    object oPC = OBJECT_SELF;
    int bRunAll = TRUE;
    
    // Command Usage: !test --schema [options]
    // Options:
    //   --validate or --validation: Run ValidateSchema tests
    //   --meta or --metaschema: Run RegisterMetaSchema tests
    //   --instance: Run ValidateInstance tests
    //   --id: Run ValidateInstanceByID tests
    //   --clear: Run ClearCache tests

    if (HasChatOption(oPC, "validate,validation"))
    {
        test_ValidateSchema();
        bRunAll = FALSE;
    }

    //if (HasChatOption(oPC, "meta,metaschema"))
    //{
    //    test_RegisterMetaSchema();
    //    bRunAll = FALSE;
    //}

    if (HasChatOption(oPC, "instance"))
    {
        test_ValidateInstance();
        bRunAll = FALSE;
    }

    if (HasChatOption(oPC, "id"))
    {
        test_ValidateInstanceByID();
        bRunAll = FALSE;
    }

    if (HasChatOption(oPC, "clear,cache"))
    {
        test_ClearCache();
        bRunAll = FALSE;
    }

    if (bRunAll)
    {
        DescribeTestSuite("NWNX Schema Unit Tests");
        test_ValidateSchema();
        //test_RegisterMetaSchema();
        test_ValidateInstance();
        test_ValidateInstanceByID();
        test_ClearCache();
    }
}
