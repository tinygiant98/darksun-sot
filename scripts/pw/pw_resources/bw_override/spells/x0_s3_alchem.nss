
#include "X2_I0_SPELLS"
#include "x2_inc_itemprop"
#include "x2_inc_spellhook"

void AddFlamingEffectToWeapon(object oTarget, float fDuration)
{
    IPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell(124,1), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
}

void main()
{
    if (!X2PreSpellCastCode())
        return;

    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_FIRE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    object oTarget = GetSpellTargetObject();
    object oMyWeapon;
    int nTarget = GetObjectType(oTarget);
    int nDuration = 4;
    int nCasterLvl = 1;

    if (nTarget == OBJECT_TYPE_ITEM)
    {
        oMyWeapon = oTarget;
        int nItem = IPGetIsMeleeWeapon(oMyWeapon);
        if (nItem == TRUE)
        {
            if (GetIsObjectValid(oMyWeapon))
            {
                SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));

                if (nDuration > 0)
                {
                    SetLocalInt(oMyWeapon, "X2_SPELL_CLEVEL_FLAMING_WEAPON", nCasterLvl);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, GetItemPossessor(oMyWeapon));
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, GetItemPossessor(oMyWeapon), RoundsToSeconds(nDuration));
                    AddFlamingEffectToWeapon(oMyWeapon, RoundsToSeconds(nDuration));
                }
                return;
            }
        }
        else
            FloatingTextStrRefOnCreature(100944, OBJECT_SELF);
    }
    else if (nTarget == OBJECT_TYPE_CREATURE || OBJECT_TYPE_DOOR || OBJECT_TYPE_PLACEABLE)
    {
        DoGrenade(d6(1), 1, VFX_IMP_FLAME_M,
                        VFX_FNF_FIREBALL,
                        DAMAGE_TYPE_FIRE,
                        RADIUS_SIZE_HUGE,
                        OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}




