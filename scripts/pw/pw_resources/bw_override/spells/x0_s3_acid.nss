
#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
        return;

    DoGrenade(d6(1), 1, VFX_IMP_ACID_L, 
                    VFX_FNF_LOS_NORMAL_30,
                    DAMAGE_TYPE_ACID,
                    RADIUS_SIZE_HUGE,
                    OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
}
