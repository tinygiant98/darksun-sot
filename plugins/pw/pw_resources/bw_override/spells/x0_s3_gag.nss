
#include "NW_I0_SPELLS"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
        return;

    object oTarget = GetSpellTargetObject();
    int nCasterLvl = GetCasterLevel(OBJECT_SELF);
    int nDamage = 0;
    int nMetaMagic = GetMetaMagicFeat();
    int nCnt;
    effect eMissile;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
    location lTarget = GetSpellTargetLocation();
    effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);

    float fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
    int nTouch;
    float fDelay = fDist/(3.0 * log(fDist) + 2.0);

    if (GetIsObjectValid(oTarget) == TRUE)
        nTouch = TouchAttackRanged(oTarget);
    else
        nTouch = -1;

    if (nTouch >= 0)
    {
        eMissile = EffectVisualEffect(VFX_IMP_MIRV_FLAME);
        int nDam = d6(1);

        if (nTouch == 2)
            nDam *= 2;

        effect eDam = EffectDamage(nDam, DAMAGE_TYPE_FIRE);
        if (!GetIsReactionTypeFriendly(oTarget))
        {
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget));
        }
    }
    else
    {
        eMissile = EffectVisualEffect(VFX_IMP_MIRV_FLAME);
        SpeakString("splash");
    }
}



