// -----------------------------------------------------------------------------
//    File: res_l_creature.nss
//  System: Base Game Resource Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Click
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Close
// -----------------------------------------------------------------------------

void __placeable_x0_closeinven();

// -----------------------------------------------------------------------------
//                              Damaged
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Death
// -----------------------------------------------------------------------------

void __placeable_generate_treasure(int nClass);
void __placeable_create_treasure(int nClass, int nType1 = 0, int nType2 = 0);
void __placeable_create_gold(int nClass);

// -----------------------------------------------------------------------------
//                              Disarm
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Heartbeat
// -----------------------------------------------------------------------------

void __placeable_nw_o2_dttrapdoor();
void __placeable_nw_o2_dtwalldoor();
void __placeable_nw_o2_gargoyle();
void __placeable_nw_o2_skeleton();
void __placeable_nw_o2_zombie();
void __placeable_x0_deck_hatch();
void __placeable_x0_deck_oracle();
void __placeable_x0_deck_plague();
void __placeable_x2_o0_glyphhb();

// -----------------------------------------------------------------------------
//                              Disturbed
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Lock
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Physical Attacked
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Open
// -----------------------------------------------------------------------------

/*  All shared with Death Event
void __placeable_nw_o2_bookshelf();
void __placeable_nw_o2_classhig();
void __placeable_nw_o2_classmed();
void __placeable_nw_o2_classlow();
void __placeable_nw_o2_generalhig();
void __placeable_nw_o2_generalmed();
void __placeable_nw_o2_generalow();
void __placeable_x0_o2_anyhigh();
void __placeable_x0_o2_anymed();
void __placeable_x0_o2_anylow();
void __placeable_x0_o2_anyuniq();
void __placeable_x0_o2_armhigh();
void __placeable_x0_o2_armmed();
void __placeable_x0_o2_armlow();
void __placeable_x0_o2_armuniq();
void __placeable_x0_o2_bookhigh();
void __placeable_x0_o2_bookmed();
void __placeable_x0_o2_booklow();
void __placeable_x0_o2_bookuniq();
void __placeable_x0_o2_clthhigh();
void __placeable_x0_o2_clthmed();
void __placeable_x0_o2_clthlow();
void __placeable_x0_o2_clthuniq();
void __placeable_x0_o2_goldhigh();
void __placeable_x0_o2_goldmed();
void __placeable_x0_o2_goldlow();
void __placeable_x0_o2_mleehigh();
void __placeable_x0_o2_mleemed();
void __placeable_x0_o2_mleelow();
void __placeable_x0_o2_mleeuniq();
void __placeable_x0_o2_noamhigh();
void __placeable_x0_o2_noammed();
void __placeable_x0_o2_noamlow();
void __placeable_x0_o2_noamuniq();
void __placeable_x0_o2_potnhigh();
void __placeable_x0_o2_potnmed();
void __placeable_x0_o2_potnlow();
void __placeable_x0_o2_potnuniq();
void __placeable_x0_o2_ranghigh();
void __placeable_x0_o2_rangmed();
void __placeable_x0_o2_ranglow();
void __placeable_x0_o2_ranguniq();
void __placeable_x0_o2_weaphigh();
void __placeable_x0_o2_weapmed();
void __placeable_x0_o2_weaplow();
void __placeable_x0_o2_weapuniq();
*/

// -----------------------------------------------------------------------------
//                              Spell Cast At
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Trap Triggered
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              UnLock
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Used
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              User Defined
// -----------------------------------------------------------------------------

void __placeable_x2_o0_glyphude();

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Click
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Close
// -----------------------------------------------------------------------------

#include "x0_henchmen"

void __placeable_x0_closeinven()
//::///////////////////////////////////////////////
//:: x0_closeinven
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Closes an open henchmen inventory
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
{
//    SpeakString("closing inventory...");
    object oHench = GetLocalObject(OBJECT_SELF, "NW_L_MYHENCH");
    if (GetIsPC(GetLastClosedBy()) == TRUE)
    {
        CopyBack(OBJECT_SELF, oHench);
        DestroyEquipped(oHench);
        DestroyObject(OBJECT_SELF, 0.3);
    }
}

// -----------------------------------------------------------------------------
//                              Damaged
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Death
// -----------------------------------------------------------------------------

#include "nw_o2_coninclude"

void __placeable_generate_treasure(int nClass)
//::///////////////////////////////////////////////
//:: General Treasure Spawn Script     BOOK
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spawns in general purpose treasure, usable
    by all classes.
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   February 26 2001
//:://////////////////////////////////////////////
{
    if (GetLocalInt(OBJECT_SELF,"NW_DO_ONCE") != 0)
    {
       return;
    }
    object oLastOpener = GetLastOpener();

    switch (nClass)
    {
        case TREASURE_LOW:
            GenerateLowTreasure(oLastOpener, OBJECT_SELF);
            break;
        case TREASURE_MEDIUM:
            GenerateMediumTreasure(oLastOpener, OBJECT_SELF);
            break;
        case TREASURE_HIGH:
            GenerateHighTreasure(oLastOpener, OBJECT_SELF);
            break;
        case TREASURE_BOOK:
            GenerateBookTreasure(oLastOpener, OBJECT_SELF);
            break;
        default:
            return;
    }

    SetLocalInt(OBJECT_SELF,"NW_DO_ONCE",1);
    ShoutDisturbed();
}

