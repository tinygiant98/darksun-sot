// -----------------------------------------------------------------------------
//    File: test_i_events.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Event handlers
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_data"
#include "test_i_main"
#include "x2_inc_switches"
#include "dlg_i_dialogs"
#include "chat_i_main"
#include "util_i_libraries"
#include "core_c_config"
#include "util_i_time"

#include "pw_i_metrics"
#include "pw_i_core"

#include "nwnx_schema"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void test_OnClientEnter()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC))
        return;

    pw_CreateTables();

    object oItem = GetItemPossessedBy(oPC, "util_playerdata");
    if (!GetIsObjectValid(oItem))
        CreateItemOnObject("util_playerdata", oPC);

    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "hook_player07");
}

void test_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    if (HasChatOption(oPC, "metrics"))
    {
        if (HasChatOption(oPC, "tables"))
        {
            pw_CreateTables();

            string s = r"
                INSERT INTO player (player_id) 
                VALUES ('unique_player_001');
            ";
            pw_ExecuteCampaignQuery(s);

            s = r"
                SELECT 
                    player_id, 
                    json(data) AS readable_json
                FROM player
                WHERE player_id = 'unique_player_001';
            ";
            sqlquery q = pw_PrepareCampaignQuery(s);
            if (SqlStep(q)) Notice("Found it! ->" + JsonDump(SqlGetJson(q, 1)));
            else Notice("Did not find it!");

            return;

            s = r"
                UPDATE player 
                SET data = jsonb('{""health"": 100, ""mana"": 50}') 
                WHERE player_id = 'unique_player_001';
            ";
            pw_ExecuteCampaignQuery(s);

            return;

            s = r"
                UPDATE player 
                SET data = jsonb_insert(data, '$.test_item', 'test_value')
                WHERE player_id = 'unique_player_001';
            ";
            pw_ExecuteCampaignQuery(s);


        }
//        else if (HasChatOption(oPC, "valid"))
//        {
//            string s = "SELECT json_valid(x'0100');";
//            sqlquery q = SqlPrepareQueryObject(GetModule(), s);
//
//
//
//            //string s = "SELECT json_valid(jsonb(:json_text), 4);";
//            //sqlquery q = SqlPrepareQueryObject(GetModule(), s);
//            //SqlBindString(q, ":json_text", "{}");
//
//
//            //string s = "SELECT json_valid('{}', 6);";
//            //qlquery q = SqlPrepareQueryObject(GetModule(), s);
//            if (SqlStep(q))
//                SendChatResult("Metrics: JSON valid -> " + IntToString(SqlGetInt(q, 0)), oPC);
//            else
//            {
//                SendChatResult("Metrics: SQL Step failed", oPC, CHAT_FLAG_ERROR);
//                string sError = SqlGetError(q);
//                SendChatResult("Metrics: SQL Error -> " + sError, oPC, CHAT_FLAG_ERROR);
//            }
//        }
//        else
//        {
//
//            json jSchema = JsonParse(r"
//                {
//                ""combat"": {
//                        ""kills"": {
//                            ""total"": ""ADD"",
//                            ""race"": {
//                                ""*"": ""ADD""
//                            }
//                        }
//                    }
//
//                }
//            ");
//
//            metrics_RegisterSchema("pw", "test_metrics", jSchema);
//        }
//    }
//    else if (HasChatOption(oPC, "hc"))
//    {
//        ExecuteScript("cm_hcmode_onoff", oPC);
//    }
//    else if (HasChatOption(oPC, "schema"))
//    {
//        Notice("Attempting to run schema plugin validation test...");
//
//        json jSchema = JsonParse(r"
//            {
//                ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
//                ""$id"": ""urn:ds_sot:test_schema"",
//                ""title"": ""TestSchema"",
//                ""type"": ""object"",
//                ""properties"": {
//                    ""testId"": { ""type"": ""integer"", ""minimum"": 1 },
//                    ""testName"": { ""type"": ""string"", ""minLength"": 3 }
//                },
//                ""required"": [""testId"", ""testName""]
//            }
//        ");
//
//        Notice("Validate the following schema against metaschema draft 2020-12");
//        Notice(JsonDump(jSchema, 4));
//
//        int t = Timer();
//        json jResult = NWNX_Schema_ValidateSchema(jSchema);
//        t = Timer(t);
//        
//        Notice("Schema validation result: " + JsonDump(jResult));
//        Notice("Validation took " + FloatToString(t/1000000f) + "s.");
//
//        jSchema = JsonParse(r"
//            {
//                ""$id"":""urn:ds_sot:test_schema"",
//                ""$schema"":""https://json-schema.org/draft/2020-12/schema"",
//                ""properties"":{
//                    ""testId"":{
//                        ""minimum"": ""one"",
//                        ""type"":""integer""
//                    },
//                    ""testName"":{
//                        ""minLength"": -5,
//                        ""type"":""string""
//                    }
//                },
//                ""required"":[
//                    ""testId"",
//                    ""testName""
//                ],
//                ""title"":""TestSchema"",
//                ""type"":""object""
//            }
//        ");
//        jResult = NWNX_Schema_ValidateSchema(jSchema);
//        Notice("Schema validation result (expected failure): " + JsonDump(jResult, 4));
//
////        jSchema = JsonParse(r"
////            {
////                ""$schema"": ""json-schema.org"",
////                ""$id"": ""urn:nwn:player_character"",
////                ""title"": ""PlayerCharacter"",
////                ""type"": ""object"",
////                ""properties"": {
////                    ""name"": { 
////                        ""type"": ""string"", 
////                        ""minLength"": 3, 
////                        ""maxLength"": 20,
////                        ""errorMessage"": {
////                            ""minLength"": ""Name '${0}' is too short; it must be at least 3 characters."",
////                            ""maxLength"": ""Name is too long; it cannot exceed 20 characters.""
////                        }
////                    },
////                    ""level"": { 
////                        ""type"": ""integer"", 
////                        ""minimum"": 1, 
////                        ""maximum"": 40,
////                        ""errorMessage"": {
////                            ""type"": ""Level must be a whole number."",
////                            ""minimum"": ""Level ${0} is too low; the minimum is 1."",
////                            ""maximum"": ""Level ${0} is too high; the level cap is 40.""
////                        }
////                    },
////                    ""alignment"": { 
////                        ""type"": ""string"", 
////                        ""enum"": [""Lawful"", ""Neutral"", ""Chaotic""],
////                        ""errorMessage"": ""Alignment must be Lawful, Neutral, or Chaotic.""
////                    }
////                },
////                ""required"": [""name"", ""level""],
////                ""errorMessage"": {
////                    ""required"": {
////                        ""name"": ""Please provide a character name."",
////                        ""level"": ""You must specify a character level.""
////                    }
////                }
////            }
////        ");
//
//        jSchema = JsonParse(r"
//            {
//                ""$schema"": ""https://json-schema.org/draft/2020-12/schema"",
//                ""$id"": ""urn:nwn:player_character"",
//                ""title"": ""PlayerCharacter"",
//                ""type"": ""object"",
//                ""properties"": {
//                    ""name"": { 
//                        ""type"": ""string"", 
//                        ""minLength"": 3, 
//                        ""maxLength"": 20 
//                    },
//                    ""level"": { 
//                        ""type"": ""integer"", 
//                        ""minimum"": 1, 
//                        ""maximum"": 40 
//                    },
//                    ""alignment"": { 
//                        ""type"": ""string"", 
//                        ""enum"": [""Lawful"", ""Neutral"", ""Chaotic""] 
//                    }
//                },
//                ""required"": [""name"", ""level""]
//            }
//        ");
//        jResult = NWNX_Schema_ValidateSchema(jSchema);
//        Notice("Schema validation result: " + JsonDump(jResult, 4));
//        NWNX_Schema_RegisterSchema(jSchema, TRUE);
//
//        json jInstance = JsonParse(r"
//            {
//                ""name"": ""Elminster"",
//                ""level"": 35,
//                ""alignment"": ""Neutral""
//            }
//        ");
//        jResult = NWNX_Schema_ValidateInstanceByID(jInstance, "urn:nwn:player_character");
//        Notice("Instance validation result: " + JsonDump(jResult, 4));
//
//        jInstance = JsonParse(r"
//            {
//                ""level"": 0,
//                ""alignment"": ""Lawful""
//            }
//        ");
////        jInstance = JsonParse(r"
////            {
////                ""name"": ""Al"",
////                ""level"": 99,
////                ""alignment"": ""Chaotic Evil""
////            }
////        ");
//
//        jResult = NWNX_Schema_ValidateInstanceByID(jInstance, "urn:nwn:player_character");
//        Notice("Instance validation result (expected failure): " + JsonDump(jResult, 4));
//
//
//
//    }
//    else if (HasChatOption(oPC, "nui"))
//    {
//        NWNX_Schema_RemoveSchema("urn:nwn:nui_master_schema:v1.0");
//
//        json j = JsonParse(ResManGetFileContents("nui_schema", RESTYPE_TXT));
//        NWNX_Schema_RegisterSchema(j, TRUE);
//
//
//        string s = "SELECT definition FROM nui_forms WHERE form = 'demo';";
//        sqlquery q = SqlPrepareQueryCampaign("nui_form_data", s);
//        if (SqlStep(q))
//        {
//            json jInstance = SqlGetJson(q, 0);
//
//            int t = Timer();
//            json jResult = NWNX_Schema_ValidateInstanceByID(jInstance, "urn:nwn:nui_master_schema:v1.0");
//            t = Timer(t);
//            Notice("NUI Form validation result: " + JsonDump(jResult, 4));
//            Notice("Validation took " + FloatToString(t/1000000.0) + "s.");
//        }
    }
    else if (HasChatOption(oPC, "schema"))
    {
        ExecuteScript("schema_test", oPC);
    }

}

