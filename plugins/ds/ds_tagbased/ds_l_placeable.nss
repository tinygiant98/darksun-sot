// -----------------------------------------------------------------------------
//    File: ds_l_placeable.nss
//  System: Event Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Scripter Use:
//  OK to Change
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"
#include "ds_aln_i_main"

// -----------------------------------------------------------------------------
// This is a little script to kill the PC when they click the switch on the start area module.
// This will be used to test the death system.
// -----------------------------------------------------------------------------
void sa_sw_suisw()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oPlaceable = OBJECT_SELF;
    Notice("Event just triggered was " + sEvent);

    if (sEvent == PLACEABLE_EVENT_ON_USED)
    {
        oPC = GetLastUsedBy();
        if (!_GetIsPC(oPC))
          return;

        Notice(GetName(oPC) + " just used the " + GetName(oPlaceable) + " in " + GetName(GetArea(oPC)));

        //OK now let's kill the PC via what looks like spontaneous combustion.
        int iHP = GetCurrentHitPoints(oPC);
        //Add the 11 to get right to the Death and avoid the Dying part
        iHP = iHP + 11;
        effect eDrain = EffectDamage(iHP, DAMAGE_TYPE_FIRE);
        effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDrain, oPC);
    }
}
// -----------------------------------------------------------------------------
// This is a script that will slide the PC's alignment 5 points towards evil.
// -----------------------------------------------------------------------------
void sa_sw_evil()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oPlaceable = OBJECT_SELF;
    Notice("Event just triggered was " + sEvent);

    if (sEvent == PLACEABLE_EVENT_ON_USED)
    {
        oPC = GetLastUsedBy();
        if (!_GetIsPC(oPC))
          return;

        Notice(GetName(oPC) + " just used the " + GetName(oPlaceable) + " in " + GetName(GetArea(oPC)));
        AdjustAlignment(oPC, ALIGNMENT_EVIL, 5, FALSE);
    }
}
// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------
void OnLibraryLoad()
{
    RegisterLibraryScript("sa_sw_suisw", 1);
    RegisterLibraryScript("sa_sw_evil", 2);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  sa_sw_suisw(); break;
        case 2:  sa_sw_evil(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