#include "x0_i0_treasure"

void __placeable_create_treasure(int nClass, int nType1 = 0, int nType2 = 0)
//::///////////////////////////////////////////////////
//:: X0_O2_WEAPHIGH.NSS
//:: OnOpened/OnDeath script for a treasure container.
//:: Treasure type: Any kind of weapon
//:: Treasure level: TREASURE_TYPE_HIGH
//::
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/21/2002
//::///////////////////////////////////////////////////
{
    CTG_CreateSpecificBaseTypeTreasure(nClass, GetLastOpener(), OBJECT_SELF, nType1, nType2);
}

void __placeable_create_gold(int nClass)
//::///////////////////////////////////////////////////
//:: X0_O2_GOLDHIGH.NSS
//:: OnOpened/OnDeath script for a treasure container.
//:: Treasure type: Gold only
//:: Treasure level: TREASURE_TYPE_HIGH
//::
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/21/2002
//::///////////////////////////////////////////////////
{
    if (CTG_GetIsTreasureGenerated(OBJECT_SELF)) {return;}
    CTG_SetIsTreasureGenerated(OBJECT_SELF);
    CTG_CreateGoldTreasure(nClass, GetLastOpener(), OBJECT_SELF);
}

//::///////////////////////////////////////////////
//:: Death Script
//:: NW_O0_DEATH.NSS
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script handles the default behavior
    that occurs when a player dies.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: November 6, 2001
//:://////////////////////////////////////////////

#include "nw_i0_plot"

void __placeable_x0_o0_death()
{
    object oPlayer = GetLastPlayerDied();
    AssignCommand(oPlayer, ClearAllActions());

    // * make friendly to Each of the 3 common factions
    if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER, oPlayer) <= 10)
    {   SetLocalInt(oPlayer, "NW_G_Playerhasbeenbad", 10); // * Player bad
        SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 80, oPlayer);
    }

    if (GetStandardFactionReputation(STANDARD_FACTION_MERCHANT, oPlayer) <= 10)
    {   SetLocalInt(oPlayer, "NW_G_Playerhasbeenbad", 10); // * Player bad
        SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 80, oPlayer);
    }

    if (GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, oPlayer) <= 10)
    {   SetLocalInt(oPlayer, "NW_G_Playerhasbeenbad", 10); // * Player bad
        SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 80, oPlayer);
    }

    //DelayCommand(2.5, PopUpGUIPanel(oPlayer,GUI_PANEL_PLAYER_DEATH));
}

// -----------------------------------------------------------------------------
//                              Disarm
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Heartbeat
// -----------------------------------------------------------------------------

void __placeable_nw_o2_dttrapdoor()
//::///////////////////////////////////////////////
//:: nw_o2_dttrapdoor.nss
//:: Copyright (c) 2001-2 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script runs on either the Hidden Trap Door
    or Hidden Wall Door Trigger invisible objects.
    This script will do a check and see
    if any PC comes within a radius of this Trigger.

    If the PC has the search skill or is an Elf then
    a search check will be made.

    It will create a Trap or Wall door that will have
    its Destination set to a waypoint that has
    a tag of DST_<tag of this object>

    The radius is determined by the Reflex saving
    throw of the invisible object

    The DC of the search stored by the Willpower
    saving throw.