void test_script_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;

    string sScript = GetChatArgument(oPC);
    if (sScript != "")
    {
        SendChatResult("Running script " + sScript + " on " + (_GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget)), oPC);
        RunLibraryScript(sScript, oTarget);
    }
    else
        SendChatResult("Cannot run script; script argument blank" +
                       "\n  Arguments received -> " + GetChatArguments(oPC), oPC, CHAT_FLAG_ERROR);
}

void test_identify_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (!GetIdentified(oItem))
        {
            SetIdentified(oItem, TRUE);
            SendChatResult("Identifying " + GetTag(oItem) + " as " + GetName(oItem), oPC);
        }

        oItem = GetNextItemInInventory(oPC);
    }
}

void test_items_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    string sObject, sObjects = GetChatArguments(oPC);
    int n, nQty, nIndex, nCount = CountList(sObjects);

    for (n = 0; n < nCount; n++)
    {
        sObject = GetListItem(sObjects, n);
        if ((nIndex = FindSubString(sObject, ":")) != -1)
            nQty = StringToInt(StringParse(sObject, ":", TRUE));
        else
            nQty = 1;

        object oItem = CreateItemOnObject(sObject, oPC, nQty);
        SetIdentified(oItem, TRUE);

        SendChatResult("Created item {tag} " + GetTag(oItem) +
                       "{name} " + GetName(oItem) + " on " + GetName(oPC), oPC);
    }
}

