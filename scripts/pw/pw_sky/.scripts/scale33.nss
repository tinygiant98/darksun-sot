void main()
{
    //note: functions compiled before the changes to SetObjectVisualTransform will not work in later versions

    //two ways to get the subject of the script
    //object oObj = GetEnteringObject();
    object oObj = OBJECT_SELF;

    //begin changing scale

    //get the appearance.2da info for the current form
    int iAppearance = GetAppearanceType(oObj);
    if (iAppearance != APPEARANCE_TYPE_INVALID) {

        //check that we are not already at 33% scale
        if (GetLocalInt(oObj,"SCALE") == 33) return;

        //switch to small human appearance line
        //which should include new creperspace, walkdist, and VSLOW movement rate
        //SetCreatureAppearanceType(oObj, 974);

        //scale the model
        SetObjectVisualTransform(oObj, OBJECT_VISUAL_TRANSFORM_SCALE, 0.33f);
        //SetObjectVisualTransform(oObj, OBJECT_VISUAL_TRANSFORM_ANIMATION_SPEED, 0.33f);

        //this speed mod pairs well with the base speed mod in appearance.2da
        //effect eSpeed = EffectMovementSpeedDecrease(20);
        effect eSpeed = EffectMovementSpeedDecrease(67);
        eSpeed = HideEffectIcon(eSpeed);
        eSpeed = SupernaturalEffect(eSpeed);
        eSpeed = TagEffect(eSpeed, "SCALE");
        //ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpeed, oObj);

        //set a scale variable on the player so we know what scale we are in right now
        SetLocalInt(oObj, "SCALE", 33);

        //try new camera zoom limit settings
        //SetCameraLimits(oObj, -1.0f, -1.0f, 0.0f, 10.0f);

        //this sets the camera to a different position than is in appearance.2da due to 2da input min limit of 1.0
        //DelayCommand(3.0f, SetCameraHeight(oObj, 0.33f));
        DelayCommand(3.0f, SetCameraHeight(oObj, 0.66f));
    }
}