*/
//:://////////////////////////////////////////////
//:: Created By  : Robert Babiak
//:: Created On  : June 25, 2002
//::---------------------------------------------
//:: Modifyed By : Robert, Andrew, Derek
//:: Modifyed On : July - September
//:://////////////////////////////////////////////
{
    // get the radius and DC of the secret door.
    float fSearchDist = IntToFloat(GetReflexSavingThrow(OBJECT_SELF));
    int nDiffaculty = GetWillSavingThrow(OBJECT_SELF);

    // what is the tag of this object used in setting the destination
    string sTag = GetTag(OBJECT_SELF);

    // has it been found?
    int nDone = GetLocalInt(OBJECT_SELF,"D_"+sTag);
    int nReset = GetLocalInt(OBJECT_SELF,"Reset");

    // ok reset the door is destroyed, and the done and reset flas are made 0 again
    if (nReset == 1)
    {
        nDone = 0;
        nReset = 0;

        SetLocalInt(OBJECT_SELF,"D_"+sTag,nDone);
        SetLocalInt(OBJECT_SELF,"Reset",nReset);

        object oidDoor= GetLocalObject(OBJECT_SELF,"Door");
        if (oidDoor != OBJECT_INVALID)
        {
            SetPlotFlag(oidDoor,0);
            DestroyObject(oidDoor,GetLocalFloat(OBJECT_SELF,"ResetDelay"));
        }

    }


    int nBestSkill = -50;
    object oidBestSearcher = OBJECT_INVALID;
    int nCount = 1;

    // Find the best searcher within the search radius.
    object oidNearestCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    int nDoneSearch = 0;
    int nFoundPCs = 0;

    while ((nDone == 0) &&
           (nDoneSearch == 0) &&
           (oidNearestCreature != OBJECT_INVALID)
          )
    {
        // what is the distance of the PC to the door location
        float fDist = GetDistanceBetween(OBJECT_SELF,oidNearestCreature);

        if (fDist <= fSearchDist)
        {
            int nSkill = GetSkillRank(SKILL_SEARCH,oidNearestCreature);

            if (nSkill > nBestSkill)
            {
                nBestSkill = nSkill;
                oidBestSearcher = oidNearestCreature;
            }
            nFoundPCs = nFoundPCs +1;
        }
        else
        {
            // If there is no one in the search radius, don't continue to search
            // for the best skill.
            nDoneSearch = 1;
        }
        nCount = nCount +1;
        oidNearestCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF ,nCount);
    }

    if ((nDone == 0) &&
        (nFoundPCs != 0) &&
        (GetIsObjectValid(oidBestSearcher))
       )
    {
       int nMod = d20();

            // did we find it.
       if ((nBestSkill +nMod > nDiffaculty))
       {
            location locLoc = GetLocation (OBJECT_SELF);
            object oidDoor;
            // yes we found it, now create the appropriate door
            oidDoor = CreateObject(OBJECT_TYPE_PLACEABLE,"NW_PL_HIDDENDR03",locLoc,TRUE);

            SetLocalString( oidDoor, "Destination" , "DST_"+sTag );
            // make this door as found.
            SetLocalInt(OBJECT_SELF,"D_"+sTag,1);
            SetPlotFlag(oidDoor,1);
            SetLocalObject(OBJECT_SELF,"Door",oidDoor);

       } // if skill search found
    } // if Object is valid
}

void __placeable_nw_o2_dtwalldoor()
//::///////////////////////////////////////////////
//:: nw_o2_dtwalldoor.nss
//:: Copyright (c) 2001-2 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script runs on either the Hidden Trap Door
    or Hidden Wall Door Trigger invisible objects.
    This script will do a check and see
    if any PC comes within a radius of this Trigger.

    If the PC has the search skill or is an Elf then
    a search check will be made.

    It will create a Trap or Wall door that will have
    its Destination set to a waypoint that has
    a tag of DST_<tag of this object>

    The radius is determined by the Reflex saving
    throw of the invisible object

    The DC of the search stored by the Willpower
    saving throw.

*/
//:://////////////////////////////////////////////
//:: Created By  : Robert Babiak
//:: Created On  : June 25, 2002
//::---------------------------------------------
//:: Modifyed By : Robert, Andrew, Derek
//:: Modifyed On : July - September
//:://////////////////////////////////////////////
{
    // get the radius and DC of the secret door.
    float fSearchDist = IntToFloat(GetReflexSavingThrow(OBJECT_SELF));
    int nDiffaculty = GetWillSavingThrow(OBJECT_SELF);

    // what is the tag of this object used in setting the destination
    string sTag = GetTag(OBJECT_SELF);

    // has it been found?
    int nDone = GetLocalInt(OBJECT_SELF,"D_"+sTag);
    int nReset = GetLocalInt(OBJECT_SELF,"Reset");

    // ok reset the door is destroyed, and the done and reset flas are made 0 again
    if (nReset == 1)
    {
        nDone = 0;
        nReset = 0;

        SetLocalInt(OBJECT_SELF,"D_"+sTag,nDone);
        SetLocalInt(OBJECT_SELF,"Reset",nReset);

        object oidDoor= GetLocalObject(OBJECT_SELF,"Door");
        if (oidDoor != OBJECT_INVALID)
        {
            SetPlotFlag(oidDoor,0);
            DestroyObject(oidDoor,GetLocalFloat(OBJECT_SELF,"ResetDelay"));
        }

    }


    int nBestSkill = -50;
    object oidBestSearcher = OBJECT_INVALID;
    int nCount = 1;

    // Find the best searcher within the search radius.
    object oidNearestCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    int nDoneSearch = 0;
    int nFoundPCs = 0;

    while ((nDone == 0) &&
           (nDoneSearch == 0) &&
           (oidNearestCreature != OBJECT_INVALID)
          )
    {
        // what is the distance of the PC to the door location
        float fDist = GetDistanceBetween(OBJECT_SELF,oidNearestCreature);

        if (fDist <= fSearchDist)
        {
            int nSkill = GetSkillRank(SKILL_SEARCH,oidNearestCreature);

            if (nSkill > nBestSkill)
            {
                nBestSkill = nSkill;
                oidBestSearcher = oidNearestCreature;
            }
            nFoundPCs = nFoundPCs +1;
        }
        else
        {
            // If there is no one in the search radius, don't continue to search
            // for the best skill.
            nDoneSearch = 1;
        }
        nCount = nCount +1;
        oidNearestCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF ,nCount);
    }

    if ((nDone == 0) &&
        (nFoundPCs != 0) &&
        (GetIsObjectValid(oidBestSearcher))
       )
    {
       int nMod = d20();

            // did we find it.
       if ((nBestSkill +nMod > nDiffaculty))
       {
            location locLoc = GetLocation (OBJECT_SELF);
            object oidDoor;
            // yes we found it, now create the appropriate door
            oidDoor = CreateObject(OBJECT_TYPE_PLACEABLE,"NW_PL_HIDDENDR01",locLoc,TRUE);

            SetLocalString( oidDoor, "Destination" , "DST_"+sTag );
            // make this door as found.
            SetLocalInt(OBJECT_SELF,"D_"+sTag,1);
            SetPlotFlag(oidDoor,1);
            SetLocalObject(OBJECT_SELF,"Door",oidDoor);

       } // if skill search found
    } // if Object is valid
}

