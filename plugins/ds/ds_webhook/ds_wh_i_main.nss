// -----------------------------------------------------------------------------
//    File: ds_wh_i_main.nss
//  System: Webhooks (core)
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "ds_wh_i_config"
#include "ds_wh_i_const"
#include "ds_wh_i_text"

#include "util_i_data"
#include "util_i_chat"
#include "util_i_time"
#include "util_i_varlists"
#include "util_i_argstack"

#include "nwnx_player"
#include "nwnx_webhook_rch"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

const string SERVER_BOT = "Dark Sun: Sands of Time";

// TODO move these all to a 2da before upload
const string WEBHOOK_SERVER_STATUS = "/api/webhooks/829184956491497552/01moMC6NMXfW8krzRZ_Fx_2mbVCML_cXUee5YP0Amub8AXsHViYZiZlM1MirTXw-54tn/slack";
const string WEBHOOK_PLAYER_STATUS = "/api/webhooks/830788709565071372/Wh7oACfRLvJuGtGR4zCXrQE_OYm_aAGeS6ejk8r1T2LvcXBSRyrGxlV63z44TWR_JWVg/slack";
const string WEBHOOK_DM_CHAT =       "/api/webhooks/830790488914657281/puwIdFB1RItvjxEINaqbWf9sMxgqSVmCD1hmLFmZZ7dWvViBMGBg-7XG3TJaUK1SQKu5/slack";
const string WEBHOOK_SERVER_ERRORS = "/api/webhooks/830790628307632168/M6n3ybQBPHVEQLirEqATni-FHk9KjHloG3G31cTpibltutMSUTkD_3C1PgNt5iFgS7e-/slack";
const string WEBHOOK_CHAT_COMMANDS = "/api/webhooks/830790795753685053/YgjUAh-BDnK0cSIJfHUpJwPj_tI_9MkO_9CGLAwg_U39MwBf_CfkLGcrbBAVIRyR1017/slack";
const string WEBHOOK_CULTURE       = "/api/webhooks/830996077054263316/Uj-QCGd7NlD1DU17XuR1Qs3PdN_WYlxdqxdDGT1LC1eUD5ECJa5uthq1HIEvV9Dgy4BJ/slack";

const string LOGO = "https://i.postimg.cc/vZxdfwBS/dssot-logo-001-2.png";
const string CRYBABY = "https://i.postimg.cc/cCpRSP3G/crybaby.jpg";
const string HAPPYBABY = "https://i.postimg.cc/xdMw3wvJ/super-happy-baby.jpg";


string ObjectTypeToString(int nObjectType)
{
    switch (nObjectType)
    {
        case OBJECT_TYPE_AREA_OF_EFFECT: return "AREA OF EFFECT";
        case OBJECT_TYPE_CREATURE: return "CREATURE";
        case OBJECT_TYPE_DOOR: return "DOOR";
        case OBJECT_TYPE_ENCOUNTER: return "ENCOUNTER";
        case OBJECT_TYPE_INVALID: return "INVALID";
        case OBJECT_TYPE_ITEM: return "ITEM";
        case OBJECT_TYPE_PLACEABLE: return "PLACEABLE";
        case OBJECT_TYPE_STORE: return "STORE";
        case OBJECT_TYPE_TILE: return "TILE";
        case OBJECT_TYPE_TRIGGER: return "TRIGGER";
        case OBJECT_TYPE_WAYPOINT: return "WAYPOINT";
    }

    return "[NOT FOUND]";
}

/*
// nLogLevels: 0 = Dev, 1 = Public, 2 = DM - iPCsToo is depreciated and does nothing.
void DoNotify(string sMessage, int iPCsToo, int iLog=FALSE, int iWebHookLevel = 0, string sName = SERVER_BOT);

// nLogLevels: 0 = Dev, 1 = Public, 2 = DM
void LogHook(string sMessage, int nLogLevel, string sName = SERVER_BOT);

//  This function is a modified version of an idea used on Isle of Thain
//  Newcastle used to use a similar version, but seeing style in action prompted
//  the change. Our original script was party members, this one is for all PCs in
//  a sphere-based radius. This lets other people spot pick pocketers.
void SendMsgWithinDistance(object oPC, string sMessage);
*/

