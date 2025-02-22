void main()
{
    //when a player enters this area
    object oObj = GetEnteringObject();
    ExecuteScript("scale33", oObj);

    //force the skybox to turn on if not already on
    //SetSkyBox(7);


    //moved to module onLoad
    //DelayCommand(0.25f, ExecuteScript("hb_updatetime"));


    //check if area sun has been set up

    /*
    if (GetLocalInt(OBJECT_SELF, "SUN_TIMER_SET") != 1){
        object oTimer = GetNearestObjectByTag("timer_sun", oObj);
        if (GetIsObjectValid(oTimer)) {
            FloatingTextStringOnCreature("Sun timer was found.", GetFirstPC());
            SignalEvent(oTimer, EventUserDefined(9666));
        } else {
            FloatingTextStringOnCreature("The sun timer cannot be found.", GetFirstPC());
        }
    } else {
        FloatingTextStringOnCreature("Sun timer already set.", GetFirstPC());
    }

    if (GetLocalInt(OBJECT_SELF, "MOON_TIMER_SET") != 1){
        object oTimer = GetNearestObjectByTag("timer_moon", oObj);
        if (GetIsObjectValid(oTimer)) {
            FloatingTextStringOnCreature("Moon timer was found.", GetFirstPC());
            SignalEvent(oTimer, EventUserDefined(9666));
        } else {
            FloatingTextStringOnCreature("The moon timer cannot be found.", GetFirstPC());
        }
    } else {
        FloatingTextStringOnCreature("Moon timer already set.", GetFirstPC());
    }
    */

    /*
    if (GetLocalInt(OBJECT_SELF, "SUN_TIMER_SET") != 1){
        //locate the managed skybox placeable
        object oSkyBox = GetNearestObjectByTag("AREA_SKYBOX");
        if (!GetIsObjectValid(oSkyBox)) {
            //area skybox does not exist, make one
            int areaWidth = GetAreaSize(AREA_WIDTH, OBJECT_SELF);
            int areaHeight = GetAreaSize(AREA_HEIGHT, OBJECT_SELF);
            location areaCenter = Location(OBJECT_SELF, Vector(IntToFloat(areaWidth)/5.0f, IntToFloat(areaHeight)/5.0f, 0.0f), 0.0f);
            oSkyBox = CreateObject(OBJECT_TYPE_PLACEABLE, "area_skybox", areaCenter, FALSE, "AREA_SKYBOX");
        }
        if (GetIsObjectValid(oSkyBox)){

            if (GetLocalInt(OBJECT_SELF, "SUN_SCALE") == 0){
                SetObjectVisualTransform(oSkyBox, OBJECT_VISUAL_TRANSFORM_SCALE, 1000.0);
                SetLocalInt(OBJECT_SELF, "SUN_SCALE", 10);
            }


            SignalEvent(oSkyBox, EventUserDefined(9666));
        }
    }
    */

}