void __placeable_nw_o2_gargoyle()
//::///////////////////////////////////////////////
//:: NW_O2_GARGOYLE.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Turns the placeable into a gargoyle
   if a player comes near enough.
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   January 17, 2002
//:://////////////////////////////////////////////
{
   object oCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
   if (GetIsObjectValid(oCreature) == TRUE && GetDistanceToObject(oCreature) < 10.0)
   {
    effect eMind = EffectVisualEffect(VFX_IMP_HOLY_AID);
    object oGargoyle = CreateObject(OBJECT_TYPE_CREATURE, "NW_GARGOYLE", GetLocation(OBJECT_SELF));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eMind, oGargoyle);
    SetPlotFlag(OBJECT_SELF, FALSE);
    DestroyObject(OBJECT_SELF, 0.5);
   }
}

//void __placeable_nw_o2_skeleton()
//::///////////////////////////////////////////////
//:: NW_O2_SKELETON.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Turns the placeable into a skeleton
   if a player comes near enough.
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   January 17, 2002
//:://////////////////////////////////////////////
void ActionCreate(string sCreature, location lLoc)
{
    CreateObject(OBJECT_TYPE_CREATURE, sCreature, lLoc);
}

void __placeable_nw_o2_skeleton()
{
   object oCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
   if (GetIsObjectValid(oCreature) == TRUE && GetDistanceToObject(oCreature) < 10.0)
   {
    effect eMind = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
    string sCreature = "NW_SKELWARR01";
    // * 10% chance of a skeleton chief instead
    if (Random(100) > 90)
    {
        sCreature = "NW_SKELCHIEF";
    }
    location lLoc = GetLocation(OBJECT_SELF);
    DelayCommand(0.3, ActionCreate(sCreature, lLoc));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eMind, GetLocation(OBJECT_SELF));
    SetPlotFlag(OBJECT_SELF, FALSE);
    DestroyObject(OBJECT_SELF, 0.5);
   }
}

void __placeable_nw_o2_zombie()
//::///////////////////////////////////////////////
//:: NW_O2_ZOMBIE.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Turns the placeable into a zombie
   if a player comes near enough.
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   January 17, 2002
//:://////////////////////////////////////////////
{
   object oCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
   if (GetIsObjectValid(oCreature) == TRUE && GetDistanceToObject(oCreature) < 10.0)
   {
    effect eMind = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
    string sCreature = "NW_ZOMBWARR01";
    // * 10% chance of a zombie lord instead
    if (Random(100) > 90)
    {
        sCreature = "NW_ZOMBIEBOSS";
    }
    object oMonster = CreateObject(OBJECT_TYPE_CREATURE, sCreature, GetLocation(OBJECT_SELF));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eMind, oMonster);
    SetPlotFlag(OBJECT_SELF, FALSE);
    DestroyObject(OBJECT_SELF, 0.5);
   }
}

#include "x0_i0_deckmany"

void __placeable_x0_deck_hatch()
/* This is the OnHeartbeat script for the Hatchling object from
 * the Deck of Hazards. It summons a hatchling that follows the
 * caster around. The object is destroyed when the hatchling is
 * transformed into an ancient dragon (good for one fight).
 */
{
    // Get the stored target
    object oTarget = GetLocalObject(OBJECT_SELF, "X0_DECK_TARGET");
    if (!GetIsObjectValid(oTarget))
        return;

    // Get the stored hatchling
    object oHatch = GetLocalObject(oTarget, "X0_DECK_HATCH");
    if (GetIsObjectValid(oHatch)) {
        // hatchling is still around
        return;
    }

    AssignCommand(oTarget, DoHatchlingDeckCardSummon());
}

//void __placeable_x0_deck_oracle()
/* The OnHeartbeat script for the oracle effect object
 * from the Deck of Many Things.
 */
int GetHasProtection(object oCaster)
{
    effect eEff = GetFirstEffect(oCaster);
    while (GetIsEffectValid(eEff)) {
        if (GetEffectType(eEff) == EFFECT_TYPE_DAMAGE_REDUCTION)
            return TRUE;
        eEff = GetNextEffect(oCaster);
    }
    return FALSE;
}

void __placeable_x0_deck_oracle()
{
    // Get the stored target
    object oTarget = GetLocalObject(OBJECT_SELF, "X0_DECK_TARGET");
    if (!GetIsObjectValid(oTarget))
        return;

    // Don't reapply if we're already protected
    if (GetHasProtection(oTarget))
        return;

    // if the oracle effect is off, reapply it
    effect ePrem = EffectDamageReduction(30, DAMAGE_POWER_PLUS_FIVE, 0);
    effect eVis = EffectVisualEffect(VFX_DUR_PROT_PREMONITION);

    //Link the visual and the damage reduction effect
    effect eLink = EffectLinkEffects(ePrem, eVis);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
}

