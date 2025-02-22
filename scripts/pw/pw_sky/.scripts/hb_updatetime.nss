#include "nw_inc_dynlight"

//custom function to get module time
float GetModuleTime()
{
    float fModuleHour = 0.0;

    //get module minutes
    fModuleHour += IntToFloat(GetTimeMinute());
    fModuleHour += IntToFloat(GetTimeSecond())/60.0f;
    fModuleHour += IntToFloat(GetTimeMillisecond())/60000.0f;

    //divide by module minutes per hour to get fraction of hour
    float fModuleMinutesPerHour = HoursToSeconds(1) / 60.0f;
    fModuleHour /= fModuleMinutesPerHour;

    //add module hour
    fModuleHour += IntToFloat(GetTimeHour());
    return fModuleHour;
}

void main()
{

    //initialize sun/moon cycle for v.35+
    ExecuteScript("nw_dynlight");

    float fModuleHour = GetModuleTime();

    //setup time vars
    float fFadeTime = 0.0;
    int bRecursive = 1;
    if(bRecursive)
    {
        if(!GetLocalInt(GetModule(), NW_DYNAMIC_LIGHT_RUNNING))
            return;

        fFadeTime = NW_DYNAMIC_LIGHT_FADE_TIME + NW_DYNAMIC_LIGHT_FADE_TIME_OVERLAP;
    }

    float fGlobalLatitude = GetLocalFloat(GetModule(), NW_DYNAMIC_LIGHT_MODULE_GLOBAL_LATITUDE);

    if(fGlobalLatitude == 0.0)
        fGlobalLatitude = NW_DYNAMIC_LIGHT_MODULE_GLOBAL_LATITUDE_DEFAULT;


    //get light positions based on time of day
    vector vSun = GetSunlightDirectionFromTime(fGlobalLatitude, fFadeTime);
    vector vMoon = GetMoonlightDirectionFromTime(fGlobalLatitude, fFadeTime);


    //send all PCs the details
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC)) {

        //pass global time to the shaders
        SetShaderUniformFloat(oPC, SHADER_UNIFORM_1, fModuleHour);

        //pass sun and moon positions to the shaders
        vSun.z *= 0.5;
        vMoon.z *= 0.5;
        SetShaderUniformVec(oPC, SHADER_UNIFORM_1, vSun.x, vSun.y, vSun.z, 1.0f);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_2, vMoon.x, vMoon.y, vMoon.z, 1.0f);

        //get player's local area sun and moon diffuse colors
    `   object oArea = GetArea(oPC);
        vector vSunColor = IntRGBToVector(GetAreaLightColor(AREA_LIGHT_COLOR_SUN_DIFFUSE, oArea));
        vector vMoonColor = IntRGBToVector(GetAreaLightColor(AREA_LIGHT_COLOR_MOON_DIFFUSE, oArea));

        //pass sun and moon colors
        SetShaderUniformVec(oPC, SHADER_UNIFORM_3, vSunColor.x, vSunColor.y, vSunColor.z, 1.0f);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_4, vMoonColor.x, vMoonColor.y, vMoonColor.z, 1.0f);

        //update the area details so the sun moves over time
        SetAreaLightDirection(AREA_LIGHT_DIRECTION_SUN, vSun, oArea, fFadeTime);
        SetAreaLightDirection(AREA_LIGHT_DIRECTION_MOON, vMoon, oArea, fFadeTime);


        oPC = GetNextPC();
    }


}
