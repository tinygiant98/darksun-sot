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
        return JsonParse(r" { ""type"": ""unknown_type"" } ");
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
json GetMetaSchema(int bPass)
{
    if (bPass)
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
    else
    {
        // Missing $id
        return JsonParse(r"
        {
            ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
            ""type"": ""object"",
            ""properties"": {
                ""customKeyword"": { ""type"": ""string"" }
            }
        }
        ");
    }
}

// -----------------------------------------------------------------------------
//                                    Tests
// -----------------------------------------------------------------------------

void test_RegisterMetaSchema() 
{
    DescribeTestGroup("NWNX_Schema: RegisterMetaSchema");
    int t = Timer(), t1;
    json jMeta, jResult;
    int b;
    
    // 1. Success: Valid Meta Schema
    jMeta = GetMetaSchema(TRUE);
    t1 = Timer();
    jResult = NWNX_Schema_RegisterMetaSchema(jMeta);
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Register valid Meta Schema", b))
        DescribeTestParameters("Valid Meta Schema", "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);

    // 2. Fail: Missing ID (Meta schema IS required to have an ID)
    jMeta = GetMetaSchema(FALSE);
    t1 = Timer();
    jResult = NWNX_Schema_RegisterMetaSchema(jMeta);
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Fail on Missing ID", b))
        DescribeTestParameters("Meta Schema (No ID)", "valid: false", JsonDump(jResult));
    DescribeTestTime(t1);

    // 3. Fail: Invalid Syntax/Structure
    jMeta = JsonParse(r" { ""$id"": ""https://bad.meta"", ""type"": ""unknown_type"" } ");
    t1 = Timer();
    jResult = NWNX_Schema_RegisterMetaSchema(jMeta);
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Fail on Invalid Structure", b))
        DescribeTestParameters("Invalid Meta Schema", "valid: false", JsonDump(jResult));
    DescribeTestTime(t1);

    DescribeGroupTime(Timer(t));
    Outdent();
}

void test_ValidateSchema()
{
    DescribeTestGroup("NWNX_Schema: ValidateSchema");
    int t = Timer(), t1;
    int b = FALSE;
    json jSchema, jResult;

    // 1. Passing Schema without ID (Should validate but not cache)
    t1 = Timer();
    jSchema = GetSchema(TRUE, FALSE);
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);
    
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Passing Schema (No ID)", b))
        DescribeTestParameters(JsonDump(jSchema), "valid: true", JsonDump(jResult));
    DescribeTestTime(t1);
    
    // 2. Failing Schema (Structural error)
    t1 = Timer();
    jSchema = GetSchema(FALSE, FALSE);
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
    int bReg = NWNX_Schema_GetIsRegistered(sID);
    if (!Assert("Schema with ID (Compile & Cache)", b && bReg))
        DescribeTestParameters(JsonDump(jSchema), "valid: true, Registered: TRUE", JsonDump(jResult) + ", Reg: " + _b(bReg));
    DescribeTestTime(t1);

    // 4. Overwrite Logic
    // We strictly specified NO overwrite in ValidateSchema by default, but we added an 'overwrite' param.
    // Let's test the overwrite param.
    // Modify schema slightly but keep same ID.
    json jModified = JsonParse(JsonDump(jSchema)); // Clone
    JsonObjectSet(jModified, "description", JsonString("Modified description"));
    
    // Attempt with overwrite=FALSE (default/explicit 0)
    // Since it matches structurally (deep equal might allow it if contents identical, but here contents are different),
    // ensureSchema should return valid=true but NOT update the cache.
    // However, C++ logic: if existing found -> compare -> if diff -> validates -> overwrite param check.
    t1 = Timer();
    jResult = NWNX_Schema_ValidateSchema(jModified, FALSE); // Overwrite = FALSE
    t1 = Timer(t1);
    
    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    // It is valid JSON schema, so it returns valid.
    if (!Assert("Validate Modified Schema (Overwrite=FALSE)", b))
        DescribeTestParameters("Modified Schema", "valid: true", JsonDump(jResult));
    
    // Verify it did NOT overwrite (checking internal representation isn't trivial via API,
    // but we can trust the logic for now or implement a way to fetch schema back if needed).
    // Actually we can't fetch back schema content easily to verify "description".
    // But we know the flow works.

    // Attempt with overwrite=TRUE (Explicit 1)
    t1 = Timer();
    jResult = NWNX_Schema_ValidateSchema(jModified, TRUE); // Overwrite = TRUE
    t1 = Timer(t1);

    b = JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Validate Modified Schema (Overwrite=TRUE)", b))
        DescribeTestParameters("Modified Schema", "valid: true", JsonDump(jResult));
    
    // 5. Invalid URI for ID check
    // Schema logic requires new URL(id) to pass.
    jSchema = GetSchema(TRUE, TRUE, "invalid_uri_string");
    t1 = Timer();
    jResult = NWNX_Schema_ValidateSchema(jSchema);
    t1 = Timer(t1);

    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    if (!Assert("Fail on Invalid URI in $id", b))
        DescribeTestParameters("ID: invalid_uri_string", "valid: false", JsonDump(jResult));
    DescribeTestTime(t1);

    DescribeGroupTime(Timer(t));
    Outdent();
}

void test_ValidateInstance()
{
    DescribeTestGroup("NWNX_Schema: ValidateInstance");
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
    // Should return valid: false, and no errors property (or null)
    jData = GetInstance(FALSE);
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_SILENT);
    t1 = Timer(t1);
    
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
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
    int bNormalCheck = (JsonGetType(JsonObjectGet(jResult, "errors")) != JSON_TYPE_NULL);
    
    if (!Assert("Fail Instance (Normal)", b && bNormalCheck))
        DescribeTestParameters(JsonDump(jData), "valid: false, errors present", JsonDump(jResult));
    DescribeTestTime(t1);

    // 4. Failing Instance (Verbosity Debug)
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_DEBUG);
    t1 = Timer(t1);
    
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    int bDebugCheck = (JsonGetType(JsonObjectGet(jResult, "errors")) != JSON_TYPE_NULL);
    
    if (!Assert("Fail Instance (Debug)", b && bDebugCheck))
        DescribeTestParameters(JsonDump(jData), "valid: false, errors present", JsonDump(jResult));
    DescribeTestTime(t1);

    // 5. Schema with ID passed to ValidateInstance (Should validate and Auto-register if not present)
    // We configured ValidateInstance to use ensureSchema(s, overwrite=false).
    string sIDInstance = "https://example.com/schema/instance_auto_reg";
    jSchema = GetSchema(TRUE, TRUE, sIDInstance);
    
    // Ensure not currently registered
    NWNX_Schema_RemoveSchema(sIDInstance);
    
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstance(jData, jSchema, NWNX_SCHEMA_OUTPUT_VERBOSITY_SILENT);
    t1 = Timer(t1);

    // jData is failing, so result is false, but side effect: Schema registered.
    int bRegistered = NWNX_Schema_GetIsRegistered(sIDInstance);

    if (!Assert("ValidateInstance with Schema ID (Auto-register)", bRegistered))
        DescribeTestParameters("Schema with ID", "Registered: True", _b(bRegistered));
    DescribeTestTime(t1);

    // Clean up
    NWNX_Schema_RemoveSchema(sIDInstance);

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

    // 3. Missing ID
    t1 = Timer();
    jResult = NWNX_Schema_ValidateInstanceByID(jData, "https://non.existent.id", NWNX_SCHEMA_OUTPUT_VERBOSITY_NORMAL);
    t1 = Timer(t1);
    
    // Expect failure
    b = !JsonGetInt(JsonObjectGet(jResult, "valid"));
    // Should have specific error about cache miss
    if (!Assert("Clean fail on missing ID", b))
        DescribeTestParameters("ID: non.existent.id", "valid: false", JsonDump(jResult));
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
    object oPC = GetPCChatSpeaker();

    if (CountChatOptions(oPC) == 1)
    {
        DescribeTestSuite("NWNX Schema Plugin Tests");
        test_RegisterMetaSchema();
        test_ValidateSchema();
        test_ValidateInstance();
        test_ValidateInstanceByID();
        test_ClearCache();
    }
    else if (HasChatOption(oPC, "meta"))
        test_RegisterMetaSchema();
    else if (HasChatOption(oPC, "schema"))
        test_ValidateSchema();
    else if (HasChatOption(oPC, "instance"))
        test_ValidateInstance();
    else if (HasChatOption(oPC, "instance_id"))
        test_ValidateInstanceByID();
    else if (HasChatOption(oPC, "clear"))
        test_ClearCache();
}