// - - Functions
/*
void SendMessageToAllPCs(string sMessage)
{
    // find each PC and display message
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);
        oPC = GetNextPC();
    }
}

void DoNotify(string sMessage, int iPCsToo, int iLog=FALSE, int iWebHookLevel = 0, string sName = SERVER_BOT)
{
    SendMessageToAllDMs(Color_ConvertString(sMessage, COLOR_RGB_TEAL));
    if (iLog) {LogHook(sMessage, iWebHookLevel, sName);}
}



void SendMsgToFactionWithinDistance(object oPC, string sMessage, float fDist)
{
    object oFaction = GetFirstFactionMember(oPC),
           oArea = GetArea(oPC);
    while (GetIsObjectValid(oFaction))
    {
        if (GetArea(oFaction) == oArea && GetDistanceBetween(oPC, oFaction) <= fDist)
        {
            DelayCommand(0.3, SendMessageToPC(oFaction, sMessage));
        }
        oFaction = GetNextFactionMember(oPC);
    }
}


void LoggedSendMessageToPC(object oPC, string sMsg, int iDMWebhook = FALSE, string sColor = COLOR_RGB_CYAN)
{
   string sLog = "To " + GetName(oPC) + ": " + sMsg;
   WriteTimestampedLogEntry(sLog);
   SendMessageToPC(oPC, Color_ConvertString(sMsg, sColor));

   if (iDMWebhook) {ModDMChatWebhook(oPC, "Logged Message to PC", sLog);
                    SendMessageToAllDMs(Color_ConvertString(sLog, sColor));}
}



void SendMsgWithinDistance(object oPC, string sMessage)
{
    location lLoc = GetLocation(oPC);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLoc, TRUE, OBJECT_TYPE_CREATURE);
    while (oTarget != OBJECT_INVALID)
    {
        // Only make this check on other PCs, excluding DMs
        if (oTarget != oPC && GetIsPC(oTarget) && !GetIsDM(oTarget) && !GetIsDMPossessed(oTarget))
            {
            // Only make this check for PCs that have better spot than the acquirer's PP
            if (GetSkillRank(SKILL_PICK_POCKET, oPC) <= GetSkillRank(SKILL_SPOT, oTarget))
                SendMessageToPC(oTarget, sMessage);
            }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLoc, TRUE, OBJECT_TYPE_CREATURE);
    }
}
*/
/*
void LogHook(string sMessage, int nLogLevel, string sName = SERVER_BOT)
{
    string sLevel;

    switch (nLogLevel)
        {
        case 0: ModDebugWebhook(sMessage);
                sLevel = "Dev."; break;
        case 1: ModPublicWebhook(sMessage);
                sLevel = "Public."; break;
        case 2: ModDMLogWebhook("Log", sMessage);
                sLevel = "DM."; break;
        default: ModDebugWebhook(sMessage);
                sLevel = "Dev."; break;
        }

    WriteTimestampedLogEntry("Logging: " + sMessage + " | Level: " + sLevel);
}
*/

