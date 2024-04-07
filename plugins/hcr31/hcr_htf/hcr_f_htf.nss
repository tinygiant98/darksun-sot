/// ----------------------------------------------------------------------------
/// @file   hcr_f_htf.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  HTF Status Form
/// ----------------------------------------------------------------------------

#include "nui_i_library"
#include "util_i_color"
#include "util_i_variables"
#include "hcr_i_htf"

const string FORM_ID = "hcr_htf_status";
const string FORM_TITLE = "HTF Status";
const string VERSION = "0.1.0";
const string IGNORE_FORM_EVENTS = "";

const int HTF_FLAG_UPDATE_HUNGERTHIRST = 0x1;
const int HTF_FLAG_UPDATE_FATIGUE = 0x2;
const int HTF_FLAG_UPDATE_ALCOHOL = 0x4;
const int HTF_FLAG_UPDATE_ALL = 0xf;

string pc(object oPC) { return HexColorString(GetName(oPC), COLOR_GREEN); }
string success(string s) { return HexColorString(s, COLOR_GREEN_LIGHT); }
string fail(string s) { return HexColorString(s, COLOR_RED_LIGHT); }
string rewardtype(int n) { return n == 1 ? "MATERIA" : n == 2 ? "FEAT" : n == 3 ? "OTHER" : "UNKNOWN"; }
string script(string s, int bStatus = -1)
{
    string sMessage = HexColorString("[hcr_f_htf:" + s + "]", COLOR_ORANGE);
    if (bStatus == -1) // note
        return sMessage;
    else if (bStatus == 0) // enter
        return HexColorString("->", COLOR_GREEN_LIGHT) + sMessage;
    else if (bStatus == 1) // exit
        return HexColorString("<-", COLOR_RED_LIGHT) + sMessage;
    else
        return fail("script unknown");
}

int DEBUG_ME = TRUE;
void debug(string s)
{
    if (DEBUG_ME)
        SendMessageToPC(GetFirstPC(), s);
}

string htf_GetInfoBarColor(float f)
{
    if      (f <= 0.15) return NUI_DefineHexColor(COLOR_RED);
    else if (f <= 0.50) return NUI_DefineHexColor(COLOR_YELLOW);
    else                return NUI_DefineHexColor(COLOR_GREEN);
}

void htf_UpdateInfoBars(object oPC, int nEvents = HTF_FLAG_UPDATE_ALL)
{
    if (nEvents & HTF_FLAG_UPDATE_ALL || nEvents & HTF_FLAG_UPDATE_HUNGERTHIRST)
    {
        float fHunger = GetPlayerFloat(oPC, H2_HT_CURR_HUNGER);
        float fThirst = GetPlayerFloat(oPC, H2_HT_CURR_THIRST);

        NUI_SetBindJ(oPC, FORM_ID, "barHunger:value", JsonFloat(fHunger));
        NUI_SetBindJ(oPC, FORM_ID, "barThirst:value", JsonFloat(fThirst));

        NUI_SetBind(oPC, FORM_ID, "barHunger:color", htf_GetInfoBarColor(fHunger));
        NUI_SetBind(oPC, FORM_ID, "barThirst:color", htf_GetInfoBarColor(fThirst));
    }

    if (nEvents & HTF_FLAG_UPDATE_ALL || nEvents & HTF_FLAG_UPDATE_FATIGUE)
    {
        float fFatigue = GetPlayerFloat(oPC, H2_CURR_FATIGUE);
        NUI_SetBindJ(oPC, FORM_ID, "barFatigue:value", JsonFloat(fFatigue));
        NUI_SetBind(oPC, FORM_ID, "barFatigue:color", htf_GetInfoBarColor(fFatigue));
    }

    // TODO Alcohol special bar ...
    if (nEvents & HTF_FLAG_UPDATE_ALL || nEvents & HTF_FLAG_UPDATE_ALCOHOL)
    {
        float f = GetPlayerFloat(oPC, H2_HT_CURR_ALCOHOL);
        NUI_SetBindJ(oPC, FORM_ID, "barAlcohol:value", JsonFloat(f));
        NUI_SetBindJ(oPC, FORM_ID, "barAlcohol:visible", JsonBool(f > 0.0));
    }
}

void HandleNUIEvents()
{

}

void HandleModuleEvents()
{
    int nEvent = GetCurrentlyRunningEvent();
    if (nEvent == EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT)
    {
        object oPC = OBJECT_SELF;

        int nType = GetUserDefinedEventNumber();
        if (nType == HTF_EVENT_UPDATE_HUNGERTHIRST)
            htf_UpdateInfoBars(oPC, HTF_FLAG_UPDATE_HUNGERTHIRST);
        else if (nType == HTF_EVENT_UPDATE_FATIGUE)
            htf_UpdateInfoBars(oPC, HTF_FLAG_UPDATE_FATIGUE);
        else if (nType == HTF_EVENT_UPDATE_ALCOHOL)
            htf_UpdateInfoBars(oPC, HTF_FLAG_UPDATE_ALCOHOL);
        else if (nType == HTF_EVENT_UPDATE_ALL)
            htf_UpdateInfoBars(oPC, HTF_FLAG_UPDATE_ALL);
    }
}

