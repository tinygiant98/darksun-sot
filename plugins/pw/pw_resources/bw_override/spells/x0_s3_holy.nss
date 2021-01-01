
#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
        return;
        
    DoGrenade(d4(2), 1, VFX_IMP_HEAD_HOLY,
                    VFX_FNF_LOS_NORMAL_20,
                    DAMAGE_TYPE_DIVINE,
                    RADIUS_SIZE_HUGE,
                    OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, RACIAL_TYPE_UNDEAD);
}