//void __placeable_x0_deck_plague()
/* The OnHeartbeat script for the plague effect object
 * from the Deck of Many Things.
 */
int GetIsDiseased(object oTarget)
{
    effect eEff = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEff)) {
        if (GetEffectType(eEff) == EFFECT_TYPE_ABILITY_DECREASE)
            return TRUE;
        eEff = GetNextEffect(oTarget);
    }
    return FALSE;
}

void __placeable_x0_deck_plague()
{
    // This script runs every 8 seconds; we should apply the
    // effect only once per game hour (120 seconds)
    int nTicks = GetLocalInt(OBJECT_SELF, "X0_DECK_PLAGUE_TICKS");
    if (nTicks < 15) {
        SetLocalInt(OBJECT_SELF, "X0_DECK_PLAGUE_TICKS", nTicks+1);
        return;
    }
    SetLocalInt(OBJECT_SELF, "X0_DECK_PLAGUE_TICKS", 0);

    // Get the stored target
    object oTarget = GetLocalObject(OBJECT_SELF, "X0_DECK_TARGET");
    if (!GetIsObjectValid(oTarget))
        return;

    // Spasm and occasionally, throw up :-)
    int nSpasmTicks = GetLocalInt(OBJECT_SELF, "X0_DECK_SPASM_TICKS");
    if (nSpasmTicks == 4) {
        SetLocalInt(OBJECT_SELF, "X0_DECK_SPASM_TICKS", 0);
        SetCustomToken(0, GetName(oTarget));
        // FloatingTextStrRefOnCreature(####, oTarget);
        FloatingTextStringOnCreature(GetName(oTarget)
                        + " is momentarily overcome by illness.",
                        oTarget);

        effect eVomit = EffectVisualEffect(VFX_COM_CHUNK_YELLOW_SMALL);
        AssignCommand(oTarget,
              PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 2.0));
        ApplyEffectToObject(DURATION_TYPE_INSTANT,
                    eVomit,
                    oTarget);

        // Apply an ability decrease effect if not currently on
        if (!GetIsDiseased(oTarget)) {
            int nAbility = ABILITY_STRENGTH;
            switch (Random(6)) {
            case 0: nAbility = ABILITY_CHARISMA; break;
            case 1: nAbility = ABILITY_DEXTERITY; break;
            case 2: nAbility = ABILITY_CONSTITUTION; break;
            case 3: nAbility = ABILITY_INTELLIGENCE; break;
            case 4: nAbility = ABILITY_WISDOM; break;
            case 5: nAbility = ABILITY_STRENGTH; break;
            }

            effect eAbil = EffectAbilityDecrease(nAbility, 1);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,
                                eAbil,
                                oTarget);
        }
    } else {
        SetLocalInt(OBJECT_SELF, "X0_DECK_SPASM_TICKS", nSpasmTicks+1);
        AssignCommand(oTarget,
              PlayAnimation(ANIMATION_LOOPING_SPASM, 1.0, 3.0));
    }


    // Apply a minor bit of damage
    effect eDam = EffectDamage(d4(),
                               DAMAGE_TYPE_MAGICAL,
                               DAMAGE_POWER_PLUS_FIVE);

    ApplyEffectToObject(DURATION_TYPE_INSTANT,
                        eDam,
                        oTarget);
}

#include "x2_inc_switches"