void DefineForm()
{
    float fFormW = 275.0;
    float fFormH = 75.0;
    float fMarginW = 50.0;
    float fMarginH = 5.0;
    float fBarW = fFormW - fMarginW;
    float fBarH = 10.0;
    float x1, y1, y2;

    NUI_CreateForm(FORM_ID, VERSION);
        NUI_SetTOCTitle(FORM_TITLE);
        NUI_SetResizable(FALSE);
        NUI_SubscribeEvent(EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT);
    {
        NUI_AddColumn();
            NUI_AddSpacer();
                NUI_SetHeight(0.1);
                NUI_AddCanvas();
                {
                    string sPoints;
                    string sGray = NUI_DefineHexColor(COLOR_GRAY_LIGHT);
                    string sRed = NUI_DefineHexColor(COLOR_RED);
                    string sYellow = NUI_DefineHexColor(COLOR_YELLOW);
                    string sGreen = NUI_DefineHexColor(COLOR_GREEN);
                    
                    y1 = fMarginH;
                    y2 = fFormH - fMarginH;

                    // 0.0 Line
                    x1 = fMarginW / 2.0;
                    sPoints = NUI_GetLinePoints(x1, y1, x1, y2);
                    NUI_DrawLine(sPoints);
                        NUI_SetColor(sGray);

                    // 100.0 Line
                    x1 = fFormW - (fMarginW / 2.0);
                    sPoints = NUI_GetLinePoints(x1, y1, x1, y2);
                    NUI_DrawLine(sPoints);
                        NUI_SetColor(sGreen);

                    // 0.15 line
                    x1 = fMarginW / 2.0 + fBarW * 0.15;
                    sPoints = NUI_GetLinePoints(x1, y1, x1, y2);
                    NUI_DrawLine(sPoints);
                        NUI_SetColor(sRed);

                    // 0.25 line
                    x1 = fMarginW / 2.0 + fBarW * 0.25;
                    sPoints = NUI_GetLinePoints(x1, y1, x1, y2);
                    NUI_DrawLine(sPoints);
                        NUI_SetColor(sGray);

                    // 0.75 line
                    x1 = fMarginW / 2.0 + fBarW * 0.75;
                    sPoints = NUI_GetLinePoints(x1, y1, x1, y2);
                    NUI_DrawLine(sPoints);
                        NUI_SetColor(sGray);

                    // 0.5 line
                    x1 = fMarginW / 2.0 + fBarW * 0.5;
                    sPoints = NUI_GetLinePoints(x1, y1, x1, y2);
                    NUI_DrawLine(sPoints);
                        NUI_SetColor(sYellow);
                } NUI_CloseCanvas();

            NUI_AddProgressBar();
                NUI_BindValue("barHunger:value");
                NUI_BindForegroundColor("barHunger:color");
                NUI_SetDimensions(fBarW, fBarH);
                NUI_SetBorder(FALSE);
            NUI_AddProgressBar();
                NUI_BindValue("barThirst:value");
                NUI_BindForegroundColor("barThirst:color");
                NUI_SetDimensions(fBarW, fBarH);
                NUI_SetBorder(FALSE);
            NUI_AddProgressBar();
                NUI_BindValue("barFatigue:value");
                NUI_BindForegroundColor("barFatigue:color");
                NUI_SetDimensions(fBarW, fBarH);
                NUI_SetBorder(FALSE);
            NUI_AddProgressBar();
                NUI_BindValue("barAlcohol:value");
                NUI_BindForegroundColor("barAlcohol:color");
                NUI_SetDimensions(fBarW, fBarH);
                NUI_BindVisible("barAlcohol:visible");
                NUI_SetBorder(FALSE);
        NUI_CloseColumn();
    }

    NUI_CreateDefaultProfile();
    {
        NUI_SetProfileBind("geometry", NUI_DefineRectangle(-1.0, 0.0, fFormW, fFormH));

        NUI_SetProfileBind("barHunger:value", nuiFloat(0.5));
        NUI_SetProfileBind("barThirst:value", nuiFloat(0.8));
        NUI_SetProfileBind("barFatigue:value", nuiFloat(0.2));
        NUI_SetProfileBind("barAlchohol:value", nuiFloat(0.9));

        NUI_SetProfileBind("barHunger:color", NUI_DefineHexColor(COLOR_YELLOW));
        NUI_SetProfileBind("barThirst:color", NUI_DefineHexColor(COLOR_GREEN));
        NUI_SetProfileBind("barFatigue:color", NUI_DefineHexColor(COLOR_RED));        
        NUI_SetProfileBind("barAlchohol:color", NUI_DefineHexColor(COLOR_GOLD));

        NUI_SetProfileBind("barAlcohol:visible", nuiBool(TRUE));
    }
}

void BindForm()
{
    json jBinds = NUI_GetOrphanBinds(FORM_ID);
    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sValue, sBind = JsonGetString(JsonArrayGet(jBinds, n));
        json jValue = JsonNull();
   
        if (sValue != "")
            NUI_SetBind(OBJECT_SELF, FORM_ID, sBind, sValue);
        else if (jValue != JsonNull())
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, sBind, jValue);
    }
}