void CultureWebhook()
{
    string sQuery = "SELECT culture_source.id, " +
                        "culture_source.source_name, " +
                        "culture_chapter.chapter_number, " +
                        "culture_chapter.chapter_name, " +
                        "culture_section.section_name, " +
                        "culture_subsection.subsection_name, " +
                        "culture_paragraph.id, " +
                        "culture_paragraph.paragraph_number, " +
                        "culture_paragraph.paragraph_text " +
                    "FROM culture_source " +
                        "INNER JOIN (culture_chapter " +
                            "INNER JOIN ((culture_section " +
                                "INNER JOIN culture_subsection " +
                                    "ON culture_section.id = culture_subsection.section_id) " +
                                "INNER JOIN culture_paragraph " +
                                    "ON culture_subsection.id = culture_paragraph.subsection_id) " +
                                "ON culture_chapter.ID = culture_section.chapter_id) " +
                            "ON culture_source.ID = culture_chapter.source_id " +
                    "WHERE (((culture_source.active)=True) " +
                        "AND ((culture_chapter.active)=True) " +
                        "AND ((culture_section.active)=True) " +
                        "AND ((culture_subsection.active)=True) " +
                        "AND ((culture_paragraph.active)=True)) " +
                    "ORDER BY RANDOM() " +
                    "LIMIT 1;";
    sqlquery sql = SqlPrepareQueryCampaign("dssot_culture", sQuery);
    if (SqlStep(sql))
    {
        string sSourceID = SqlGetString(sql, 0);
        string sSource = SqlGetString(sql, 1);
        string sChapterNumber = SqlGetString(sql, 2);
        string sChapterName = SqlGetString(sql, 3);
        string sSectionName = SqlGetString(sql, 4);
        string sSubsectionName = SqlGetString(sql, 5);
        string sParagraphID = SqlGetString(sql, 6);
        string sParagraphNumber = SqlGetString(sql, 7);
        string sText = SqlGetString(sql, 8);

        string sConstructedMsg;
        struct NWNX_WebHook_Message stMessage;

        sQuery = "SELECT id, image_address " +
                 "FROM culture_image " +
                 "WHERE source_id = @source_id " +
                    "AND active = True " +
                 "ORDER BY RANDOM() " +
                 "LIMIT 1;";
        sqlquery sqlImage = SqlPrepareQueryCampaign("dssot_culture", sQuery);
        SqlBindString(sqlImage, "@source_id", sSourceID);

        string sThumbnail, sImageID, sImageAddress;
        if (SqlStep(sqlImage))
        {
            sImageID = SqlGetString(sqlImage, 0);
            sImageAddress = SqlGetString(sqlImage, 1);
            sThumbnail = sImageAddress;
        }
        else
            sThumbnail = LOGO;

        if (d10() == 1)
        {
            sThumbnail = LOGO;
            sImageID = "";
        }

        string sFooter = "Sands of Time | Snippet ID " + sParagraphID +
            (sImageID == "" ? "" : " | Image ID " + sImageID);
        
        stMessage.sUsername = "You Uncultured Swine";
        stMessage.sThumbnailURL = sThumbnail;
        stMessage.sColor = "#bc8812";
        stMessage.sAvatarURL = LOGO;
        stMessage.sTitle = "From *" + sSource + "*, Chapter " + sChapterNumber +
            ": " + sChapterName + ", " + sSectionName + 
            (sSectionName == sSubsectionName ? "" : ", " + sSubsectionName) +
            ", Paragraph " + sParagraphNumber;
        stMessage.sDescription = sText;
        stMessage.sFooterText = sFooter;
        stMessage.iTimestamp = GetUnixTimeStamp();
        sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_CULTURE, stMessage);
        NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_CULTURE, sConstructedMsg);
    }
}

void LogWebhook(object oPC, int nLogMode = LOG_IN)
{
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage;

    string sTitle, sDescription = "**" + sName + "** has ";   

    if (nLogMode == LOG_IN)
    {
        sTitle = "LOGIN";
        sDescription += "logged in!";
    }
    else if (nLogMode == LOG_OUT)
    {
        sTitle = "LOGOUT";
        sDescription += "logged out!";
    }

    if (_GetIsDM(oPC) && nLogMode == LOG_IN)
        sDescription += " Parental supervision has arrived!";

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = sTitle;
    stMessage.sColor = "#14aed3";
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = LOGO;
    stMessage.sDescription = sDescription;

    stMessage.sField1Name = "PLAYERS";
    stMessage.sField1Value = IntToString(CountObjectList(MODULE, PLAYER_ROSTER) + (nLogMode == LOG_IN ? 1 : -1));
    stMessage.iField1Inline = TRUE;

    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = GetUnixTimeStamp();

    stMessage.sField1Name = "ACCOUNT";
    stMessage.sField1Value = GetPCPlayerName(oPC);
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "LEVEL";
    stMessage.sField2Value = IntToString(GetHitDice(oPC));
    stMessage.iField2Inline = TRUE;

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", WEBHOOK_PLAYER_STATUS, stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discord.com", WEBHOOK_PLAYER_STATUS, sConstructedMsg);
}