void __placeable_x2_o0_glyphhb()
//::///////////////////////////////////////////////
//:: Glyph of Warding Heartbeat
//:: x2_o0_glyphhb
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Heartbeat for glyph of warding object

    Short rundown:

    Casting "glyph of warding" will create a GlyphOfWarding
    object from the palette and store all required variables
    on that object. You can also manually add those variables
    through the toolset.

    On the first heartbeat, the glyph creates the glyph visual
    effect on itself for the duration of the spell.

    Each subsequent heartbeat the glyph checks if the effect
    is still there. If it is no longer there, it has either been
    dispelled or removed, and the glyph will terminate itself.

    Also on the first heartbeat, this object creates an AOE object
    around itself, which, when getting the OnEnter Event from a
    Creature Hostile to the player, will  signal User Defined Event
    2000 to the glyph placeable which will fire the spell
    stored on a variable on it self on the intruder

    Note that not all spells might work because this is a placeable
    object casting them, but the more populare ones are working.

    The default spell cast is id 764, which is the script for
    the standard glyph of warding.

    Check the comments on the Glyph of Warding object on the palette
    for more information

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-02
//:://////////////////////////////////////////////
{

    int bSetup = GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_INIT");
    int nLevel = GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_CASTER_LEVEL");
    if (bSetup == 0)
    {
        SetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_INIT",1);
        int nMetaMagic = GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_CASTER_METAMAGIC") ;
        int nDuration = nLevel /2;
        if (nMetaMagic == METAMAGIC_EXTEND)
        {
           nDuration =           nDuration *2;//Duration is +100%
        }

        if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_INVISIBLE_GLYPH_OF_WARDING))
        {
            // show glyph symbol only for 6 seconds
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(445),OBJECT_SELF,6.0f);
            // use blur VFX therafter (which should be invisible);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(0),OBJECT_SELF,TurnsToSeconds(nDuration));
        }
        else
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(445),OBJECT_SELF,TurnsToSeconds(nDuration));
        }
        effect eAOE = EffectAreaOfEffect(38, "x2_s0_glphwarda");
        if (GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_PERMANENT") == TRUE)
        {
            ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eAOE, GetLocation(OBJECT_SELF));
        }
        else
        {
            ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, GetLocation(OBJECT_SELF), TurnsToSeconds(nDuration));
        }
     }
    else
    {
        effect e1 = GetFirstEffect(OBJECT_SELF);
        int bGood = FALSE;
        while (GetIsEffectValid(e1))
        {
            if (GetEffectType(e1) == EFFECT_TYPE_VISUALEFFECT)
            {
                if (GetEffectCreator(e1) == OBJECT_SELF)
                {
                    bGood = TRUE;
                }
            }
            e1 = GetNextEffect(OBJECT_SELF);
        }

        if (!bGood)
        {
            DestroyObject(OBJECT_SELF);
            return;
        }

    }

    // check if caster left the game
    object oCaster = GetLocalObject(OBJECT_SELF,"X2_PLC_GLYPH_CASTER");
    if (!GetIsObjectValid(oCaster) || GetIsDead(oCaster))
    {
        if (GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_PLAYERCREATED") == TRUE)
        {
            DestroyObject(OBJECT_SELF);
        }
        return;
    }
}

// -----------------------------------------------------------------------------
//                              Disturbed
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Lock
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Physical Attacked
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Open
// -----------------------------------------------------------------------------

/*  All shared with Death Event
void __placeable_ nw_o2_bookshelf();
void __placeable_ nw_o2_classhig();
void __placeable_ nw_o2_classmed();
void __placeable_ nw_o2_classlow();
void __placeable_ nw_o2_generalhig();
void __placeable_ nw_o2_generalmed();
void __placeable_ nw_o2_generalow();
void __placeable_ x0_o2_anyhigh();
void __placeable_ x0_o2_anymed();
void __placeable_ x0_o2_anylow();
void __placeable_ x0_o2_anyuniq();
void __placeable_ x0_o2_armhigh();
void __placeable_ x0_o2_armmed();
void __placeable_ x0_o2_armlow();
void __placeable_ x0_o2_armuniq();
void __placeable_ x0_o2_bookhigh();
void __placeable_ x0_o2_bookmed();
void __placeable_ x0_o2_booklow();
void __placeable_ x0_o2_bookuniq();
void __placeable_ x0_o2_clthhigh();
void __placeable_ x0_o2_clthmed();
void __placeable_ x0_o2_clthlow();
void __placeable_ x0_o2_clthuniq();
void __placeable_ x0_o2_goldhigh();
void __placeable_ x0_o2_goldmed();
void __placeable_ x0_o2_goldlow();
void __placeable_ x0_o2_mleehigh();
void __placeable_ x0_o2_mleemed();
void __placeable_ x0_o2_mleelow();
void __placeable_ x0_o2_mleeuniq();
void __placeable_ x0_o2_noamhigh();
void __placeable_ x0_o2_noammed();
void __placeable_ x0_o2_noamlow();
void __placeable_ x0_o2_noamuniq();
void __placeable_ x0_o2_potnhigh();
void __placeable_ x0_o2_potnmed();
void __placeable_ x0_o2_potnlow();
void __placeable_ x0_o2_potnuniq();
void __placeable_ x0_o2_ranghigh();
void __placeable_ x0_o2_rangmed();
void __placeable_ x0_o2_ranglow();
void __placeable_ x0_o2_ranguniq();
void __placeable_ x0_o2_weaphigh();
void __placeable_ x0_o2_weapmed();
void __placeable_ x0_o2_weaplow();
void __placeable_ x0_o2_weapuniq();
*/

// -----------------------------------------------------------------------------
//                              Spell Cast At
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Trap Triggered
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              UnLock
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Used
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              User Defined
// -----------------------------------------------------------------------------