void test_unlock_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    object oLocked = GetNearestObject(OBJECT_TYPE_DOOR, oPC);
    if (GetIsObjectValid(oLocked) && GetLocked(oLocked))
        SetLocked(oLocked, FALSE);

    oLocked = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC);
    if (GetIsObjectValid(oLocked) && GetLocked(oLocked))
    {
        SetLocked(oLocked, FALSE);
        SendChatResult("Unlocking " + GetTag(oLocked), oPC);
    }
}

void test_PlayerDataItem()
{
    int nEvent = GetUserDefinedItemEventNumber();

    // * This code runs when the Unique Power property of the item is used
    // * Note that this event fires PCs only
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC = GetItemActivator();
        SetLocalString(oPC, "*Dialog", "TestDialog");
        StartDialog(oPC, OBJECT_SELF, "TestDialog", TRUE, TRUE, TRUE);
    }
}

void test_convo_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    
    SetLocalString(oPC, "*Dialog", "TestDialog");
    Debug("Convo:  Starting Test System Dialog");
    StartDialog(oPC, OBJECT_SELF, "TestDialog", TRUE, TRUE, TRUE);
}

void test_libraries_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    if (!CountChatArguments(oPC))
        LoadLibraries(INSTALLED_LIBRARIES, TRUE);
    else
        LoadLibraries(GetChatArguments(oPC), TRUE);
}

void test_destroy_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    object oTarget = GetChatTarget(oPC);
    object oDestroy = GetNearestObjectByTag(GetChatArgument(oPC), oTarget);
    DestroyObject(oDestroy);
}

void test_go_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    int nArguments;

    if (nArguments = CountChatArguments(oPC))
    {
        if (nArguments == 1)
        {
            string sTarget = GetChatArgument(oPC, 0);
            object oTarget = GetObjectByTag(sTarget);
            if (GetIsObjectValid(oTarget))
            {
                Debug("Go: TargetFound -> " + GetTag(oTarget));
                if (!GetObjectType(oTarget))
                    oTarget = GetFirstObjectInArea(oTarget);

                AssignCommand(oPC, ActionJumpToObject(oTarget));
            }
            else
                SendChatResult("Go: " + sTarget + " is not a valid target", oPC, CHAT_FLAG_ERROR);
        }
        else
            SendChatResult("Go: You can only jump to one place, dumbass.  Make a decision already.", oPC, CHAT_FLAG_ERROR);
    }
    else
        SendChatResult("Go: No target argument provided", oPC, CHAT_FLAG_ERROR);
}