void LogDetailedWebhook(object oPC, int nLogMode = LOG_IN)
{
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage;

    string sTitle, sDescription = "**" + sName + "** has ";   

    if (nLogMode == LOG_IN)
    {
        sTitle = "LOGIN";
        sDescription += "logged in!";
    }
    else if (nLogMode == LOG_OUT)
    {
        sTitle = "LOGOUT";
        sDescription += "logged out!";
    }

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = sTitle;
    stMessage.sColor = "#14aed3";
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = LOGO;
    stMessage.sDescription = sDescription;

    stMessage.sField1Name = "PLAYERS";
    stMessage.sField1Value = IntToString(CountObjectList(MODULE, PLAYER_ROSTER) + (nLogMode == LOG_IN ? 1 : -1));
    stMessage.iField1Inline = TRUE;

    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = GetUnixTimeStamp();

    stMessage.sField2Name = "IP";
    stMessage.sField2Value = GetPCIPAddress(oPC);
    stMessage.iField2Inline = TRUE;

    stMessage.sField3Name = "CD";
    stMessage.sField3Value = GetPCPublicCDKey(oPC);
    stMessage.iField3Inline = TRUE;

    stMessage.sField4Name = "ACCOUNT";
    stMessage.sField4Value = GetPCPlayerName(oPC);
    stMessage.iField4Inline = TRUE;

    stMessage.sField5Name = "BIC";
    stMessage.sField5Value = NWNX_Player_GetBicFileName(oPC);
    stMessage.iField5Inline = TRUE;

    stMessage.sField6Name = "LEVEL";
    stMessage.sField6Value = IntToString(GetHitDice(oPC));
    stMessage.iField6Inline = TRUE;

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", WEBHOOK_DM_CHAT, stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discord.com", WEBHOOK_DM_CHAT, sConstructedMsg);
}
/*
void ModLvlUpWebhook(object oPC, string sMessage, string sDM)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = sDM;
  stMessage.sColor = "#bc8812";
  stMessage.sTitle = "Congratulations "+GetName(oPC)+"!";
  stMessage.sDescription = sMessage;

  stMessage.sAuthorName = GetName(oPC);
  stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
  stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";

    stMessage.sField2Name = "IP";
    stMessage.sField2Value = GetPCIPAddress(oPC);
    stMessage.iField2Inline = TRUE;

    stMessage.sField3Name = "CD";
    stMessage.sField3Value = GetPCPublicCDKey(oPC);
    stMessage.iField3Inline = TRUE;

    stMessage.sField4Name = "ACCOUNT";
    stMessage.sField4Value = GetPCPlayerName(oPC);
    stMessage.iField4Inline = TRUE;

    stMessage.sField5Name = "BIC";
    stMessage.sField5Value = NWNX_Player_GetBicFileName(oPC);
    stMessage.iField5Inline = TRUE;

    stMessage.sField6Name = "LEVEL";
    stMessage.sField6Value = IntToString(GetHitDice(oPC));
    stMessage.iField6Inline = TRUE;


  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PUBLIC, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PUBLIC, sConstructedMsg);
}

void ModPublicWebhook(string sMessage)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sColor = "#bc8812";
  stMessage.sDescription = sMessage;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PUBLIC, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PUBLIC, sConstructedMsg);
}

void ModDebugWebhook(string sMessage)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sColor = "#bc8812";
  stMessage.sDescription = sMessage;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_DEBUG, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_DEBUG, sConstructedMsg);
}


void ModChatWebhook(string sMessage)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sColor = "#bc8812";
  stMessage.sDescription = sMessage;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_CHAT_LOG, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_CHAT_LOG, sConstructedMsg);
}

void ModDMChatWebhook(object oPC, string sPCName, string sMessage)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT + ": DM Channel";
  stMessage.sColor = "#bc8812";

  stMessage.sAuthorName = sPCName;
  stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
  stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";

  stMessage.sDescription = sMessage;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PRIVATE, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PRIVATE, sConstructedMsg);
}*/

void DMChatWebhook()
{
    string sConstructedMsg;
    struct NWNX_WebHook_Message stMessage;

    object oPC = GetPCChatSpeaker();
    string sMessage = GetPCChatMessage();

    stMessage.sUsername = "Sands of Time DM Log";
    stMessage.sColor = "#bc8812";

    stMessage.sAuthorName = GetName(oPC);
    stMessage.sThumbnailURL = LOGO;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";

    stMessage.sDescription = sMessage;
    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = GetUnixTimeStamp();
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_DM_CHAT, stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_DM_CHAT, sConstructedMsg);
}

/*
void ModDMLogWebhook(string sPCName, string sMessage)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT + ": DM Log";
  stMessage.sColor = "#bc8812";

  stMessage.sAuthorName = sPCName;
  stMessage.sThumbnailURL = LOGO;

  stMessage.sDescription = sMessage;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PRIVATE, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PRIVATE, sConstructedMsg);
}

void ModRPWebhook(object oPC, string sPCName, string sMessage)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = "The Pig's Arms Inn";
  stMessage.sColor = "#bc8812";

  stMessage.sAuthorName = sPCName;
  stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
  stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";

  stMessage.sDescription = sMessage;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_RP, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_RP, sConstructedMsg);
}
*/
void ModuleEventWebhook(string sTitle, string sDescription, string sUserName, string sThumbnail)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = sUserName;
  stMessage.sThumbnailURL = sThumbnail;
  stMessage.sColor = "#bc8812";
  stMessage.sTitle = sTitle;
  stMessage.sDescription = sDescription;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = GetUnixTimeStamp();

  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_SERVER_STATUS, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_SERVER_STATUS, sConstructedMsg);
}

