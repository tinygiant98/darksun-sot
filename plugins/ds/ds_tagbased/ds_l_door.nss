// -----------------------------------------------------------------------------
//    File: ds_l_door.nss
//  System: Event Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"

/* Example
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
    // RegisterLibraryScript("door_tag", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  door_tag();           break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
