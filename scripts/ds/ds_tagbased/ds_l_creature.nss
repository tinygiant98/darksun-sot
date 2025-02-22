/// ----------------------------------------------------------------------------
/// @file   ds_l_creature.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"

#include "quest_i_main"

/*
void creature_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oCreature = OBJECT_SELF;

    if (sEvent == CREATURE_EVENT_ON_BLOCKED)
    {
        object oDoor = GetBlockingDoor();

    }
    else if (sEvent == CREATURE_EVENT_ON_COMBAT_ROUND_END)
    {

    }
    else if (sEvent == CREATURE_EVENT_ON_CONVERSATION)
    {
        object oSpeaker = GetLastSpeaker();

    }
    else if (sEvent == CREATURE_EVENT_ON_DAMAGED)
    {
        object oDamager = GetLastDamager();
        int nDamage = GetTotalDamageDealt();

    }
    else if (sEvent == CREATURE_EVENT_ON_DEATH)
    {
        object oKiller = GetLastKiller();

    }
    else if (sEvent == CREATURE_EVENT_ON_DISTURBED)
    {
        object oTaker = GetLastDisturbed();
        object oTaken = GetInventoryDisturbItem();
        int nType = GetInventoryDisturbType();

    }
    else if (sEvent == CREATURE_EVENT_ON_HEARTBEAT)
    {

    }
    else if (sEvent == NT_ON_DAMAGED)
    {
        object oDamager = GetLastDamager();
        int nDamage = GetTotalDamageDealt();

    }
    else if (sEvent == CREATURE_EVENT_ON_PERCEPTION)
    {
        object oPerceived = GetLastPerceived();
        
        //  One of these will be true
        // GetLastPerceptionSeen();
        // GetLastPerceptionVanished();
        // GetLastPerceptionHeard();
        // GetLastPerceptionInaudible();
        
    }
    else if (sEvent == CREATURE_EVENT_ON_PHYSICAL_ATTACKED)
    {
        object oAttacker = GetLastAttacker();
        object oWeapons = GetLastWeaponsUsed();
        int nType = GetLastAttackType();
        int nMode = GetLastAttackMode();

    }
    else if (sEvent == CREATURE_EVENT_ON_RESTED)
    {

    }
    else if (sEvent == CREATURE_EVENT_ON_SPAWN)
    {

    }
    else if (sEvent == CREATURE_EVENT_ON_SPELL_CAST_AT)
    {
        int nSpell = GetLastSpell();
        object oCaster = GetLastSpellCaster();
        int nHarmful = GetLastSpellHarmful();

    }
    else if (sEvent == CREATURE_EVENT_ON_USER_DEFINED)
    {

    }
}
*/

void nw_goblina()
{
    string sEvent = GetCurrentEvent(); //GetName(GetCurrentEvent());
    object oCreature = OBJECT_SELF;

    if (sEvent == CREATURE_EVENT_ON_DEATH)
    {
        object oKiller = GetLastKiller();
        SignalQuestStepProgress(oKiller, GetTag(oCreature), QUEST_OBJECTIVE_KILL);
    }
}

void nw_oldman()
{
    string sEvent = GetCurrentEvent(); //GetName(GetCurrentEvent());
    object oCreature = OBJECT_SELF;

    if (sEvent == CREATURE_EVENT_ON_DEATH)
    {
        object oKiller = GetLastKiller();
        object oProtector = GetLocalObject(oCreature, "QUEST_PROTECTOR");

        if (GetIsObjectValid(oProtector))
            SignalQuestStepProgress(oProtector, GetTag(oCreature), QUEST_OBJECTIVE_KILL);
        else
            SignalQuestStepProgress(oKiller, GetTag(oCreature), QUEST_OBJECTIVE_KILL);
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    int n;

    // n = 0; quest creatures
    RegisterLibraryScript("NW_GOBLINA",  n++);
    RegisterLibraryScript("NW_OLDMAN",   n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) nw_goblina();
            else if (nEntry == n++) nw_oldman();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_creature.nss");
    }
}
