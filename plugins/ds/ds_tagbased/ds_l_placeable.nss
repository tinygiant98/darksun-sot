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

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"

#include "quest_i_main"

/* Example
void placeable_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oPlaceable = OBJECT_SELF;

    if (sEvent == PLACEABLE_EVENT_ON_CLICK)
    {
        oPC = GetPlaceableLastClickedBy();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_CLOSE)
    {
        oPC = GetLastClosedBy();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_DAMAGED)
    {
        object oDamager = GetLastDamager();
        int nDamage = GetTotalDamageDealt();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_DEATH)
    {
        object oKiller = GetLastKiller();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_DISTURBED)
    {
        object oTaker = GetLastDisturbed();
        object oTaken = GetInventoryDisturbItem();
        int nType = GetInventoryDisturbType();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_HEARTBEAT)
    {

    }
    else if (sEvent == PLACEABLE_EVENT_ON_LOCK)
    {

    }
    else if (sEvent == PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED)
    {
        object oAttacker = GetLastAttacker();
        object oWeapons = GetLastWeaponsUsed();
        int nType = GetLastAttackType();
        int nMode = GetLastAttackMode();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_OPEN)
    {
        oPC = GetLastOpenedBy();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_SPELL_CAST_AT)
    {
        int nSpell = GetLastSpell();
        object oCaster = GetLastSpellCaster();
        int nHarmful = GetLastSpellHarmful();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_UNLOCK)
    {
        oPC = GetLastUnlocked();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_USED)
    {
        oPC = GetLastUsedBy();

    }
    else if (sEvent == PLACEABLE_EVENT_ON_USER_DEFINED)
    {

    }
}
*/

void quest_deliver_wagon()
{
    string sEvent = GetCurrentEvent(); //GetName(GetCurrentEvent());
    object oPC, oPlaceable = OBJECT_SELF;

    if (sEvent == PLACEABLE_EVENT_ON_CLOSE)
    {
        oPC = GetLastClosedBy();

        object oItem = GetFirstItemInInventory(oPlaceable);
        while (GetIsObjectValid(oItem))
        {
            SignalQuestStepProgress(oPC, GetTag(oPlaceable), QUEST_OBJECTIVE_DELIVER, GetTag(oItem));
            DestroyObject(oItem);

            oItem = GetNextItemInInventory(oPlaceable);
        }
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript("quest_deliver_wagon", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: quest_deliver_wagon(); break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
