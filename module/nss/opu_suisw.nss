#include "util_i_data"

void main()
{
    //************************************
    //opu_suisw.nss
    //OnPlaceableUsed for the Suicide Switch in the Start Area
    //
    //I wrote this script as a standalone.  I then used the toolset
    //to place a variable directly on the switch named OnPlaceableUsed.
    //The value of that variable is the name of script (opu_suisw.nss).
    //
    //TinyGiant tells me there is a better way to handle stuff like this.
    //Remember to check back with him on it.
    //************************************
    object oPlaceable = OBJECT_SELF;
    //It is weird, but even though I am in the PlaceableUsed script, it seems
    //like on GetPlaceableLastClickedBy() actually works here.
    object oPC = GetPlaceableLastClickedBy();

    if (!_GetIsPC(oPC))    // <-- Not a big deal now, but don't want to waste computes if you don't need to
      return;

    Notice(GetName(oPC) + " just used the " + GetName(oPlaceable) + " in " + GetName(GetArea(oPC)));

    //OK now let's kill the PC via what looks like spontaneous combustion.
     int iHP = GetCurrentHitPoints(oPC);
    effect eDrain = EffectDamage(iHP, DAMAGE_TYPE_FIRE);
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDrain, oPC);
}
