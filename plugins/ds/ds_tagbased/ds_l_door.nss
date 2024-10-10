/// ----------------------------------------------------------------------------
/// @file   ds_l_door.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_data"

/*
void door_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oDoor = OBJECT_SELF;

    if (sEvent == DOOR_EVENT_ON_AREA_TRANSITION_CLICK)
    {
        oPC = GetClickingObject();
        object oTarget = GetTransitionTarget(oDoor);

    }
    else if (sEvent == DOOR_EVENT_ON_CLOSE)
    {
        oPC = GetLastClosedBy();

    }
    else if (sEvent == DOOR_EVENT_ON_DAMAGED)
    {
        object oDamager = GetLastDamager();
        int nDamage = GetTotalDamageDealt();

    }
    else if (sEvent == DOOR_EVENT_ON_DEATH)
    {
        object oKiller = GetLastKiller();

    }
    else if (sEvent == DOOR_EVENT_ON_FAIL_TO_OPEN)
    {
        oPC = GetClickingObject();

    }
    else if (sEvent == DOOR_EVENT_ON_HEARTBEAT)
    {

    }
    else if (sEvent == DOOR_EVENT_ON_LOCK)
    {

    }
    else if (sEvent == DOOR_EVENT_ON_OPEN)
    {
        oPC = GetLastOpenedBy();

    }
    else if (sEvent == DOOR_EVENT_ON_PHYSICAL_ATTACKED)
    {
        object oAttacker = GetLastAttacker();
        object oWeapons = GetLastWeaponsUsed();
        int nType = GetLastAttackType();
        int nMode = GetLastAttackMode();

    }
    else if (sEvent == DOOR_EVENT_ON_SPELL_CAST_AT)
    {
        int nSpell = GetLastSpell();
        object oCaster = GetLastSpellCaster();
        int nHarmful = GetLastSpellHarmful();

    }
    else if (sEvent == DOOR_EVENT_ON_UNLOCK)
    {
        oPC = GetLastUnlocked();

    }
    else if (sEvent == DOOR_EVENT_ON_USER_DEFINED)
    {

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    int n;
    // RegisterLibraryScript("door_tag", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            //if      (nEntry == n++) door_tag();
            //else if (nEntry == n++) something_else();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_door.nss");
    }
}