void ChatCommandWebhook(object oPC)
{
    string sConstructedMsg;
    struct NWNX_WebHook_Message stMessage;

    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    string sCommandLine = cl.chatLine;
    string sResult = cl.result;

    string sRole;
    if (_GetIsPC(oPC)) sRole = "Player";
    if (_GetIsDM(oPC)) sRole = "DM";
    if (GetIsDeveloper(oPC)) sRole = "Developer";

    string sArea = GetName(GetArea(oPC));
    string sName = GetName(oPC);
    string sTitle = "CHAT COMMAND LOGGED";
    string sDescription = "**" + sName + "** has used a chat command.";

    stMessage.sUsername = "Dark Sun: Sands of Time Chat Command Logger";
    stMessage.sTitle = sTitle;
    stMessage.sColor = "#14aed3";
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = LOGO;
    stMessage.sDescription = sDescription;

    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = GetUnixTimeStamp();

    stMessage.sField1Name = "ACCOUNT";
    stMessage.sField1Value = GetPCPlayerName(oPC);
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "IP";
    stMessage.sField2Value = GetPCIPAddress(oPC);
    stMessage.iField2Inline = TRUE;

    stMessage.sField3Name = "CD";
    stMessage.sField3Value = GetPCPublicCDKey(oPC);
    stMessage.iField3Inline = TRUE;

    stMessage.sField4Name = "AREA";
    stMessage.sField4Value = sArea;
    stMessage.iField4Inline = TRUE;

    stMessage.sField5Name = "ROLE";
    stMessage.sField5Value = sRole;
    stMessage.iField5Inline = TRUE;

    stMessage.sField6Name = "CHAT COMMAND";
    stMessage.sField6Value = sCommandLine;
    stMessage.iField6Inline = FALSE;

    stMessage.sField7Name = "CHAT RESULT";
    stMessage.sField7Value = sResult;
    stMessage.iField7Inline = FALSE;

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_CHAT_COMMANDS, stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_CHAT_COMMANDS, sConstructedMsg);
}

void DebugWebhook(int nLevel, string sMessage, object oTarget)
{
    string sLevel = DebugLevelToString(nLevel);
    string sName = GetName(oTarget);
    string sTag = GetTag(oTarget);

    sMessage = UnColorString(sMessage);

    string sConstructedMsg;
    struct NWNX_WebHook_Message stMessage;

    stMessage.sUsername = "Terminix:  Kills Bugs Dead";
    stMessage.sThumbnailURL = LOGO;
    stMessage.sColor = "#bc8812";
    stMessage.sTitle = "Error Alert:  **" + sLevel + "**";
    stMessage.sDescription = sMessage;
    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = GetUnixTimeStamp();

    stMessage.sField1Name = "MESSAGE LEVEL";
    stMessage.sField1Value = sLevel;
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "OBJECT NAME";
    stMessage.sField2Value = sName;
    stMessage.iField2Inline = TRUE;

    stMessage.sField3Name = "OBJECT TAG";
    stMessage.sField3Value = sTag;
    stMessage.iField3Inline = TRUE;

    if (oTarget != GetModule())
    {
        stMessage.sField4Name = "OBJECT AREA";
        stMessage.sField4Value = GetName(GetArea(oTarget));
        stMessage.iField4Inline = TRUE;
    
        string sObjectType;
        int nObjectType = GetObjectType(oTarget);
        if (nObjectType == 0)
        {
            if (GetArea(oTarget) == oTarget)
                sObjectType = "AREA";
            else
                sObjectType = "[NOT FOUND]";
        }
        else
            sObjectType = ObjectTypeToString(nObjectType);

        stMessage.sField5Name = "OBJECT TYPE";
        stMessage.sField5Value = sObjectType;
        stMessage.iField5Inline = TRUE;
    }

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_SERVER_ERRORS, stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_SERVER_ERRORS, sConstructedMsg);
}

