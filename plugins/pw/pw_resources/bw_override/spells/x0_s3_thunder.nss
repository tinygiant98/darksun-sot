
#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"

float nSize =  RADIUS_SIZE_MEDIUM;

void main()
{
    if (!X2PreSpellCastCode())
        return;

    object oCaster = OBJECT_SELF;
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDeaf = EffectDeaf();
    effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    location lTarget = GetSpellTargetLocation();
    int nDuration = 5;

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShake, OBJECT_SELF, RoundsToSeconds(3));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, nSize, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oTarget))
    {
        if (!GetIsReactionTypeFriendly(oTarget))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), TRUE));
            fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;

            if (oTarget != oCaster)
                if (!MySavingThrow(SAVING_THROW_FORT, oTarget, 15))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, oTarget, RoundsToSeconds(nDuration)));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }

        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, nSize, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }
}
