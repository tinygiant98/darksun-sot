
#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
        return;

    effect eAOE = EffectAreaOfEffect(AOE_PER_FOGSTINK, "x0_s3_chokeen", "x0_s3_chokeHB", "");
    location lTarget = GetSpellTargetLocation();
    int nDuration = 5;
    effect eImpact = EffectVisualEffect(259);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lTarget);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, lTarget, RoundsToSeconds(nDuration));
}