void __placeable_x2_o0_glyphude()
//::///////////////////////////////////////////////
//:: Glyph of Warding OnuserDefined
//:: x2_o0_glyphhb
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script fires the glyph of warding
    effects.

    Check x2_o0_hhb.nss and the Glyph of Warding
    placeable object for details

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-02
//:://////////////////////////////////////////////
{
    if (GetUserDefinedEventNumber() == 2000 &&  GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_TRIGGERED") == 0 )
    {
        effect eVis = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,OBJECT_SELF);
        int nSpell  = GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_SPELL");
        int nMetaMagic = GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_CASTER_METAMAGIC");
        object oTarget = GetLocalObject(OBJECT_SELF,"X2_GLYPH_LAST_ENTER");
        string sScript = GetLocalString(OBJECT_SELF,"X2_GLYPH_SPELLSCRIPT");

        if (sScript != "")
        {
            ActionCastFakeSpellAtObject(nSpell,oTarget,PROJECTILE_PATH_TYPE_DEFAULT);
            ExecuteScript(sScript,oTarget);
        }
        else
        {
            ActionCastSpellAtObject(nSpell,oTarget,nMetaMagic,TRUE,0,PROJECTILE_PATH_TYPE_DEFAULT,TRUE);
        }

        int nCharges = GetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_CHARGES");

        if(nCharges ==0)
        {
            SetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_TRIGGERED",TRUE);
            effect e1 = GetFirstEffect(OBJECT_SELF);
            while (GetIsEffectValid(e1))
            {
                if (GetEffectType(e1) == EFFECT_TYPE_VISUALEFFECT)
                {
                    if (GetEffectCreator(e1) == OBJECT_SELF)
                    {
                        RemoveEffect(OBJECT_SELF,e1);
                    }
                }
                e1 = GetNextEffect(OBJECT_SELF);
            }


            DestroyObject(OBJECT_SELF,1.0f);
        }
        else
        {
          if (nCharges >0)
          {
            nCharges --;
            SetLocalInt(OBJECT_SELF,"X2_PLC_GLYPH_CHARGES",nCharges);
           }
        }

    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // ----- Module Events -----
    //RegisterEventScripts(oPlugin, EVENT_CONSTANT, "function_name", 4.0);

    // ----- Click Events -----
    // ----- Close Events -----
    RegisterLibraryScript("x0_closeinven",          10);
    // ----- Damaged Events -----
    // ----- Death Events -----
    RegisterLibraryScript("nw_o2_bookshelf",        50);
    RegisterLibraryScript("nw_o2_classhig",         51);
    RegisterLibraryScript("nw_o2_classmed",         52);
    RegisterLibraryScript("nw_o2_classlow",         53);
    RegisterLibraryScript("nw_o2_generalhig",       54);
    RegisterLibraryScript("nw_o2_generalmed",       55);
    RegisterLibraryScript("nw_o2_generalow",        56);
    RegisterLibraryScript("x0_o2_anyhigh",          57);
    RegisterLibraryScript("x0_o2_anymed",           58);
    RegisterLibraryScript("x0_o2_anylow",           59);
    RegisterLibraryScript("x0_o2_anyuniq",          60);
    RegisterLibraryScript("x0_o2_armhigh",          61);
    RegisterLibraryScript("x0_o2_armmed",           62);
    RegisterLibraryScript("x0_o2_armlow",           63);
    RegisterLibraryScript("x0_o2_armuniq",          64);
    RegisterLibraryScript("x0_o2_bookhigh",         65);
    RegisterLibraryScript("x0_o2_bookmed",          66);
    RegisterLibraryScript("x0_o2_booklow",          67);
    RegisterLibraryScript("x0_o2_bookuniq",         68);
    RegisterLibraryScript("x0_o2_clthhigh",         69);
    RegisterLibraryScript("x0_o2_clthmed",          70);
    RegisterLibraryScript("x0_o2_clthlow",          71);
    RegisterLibraryScript("x0_o2_clthuniq",         72);
    RegisterLibraryScript("x0_o2_goldhigh",         73);
    RegisterLibraryScript("x0_o2_goldmed",          74);
    RegisterLibraryScript("x0_o2_goldlow",          75);
    RegisterLibraryScript("x0_o2_mleehigh",         76);
    RegisterLibraryScript("x0_o2_mleemed",          77);
    RegisterLibraryScript("x0_o2_mleelow",          78);
    RegisterLibraryScript("x0_o2_mleeuniq",         79);
    RegisterLibraryScript("x0_o2_noamhigh",         80);
    RegisterLibraryScript("x0_o2_noammed",          81);
    RegisterLibraryScript("x0_o2_noamlow",          82);
    RegisterLibraryScript("x0_o2_noamuniq",         83);
    RegisterLibraryScript("x0_o2_potnhigh",         84);
    RegisterLibraryScript("x0_o2_potnmed",          85);
    RegisterLibraryScript("x0_o2_potnlow",          86);
    RegisterLibraryScript("x0_o2_potnuniq",         87);
    RegisterLibraryScript("x0_o2_ranghigh",         88);
    RegisterLibraryScript("x0_o2_rangmed",          89);
    RegisterLibraryScript("x0_o2_ranglow",          90);
    RegisterLibraryScript("x0_o2_ranguniq",         91);
    RegisterLibraryScript("x0_o2_weaphigh",         92);
    RegisterLibraryScript("x0_o2_weapmed",          93);
    RegisterLibraryScript("x0_o2_weaplow",          94);
    RegisterLibraryScript("x0_o2_weapuniq",         95);
    RegisterLibraryScript("x0_o0_death",            96);
    // ----- Disarm Events -----
    // ----- Heartbeat Events -----
    RegisterLibraryScript("nw_o2_dttrapdoor",       110);
    RegisterLibraryScript("nw_o2_dtwalldoor",       111);
    RegisterLibraryScript("nw_o2_gargoyle",         112);
    RegisterLibraryScript("nw_o2_skeleton",         113);
    RegisterLibraryScript("nw_o2_zombie",           114);
    RegisterLibraryScript("x0_deck_hatch",          115);
    RegisterLibraryScript("x0_deck_oracle",         116);
    RegisterLibraryScript("x0_deck_plague",         117);
    RegisterLibraryScript("x2_o0_glyphhb",          118);
    // ----- Disturbed Events -----
    // ----- Lock Events -----
    // ----- Physical Attacked Events -----
    // ----- Open Events -----
    // Same as death events -- shared
    // ----- Spell Cast At Events -----
    // ----- Trap Triggered Events -----
    // ----- UnLock Events -----
    // ----- Used Events -----
    // ----- User Defined Events -----
    RegisterLibraryScript("x2_o0_glyphude",         200);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int nClass, nType1, nType2;

    switch (nEntry)
    {

        // ----- Click Events -----
        // ----- Close Events -----
        case 10:  __placeable_x0_closeinven(); break;
        // ----- Damaged Events -----
        // ----- Death Events -----
        case 50:  nClass = TREASURE_BOOK;
        case 51:  if (!nClass) nClass = TREASURE_HIGH;
        case 52:  if (!nClass) nClass = TREASURE_MEDIUM;
        case 53:  if (!nClass) nClass = TREASURE_LOW;
        case 54:  if (!nClass) nClass = TREASURE_HIGH;
        case 55:  if (!nClass) nClass = TREASURE_MEDIUM;
        case 56:
            if (!nClass) nClass = TREASURE_LOW;
            __placeable_generate_treasure(nClass);
            break;
        case 57:  nClass = TREASURE_TYPE_HIGH;
        case 58:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 59:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 60:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            __placeable_create_treasure(nClass);
            break;
        case 61:  nClass = TREASURE_TYPE_HIGH;
        case 62:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 63:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 64:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = TREASURE_BASE_TYPE_ARMOR;
            __placeable_create_treasure(nClass, nType1);
            break;
        case 65:  nClass = TREASURE_TYPE_HIGH;
        case 66:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 67:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 68:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = BASE_ITEM_BOOK;
            nType2 = BASE_ITEM_SPELLSCROLL;
            __placeable_create_treasure(nClass, nType1, nType2);
            break;
        case 69:  nClass = TREASURE_TYPE_HIGH;
        case 70:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 71:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 72:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = TREASURE_BASE_TYPE_CLOTHING;
            __placeable_create_treasure(nClass, nType1);
            break;
        case 73:  nClass = TREASURE_TYPE_HIGH;
        case 74:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 75: 
            if (!nClass) nClass = TREASURE_TYPE_LOW;
            __placeable_create_gold(nClass);
            break;

        case 76:  nClass = TREASURE_TYPE_HIGH;
        case 77:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 78:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 79:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = TREASURE_BASE_TYPE_WEAPON_MELEE;
            __placeable_create_treasure(nClass, nType1);
            break;

        case 80:  nClass = TREASURE_TYPE_HIGH;
        case 81:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 82:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 83:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = TREASURE_BASE_TYPE_WEAPON_NOAMMO;
            __placeable_create_treasure(nClass, nType1);
            break;
        case 84:  nClass = TREASURE_TYPE_HIGH;
        case 85:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 86:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 87:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = BASE_ITEM_POTIONS;
            __placeable_create_treasure(nClass, nType1);
            break;

        case 88:  nClass = TREASURE_TYPE_HIGH;
        case 89:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 90:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 91:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = TREASURE_BASE_TYPE_WEAPON_RANGED;
            __placeable_create_treasure(nClass, nType1);
            break;
        case 92:  nClass = TREASURE_TYPE_HIGH;
        case 93:  if (!nClass) nClass = TREASURE_TYPE_MED;
        case 94:  if (!nClass) nClass = TREASURE_TYPE_LOW;
        case 95:  
            if (!nClass) nClass = TREASURE_TYPE_UNIQUE;
            nType1 = TREASURE_BASE_TYPE_WEAPON;
            __placeable_create_treasure(nClass, nType1);
            break;
        case 96:  __placeable_x0_o0_death(); break;
        // ----- Disarm Events -----
        // ----- Heartbeat Events -----
        case 110: __placeable_nw_o2_dttrapdoor(); break;
        case 111: __placeable_nw_o2_dtwalldoor(); break;
        case 112: __placeable_nw_o2_gargoyle(); break;
        case 113: __placeable_nw_o2_skeleton(); break;
        case 114: __placeable_nw_o2_zombie(); break;
        case 115: __placeable_x0_deck_hatch(); break;
        case 116: __placeable_x0_deck_oracle(); break;
        case 117: __placeable_x0_deck_plague(); break;
        case 118: __placeable_x2_o0_glyphhb(); break;
        // ----- Disturbed Events -----
        // ----- Lock Events -----
        // ----- Physical Attacked Events -----
        // ----- Open Events -----
        // ----- Spell Cast At Events -----
        // ----- Trap Triggered Events -----
        // ----- UnLock Events -----
        // ----- Used Events -----
        // ----- User Defined Events -----
        case 200: __placeable_x2_o0_glyphude(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
