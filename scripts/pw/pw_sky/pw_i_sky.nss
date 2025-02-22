/// ----------------------------------------------------------------------------
/// @file   pw_i_sky.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Sky Library (core)
/// ----------------------------------------------------------------------------

#include "nw_inc_dynlight"

float sky_GetModuleTime()
{
    float fModuleHour = 0f;

    fModuleHour += IntToFloat(GetTimeMinute());
    fModuleHour += IntToFloat(GetTimeSecond()) / 60f;
    fModuleHour += IntToFloat(GetTimeMillisecond()) / 60000f;

    fModuleHour /= (HoursToSeconds(1) / 60f);

    return fModuleHour += IntToFloat(GetTimeHour());
}

void sky_UpdatePlayerShaders()
{
    if(!GetLocalInt(GetModule(), NW_DYNAMIC_LIGHT_RUNNING))
        return;

    ExecuteScript("nw_dynlight");

    float fModuleHour = sky_GetModuleTime();
    float fFadeTime = NW_DYNAMIC_LIGHT_FADE_TIME + NW_DYNAMIC_LIGHT_FADE_TIME_OVERLAP;
    float fGlobalLatitude = GetLocalFloat(GetModule(), NW_DYNAMIC_LIGHT_MODULE_GLOBAL_LATITUDE);

    if (FloatToInt(fGlobalLatitude) == 0)
        fGlobalLatitude = NW_DYNAMIC_LIGHT_MODULE_GLOBAL_LATITUDE_DEFAULT;

    vector vSun = GetSunlightDirectionFromTime(fGlobalLatitude, fFadeTime);
    vector vMoon = GetMoonlightDirectionFromTime(fGlobalLatitude, fFadeTime);

    vSun.z *= 0.5;
    vMoon.z *= 0.5;

    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        SetShaderUniformFloat(oPC, SHADER_UNIFORM_1, fModuleHour);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_1, vSun.x, vSun.y, vSun.z, 1f);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_2, vMoon.x, vMoon.y, vMoon.z, 1f);

        object oArea = GetArea(oPC);
        vector vSunColor = IntRGBToVector(GetAreaLightColor(AREA_LIGHT_COLOR_SUN_DIFFUSE, oArea));
        vector vMoonColor = IntRGBToVector(GetAreaLightColor(AREA_LIGHT_COLOR_MOON_DIFFUSE, oArea));

        SetShaderUniformVec(oPC, SHADER_UNIFORM_3, vSunColor.x, vSunColor.y, vSunColor.z, 1f);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_4, vMoonColor.x, vMoonColor.y, vMoonColor.z, 1f);

        SetAreaLightDirection(AREA_LIGHT_DIRECTION_SUN, vSun, oArea, fFadeTime);
        SetAreaLightDirection(AREA_LIGHT_DIRECTION_MOON, vMoon, oArea, fFadeTime);

        oPC = GetNextPC();
    }
}