void SendQuestWebhookMessage(object oPC)
{
    RunLibraryScript("QUEST_GetCurrentWebhookMessage");
    string sMessage = GetReturnValueString();

    if (sMessage == "")
        return;

    PushArgumentString(sMessage);
    PushArgumentObject(oPC);

    RunLibraryScript("TOKEN_EvaluateTokens", oPC);
    sMessage = GetReturnValueString();

    string sConstructedMsg;
    struct NWNX_WebHook_Message stMessage;
    stMessage.sUsername = "Questy McQuestFace";
    stMessage.sThumbnailURL = LOGO;
    stMessage.sColor = "#bc8812";
    stMessage.sTitle = "Look!  Somebody did something!";
    stMessage.sDescription = sMessage;
    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = GetUnixTimeStamp();
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PLAYER_STATUS, stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PLAYER_STATUS, sConstructedMsg);
}

/*
void ModFlavorWebhook(string sMsg, string sDM, string sFlavor)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = sDM;
  stMessage.sThumbnailURL = LOGO_DICE;
  stMessage.sColor = "#bc8812";
  stMessage.sTitle = sFlavor;
  stMessage.sDescription = sMsg;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PUBLIC, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PUBLIC, sConstructedMsg);
}

void ModPvPWebhook(string sMsg, string sPvPDM, string sPvP)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = sPvPDM;
  stMessage.sThumbnailURL = LOGO_DICE;
  stMessage.sColor = "#bc8812";
  stMessage.sTitle = sPvP;
  stMessage.sDescription = sMsg;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PUBLIC, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PUBLIC, sConstructedMsg);
}

void ModRushWebhook(string sMsg, string sDM)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = sDM;
  stMessage.sThumbnailURL = LOGO_DICE;
  stMessage.sColor = "#bc8812";
  stMessage.sTitle = "Players are rushing the server to log in. Please wait a moment";
  stMessage.sDescription = sMsg;
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", WEBHOOK_PUBLIC, stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", WEBHOOK_PUBLIC, sConstructedMsg);
}

void ModDownWebhook() {
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sThumbnailURL = LOGO;
  stMessage.sColor = "#bc8812";
  stMessage.sDescription = "A Carpathian Nightmare server restart has begun";
  stMessage.sFooterText = GetName(GetModule());
  stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_PUBLIC_CHANNEL"), stMessage);
  NWNX_WebHook_SendWebHookHTTPS("discordapp.com", NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_PUBLIC_CHANNEL"), sConstructedMsg);
}

void CheatMaxStatsWebhook(object oPC, string sMessage)
{
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage;

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = "ALERT";
    stMessage.sColor = "#14aed3";
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";
    stMessage.sDescription = "**" + sName + "** has " + sMessage;
    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = SQLite_GetTimeStamp();

    stMessage.sField1Name = "CHA";
    stMessage.sField1Value = IntToString(GetAbilityScore(oPC, ABILITY_CHARISMA, TRUE));
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "CON";
    stMessage.sField2Value = IntToString(GetAbilityScore(oPC, ABILITY_CONSTITUTION, TRUE));
    stMessage.iField2Inline = TRUE;

    stMessage.sField3Name = "DEX";
    stMessage.sField3Value = IntToString(GetAbilityScore(oPC, ABILITY_DEXTERITY, TRUE));
    stMessage.iField3Inline = TRUE;

    stMessage.sField4Name = "INT";
    stMessage.sField4Value = IntToString(GetAbilityScore(oPC, ABILITY_INTELLIGENCE, TRUE));
    stMessage.iField4Inline = TRUE;

    stMessage.sField5Name = "STR";
    stMessage.sField5Value = IntToString(GetAbilityScore(oPC, ABILITY_STRENGTH, TRUE));
    stMessage.iField5Inline = TRUE;

    stMessage.sField6Name = "WIS";
    stMessage.sField6Value = IntToString(GetAbilityScore(oPC, ABILITY_WISDOM, TRUE));
    stMessage.iField6Inline = TRUE;

   // public webhook
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_ADMIN_CHANNEL"), stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_ADMIN_CHANNEL"), sConstructedMsg);
}

void CheatCreationStatsWebhook(object oPC, string sMessage)
{
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage;

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = "ALERT";
    stMessage.sColor = "#14aed3";
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";
    stMessage.sDescription = "**" + sName + "** has " + sMessage;
    stMessage.sFooterText = GetName(GetModule());
    stMessage.iTimestamp = SQLite_GetTimeStamp();

    stMessage.sField1Name = "Feat Count";
    stMessage.sField1Value = IntToString(GetLocalInt(oPC, "GetHasValidFeatCount"));
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "Feat Invalid";
    stMessage.sField2Value = GetLocalString(oPC, "GetHasInvalidFeats");
    stMessage.iField2Inline = TRUE;

    stMessage.sField3Name = "Abililty Score";
    stMessage.sField3Value = IntToString(GetAbilityScore(oPC, ABILITY_CHARISMA) +
    GetAbilityScore(oPC, ABILITY_CONSTITUTION) + GetAbilityScore(oPC, ABILITY_DEXTERITY) +
    GetAbilityScore(oPC, ABILITY_INTELLIGENCE) + GetAbilityScore(oPC, ABILITY_STRENGTH) + GetAbilityScore(oPC, ABILITY_WISDOM));
    stMessage.iField3Inline = TRUE;

    stMessage.sField4Name = "Hitpoints";
    stMessage.sField4Value = IntToString(GetMaxHitPoints(oPC));
    stMessage.iField4Inline = TRUE;

    stMessage.sField5Name = "Skill Points";
    stMessage.sField5Value = GetLocalString(oPC, "GetHasLegalSkillPoints");
    stMessage.iField5Inline = TRUE;

    stMessage.sField6Name = "AC";
    stMessage.sField6Value = IntToString(GetAC(oPC));
    stMessage.iField6Inline = TRUE;

   // public webhook
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_ADMIN_CHANNEL"), stMessage);
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_ADMIN_CHANNEL"), sConstructedMsg);
}


string RandomDMName()
{
    string sDorriansBored;

    switch(Random(5))
        {
        case 0: sDorriansBored = "DM Fraus";     break;
        case 1: sDorriansBored = "DM Mask";  break;
        case 2: sDorriansBored = "DM Tarrasque";  break;
        case 3: sDorriansBored = "DM Shimmer";  break;
        case 4: sDorriansBored = "DM Anvil";  break;
        }

    return sDorriansBored;
}


string RandomDMWelcome()
{
    string sDorriansBored;

    switch(Random(4))
        {
        case 0: sDorriansBored = "The companions find themselves in a sun washed glade. Enemies far behind them. A collective sigh pays homage to the welcome respite. As the sun nestles down to its own slumber the night transforms glory into solmn retrospect. You hear a twig snap in the darkness. Roll for initiative.";
                                    break;
        case 1: sDorriansBored = "The companions gather around a table at The Pig's Arms Inn in Saltsprey, to share a warm fire, brave smiles and the mirth of strangers after their forays into the Shadow Bog. The wicked magics of Hedron and the ills of his disease infested host left far behind. As Bonnie, the waitress, delivers another round of Ironblood Whiskey a cloaked man pushes past her on his way to the bathroom muttering something about having found the entrance to the elven City of Skye. Roll for initiative.";
                                    break;
        case 2: sDorriansBored = "The voice hissed: 'You let us in. And now you are going to have to let us stay. Don't you see? All this time. we've been building it. We've been building it... for you. All that work, all that pain, all of it for you. And now it's time. Time to end it. And we are going to end you. And when you are gone, we are going to end your friends. And then we are going to end... everyone.' Roll for initiative.";
                                    break;
        case 3: sDorriansBored = "'Ancient beings - such as the one that we may not name', Professor Ryan continued, 'were not composed altogether of flesh and blood. They had shape - for did not this star-fashioned image prove it? - but that shape was not made of matter. When the stars were right, They could plunge from world to world through the sky; but when the stars were wrong, They could not live. But although They no longer lived, " +
                                   "They would never really die. They all lay in stone houses in Their great city, preserved by mighty and vile spells, for a glorious resurrection when the stars and the earth might once more be ready for Them. But at that time some force from outside must serve to liberate Their bodies. The spells that preserved Them intact likewise prevented Them from making an initial move, and They could only lie awake " +
                                   "in the dark and think whilst uncounted millions of years rolled by. They knew all that was occurring in the universe, but Their mode of speech was transmitted thought. Even now They talked in Their tombs. When, after infinities of chaos, the first men came, the Great Old Ones spoke to the sensitive among them by moulding their dreams; for only thus could Their language reach the fleshly minds of mammals.' "+
                                   "Roll for initiative.";
        }

    return sDorriansBored;
}*/