void test_get_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    int n, nCount = CountChatArguments(oPC);
    string sTarget;
    object oTarget, oStake;

    if (!nCount)
        SendChatResult("Get: No target argument(s) provided", oPC, CHAT_FLAG_ERROR);

    oStake = GetChatTarget(oPC);
    
    for (n = 0; n < nCount; n++)
    {
        sTarget = GetChatArgument(oPC, n);
        oTarget = GetObjectByTag(sTarget);
        if (GetIsObjectValid(oTarget))
        {
            SendChatResult("Get: getting " + sTarget, oPC);
            AssignCommand(oTarget, ActionJumpToObject(oStake));
        }
    }
}

void test_time_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;

    int nHours;
    string sTime;

    if (HasChatKey(oPC, "add"))
    {
        nHours = StringToInt(GetChatKeyValue(oPC, "add"));
        sTime = AddGameTimeElement(TIME_HOURS, nHours);
    }
    else if (HasChatKey(oPC, "sub,subtract"))
    {
        nHours = StringToInt(GetChatKeyValue(oPC, "sub,subtract"));
        sTime = SubtractGameTimeElement(TIME_HOURS, nHours);
    }
    else
        SendChatResult("Current game time is " + FormatGameTime(), oPC, CHAT_FLAG_INFO);

    if (sTime != "")
    {
        Notice("test_time_OnPlayerChat: sTime -> " + sTime);
        sTime = ConvertGameTimeToSystemTime(sTime);
        _SetCalendar(sTime, TRUE, TRUE);   
        SendChatResult("Game time has been set to " + FormatGameTime(), oPC);
    } 
}

void test_var_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    int bHelp;
    
    // If no variable names passed, abort
    if (!CountChatArguments(oPC))
    {
        SendChatResult("Variable names required, but not received", oPC, CHAT_FLAG_ERROR);
        return;
    }

    if (HasChatOption(oPC, "h,help"))
        bHelp = TRUE;

    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;

    if (HasChatOption(oPC, "set"))
    {
        if (bHelp)
            SendChatResult(SetVariableHelp(), oPC, CHAT_FLAG_HELP);
        else
            SetVariable(oPC, oTarget);
    }
    else if (HasChatOption(oPC, "d,del,delete"))
    {
        if (bHelp)
            SendChatResult(DeleteVariableHelp(), oPC, CHAT_FLAG_HELP);
        else
            DeleteVariable(oPC, oTarget);
    }
    else
    {
        if (bHelp)
            SendChatResult(GetVariableHelp(), oPC, CHAT_FLAG_HELP);
        else
            GetVariable(oPC, oTarget);
    }
}

void test_level_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    int nLevel = StringToInt(GetChatArgument(oPC, 0));
    int nLevelXP = 500 * nLevel * (nLevel - 1);
    int nPC = GetXP(oPC);

    GiveXPToCreature(oPC, nLevelXP - nPC);
}

void test_stake_OnPlayerChat()
{
    Debug("Stake chat command not yet active");
    /*
    if (CountChatArguments(sArguments) > 1)
    {
        Error("Stake: Too many arguments, only the first will be used");
        string sVarName = GetListItem(sArguments);
        location lPC = GetLocation(oPC);

        Debug("Stake: Setting current location as ''")
        _SetLocalLocation(oPC, sVarName, lPC);
    }*/
    SetPCChatMessage();
}

void test_debug_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC, CHAT_TARGET_NO_REVERT, GetModule())) == OBJECT_INVALID)
        return;

    int nLevel;
    if (HasChatOption(oPC, "5,debug"))
        nLevel = 5;
    else if (HasChatOption(oPC, "4,notice"))
        nLevel = 4;
    else if (HasChatOption(oPC, "3,warning,warn"))
        nLevel = 3;
    else if (HasChatOption(oPC, "2,error"))
        nLevel = 2;
    else if (HasChatOption(oPC, "1,critical,crit"))
        nLevel = 1;
    else if (HasChatOption(oPC, "0,none"))
        nLevel = 0;
    else
        nLevel = 5;

    SetDebugLevel(nLevel, oTarget);
    SendChatResult("Debug level for " + (oTarget == GetModule() ? GetName(oTarget) : GetTag(oTarget)) + " set to " +
                   (nLevel == 5 ? "DEBUG" : 
                    nLevel == 4 ? "NOTICE" :
                    nLevel == 3 ? "WARNING" :
                    nLevel == 2 ? "ERROR" :
                    nLevel == 1 ? "CRITICAL ERROR" : "NONE"), oPC);
}
