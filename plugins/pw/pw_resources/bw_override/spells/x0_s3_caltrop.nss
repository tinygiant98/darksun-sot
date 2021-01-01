
#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"

void SetObject(location lTarget, object oVisual)
{
    object oArea = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget);
    if (GetIsObjectValid(oArea) == TRUE)
        SetLocalObject(oArea, "X0_L_IMPACT", oVisual);
}

void main()
{
    if (!X2PreSpellCastCode())
        return;

    effect eAOE = EffectAreaOfEffect(37, "x0_s3_calEN", "x0_s3_calHB", "");
    location lTarget = GetSpellTargetLocation();

    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eAOE, lTarget);
    object oVisual = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_invisobj", lTarget);
    SetObject(lTarget, oVisual);

    effect eFieldOfSharp = EffectVisualEffect(VFX_DUR_CALTROPS);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eFieldOfSharp, oVisual);
}

