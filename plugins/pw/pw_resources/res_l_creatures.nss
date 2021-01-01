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
//                              Hearbeat
// -----------------------------------------------------------------------------

void __creature_nw_c2_default1();
void __creature_nw_ch_ac1();
void __creature_x0_ch_hen_heart();
void __creature_x3_c2_pm_hb();
void __creature_x0_wyrm_heart();
void __creature_nw_c2_gargoyle();
void __creature_x2_c2_gcube_hbt();

// -----------------------------------------------------------------------------
//                              Spell Cast At
// -----------------------------------------------------------------------------

void __creature_nw_c2_defaultb();
void __creature_nw_ch_acb();
void __creature_nw_ch_fmb();
void __creature_nw_nw_acb();
void __creature_nw_ochrejlly_osc();
void __creature_q2_spell_djinn();
void __creature_x2_bb_spellcast();
void __creature_x2_def_spellcast();
void __creature_x2_hen_spell();

// -----------------------------------------------------------------------------
//                              Physical Attacked
// -----------------------------------------------------------------------------

void __creature_nw_ch_default5();
void __creature_nw_ch_ac5();
void __creature_nw_ch_acd();
void __creature_nw_e0_default5();
void __creature_nw_ochrejlly_opa();
void __creature_q2_attack_djinn();
void __creature_x0_ch_hen_attack();
void __creature_x2_def_attacked();

// -----------------------------------------------------------------------------
//                              Damaged
// -----------------------------------------------------------------------------

void __creature_nw_c2_default6();
//void __creature_nw_ch_ac5();  Shared
void __creature_nw_ch_ac6();
void __creature_x0_ch_hen_damage();
void __creature_x0_hatch_dam();
void __creature_x2_def_ondamage();

// -----------------------------------------------------------------------------
//                              Death
// -----------------------------------------------------------------------------

void __creature_nw_c2_default7();
void __creature_nw_c2_stnkbtdie();
void __creature_nw_c2_vampire7();
void __creature_nw_ch_ac7();
void __creature_nw_s3_balordeth();
//void __creature_x0_hatch_dam();  Shared
void __creature_x2_def_ondeath();
void __creature_x2_hen_death();
void __creature_x3_c2_pm_death();

// -----------------------------------------------------------------------------
//                              Conversation
// -----------------------------------------------------------------------------

void __creature_nw_ch_ac4();
void __creature_nw_c2_default4();
void __creature_x2_def_onconv();
void __creature_x0_ch_hen_conv();
void __creature_nw_ch_fm4();
void __creature_x0_cheatlisten();

// -----------------------------------------------------------------------------
//                              Disturbed
// -----------------------------------------------------------------------------

void __creature_nw_ch_ac8();
void __creature_nw_c2_default8();
void __creature_x2_def_ondisturb();
void __creature_x0_ch_hen_distrb();
void __creature_nw_e0_default8();

// -----------------------------------------------------------------------------
//                              End Combat Round
// -----------------------------------------------------------------------------

void __creature_nw_c2_default3();
void __creature_nw_ch_ac3();
void __creature_nw_ch_fm3();
void __creature_x0_ch_hen_combat();
void __creature_x2_def_endcombat();

// -----------------------------------------------------------------------------
//                              Blocked
// -----------------------------------------------------------------------------

void __creature_nw_c2_defaulte();
void __creature_nw_ch_ace();
void __creature_x0_ch_hen_block();
void __creature_x2_def_onblocked();

// -----------------------------------------------------------------------------
//                              Perception
// -----------------------------------------------------------------------------

void __creature_nw_c2_default2();
void __creature_nw_ch_ac2();
void __creature_x0_ch_hen_percep();
void __creature_x2_def_percept();

// -----------------------------------------------------------------------------
//                              Rested
// -----------------------------------------------------------------------------

void __creature_nw_c2_defaulta();
void __creature_nw_ch_aca();
void __creature_x0_ch_rest();
void __creature_x2_def_rested();

// -----------------------------------------------------------------------------
//                              Spawn
// -----------------------------------------------------------------------------

void __creature_nw_c2_bat9();
void __creature_nw_c2_default9();
void __creature_nw_c2_dimdoors();
void __creature_nw_c2_dropin9();
void __creature_nw_c2_gated();
void __creature_nw_c2_gatedbad();
void __creature_nw_c2_herbivore();
void __creature_nw_c2_lycan_9();
void __creature_nw_c2_omnivore();
void __creature_nw_c2_vampireg9();
void __creature_nw_ch_ac9();
void __creature_nw_ch_acani9();
void __creature_nw_ch_acgs9();
void __creature_nw_ch_summon_9();
void __creature_x0_ch_hen_spawn();
void __creature_x2_ch_summon_sld();
void __creature_x2_def_spawn();
void __creature_x2_spawn_genie();

// -----------------------------------------------------------------------------
//                              UserDefined
// -----------------------------------------------------------------------------

void __creature_nw_c2_dimdoor();

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Hearbeat
// -----------------------------------------------------------------------------

#include "nw_i0_generic"
#include "x0_inc_henai"
#include "x2_inc_spellhook"
#include "x3_inc_horse"
#include "x2_inc_summscale"
#include "x0_i0_spells"
#include "x2_i0_spells"

//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT1
/*
  Default OnHeartbeat script for NPCs.

  This script causes NPCs to perform default animations
  while not otherwise engaged.

  This script duplicates the behavior of the default
  script and just cleans up the code and removes
  redundant conditional checks.

 */
void __creature_nw_c2_default1()
{
    // * if not runnning normal or better Ai then exit for performance reasons
    if (GetAILevel() == AI_LEVEL_VERY_LOW) return;

    // Buff ourselves up right away if we should
    if(GetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY))
    {
        // This will return TRUE if an enemy was within 40.0 m
        // and we buffed ourselves up instantly to respond --
        // simulates a spellcaster with protections enabled
        // already.
        if(TalentAdvancedBuff(40.0))
        {
            // This is a one-shot deal
            SetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY, FALSE);

            // This return means we skip sending the user-defined
            // heartbeat signal in this one case.
            return;
        }
    }

    if(GetHasEffect(EFFECT_TYPE_SLEEP))
    {
        // If we're asleep and this is the result of sleeping
        // at night, apply the floating 'z's visual effect
        // every so often

        if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT))
        {
            effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
            if(d10() > 6)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
            }
        }
    }

    // If we have the 'constant' waypoints flag set, walk to the next
    // waypoint.
    else if ( GetWalkCondition(NW_WALK_FLAG_CONSTANT) )
    {
        WalkWayPoints();
    }

    // Check to see if we should be playing default animations
    // - make sure we don't have any current targets
    else if ( !GetIsObjectValid(GetAttemptedAttackTarget())
          && !GetIsObjectValid(GetAttemptedSpellTarget())
          // && !GetIsPostOrWalking())
          && !GetIsObjectValid(GetNearestSeenEnemy()))
    {
        if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL) || GetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE) ||
            GetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE))
        {
            // This handles special attacking/fleeing behavior
            // for omnivores & herbivores.
            DetermineSpecialBehavior();
        }
        else if (!IsInConversation(OBJECT_SELF))
        {
            if (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)
                || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)
                || GetIsEncounterCreature())
            {
                PlayMobileAmbientAnimations();
            }
            else if (GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS))
            {
                PlayImmobileAmbientAnimations();
            }
        }
    }

    // Send the user-defined event signal if specified
    if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_HEARTBEAT));
    }
}

//::///////////////////////////////////////////////
//:: Associate: Heartbeat
//:: NW_CH_AC1.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Move towards master or wait for him
*/
void __creature_nw_ch_ac1()
{
    // GZ: Fallback for timing issue sometimes preventing epic summoned creatures from leveling up to their master's level.
    // There is a timing issue with the GetMaster() function not returning the fof a creature
    // immediately after spawn. Some code which might appear to make no sense has been added
    // to the nw_ch_ac1 and x2_inc_summon files to work around this
    // This code is only run at the first hearbeat
    int nLevel =SSMGetSummonFailedLevelUp(OBJECT_SELF);
    if (nLevel != 0)
    {
        int nRet;
        if (nLevel == -1) // special shadowlord treatment
        {
          SSMScaleEpicShadowLord(OBJECT_SELF);
        }
        else if  (nLevel == -2)
        {
          SSMScaleEpicFiendishServant(OBJECT_SELF);
        }
        else
        {
            nRet = SSMLevelUpCreature(OBJECT_SELF, nLevel, CLASS_TYPE_INVALID);
            if (nRet == FALSE)
            {
                WriteTimestampedLogEntry("WARNING - nw_ch_ac1:: could not level up " + GetTag(OBJECT_SELF) + "!");
            }
        }

        // regardless if the actual levelup worked, we give up here, because we do not
        // want to run through this script more than once.
        SSMSetSummonLevelUpOK(OBJECT_SELF);
    }

    // Check if concentration is required to maintain this creature
    X2DoBreakConcentrationCheck();

    object oMaster = GetMaster();
    if(!GetAssociateState(NW_ASC_IS_BUSY))
    {

        //Seek out and disable undisabled traps
        object oTrap = GetNearestTrapToObject();
        if (bkAttemptToDisarmTrap(oTrap) == TRUE) return ; // succesful trap found and disarmed

        if(GetIsObjectValid(oMaster) &&
            GetCurrentAction(OBJECT_SELF) != ACTION_FOLLOW &&
            GetCurrentAction(OBJECT_SELF) != ACTION_DISABLETRAP &&
            GetCurrentAction(OBJECT_SELF) != ACTION_OPENLOCK &&
            GetCurrentAction(OBJECT_SELF) != ACTION_REST &&
            GetCurrentAction(OBJECT_SELF) != ACTION_ATTACKOBJECT)
        {
            if(
               !GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN))
              )
            {
                if (GetIsObjectValid(oMaster) == TRUE)
                {
                    if(GetDistanceToObject(oMaster) > 6.0)
                    {
                        if(GetAssociateState(NW_ASC_HAVE_MASTER))
                        {
                            if(!GetIsFighting(OBJECT_SELF))
                            {
                                if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                                {
                                    if(GetDistanceToObject(GetMaster()) > GetFollowDistance())
                                    {
                                        ClearActions(CLEAR_NW_CH_AC1_49);
                                        if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH) || GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                        {
                                             if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH))
                                             {
                                                //ActionUseSkill(SKILL_HIDE, OBJECT_SELF);
                                                //ActionUseSkill(SKILL_MOVE_SILENTLY,OBJECT_SELF);
                                             }
                                             if(GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                             {
                                                ActionUseSkill(SKILL_SEARCH, OBJECT_SELF);
                                             }
                                             //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Command with Search and/or Stealth");
                                             ActionForceFollowObject(oMaster, GetFollowDistance());
                                        }
                                        else
                                        {
                                             //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Normal");
                                             ActionForceFollowObject(oMaster, GetFollowDistance());
                                             //ActionForceMoveToObject(GetMaster(), TRUE, GetFollowDistance(), 5.0);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                {
                    if(GetIsObjectValid(oMaster))
                    {
                        if(GetCurrentAction(oMaster) != ACTION_REST)
                        {
                            ClearActions(CLEAR_NW_CH_AC1_81);
                            if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH) || GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                            {
                                 if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH))
                                 {
                                    //ActionUseSkill(SKILL_HIDE, OBJECT_SELF);
                                    //ActionUseSkill(SKILL_MOVE_SILENTLY,OBJECT_SELF);
                                 }
                                 if(GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                 {
                                    ActionUseSkill(SKILL_SEARCH, OBJECT_SELF);
                                 }
                                 //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Command with Search and/or Stealth");
                                 ActionForceFollowObject(oMaster, GetFollowDistance());
                            }
                            else
                            {
                                 //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Normal");
                                 ActionForceFollowObject(oMaster, GetFollowDistance());
                            }
                        }
                    }
                }
            }
            else if(!GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetAssociateState(NW_ASC_MODE_STAND_GROUND))
            {
                //DetermineCombatRound();
            }

        }
        // * if I am dominated, ask for some help
        if (GetHasEffect(EFFECT_TYPE_DOMINATED, OBJECT_SELF) == TRUE && GetIsEncounterCreature(OBJECT_SELF) == FALSE)
        {
            SendForHelp();
        }

        if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
        {
            SignalEvent(OBJECT_SELF, EventUserDefined(1001));
        }
    }
}

//:://////////////////////////////////////////////////
//:: X0_CH_HEN_HEART
/*

  OnHeartbeat event handler for henchmen/associates.

 */
void __creature_x0_ch_hen_heart()
{
    // If the henchman is in dying mode, make sure
    // they are non commandable. Sometimes they seem to
    // 'slip' out of this mode
    int bDying = GetIsHenchmanDying();

    if (bDying == TRUE)
    {
        int bCommandable = GetCommandable();
        if (bCommandable == TRUE)
        {
            // lie down again
            ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT,
                                          1.0, 65.0);
           SetCommandable(FALSE);
        }
    }

    // If we're dying or busy, we return
    // (without sending the user-defined event)
    if(GetAssociateState(NW_ASC_IS_BUSY) ||
       bDying)
        return;

    // Check to see if should re-enter stealth mode
    if (GetIsInCombat() == FALSE)
    {
        int nStealth=GetLocalInt(OBJECT_SELF, "X2_HENCH_STEALTH_MODE");
        if((nStealth == 1 || nStealth == 2)
            && GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH) == FALSE)
            {
                SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
            }
    }

    // * checks to see if a ranged weapon was being used
    // * if so, it equips it back
    if (GetIsInCombat() == FALSE)
    {        //   SpawnScriptDebugger();
        object oRight = GetLocalObject(OBJECT_SELF, "X0_L_RIGHTHAND");
        if (GetIsObjectValid(oRight) == TRUE)
        {    // * you always want to blank this value, if it not invalid
            SetLocalObject(OBJECT_SELF, "X0_L_RIGHTHAND", OBJECT_INVALID);
            if (GetWeaponRanged(oRight) == TRUE)
            {
                ClearAllActions();
                bkEquipRanged(OBJECT_INVALID, TRUE, TRUE);
                //ActionEquipItem(
                return;

            }
        }
    }

    __creature_nw_ch_ac1();
    //ExecuteScript("nw_ch_ac1", OBJECT_SELF);
}

//::///////////////////////////////////////////////
//:: Paladin Mount Heartbeat Script
//:: x3_c2_pm_hb
//:: Copyright (c) 2007 Bioware Corp.
//:://////////////////////////////////////////////
/*
     This script handles the summoning of the paladin mount.
*/
void __creature_x3_c2_pm_hb()
{
    // GZ: Fallback for timing issue sometimes preventing epic summoned creatures from leveling up to their master's level.
    // There is a timing issue with the GetMaster() function not returning the fof a creature
    // immediately after spawn. Some code which might appear to make no sense has been added
    // to the nw_ch_ac1 and x2_inc_summon files to work around this
    // This code is only run at the first hearbeat
    object oMaster=GetMaster(OBJECT_SELF);
    int nTime=HORSE_SupportAbsoluteMinute();
    if (!GetIsObjectValid(oMaster)||oMaster==OBJECT_SELF||GetIsDead(oMaster)) oMaster=GetLocalObject(OBJECT_SELF,"oX3_HorseOwner");
    if (!GetIsObjectValid(oMaster)||oMaster==OBJECT_SELF||GetIsDead(oMaster))
    { // master not present
        if (GetIsObjectValid(oMaster)&&oMaster!=OBJECT_SELF)
        { // remove from master
            AssignCommand(oMaster,HorseUnsummonPaladinMount());
            return;
        } // remove from master
        else
        { // master not present
            AssignCommand(OBJECT_SELF,ClearAllActions(TRUE));
            AssignCommand(OBJECT_SELF,HorseUnsummonPaladinMount());
            return;
        } // master not present
    } // master not present
    if (nTime>=GetLocalInt(oMaster,"nX3_PALADIN_UNSUMMON"))
    { // unsummon
        AssignCommand(oMaster,HorseUnsummonPaladinMount());
    } // unsummon
    int nLevel =SSMGetSummonFailedLevelUp(OBJECT_SELF);
    if (nLevel != 0)
    {
        int nRet;
        if (nLevel == -1) // special shadowlord treatment
        {
          SSMScaleEpicShadowLord(OBJECT_SELF);
        }
        else if  (nLevel == -2)
        {
          SSMScaleEpicFiendishServant(OBJECT_SELF);
        }
        else
        {
            nRet = SSMLevelUpCreature(OBJECT_SELF, nLevel, CLASS_TYPE_INVALID);
            if (nRet == FALSE)
            {
                WriteTimestampedLogEntry("WARNING - nw_ch_ac1:: could not level up " + GetTag(OBJECT_SELF) + "!");
            }
        }

        // regardless if the actual levelup worked, we give up here, because we do not
        // want to run through this script more than once.
        SSMSetSummonLevelUpOK(OBJECT_SELF);
    }

    // Check if concentration is required to maintain this creature
    X2DoBreakConcentrationCheck();

    if(!GetAssociateState(NW_ASC_IS_BUSY))
    {

        //Seek out and disable undisabled traps
        object oTrap = GetNearestTrapToObject();
        if (bkAttemptToDisarmTrap(oTrap) == TRUE) return ; // succesful trap found and disarmed

        if(GetIsObjectValid(oMaster) &&
            GetCurrentAction(OBJECT_SELF) != ACTION_FOLLOW &&
            GetCurrentAction(OBJECT_SELF) != ACTION_DISABLETRAP &&
            GetCurrentAction(OBJECT_SELF) != ACTION_OPENLOCK &&
            GetCurrentAction(OBJECT_SELF) != ACTION_REST &&
            GetCurrentAction(OBJECT_SELF) != ACTION_ATTACKOBJECT)
        {
            if(
               !GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN))
              )
            {
                if (GetIsObjectValid(oMaster) == TRUE)
                {
                    if(GetDistanceToObject(oMaster) > 6.0)
                    {
                        if(GetAssociateState(NW_ASC_HAVE_MASTER))
                        {
                            if(!GetIsFighting(OBJECT_SELF))
                            {
                                if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                                {
                                    if(GetDistanceToObject(GetMaster()) > GetFollowDistance())
                                    {
                                        ClearActions(CLEAR_NW_CH_AC1_49);
                                        if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH) || GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                        {
                                             if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH))
                                             {
                                                //ActionUseSkill(SKILL_HIDE, OBJECT_SELF);
                                                //ActionUseSkill(SKILL_MOVE_SILENTLY,OBJECT_SELF);
                                             }
                                             if(GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                             {
                                                ActionUseSkill(SKILL_SEARCH, OBJECT_SELF);
                                             }
                                             //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Command with Search and/or Stealth");
                                             ActionForceFollowObject(oMaster, GetFollowDistance());
                                        }
                                        else
                                        {
                                             //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Normal");
                                             ActionForceFollowObject(oMaster, GetFollowDistance());
                                             //ActionForceMoveToObject(GetMaster(), TRUE, GetFollowDistance(), 5.0);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                {
                    if(GetIsObjectValid(oMaster))
                    {
                        if(GetCurrentAction(oMaster) != ACTION_REST)
                        {
                            ClearActions(CLEAR_NW_CH_AC1_81);
                            if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH) || GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                            {
                                 if(GetAssociateState(NW_ASC_AGGRESSIVE_STEALTH))
                                 {
                                    //ActionUseSkill(SKILL_HIDE, OBJECT_SELF);
                                    //ActionUseSkill(SKILL_MOVE_SILENTLY,OBJECT_SELF);
                                 }
                                 if(GetAssociateState(NW_ASC_AGGRESSIVE_SEARCH))
                                 {
                                    ActionUseSkill(SKILL_SEARCH, OBJECT_SELF);
                                 }
                                 //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Command with Search and/or Stealth");
                                 ActionForceFollowObject(oMaster, GetFollowDistance());
                            }
                            else
                            {
                                 //MyPrintString("GENERIC SCRIPT DEBUG STRING ********** " + "Assigning Force Follow Normal");
                                 ActionForceFollowObject(oMaster, GetFollowDistance());
                            }
                        }
                    }
                }
            }
            else if(!GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetAssociateState(NW_ASC_MODE_STAND_GROUND))
            {
                //DetermineCombatRound();
            }
        }
        // * if I am dominated, ask for some help
        if (GetHasEffect(EFFECT_TYPE_DOMINATED, OBJECT_SELF) == TRUE && GetIsEncounterCreature(OBJECT_SELF) == FALSE)
        {
            SendForHelp();
        }

        if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
        {
            SignalEvent(OBJECT_SELF, EventUserDefined(1001));
        }
    }
}

/* OnHeartbeat Script for the wyrm that the Deck of Many Things
 * hatchling turns into. This causes the wyrm to vanish after
 * no more enemies are around.
 */
void __creature_x0_wyrm_heart()
{
    object oMaster = GetMaster();
    object oNearEnemy = GetNearestSeenEnemy();

    if (GetIsObjectValid(oNearEnemy) || GetIsInCombat()) 
    {
        DetermineCombatRound(oNearEnemy);
        return;
    }

    // if we got here, no more enemies
    effect eVanish = EffectDisappear();
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                        eVanish,
                        OBJECT_SELF,
                        3.0);
}

//::///////////////////////////////////////////////
//:: NW_C2_GARGOYLE.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   on gargoyle's heartbeat, if no PC nearby then become a statue
*/
void __CreateGargoyle(object oPC)
{
    object oGargoyle = CreateObject(OBJECT_TYPE_CREATURE, "NW_GARGOYLE", GetLocation(OBJECT_SELF));
    DelayCommand(0.1, AssignCommand(oGargoyle, ActionAttack(oPC)));
}

void __creature_nw_c2_gargoyle()
{
   object oCreature = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
   if (GetIsObjectValid(oCreature) == TRUE && GetDistanceToObject(oCreature) < 7.0)
   {
    //effect eMind = EffectVisualEffect(VFX_IMP_HOLY_AID);
    DelayCommand(0.1, __CreateGargoyle(oCreature));
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eMind, oGargoyle);
    SetPlotFlag(OBJECT_SELF, FALSE);
    effect eDam = EffectDamage(500);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, OBJECT_SELF);
   }
}

//::///////////////////////////////////////////////
//:: Name x2_def_heartbeat
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gelatinous Cube Heartbeat
*/
void __creature_x2_c2_gcube_hbt()
{
    // execute default AI
    __creature_nw_c2_default1();
    //ExecuteScript("nw_c2_default1", OBJECT_SELF);
    // Cube additions

    // * Only on the first heartbeat, destroy the creature's personal space
    if (!GetLocalInt(OBJECT_SELF,"X2_L_GCUBE_SETUP"))
    {
        effect eGhost = EffectCutsceneGhost();
        eGhost = SupernaturalEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,eGhost,OBJECT_SELF);
        SetLocalInt(OBJECT_SELF,"X2_L_GCUBE_SETUP",TRUE)   ;
    }

   object oVictim = GetFirstObjectInShape(SHAPE_CUBE,4.0f,GetLocation(OBJECT_SELF),TRUE, OBJECT_TYPE_CREATURE);

   while (GetIsObjectValid(oVictim))
   {
        if (spellsIsTarget(oVictim,SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF) && oVictim != OBJECT_SELF)
        {
            EngulfAndDamage(oVictim,OBJECT_SELF);
        }
        oVictim = GetNextObjectInShape(SHAPE_CUBE,4.0f,GetLocation(OBJECT_SELF),TRUE, OBJECT_TYPE_CREATURE);
   }
}

// -----------------------------------------------------------------------------
//                              Spell Cast At
// -----------------------------------------------------------------------------

#include "nw_i0_ochrejelly"

//::///////////////////////////////////////////////
//:: Default: On Spell Cast At
//:: NW_C2_DEFAULTB
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This determines if the spell just cast at the
    target is harmful or not.

    GZ 2003-Oct-02 : - New AoE Behavior AI. Will use
                       Dispel Magic against AOES
                     - Flying Creatures will ignore
                       Grease

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 6, 2001
//:: Last Modified On: 2003-Oct-13
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 4th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
void __creature_nw_c2_defaultb()
{
    object oCaster = GetLastSpellCaster();

    if(GetLastSpellHarmful())
    {
        SetCommandable(TRUE);

        if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
        { // set variables on target for mounted combat
            DeleteLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL");
        } // set variables on target for mounted combat

        // ------------------------------------------------------------------
        // If I was hurt by someone in my own faction
        // Then clear any hostile feelings I have against them
        // After all, we're all just trying to do our job here
        // if we singe some eyebrow hair, oh well.
        // ------------------------------------------------------------------
        if (GetFactionEqual(oCaster, OBJECT_SELF) == TRUE)
        {
            ClearPersonalReputation(oCaster, OBJECT_SELF);
            ClearAllActions(TRUE);
            DelayCommand(1.2, ActionDoCommand(DetermineCombatRound(OBJECT_INVALID)));
            // Send the user-defined event as appropriate
            if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
            {
                SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
            }
            return;
        }

        int bAttack = TRUE;
        // ------------------------------------------------------------------
        // GZ, 2003-Oct-02
        // Try to do something smart if we are subject to an AoE Spell.
        // ------------------------------------------------------------------
        if (MatchAreaOfEffectSpell(GetLastSpell()) == TRUE)
        {
            int nAI = (GetBestAOEBehavior(GetLastSpell())); // from x2_i0_spells
            switch (nAI)
            {
                case X2_SPELL_AOEBEHAVIOR_DISPEL_L:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_N:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_M:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_G:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_C:
                        bAttack = FALSE;
                        ActionCastSpellAtLocation(nAI, GetLocation(OBJECT_SELF));
                        ActionDoCommand(SetCommandable(TRUE));
                        SetCommandable(FALSE);
                        break;

                case X2_SPELL_AOEBEHAVIOR_FLEE:
                         ClearActions(CLEAR_NW_C2_DEFAULTB_GUSTWIND);
                         oCaster = GetLastSpellCaster();
                         ActionForceMoveToObject(oCaster, TRUE, 2.0);
                         DelayCommand(1.2, ActionDoCommand(DetermineCombatRound(oCaster)));
                         bAttack = FALSE;
                         break;

                case X2_SPELL_AOEBEHAVIOR_IGNORE:
                         // well ... nothing
                        break;

                case X2_SPELL_AOEBEHAVIOR_GUST:
                        ActionCastSpellAtLocation(SPELL_GUST_OF_WIND, GetLocation(OBJECT_SELF));
                        ActionDoCommand(SetCommandable(TRUE));
                        SetCommandable(FALSE);
                         bAttack = FALSE;
                        break;
            }

        }
        // ---------------------------------------------------------------------
        // Not an area of effect spell, but another hostile spell.
        // If we're not already fighting someone else,
        // attack the caster.
        // ---------------------------------------------------------------------
        if( !GetIsFighting(OBJECT_SELF) && bAttack)
        {
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                DetermineSpecialBehavior(oCaster);
            }
            else
            {
                DetermineCombatRound(oCaster);
            }
        }

        // We were attacked, so yell for help
        SetCommandable(TRUE);
        //Shout Attack my target, only works with the On Spawn In setup
        SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

        //Shout that I was attacked
        SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
    }
    else
    {
        // ---------------------------------------------------------------------
        // July 14, 2003 BK
        // If there is a valid enemy nearby and a NON HARMFUL spell has been
        // cast on me  I should call DetermineCombatRound
        // I may be invisible and casting spells on myself to buff myself up
        // ---------------------------------------------------------------------
        // Fix: JE - let's only do this if I'm currently in combat. If I'm not
        // in combat, and something casts a spell on me, it'll make me search
        // out the nearest enemy, no matter where they are on the level, which
        // is kinda dumb.
        object oEnemy =GetNearestEnemy();
        if ((GetIsObjectValid(oEnemy) == TRUE) && (GetIsInCombat() == TRUE))
        {
           // SpeakString("keep me in combat");
            DetermineCombatRound(oEnemy);
        }
    }

    // Send the user-defined event as appropriate
    if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
    }
}

//::///////////////////////////////////////////////
//:: Henchmen: On Spell Cast At
//:: NW_CH_ACB
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This determines if the spell just cast at the
    target is harmful or not.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 6, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 4th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
void __creature_nw_ch_acb()
{
    object oCaster = GetLastSpellCaster();
    if(GetLastSpellHarmful())
    {
        SetCommandable(TRUE);

        if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
        { // set variables on target for mounted combat
            DeleteLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL");
        } // set variables on target for mounted combat

        // * GZ Oct 3, 2003
        // * Really, the engine should handle this, but hey, this world is not perfect...
        // * If I was hurt by my master or the creature hurting me has
        // * the same master
        // * Then clear any hostile feelings I have against them
        // * After all, we're all just trying to do our job here
        // * if we singe some eyebrow hair, oh well.
        object oMyMaster = GetMaster(OBJECT_SELF);
        if ((oMyMaster != OBJECT_INVALID) && (oMyMaster == oCaster || (oMyMaster  == GetMaster(oCaster)))  )
        {
            ClearPersonalReputation(oCaster, OBJECT_SELF);
            // Send the user-defined event as appropriate
            if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
            {
                SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
            }
            return;
        }

        int bAttack = TRUE;
        // * AOE Behavior

        if (MatchAreaOfEffectSpell(GetLastSpell()) == TRUE)
        {
            if (GetIsHenchmanDying() == FALSE)
            {

                //* GZ 2003-Oct-02 : New AoE Behavior AI
                int nAI = (GetBestAOEBehavior(GetLastSpell()));

                switch (nAI)
                {
                    case X2_SPELL_AOEBEHAVIOR_DISPEL_L:
                    case X2_SPELL_AOEBEHAVIOR_DISPEL_N:
                    case X2_SPELL_AOEBEHAVIOR_DISPEL_M:
                    case X2_SPELL_AOEBEHAVIOR_DISPEL_G:
                    case X2_SPELL_AOEBEHAVIOR_DISPEL_C:
                            bAttack = FALSE;
                            ActionCastSpellAtLocation(nAI, GetLocation(OBJECT_SELF));
                            ActionDoCommand(SetCommandable(TRUE));
                            SetCommandable(FALSE);
                            break;


                    case X2_SPELL_AOEBEHAVIOR_FLEE:
                             ClearActions(CLEAR_NW_C2_DEFAULTB_GUSTWIND);
                             ActionForceMoveToObject(oCaster, TRUE, 2.0);
                             ActionMoveToObject(GetMaster(), TRUE, 1.1);
                                DelayCommand(1.2, ActionDoCommand(HenchmenCombatRound(OBJECT_INVALID)));
                             bAttack = FALSE;
                             break;

                    case X2_SPELL_AOEBEHAVIOR_IGNORE:
                             // well ... nothing
                            break;

                    case X2_SPELL_AOEBEHAVIOR_GUST:
                            ActionCastSpellAtLocation(SPELL_GUST_OF_WIND, GetLocation(OBJECT_SELF));
                            ActionDoCommand(SetCommandable(TRUE));
                            SetCommandable(FALSE);
                             bAttack = FALSE;
                            break;
                }
            }
        }

        if(
         (!GetIsObjectValid(GetAttackTarget()) &&
         !GetIsObjectValid(GetAttemptedSpellTarget()) &&
         !GetIsObjectValid(GetAttemptedAttackTarget()) &&
         !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)) &&
         !GetIsFriend(oCaster)) && bAttack)
        {
            SetCommandable(TRUE);
            //Shout Attack my target, only works with the On Spawn In setup
            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
            //Shout that I was attacked
            SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
            HenchmenCombatRound(oCaster);
        }
    }
}

void __creature_nw_ch_fmb()
{
    // Used by one base game resource.  No idea why, but it's here to cover
    //  all our bases.  The script itself doesn't exist, so we're just
    //  routing to the standard handler.  All of the other similar resources
    //  us nw_ch_acb, so we're going there.

        __creature_nw_ch_acb();
}

void __creature_nw_nw_acb()
{
    //This function assignment is a typo, but the Panther Companion
    //  has it listed, so it's included here to route correctly.
    __creature_nw_ch_acb();
}

void __creature_nw_ochrejlly_osc()
//::///////////////////////////////////////////////
//:: nw_ochrejlly_osc
//:: Copyright (c) 2004 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This NPC On Spell Cast at script is specially
    designed for Orche Jellys. It will check to
    see what spell was cast at it, then (it the
    spell was electrical) it will cause the jelly
    to split into smaller jellies.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith K2 Hayward
//:: Created On: Oct, 2004
//:: Modified On: January, 2006
//:://////////////////////////////////////////////
{
    object oPC = GetLastSpellCaster();
    object oSelf = OBJECT_SELF;

    int iCurrentHP = GetCurrentHitPoints(oSelf);
    int iSpell = GetLastSpell();

    effect eGhost = EffectCutsceneGhost();

    // if the Spell is eletrical in nature, split the Jelly into smaller jellies
    if((iSpell == SPELL_BALL_LIGHTNING) || (iSpell == SPELL_CHAIN_LIGHTNING)
      || (iSpell == SPELL_ELECTRIC_JOLT) || (iSpell == SPELL_GEDLEES_ELECTRIC_LOOP)
      || (iSpell == SPELL_GREAT_THUNDERCLAP) || (iSpell == SPELL_HAMMER_OF_THE_GODS)
      || (iSpell == SPELL_LIGHTNING_BOLT) || (iSpell == SPELL_STORM_OF_VENGEANCE))
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oSelf);
        SplitCreature(oSelf, iCurrentHP);
    }
    
    __creature_x2_def_ondamage();
    //ExecuteScript("x2_def_ondamage", oSelf);
}

void __creature_q2_spell_djinn()
//::///////////////////////////////////////////////
//:: q2_spell_djinn
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The Djinn will never stick around if a spell
    is cast at him...
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Dec 12/02
//:://////////////////////////////////////////////
{
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), GetLocation(OBJECT_SELF));
    DestroyObject(OBJECT_SELF, 2.0);
}

void __creature_x2_bb_spellcast()
//::///////////////////////////////////////////////
//:: Black Blade Of Disaster On Spell Cast AT
//:: x2_bb_spellcast
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The black blade of disaster is destroyed
    by mordenkainens disjunction
*/
//:://////////////////////////////////////////////
//:: Created By: GeorgZ
//:: Created On: Oct 11, 2003
//:://////////////////////////////////////////////
{
    if (GetLastSpell() ==  SPELL_MORDENKAINENS_DISJUNCTION)
    {
        SetPlotFlag(OBJECT_SELF,FALSE);
        DestroyObject(OBJECT_SELF);
    }
}

void __creature_x2_def_spellcast()
//::///////////////////////////////////////////////
//:: Name x2_def_spellcast
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On Spell Cast At script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{

    //--------------------------------------------------------------------------
    // GZ: 2003-10-16
    // Make Plot Creatures Ignore Attacks
    //--------------------------------------------------------------------------
    if (GetPlotFlag(OBJECT_SELF))
    {
        return;
    }

    //--------------------------------------------------------------------------
    // Execute old NWN default AI code
    //--------------------------------------------------------------------------
    __creature_nw_c2_defaultb();
    //ExecuteScript("nw_c2_defaultb", OBJECT_SELF);
}

#include "X0_INC_HENAI"
#include "x2_i0_spells"
#include "nw_i0_plot"

void __creature_x2_hen_spell()

//::///////////////////////////////////////////////
//:: Henchmen: On Spell Cast At
//:: NW_CH_ACB
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This determines if the spell just cast at the
    target is harmful or not.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 6, 2001
//:://////////////////////////////////////////////
{
    object oCaster = GetLastSpellCaster();

    // **************************************
    // * CHAPTER 1
    // * Player brings back a dead henchmen
    // * for the first time
    // *
    // **************************************
    //This should only fire the first time they are raised - when they have
        //first been discovered in Undermountain
    if (GetLocalInt(OBJECT_SELF, "X2_SavedInUndermountain") == FALSE && GetTag(GetModule()) == "x0_module1")
    {
        if (GetLastSpell() == SPELL_RAISE_DEAD || GetLastSpell() == SPELL_RESURRECTION)
        {
            SetLocalInt(OBJECT_SELF, "X2_SavedInUndermountain", 1);

            object oPC = oCaster;

            if (GetTag(OBJECT_SELF) == "x2_hen_sharwyn")
            {
                AddJournalQuestEntry("q2sharwyn", 20, oPC);
            }
            else if (GetTag(OBJECT_SELF) == "x2_hen_tomi")
            {
                AddJournalQuestEntry("q2tomi", 20, oPC);
            }
            else if (GetTag(OBJECT_SELF) == "x2_hen_daelan")
            {
                AddJournalQuestEntry("q2daelan", 20, oPC);
            }


            if (GetHitDice(oPC) < 15)
            {
                Reward_2daXP(oPC, 12, TRUE); //600 xp reward if PC is less than 15th level
            }
            else
            {
                Reward_2daXP(oPC, 11, TRUE); //200 xp reward if PC is 15th level or higher

            }

        }
    }   // special case, first time being raised (if original henches

    if(GetLastSpellHarmful())
    {
    // * GZ Oct 3, 2003
        // * Really, the engine should handle this, but hey, this world is not perfect...
        // * If I was hurt by my master or the creature hurting me has
        // * the same master
        // * Then clear any hostile feelings I have against them
        // * After all, we're all just trying to do our job here
        // * if we singe some eyebrow hair, oh well.
        object oMyMaster = GetMaster(OBJECT_SELF);
        if ((oMyMaster != OBJECT_INVALID) && (oMyMaster == oCaster || oMyMaster  == GetMaster(oCaster) ))
        {
            ClearPersonalReputation(oCaster, OBJECT_SELF);
            ClearAllActions(TRUE);
            DelayCommand(1.2, ActionDoCommand(HenchmenCombatRound(OBJECT_INVALID)));
            // Send the user-defined event as appropriate
            if(GetSpawnInCondition(NW_FLAG_SPELL_CAST_AT_EVENT))
            {
                SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_SPELL_CAST_AT));
            }
            return;
        }

        SetCommandable(TRUE);
        int bAttack = TRUE;
        // * AOE Behavior

        if (MatchAreaOfEffectSpell(GetLastSpell()) == TRUE)
        {
             //* GZ 2003-Oct-02 : New AoE Behavior AI
            int nAI = (GetBestAOEBehavior(GetLastSpell()));
            switch (nAI)
            {
                case X2_SPELL_AOEBEHAVIOR_DISPEL_L:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_N:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_M:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_G:
                case X2_SPELL_AOEBEHAVIOR_DISPEL_C:
                        bAttack = FALSE;
                        ActionCastSpellAtLocation(nAI, GetLocation(OBJECT_SELF));
                        ActionDoCommand(SetCommandable(TRUE));
                        SetCommandable(FALSE);
                        break;


                case X2_SPELL_AOEBEHAVIOR_FLEE:
                         ClearActions(CLEAR_NW_C2_DEFAULTB_GUSTWIND);
                         ActionForceMoveToObject(oCaster, TRUE, 2.0);
                         ActionMoveToObject(GetMaster(), TRUE, 1.1);
                            DelayCommand(1.2, ActionDoCommand(HenchmenCombatRound(OBJECT_INVALID)));
                         bAttack = FALSE;
                         break;

                case X2_SPELL_AOEBEHAVIOR_IGNORE:
                         // well ... nothing
                        break;

                case X2_SPELL_AOEBEHAVIOR_GUST:
                        ActionCastSpellAtLocation(SPELL_GUST_OF_WIND, GetLocation(OBJECT_SELF));
                        ActionDoCommand(SetCommandable(TRUE));
                        SetCommandable(FALSE);
                         bAttack = FALSE;
                        break;
                }
        }

        if(
         (!GetIsObjectValid(GetAttackTarget()) &&
         !GetIsObjectValid(GetAttemptedSpellTarget()) &&
         !GetIsObjectValid(GetAttemptedAttackTarget()) &&
         !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)) &&
         !GetIsFriend(oCaster)) && bAttack
        )
        {
            SetCommandable(TRUE);
            //Shout Attack my target, only works with the On Spawn In setup
            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
            //Shout that I was attacked
            SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
            HenchmenCombatRound(oCaster);
        }
    }
    // * Make a henchman initiate with the player if they've just been raised or resurrected
    else if(GetLastSpell() == SPELL_RAISE_DEAD || GetLastSpell()  == SPELL_RESURRECTION)
    {
       // * restore merchant faction to neutral
       SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 100, oCaster);
       SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 100, oCaster);
       SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 100, oCaster);
       ClearPersonalReputation(oCaster, OBJECT_SELF);
       AssignCommand(OBJECT_SELF, SurrenderToEnemies());
        object oHench = OBJECT_SELF;
        AssignCommand(oHench, ClearAllActions(TRUE));
        string sFile = GetDialogFileToUse(oCaster);

        // * reset henchmen attack state - Oct 28 (BK)
        SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE, oHench);
        SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE, oHench);

        // * Oct 30 - If player previously hired this hench
        // * then just have them rejoin automatically
        if (GetPlayerHasHired(oCaster, oHench) == TRUE)
        {
            // Feb 11, 2004 - Jon: Don't fire the HireHenchman function if the
            // henchman is already oCaster's associate. Fixes a silly little problem
            // that occured when you try to raise a henchman who wasn't actually dead.
            if(GetMaster(oHench)!=oCaster) HireHenchman(oCaster, oHench, TRUE);
        }
        // * otherwise, they talk
        else
        {
            AssignCommand(oCaster, ActionStartConversation(oHench, sFile));
        }
    }
}

// -----------------------------------------------------------------------------
//                              Physical Attacked
// -----------------------------------------------------------------------------

void __creature_nw_c2_default5()
//::///////////////////////////////////////////////
//:: Default On Attacked
//:: NW_C2_DEFAULT5
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 4th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
{
    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
        { // set variables on target for mounted combat
            SetLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL",TRUE);
            SetLocalInt(OBJECT_SELF,"nX3_HP_BEFORE",GetCurrentHitPoints(OBJECT_SELF));
        } // set variables on target for mounted combat

    if(GetFleeToExit()) {
        // Run away!
        ActivateFleeToExit();
    } else if (GetSpawnInCondition(NW_FLAG_SET_WARNINGS)) {
        // We give an attacker one warning before we attack
        // This is not fully implemented yet
        SetSpawnInCondition(NW_FLAG_SET_WARNINGS, FALSE);

        //Put a check in to see if this attacker was the last attacker
        //Possibly change the GetNPCWarning function to make the check
    } else {
        object oAttacker = GetLastAttacker();
        if (!GetIsObjectValid(oAttacker)) {
            // Don't do anything, invalid attacker

        } else if (!GetIsFighting(OBJECT_SELF)) {
            // We're not fighting anyone else, so
            // start fighting the attacker
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) {
                SetSummonHelpIfAttacked();
                DetermineSpecialBehavior(oAttacker);
            } else if (GetArea(oAttacker) == GetArea(OBJECT_SELF)) {
                SetSummonHelpIfAttacked();
                DetermineCombatRound(oAttacker);
            }

            //Shout Attack my target, only works with the On Spawn In setup
            SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

            //Shout that I was attacked
            SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
        }
    }

    if(GetSpawnInCondition(NW_FLAG_ATTACK_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_ATTACKED));
    }
}

void __creature_nw_ch_ac5()
//::///////////////////////////////////////////////
//:: Associate On Attacked
//:: NW_CH_AC5
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 4th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
{
    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
        { // set variables on target for mounted combat
            SetLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL",TRUE);
            SetLocalInt(OBJECT_SELF,"nX3_HP_BEFORE",GetCurrentHitPoints(OBJECT_SELF));
        } // set variables on target for mounted combat

    SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
    if(!GetAssociateState(NW_ASC_IS_BUSY))
    {
        SetCommandable(TRUE);
        if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
        {
            if(!GetIsObjectValid(GetAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
            {
                if(GetIsObjectValid(GetLastAttacker()))
                {
                    if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER))
                    {
                        object oTarget = GetLastAttacker(GetMaster());
                        HenchmenCombatRound(oTarget);
                    }
                    else
                    {
                        HenchmenCombatRound(OBJECT_INVALID);
                    }

                }
            }
            if(GetSpawnInCondition(NW_FLAG_ATTACK_EVENT))
            {
                SignalEvent(OBJECT_SELF, EventUserDefined(1005));
            }
        }
    }
}

void __creature_nw_ch_acd()
//::///////////////////////////////////////////////
//:: User Defined Henchmen Script
//:: NW_CH_ACD
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The most complicated script in the game.
    ... ever
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: March 18, 2002
//:://////////////////////////////////////////////
{
    int nEvent = GetUserDefinedEventNumber();

    // * If a creature has the integer variable X2_L_CREATURE_NEEDS_CONCENTRATION set to TRUE
    // * it may receive this event. It will unsommon the creature immediately
    if (nEvent == X2_EVENT_CONCENTRATION_BROKEN)
    {
        effect eVis = EffectVisualEffect(VFX_IMP_UNSUMMON);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eVis,GetLocation(OBJECT_SELF));
        FloatingTextStrRefOnCreature(84481,GetMaster(OBJECT_SELF));
        DestroyObject(OBJECT_SELF,0.1f);
    }
}

void __creature_nw_e0_default5()
//::///////////////////////////////////////////////
//:: Default On Attacked
//::
//:: NW_E0_Default5.nss
//::
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: If I am attacked, I attack my attacker.
//:://////////////////////////////////////////////
//:: Created By: Brent, On: April 24, 2001
//:: Modified By Aidan on Oct 2001
//:://////////////////////////////////////////////
{
    object oTarget = GetAttackTarget();
    object oAttacker = GetLastAttacker(OBJECT_SELF);
    SpeakString("NW_I_WAS_ATTACKED",TALKVOLUME_SILENT_SHOUT);
    if (GetIsObjectValid(oAttacker) &&
        !GetIsObjectValid(oTarget) &&
        GetIsEnemy(oAttacker) )
    {
      ClearAllActions();
      ActionAttack(oAttacker);
    }

}

void __creature_nw_ochrejlly_opa()
//::///////////////////////////////////////////////
//:: nw_ochrejlly_opa
//:: Copyright (c) 2004 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The NPC On Physically Attacked script is for the
    Ochre Jellies in PotSC. If the Target is physically
    attacked, divide into smaller jellies.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith K2 Hayward
//:: Created On: August 2004
//:: Modified On: January, 2006
//:://////////////////////////////////////////////
{
    object oPC = GetLastAttacker();
    object oSelf = OBJECT_SELF;
    object oWeapon = GetLastWeaponUsed(oPC);

    effect eGhost = EffectCutsceneGhost();
    int iCurrentHP = GetCurrentHitPoints(oSelf);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oSelf);
    SplitCreature(oSelf, iCurrentHP);
}

void __creature_q2_attack_djinn()
//::///////////////////////////////////////////////
//:: q2_attack_djinn
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round

    Djinn will dissappear if attacked
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Dec 12/02
//:://////////////////////////////////////////////
{

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), GetLocation(OBJECT_SELF));
    DestroyObject(OBJECT_SELF, 2.0);
}

void __creature_x0_ch_hen_attack()
//::///////////////////////////////////////////////
//:: Associate On Attacked
//:: NW_CH_AC5
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////
{
    __creature_nw_ch_ac5();
	//ExecuteScript("nw_ch_ac5", OBJECT_SELF);
}

void __creature_x2_def_attacked()
//::///////////////////////////////////////////////
//:: Associate On Attacked
//:: NW_CH_AC5
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////
{
    __creature_nw_ch_ac5();
	//ExecuteScript("nw_ch_ac5", OBJECT_SELF);
}

// -----------------------------------------------------------------------------
//                              Damaged
// -----------------------------------------------------------------------------

void __creature_nw_c2_default6()
//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT6
//:: Default OnDamaged handler
/*
    If already fighting then ignore, else determine
    combat round
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
//:://////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 17th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////////
{
    object oDamager = GetLastDamager();
    object oMe=OBJECT_SELF;
    int nHPBefore;
    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
    if (GetHasFeat(FEAT_MOUNTED_COMBAT)&&HorseGetIsMounted(OBJECT_SELF))
    { // see if can negate some damage
        if (GetLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL"))
        { // last attack was physical
            nHPBefore=GetLocalInt(OBJECT_SELF,"nX3_HP_BEFORE");
            if (!GetLocalInt(OBJECT_SELF,"bX3_ALREADY_MOUNTED_COMBAT"))
            { // haven't already had a chance to use this for the round
                SetLocalInt(OBJECT_SELF,"bX3_ALREADY_MOUNTED_COMBAT",TRUE);
                int nAttackRoll=GetBaseAttackBonus(oDamager)+d20();
                int nRideCheck=GetSkillRank(SKILL_RIDE,OBJECT_SELF)+d20();
                if (nRideCheck>=nAttackRoll&&!GetIsDead(OBJECT_SELF))
                { // averted attack
                    if (GetIsPC(oDamager)) SendMessageToPC(oDamager,GetName(OBJECT_SELF)+GetStringByStrRef(111991));
                    //if (GetIsPC(OBJECT_SELF)) SendMessageToPCByStrRef(OBJECT_SELF,111992");
                    if (GetCurrentHitPoints(OBJECT_SELF)<nHPBefore)
                    { // heal
                        effect eHeal=EffectHeal(nHPBefore-GetCurrentHitPoints(OBJECT_SELF));
                        AssignCommand(GetModule(),ApplyEffectToObject(DURATION_TYPE_INSTANT,eHeal,oMe));
                    } // heal
                } // averted attack
            } // haven't already had a chance to use this for the round
        } // last attack was physical
    } // see if can negate some damage
    if(GetFleeToExit()) {
        // We're supposed to run away, do nothing
    } else if (GetSpawnInCondition(NW_FLAG_SET_WARNINGS)) {
        // don't do anything?
    } else {
        if (!GetIsObjectValid(oDamager)) {
            // don't do anything, we don't have a valid damager
        } else if (!GetIsFighting(OBJECT_SELF)) {
            // If we're not fighting, determine combat round
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) {
                DetermineSpecialBehavior(oDamager);
            } else {
                if(!GetObjectSeen(oDamager)
                   && GetArea(OBJECT_SELF) == GetArea(oDamager)) {
                    // We don't see our attacker, go find them
                    ActionMoveToLocation(GetLocation(oDamager), TRUE);
                    ActionDoCommand(DetermineCombatRound());
                } else {
                    DetermineCombatRound();
                }
            }
        } else {
            // We are fighting already -- consider switching if we've been
            // attacked by a more powerful enemy
            object oTarget = GetAttackTarget();
            if (!GetIsObjectValid(oTarget))
                oTarget = GetAttemptedAttackTarget();
            if (!GetIsObjectValid(oTarget))
                oTarget = GetAttemptedSpellTarget();

            // If our target isn't valid
            // or our damager has just dealt us 25% or more
            //    of our hp in damager
            // or our damager is more than 2HD more powerful than our target
            // switch to attack the damager.
            if (!GetIsObjectValid(oTarget)
                || (
                    oTarget != oDamager
                    &&  (
                         GetTotalDamageDealt() > (GetMaxHitPoints(OBJECT_SELF) / 4)
                         || (GetHitDice(oDamager) - 2) > GetHitDice(oTarget)
                         )
                    )
                )
            {
                // Switch targets
                DetermineCombatRound(oDamager);
            }
        }
    }

    // Send the user-defined event signal
    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DAMAGED));
    }
}

/*
Shared with Physical Attacked above
void __creature_nw_ch_ac5()
*/

//void __creature_nw_ch_ac6()
// Determine whether to switch to new attacker
int SwitchTargets(object oCurTarget, object oNewEnemy)
{
    return (GetIsObjectValid(oNewEnemy) && oCurTarget != oNewEnemy
            &&
            (
             // The new enemy is of a higher level
             GetHitDice(oNewEnemy) > GetHitDice(oCurTarget)
             ||
             // or we just received more than 25% of our hp in damage
             GetTotalDamageDealt() > (GetMaxHitPoints(OBJECT_SELF) / 4)
             )
            );
}

void __creature_nw_ch_ac6()
//::///////////////////////////////////////////////
//:: Associate: On Damaged
//:: NW_CH_AC6
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 17th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
// Determine whether to switch to new attacker
{
    object oAttacker = GetLastDamager();
    object oTarget = GetAttackTarget();
    object oDamager = oAttacker;
    object oMe=OBJECT_SELF;
    int nHPBefore;
    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
    if (GetHasFeat(FEAT_MOUNTED_COMBAT)&&HorseGetIsMounted(OBJECT_SELF))
    { // see if can negate some damage
        if (GetLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL"))
        { // last attack was physical
            nHPBefore=GetLocalInt(OBJECT_SELF,"nX3_HP_BEFORE");
            if (!GetLocalInt(OBJECT_SELF,"bX3_ALREADY_MOUNTED_COMBAT"))
            { // haven't already had a chance to use this for the round
                SetLocalInt(OBJECT_SELF,"bX3_ALREADY_MOUNTED_COMBAT",TRUE);
                int nAttackRoll=GetBaseAttackBonus(oDamager)+d20();
                int nRideCheck=GetSkillRank(SKILL_RIDE,OBJECT_SELF)+d20();
                if (nRideCheck>=nAttackRoll&&!GetIsDead(OBJECT_SELF))
                { // averted attack
                    if (GetIsPC(oDamager)) SendMessageToPC(oDamager,GetName(OBJECT_SELF)+GetStringByStrRef(111991));
                    //if (GetIsPC(OBJECT_SELF)) SendMessageToPCByStrRef(OBJECT_SELF,111992);
                    if (GetCurrentHitPoints(OBJECT_SELF)<nHPBefore)
                    { // heal
                        effect eHeal=EffectHeal(nHPBefore-GetCurrentHitPoints(OBJECT_SELF));
                        AssignCommand(GetModule(),ApplyEffectToObject(DURATION_TYPE_INSTANT,eHeal,oMe));
                    } // heal
                } // averted attack
            } // haven't already had a chance to use this for the round
        } // last attack was physical
    } // see if can negate some damage

    // UNINTERRUPTIBLE ACTIONS
    if(GetAssociateState(NW_ASC_IS_BUSY)
       || GetAssociateState(NW_ASC_MODE_STAND_GROUND)
       || GetCurrentAction() == ACTION_FOLLOW) {
        // We're busy, don't do anything
    }

    // DEFEND MASTER
    // Priority is to protect our master
    else if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER)) {
        object oMasterEnemy = GetLastHostileActor(GetMaster());

        // defend our master first
        if (GetIsObjectValid(oMasterEnemy)) {
            HenchmenCombatRound(oMasterEnemy);

        } else if ( !GetIsObjectValid(oTarget)
                || SwitchTargets(oTarget, oAttacker)) {
            HenchmenCombatRound(oAttacker);
        }
    }

    // SWITCH TO MORE DANGEROUS ATTACKER
    // If we're already fighting, possibly switch to our new attacker
    else if (GetIsObjectValid(oTarget) && SwitchTargets(oTarget, oAttacker)) {
        // Switch to the attacker
        HenchmenCombatRound(oAttacker);
    }

    // Signal the user-defined event
    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1006));
    }
}

void __creature_x0_ch_hen_damage()
//:://////////////////////////////////////////////////
//:: X0_CH_HEN_DAMAGE
/*
  OnDamaged event handler for henchmen/associates.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/06/2003
//:://////////////////////////////////////////////////
{
    __creature_nw_ch_ac6();
	//ExecuteScript("nw_ch_ac6", OBJECT_SELF);
}

//:://////////////////////////////////////////////////
/* OnDamaged/OnDeath script for the Deck-summoned hatchlings
 * Transforms them into ancient dragons of the same color.
 */

void DoWyrmSummon(string sResRef, location locSummon)
{
    // This will automatically unsummon the hatchling
    effect eSumm = EffectSummonCreature(sResRef,
                                        VFX_IMP_DISPEL,
                                        0.5);

    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT,
                          eSumm,
                          locSummon);
}

void __creature_x0_hatch_dam()
{
    if (GetLocalInt(OBJECT_SELF, "TRIGGERED")) return;
    SetLocalInt(OBJECT_SELF, "TRIGGERED", TRUE);

    object oCaster = GetMaster();

    // Destroy the hatchling-summoning object
    object oHatchObject = GetLocalObject(oCaster, "X0_DECK_HATCH_OBJECT");
    DestroyObject(oHatchObject);

    // transform the hatchling into appropriate ancient dragon
    string sResRef = GetResRef(OBJECT_SELF);
    if (sResRef == "x0_hatch_good") {
        sResRef = "x0_wyrm_good";
    } else {
        sResRef = "x0_wyrm_evil";
    }

    location locMe = GetLocation(OBJECT_SELF);
    AssignCommand(oCaster, DoWyrmSummon(sResRef, locMe));
}

void __creature_x2_def_ondamage()
//::///////////////////////////////////////////////
//:: Name x2_def_ondamage
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default OnDamaged script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    //--------------------------------------------------------------------------
    // GZ: 2003-10-16
    // Make Plot Creatures Ignore Attacks
    //--------------------------------------------------------------------------
    if (GetPlotFlag(OBJECT_SELF))
    {
        return;
    }

    //--------------------------------------------------------------------------
    // Execute old NWN default AI code
    //--------------------------------------------------------------------------
    __creature_nw_c2_default6();
    //ExecuteScript("nw_c2_default6", OBJECT_SELF);
}

// -----------------------------------------------------------------------------
//                              Death
// -----------------------------------------------------------------------------

#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "nw_i0_plot"
#include "nw_i0_spells"

void __creature_nw_c2_default7()
//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT7
/*
  Default OnDeath event handler for NPCs.

  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
//:://////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: April 1st, 2008
//:: Added Support for Dying Wile Mounted
//:://///////////////////////////////////////////////
{
    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();

    if (GetLocalInt(GetModule(),"X3_ENABLE_MOUNT_DB")&&GetIsObjectValid(GetMaster(OBJECT_SELF))) SetLocalInt(GetMaster(OBJECT_SELF),"bX3_STORE_MOUNT_INFO",TRUE);


    // If we're a good/neutral commoner,
    // adjust the killer's alignment evil
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }
    craft_drop_items(oKiller);
}

void __creature_nw_c2_stnkbtdie()
//::///////////////////////////////////////////////
//:: Stink Beetle OnDeath Event
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Releases the Stink Beetle's Stinking Cloud
    special ability OnDeath.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew
//:: Created On: Jan 2002
//:://////////////////////////////////////////////
{
    //Declare major variables
    effect eAOE = EffectAreaOfEffect(AOE_MOB_TYRANT_FOG,"NW_S1_Stink_A");
    location lTarget = GetLocation(OBJECT_SELF);

    //Create the AOE object at the selected location
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, lTarget, RoundsToSeconds(2));
}

void __creature_nw_c2_vampire7()
//::///////////////////////////////////////////////
//:: NW_C2_VAMPIRE7.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Vampire turns into a vampire shadow
    that looks for the nearest coffin
    with the same tag as the shadow.
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
{
    object oGas = CreateObject(OBJECT_TYPE_CREATURE, GetTag(OBJECT_SELF) + "_SHAD",GetLocation(OBJECT_SELF));
    SetLocalString(oGas, "NW_L_MYCREATOR", GetTag(OBJECT_SELF));
    DestroyObject(OBJECT_SELF, 0.5);
}

//void __creature_nw_ch_ac7()
//::///////////////////////////////////////////////
//:: Henchman Death Script
//::
//:: NW_CH_AC7.nss
//::
//:: Copyright (c) 2001-2008 Bioware Corp.
//:://////////////////////////////////////////////
//:: Official Campaign Henchmen Respawn
//:://////////////////////////////////////////////
//::
//:: Modified by:   Brent, April 3 2002
//::                Removed delay in respawning
//::                the henchman - caused bugs
//:
//::                Georg, Oct 8 2003
//::                Rewrote teleport to temple routine
//::                because it was broken by
//::                some delicate timing issues in XP2
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: April 9th, 2008
//:: Added Support for Dying Wile Mounted
//:://///////////////////////////////////////////////

// -----------------------------------------------------------------------------
// Georg, 2003-10-08
// Rewrote that jump part to get rid of the DelayCommand Code that was prone to
// timing problems. If want to see a really back hack, this function is just that.
// -----------------------------------------------------------------------------
void WrapJump(string sTarget)
{
    if (GetIsDead(OBJECT_SELF))
    {
        // * Resurrect and heal again, just in case
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectResurrection(), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectHeal(GetMaxHitPoints(OBJECT_SELF)), OBJECT_SELF);

        // * recursively call self until we are alive again
        DelayCommand(1.0f,WrapJump( sTarget));
        return;
    }
    // * since the henchmen are teleporting very fast now, we leave a bloodstain on the ground
    object oBlood = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_bloodstain", GetLocation(OBJECT_SELF));

    // * Remove blood after a while
    DestroyObject(oBlood,30.0f);

    // * Ensure the action queue is open to modification again
    SetCommandable(TRUE,OBJECT_SELF);

    // * Jump to Target
    JumpToObject(GetObjectByTag(sTarget), FALSE);

    // * Unset busy state
    ActionDoCommand(SetAssociateState(NW_ASC_IS_BUSY, FALSE));

    // * Make self vulnerable
    SetPlotFlag(OBJECT_SELF, FALSE);

    // * Set destroyable flag to leave corpse
    DelayCommand(6.0f, SetIsDestroyable(TRUE, TRUE, TRUE));

    // * if mounted make sure dismounted
    if (HorseGetIsMounted(OBJECT_SELF))
    { // dismount
        DelayCommand(3.0,AssignCommand(OBJECT_SELF,HorseDismountWrapper()));
    } // dismount
}

// -----------------------------------------------------------------------------
// Georg, 2003-10-08
// Changed to run the bad recursive function above.
// -----------------------------------------------------------------------------
void BringBack()
{
    object oSelf = OBJECT_SELF;

    SetLocalObject(oSelf,"NW_L_FORMERMASTER", GetMaster());
    RemoveEffects(oSelf);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectResurrection(), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectHeal(GetMaxHitPoints(OBJECT_SELF)), OBJECT_SELF);

    object oWay = GetObjectByTag("NW_DEATH_TEMPLE");

    if (GetIsObjectValid(oWay) == TRUE)
    {
        // * if in Source stone area, respawn at opening to area
        if (GetTag(GetArea(oSelf)) == "M4Q1D2")
        {
            DelayCommand(1.0, WrapJump("M4QD07_ENTER"));
        }
        else
        {
            DelayCommand(1.0, WrapJump(GetTag(oWay)));
        }
    }
    else
    {
        WriteTimestampedLogEntry("UT: No place to go");
    }
}

void __creature_nw_ch_ac7()
{
    SetLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT","nw_ch_ac7");
    if (HorseHandleDeath()) return;
    DeleteLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT");

    // * This is used by the advanced henchmen
    // * Let Brent know if it interferes with animal
    // * companions et cetera
    if (GetIsObjectValid(GetMaster()) == TRUE)
    {
        object oMe = OBJECT_SELF;
        if (GetAssociateType(oMe) == ASSOCIATE_TYPE_HENCHMAN
            // * this is to prevent 'double hits' from stopping
            // * the henchmen from moving to the temple of tyr
            // * I.e., henchmen dies 'twice', once after leaving  your party
            || GetLocalInt(oMe, "NW_L_HEN_I_DIED") == TRUE)
        {
            // -----------------------------------------------------------------------------
            // Georg, 2003-10-08
            // Rewrote code from here.
            // -----------------------------------------------------------------------------

           SetPlotFlag(oMe, TRUE);
           SetAssociateState(NW_ASC_IS_BUSY, TRUE);
           AddJournalQuestEntry("Henchman", 99, GetMaster(), FALSE, FALSE, FALSE);
           SetIsDestroyable(FALSE, TRUE, TRUE);
           SetLocalInt(OBJECT_SELF, "NW_L_HEN_I_DIED", TRUE);
           BringBack();

           // -----------------------------------------------------------------------------
           // End of rewrite
           // -----------------------------------------------------------------------------

        }
        else
        // * I am a familiar, give 1d6 damage to my master
        if (GetAssociate(ASSOCIATE_TYPE_FAMILIAR, GetMaster()) == OBJECT_SELF)
        {
            // April 2002: Made it so that familiar death can never kill the player
            // only wound them.
            int nDam =d6();
            if (nDam >= GetCurrentHitPoints(GetMaster()))
            {
                nDam = GetCurrentHitPoints(GetMaster()) - 1;
            }
            effect eDam = EffectDamage(nDam);
            FloatingTextStrRefOnCreature(63489, GetMaster(), FALSE);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, GetMaster());
        }
    }
}

void __creature_nw_s3_balordeth()
//::///////////////////////////////////////////////
//:: Balor On Death
//:: NW_S3_BALORDETH
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Fireball explosion does 50 damage to all within
    20ft
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 9, 2002
//:://////////////////////////////////////////////
{
    //Declare major variables
    object oCaster = OBJECT_SELF;
    int nMetaMagic = GetMetaMagicFeat();
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eDam;
    //Get the spell target location as opposed to the spell target.
    location lTarget = GetLocation(OBJECT_SELF);
    //Limit Caster level for the purposes of damage
    //Apply the fireball explosion at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
       //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FIREBALL));
        //Get the distance between the explosion and the target to calculate delay
        fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;
        if (!MyResistSpell(OBJECT_SELF, oTarget, fDelay))
	    {
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamage = GetReflexAdjustedDamage(50, oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_FIRE);
            //Set the damage effect
            eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
            if(nDamage > 0)
            {
                // Apply effects to the currently selected target.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                //This visual effect is applied to the target object not the location as above.  This visual effect
                //represents the flame that erupts on the target not on the ground.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
         }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR);
    }
}

//void __creature_x0_hatch_dam()  Shared

void __creature_x2_def_ondeath()
//::///////////////////////////////////////////////
//:: Name x2_def_ondeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default OnDeath script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    __creature_nw_c2_default7();
    //ExecuteScript("nw_c2_default7", OBJECT_SELF);
}

void __creature_x2_hen_death()
//::///////////////////////////////////////////////
//:: Henchman Death Script
//::
//:: X2_HEN_DEATH.nss
//::
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: <description>
//:://////////////////////////////////////////////
//::
//:: Created By:
//:: Modified by:   Brent, April 3 2002
//::                Removed delay in respawning
//::                the henchman - caused bugs
//:: Modified November 14 2002
//::  - Henchem will now stay dead. Need to be raised
//:://////////////////////////////////////////////

//::///////////////////////////////////////////////
//:: Greater Restoration
//:: NW_S0_GrRestore.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes all negative effects of a temporary nature
    and all permanent effects of a supernatural nature
    from the character. Does not remove the effects
    relating to Mind-Affecting spells or movement alteration.
    Heals target for 5d8 + 1 point per caster level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Modifications To Support Horses By: Deva Winblood, On: April 17th, 2008

{
    SetLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT","x2_hen_death");
    if (HorseHandleDeath()) return;
    DeleteLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT");

    if (GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN)
    {
       SetLocalInt(OBJECT_SELF, "X2_L_IJUSTDIED", 10);
       SetKilled(GetMaster());
       SetDidDie();
       object oHench = OBJECT_SELF;
        // * Take them out of stealth mode too (Nov 1 - BK)
        SetActionMode(oHench, ACTION_MODE_STEALTH, FALSE);
        // * Remove invisibility type effects off of henchmen (Nov 7 - BK)
        RemoveSpellEffects(SPELL_INVISIBILITY, oHench, oHench);
        RemoveSpellEffects(SPELL_IMPROVED_INVISIBILITY, oHench, oHench);
        RemoveSpellEffects(SPELL_SANCTUARY, oHench, oHench);
        RemoveSpellEffects(SPELL_ETHEREALNESS, oHench, oHench);
    }
    RemoveHenchman(GetMaster(), OBJECT_SELF);

       // * Custom stuff, if your henchman betrayed you
   // * they can no longer be raised
   string sTag = GetTag(OBJECT_SELF);
   int bDestroyMe = FALSE;
   if (sTag == "H2_Aribeth" && GetLocalInt(GetModule(), "bAribethBetrays") == TRUE)
   {
    bDestroyMe = TRUE;
   }
   else
   if (sTag == "x2_hen_nathyra" && GetLocalInt(GetModule(), "bNathyrraBetrays") == TRUE)
   {
    bDestroyMe = TRUE;

   }
   else
   if (sTag == "x2_hen_valen" && GetLocalInt(GetModule(), "bValenBetrays") == TRUE)
   {
    bDestroyMe = TRUE;

   }
   else
   if (sTag == "x2_hen_deekin" && GetLocalInt(GetModule(), "bDeekinBetrays") == TRUE)
   {
    bDestroyMe = TRUE;
   }

   if (bDestroyMe == TRUE)
   {
    // * For purposes of end-game narration, set whether henchmen
    // * died in final battle
    SetLocalInt(GetModule(), GetTag(OBJECT_SELF) + "_DIED", 1);
    SetIsDestroyable(FALSE, FALSE, FALSE);
   }
}

void __creature_x3_c2_pm_death()
//:://////////////////////////////////////////////////
//:: X3_C2_PM_DEATH
/*
  Default OnDeath event handler for Paladin Mount

  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: 2008-01-02
//:: Modified to remove despawn info from PC owner
//:://////////////////////////////////////////////
{
    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();
    object oMaster=GetMaster(OBJECT_SELF);
    effect eVFX;
    DeleteLocalInt(oMaster,"nX3_PALADIN_UNSUMMON");
    eVFX=EffectVisualEffect(VFX_IMP_UNSUMMON);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eVFX,GetLocation(OBJECT_SELF));
    // If we're a good/neutral commoner,
    // adjust the killer's alignment evil
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }
    //craft_drop_items(oKiller);
}

// -----------------------------------------------------------------------------
//                              Conversation
// -----------------------------------------------------------------------------

void __creature_nw_ch_ac4()
//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT4
/*
  Default OnConversation event handler for NPCs.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
{
    // * if petrified, jump out
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF) == TRUE)
    {
        return;
    }

    // * If dead, exit directly.
    if (GetIsDead(OBJECT_SELF) == TRUE)
    {
        return;
    }

    // See if what we just 'heard' matches any of our
    // predefined patterns
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();

    if (nMatch == -1) 
    {
        // Not a match -- start an ordinary conversation
        if (GetCommandable(OBJECT_SELF))
        {
            ClearActions(CLEAR_NW_C2_DEFAULT4_29);
            BeginConversation();
        }
        else
        // * July 31 2004
        // * If only charmed then allow conversation
        // * so you can have a better chance of convincing
        // * people of lowering prices
        if (GetHasEffect(EFFECT_TYPE_CHARMED) == TRUE)
        {
            ClearActions(CLEAR_NW_C2_DEFAULT4_29);
            BeginConversation();
        }
    } 
    // Respond to shouts from friendly non-PCs only
    else if (GetIsObjectValid(oShouter) 
               && !GetIsPC(oShouter) 
               && GetIsFriend(oShouter))
    {
        object oIntruder = OBJECT_INVALID;
        // Determine the intruder if any
        if(nMatch == 4)
        {
            oIntruder = GetLocalObject(oShouter, "NW_BLOCKER_INTRUDER");
        }
        else if (nMatch == 5)
        {
            oIntruder = GetLastHostileActor(oShouter);
            if(!GetIsObjectValid(oIntruder))
            {
                oIntruder = GetAttemptedAttackTarget();
                if(!GetIsObjectValid(oIntruder))
                {
                    oIntruder = GetAttemptedSpellTarget();
                    if(!GetIsObjectValid(oIntruder))
                    {
                        oIntruder = OBJECT_INVALID;
                    }
                }
            }
        }
        
        // Actually respond to the shout
        RespondToShout(oShouter, nMatch, oIntruder);
    }

    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}

//void __creature_nw_c2_default4()
//::///////////////////////////////////////////////
//:: Associate: On Dialogue
//:: NW_CH_AC4
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    by the generic script after dialogue or a
    shout is initiated.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 24, 2001
//:://////////////////////////////////////////////
// * This function checks to make sure no
// * dehibilating effects are on the player that should
// * Don't use getcommandable for this since the dying system
// * will sometimes leave a player in a noncommandable state
int AbleToTalk(object oSelf)
{
    if (GetCommandable(oSelf) == FALSE)
    {
        if (GetHasEffect(EFFECT_TYPE_CONFUSED, oSelf) || GetHasEffect(EFFECT_TYPE_DOMINATED, oSelf) ||
            GetHasEffect(EFFECT_TYPE_PETRIFY, oSelf) || GetHasEffect(EFFECT_TYPE_PARALYZE, oSelf)   ||
            GetHasEffect(EFFECT_TYPE_STUNNED, oSelf) || GetHasEffect(EFFECT_TYPE_FRIGHTENED, oSelf)
        )
        {
            return FALSE;
        }
    }
    return TRUE;
}

void __creature_nw_c2_default4()
{
    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    object oIntruder;

    if (nMatch == -1) {
        if(AbleToTalk(OBJECT_SELF) || GetCurrentAction() != ACTION_OPENLOCK)
        {
            ClearActions(CLEAR_NW_CH_AC4_28);

            // * if in XP2, use an alternative dialog file
            string sDialog = "";
            if (GetLocalInt(GetModule(), "X2_L_XP2") ==  1)
            {
                sDialog = "x2_associate";
            }
            BeginConversation(sDialog);
        }
    } else {
        // listening pattern matched
        if (GetIsObjectValid(oShouter) && oMaster == oShouter)
        {
            SetCommandable(TRUE);
            bkRespondToHenchmenShout(oShouter, nMatch, oIntruder, TRUE);
        }
    }

    // Signal user-defined event
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT)) {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}

void __creature_x2_def_onconv()
//::///////////////////////////////////////////////
//:: Name x2_def_onconv
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On Conversation script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    __creature_nw_c2_default4();
    //ExecuteScript("nw_c2_default4", OBJECT_SELF);
}

//void __creature_x0_ch_hen_conv()
//:://////////////////////////////////////////////////
//:: X0_CH_HEN_CONV
/*

  OnDialogue event handler for henchmen/associates.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/05/2003
//:://////////////////////////////////////////////////

/*  Shared with above
//* GeorgZ - Put in a fix for henchmen talking even if they are petrified
int AbleToTalk(object oSelf)
{
   if (GetHasEffect(EFFECT_TYPE_CONFUSED, oSelf) || GetHasEffect(EFFECT_TYPE_DOMINATED, oSelf) ||
        GetHasEffect(EFFECT_TYPE_PETRIFY, oSelf) || GetHasEffect(EFFECT_TYPE_PARALYZE, oSelf)   ||
        GetHasEffect(EFFECT_TYPE_STUNNED, oSelf) || GetHasEffect(EFFECT_TYPE_FRIGHTENED, oSelf)
    )
    {
        return FALSE;
    }

   return TRUE;
}
*/

void __creature_x0_ch_hen_conv()
{
  // * XP2, special handling code for interjections
  // * This script only fires if someone inits with me.
  // * with that in mind, I am now clearing any interjections
  // * that the character might have on themselves.
  if (GetLocalInt(GetModule(), "X2_L_XP2") == TRUE)
  {
    SetLocalInt(OBJECT_SELF, "X2_BANTER_TRY", 0);
    SetHasInterjection(GetMaster(OBJECT_SELF), FALSE);
    SetLocalInt(OBJECT_SELF, "X0_L_BUSY_SPEAKING_ONE_LINER", 0);
    SetOneLiner(FALSE, 0);
  }
    
    object oShouter = GetLastSpeaker();
    if (GetTag(OBJECT_SELF) == "x0_hen_dee")
    {
        string sCall = GetCampaignString("Deekin", "q6_Deekin_Call"+ GetName(oShouter), oShouter);

        if (sCall == "")
        {
            SetCustomToken(1001, GetStringByStrRef(40570));
        }
        else SetCustomToken(1001, sCall);
    }

//    int i = GetLocalInt(OBJECT_SELF, sAssociateMasterConditionVarname);
//    SendMessageToPC(GetFirstPC(), IntToHexString(i));
    if (GetIsHenchmanDying() == TRUE)
    {
        return;
    }

    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();

    object oIntruder;

    if (nMatch == -1)
    {
        // * September 2 2003
        // * Added the GetIsCommandable check back in so that
        // * Henchman cannot be interrupted when they are walking away
        if (GetCommandable(OBJECT_SELF) == TRUE && AbleToTalk(OBJECT_SELF)
           && (GetCurrentAction() != ACTION_OPENLOCK))
        {   //SetCommandable(TRUE);
            ClearActions(CLEAR_X0_CH_HEN_CONV_26);
            

            string sDialogFileToUse = GetDialogFileToUse(GetLastSpeaker());

            
            BeginConversation(sDialogFileToUse);
        }
    }
    else
    {
        // listening pattern matched
        if (GetIsObjectValid(oMaster))
        {
            // we have a master, only listen to them
            // * Nov 2003 - Added an AbleToTalk, so that henchmen
            // * do not respond to orders when 'frozen'
            if (GetIsObjectValid(oShouter) && oMaster == oShouter && AbleToTalk(OBJECT_SELF)) {
                SetCommandable(TRUE);
                bkRespondToHenchmenShout(oShouter, nMatch, oIntruder);
            }
        }

        // we don't have a master, behave in default way
        else if (GetIsObjectValid(oShouter)
                 && !GetIsPC(oShouter)
                 && GetIsFriend(oShouter)) {

             object oIntruder = OBJECT_INVALID;

             // Determine the intruder if any
             if(nMatch == 4) {
                 oIntruder = GetLocalObject(oShouter, "NW_BLOCKER_INTRUDER");
             }
             else if (nMatch == 5) {
                 oIntruder = GetLastHostileActor(oShouter);
                 if(!GetIsObjectValid(oIntruder)) {
                     oIntruder = GetAttemptedAttackTarget();
                     if(!GetIsObjectValid(oIntruder)) {
                         oIntruder = GetAttemptedSpellTarget();
                     }
                 }
             }

             // Actually respond to the shout
             RespondToShout(oShouter, nMatch, oIntruder);
         }
    }


    // Signal user-defined event
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT)) {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}

void __creature_nw_ch_fm4()
//::///////////////////////////////////////////////
//:: <title>
//::
//:: <name>.nss
//::
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: <description>
//:://////////////////////////////////////////////
//::
//:: Created By: 
//:: Modified by: 
//:://////////////////////////////////////////////
{
    __creature_nw_ch_ac4();
    //ExecuteScript("NW_CH_AC4", OBJECT_SELF);
}

void __creature_x0_cheatlisten()
// * LIstens to various cheat commands
{      // SpawnScriptDebugger();
    int nListen = GetListenPatternNumber();
    object oPC = GetLastSpeaker();

    SendMessageToAllDMs(GetName(oPC) + " used cheater NPC");
    WriteTimestampedLogEntry (GetName(oPC) + " " + GetPCPublicCDKey(oPC) + " used cheater NPC");

    // * level up command issued
    if (nListen >= 1001 && nListen <= 1020)
    {
        int i = 1;
        int nAddLevels = nListen - 1000;
        int nHD = GetHitDice(oPC);


        int nRequired = (( (nHD + nAddLevels) * ( (nHD + nAddLevels) - 1)) / 2) * 1000;
        int nGive =           nRequired - GetXP(oPC);
        SpeakString(IntToString(nRequired) + " / "  + IntToString(nGive));
        GiveXPToCreature(oPC, nGive);

        for (i=1; i<=nAddLevels; i++)
        {
            LevelUpHenchman(oPC,CLASS_TYPE_INVALID, TRUE);
        }
    }
    switch (nListen)
    {
        case 1021:
        {
            SetPlotFlag(oPC, TRUE);
            CreateItemOnObject("x0_cheatstick", oPC);
            break;
        }
        case 1022: SpeakString("god - plot and gives you the cheat stick. "
           + " Any number from 1 to 20 - levels you up to this level. "
           + " w3: +3 weapon selection "
           + " other scripts (x0_dm_spyspell) will reveal all spells on all npcs in level "
           + " spells: shows all spells on all creatures in area (slow "
           + " stats:  shows ability scores for nearest creature "
           + " commandable: shows commandable state for all creatures in area "
           + " skills: show skill ranks for all creatures in area "
           + " identify: identifies all items in backpack "
           + " skillful: Applies EffectSkillIncrease for all skills "

           ); break;
        case 1023:
        {
            CreateItemOnObject("nw_wswmls012", oPC);
            CreateItemOnObject("nw_wswmgs012", oPC);
            CreateItemOnObject("nw_wswmka011", oPC);
            CreateItemOnObject("nw_wbwmln009", oPC);
            CreateItemOnObject("nw_wbwmxh009", oPC);
            CreateItemOnObject("nw_wdbmqs009", oPC);
            CreateItemOnObject("nw_wblmml012", oPC);

            CreateItemOnObject("nw_wammar011", oPC, 99);
            CreateItemOnObject("nw_wammbo010", oPC, 99);
            CreateItemOnObject("nw_waxmbt011", oPC);
            CreateItemOnObject("nw_wspmka009", oPC);
            break;
        }
        case 1024:
        {
        ExecuteScript("x0_dm_spyspells", OBJECT_SELF);
        break;
        }
        case 1025:
        {
        ExecuteScript("x0_dm_spystats", OBJECT_SELF);
        break;
        }
        case 1026:
        {
        ExecuteScript("x0_dm_spycomm", OBJECT_SELF);
        break;
        }
        case 1027:
        {
        ExecuteScript("x0_dm_spyskill", OBJECT_SELF);
        break;
        }
        case 1028:
        {
            object oItem = GetFirstItemInInventory(oPC);
            while(GetIsObjectValid(oItem))
            {
                if(!GetIdentified(oItem))
                {
                    SetIdentified(oItem, TRUE);
                    SendMessageToPC(oPC, "Identified: " + GetName(oItem));
                }
                oItem = GetNextItemInInventory(oPC);
            }
            break;
        }
        case 1029:
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectSkillIncrease(SKILL_ALL_SKILLS, 20), oPC);
            break;
        }
        case 1030:
        {
            CreateItemOnObject("nw_wmgmrd002", oPC);
            break;
        }
    }
}

// -----------------------------------------------------------------------------
//                              Disturbed
// -----------------------------------------------------------------------------

void __creature_nw_ch_ac8()
//::///////////////////////////////////////////////
//:: Henchmen: On Disturbed
//:: NW_C2_AC8
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determine Combat Round on disturbed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//::///////////////////////////////////////////

// * Make me hostile the faction of my last attacker (TEMP)
//  AdjustReputation(OBJECT_SELF,GetFaction(GetLastAttacker()),-100);
// * Determined Combat Round
{
    object oTarget = GetLastDisturbed();

    if(!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
    {
        if(GetIsObjectValid(oTarget))
        {
            HenchmenCombatRound(oTarget);
        }
        else
        {
        }
    }
    if(GetSpawnInCondition(NW_FLAG_DISTURBED_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1008));
    }
}

void __creature_nw_c2_default8()
//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT8
/*
  Default OnDisturbed event handler for NPCs.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
{
    object oTarget = GetLastDisturbed();

    // If we've been disturbed and are not already fighting,
    // attack our disturber.
    if (GetIsObjectValid(oTarget) && !GetIsFighting(OBJECT_SELF)) {
        DetermineCombatRound(oTarget);
    }

    // Send the disturbed flag if appropriate.
    if(GetSpawnInCondition(NW_FLAG_DISTURBED_EVENT)) {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DISTURBED));
    }
}

void __creature_x2_def_ondisturb()
//::///////////////////////////////////////////////
//:: Name x2_def_ondisturb
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default OnDisturbed script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////

{
    __creature_nw_c2_default8();
    //ExecuteScript("nw_c2_default8", OBJECT_SELF);
}

void __creature_x0_ch_hen_distrb()
//::///////////////////////////////////////////////
//:: Henchmen: On Disturbed
//:: NW_C2_AC8
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determine Combat Round on disturbed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//::///////////////////////////////////////////
{
	__creature_nw_ch_ac8();
    //ExecuteScript("nw_ch_ac8", OBJECT_SELF);
}

void __creature_nw_e0_default8()
//::///////////////////////////////////////////////
//::
//:: [ScriptName]
//::
//:: [FileName.nss]
//::
//:: Copyright (c) 2001 Bioware Corp.
//::
//::
//:://////////////////////////////////////////////
//::
//::
//:: [Description of File]
//::
//::
//::
//:://////////////////////////////////////////////
//::
//:: Created By: [Your Name]
//:: Created On: [date]
//::
//:://////////////////////////////////////////////
{
    // * THIS IS JUST TEMP TO HELP
    // * THE ANIMATORS OUT BY RUNNING THROUGH THE ANIMATIONS
  /*  if (GetLocalInt(OBJECT_SELF,"RUNONCE") == 0)
    {
    SetLocalInt(OBJECT_SELF,"RUNONCE",1);
    ExecuteScript("NW_C2_DEFAULT8",OBJECT_SELF);
    }*/

    // There's nothing here, but at least one creatures uses this, so
    //  we'll just point it here:
    __creature_nw_ch_ac8();
}

// -----------------------------------------------------------------------------
//                              End Combat Round
// -----------------------------------------------------------------------------

void __creature_nw_c2_default3()
//::///////////////////////////////////////////////
//:: Default: End of Combat Round
//:: NW_C2_DEFAULT3
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Calls the end of combat script every round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Feb 16th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
{

    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
        { // set variables on target for mounted combat
            DeleteLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL");
            DeleteLocalInt(OBJECT_SELF,"nX3_HP_BEFORE");
            DeleteLocalInt(OBJECT_SELF,"bX3_ALREADY_MOUNTED_COMBAT");
            if (GetHasFeat(FEAT_MOUNTED_COMBAT,OBJECT_SELF))
            { // check for AC increase
                int nRoll=d20()+GetSkillRank(SKILL_RIDE);
                nRoll=nRoll-10;
                if (nRoll>4)
                { // ac increase
                    nRoll=nRoll/5;
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectACIncrease(nRoll),OBJECT_SELF,8.5);
                } // ac increase
            } // check for AC increase
        } // set variables on target for mounted combat

    if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
    {
        DetermineSpecialBehavior();
    }
    else if(!GetSpawnInCondition(NW_FLAG_SET_WARNINGS))
    {
       DetermineCombatRound();
    }
    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1003));
    }
}

void __creature_nw_ch_ac3()
//::///////////////////////////////////////////////
//:: Associate: End of Combat End
//:: NW_CH_AC3
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Calls the end of combat script every round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 4th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
{
    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
        { // set variables on target for mounted combat
            DeleteLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL");
            DeleteLocalInt(OBJECT_SELF,"nX3_HP_BEFORE");
            DeleteLocalInt(OBJECT_SELF,"bX3_ALREADY_MOUNTED_COMBAT");
        } // set variables on target for mounted combat

    if(!GetSpawnInCondition(NW_FLAG_SET_WARNINGS))
    {
       HenchmenCombatRound(OBJECT_INVALID);
    }


    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1003));
    }

    // Check if concentration is required to maintain this creature
    X2DoBreakConcentrationCheck();
}

void __creature_nw_ch_fm3()
//::///////////////////////////////////////////////
//:: <title>
//::
//:: <name>.nss
//::
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: <description>
//:://////////////////////////////////////////////
//::
//:: Created By: 
//:: Modified by: 
//:://////////////////////////////////////////////
{
    __creature_nw_ch_ac3();
    //ExecuteScript("NW_CH_AC3", OBJECT_SELF);
}

void __creature_x0_ch_hen_combat()
//::///////////////////////////////////////////////
//:: Associate: End of Combat End
//:: NW_CH_AC3
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Calls the end of combat script every round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 16th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////
{
    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
        { // set variables on target for mounted combat
            DeleteLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL");
            DeleteLocalInt(OBJECT_SELF,"nX3_HP_BEFORE");
            DeleteLocalInt(OBJECT_SELF,"bX3_ALREADY_MOUNTED_COMBAT");
        } // set variables on target for mounted combat

    if(!GetSpawnInCondition(NW_FLAG_SET_WARNINGS))
    {
       HenchmenCombatRound(OBJECT_INVALID);
    }

    if(GetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1003));
    }
}

void __creature_x2_def_endcombat()
//::///////////////////////////////////////////////
//:: Name x2_def_endcombat
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default Combat Round End script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    __creature_nw_c2_default3();
    //ExecuteScript("nw_c2_default3", OBJECT_SELF);
}

// -----------------------------------------------------------------------------
//                              Blocked
// -----------------------------------------------------------------------------

void __creature_nw_c2_defaulte()
//::///////////////////////////////////////////////
//:: Default On Blocked
//:: NW_C2_DEFAULTE
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This will cause blocked creatures to open
    or smash down doors depending on int and
    str.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:://////////////////////////////////////////////
{
    object oDoor = GetBlockingDoor();
    if (GetObjectType(oDoor) == OBJECT_TYPE_CREATURE)
    {
        // * Increment number of times blocked
        /*SetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED", GetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED") + 1);
        if (GetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED") > 3)
        {
            SpeakString("Blocked by creature");
            SetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED",0);
            ClearAllActions();
            object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
            if (GetIsObjectValid(oEnemy) == TRUE)
            {
                ActionEquipMostDamagingRanged(oEnemy);
                ActionAttack(oEnemy);
            }
            return;
        }   */
        return;
    }
    if(GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 5)
    {
        if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN) && GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 7 )
        {
            DoDoorAction(oDoor, DOOR_ACTION_OPEN);
        }
        else if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH))
        {
            DoDoorAction(oDoor, DOOR_ACTION_BASH);
        }
    }
}

void __creature_nw_ch_ace()
//::///////////////////////////////////////////////
//:: On Blocked
//:: NW_CH_ACE
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This will cause blocked creatures to open
    or smash down doors depending on int and
    str.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:://////////////////////////////////////////////
{
    object oDoor = GetBlockingDoor();

    if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN) && GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 3)
    {
        DoDoorAction(oDoor, DOOR_ACTION_OPEN);
    }
    else if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH) && GetAbilityScore(OBJECT_SELF, ABILITY_STRENGTH) >= 16)
    {
        DoDoorAction(oDoor, DOOR_ACTION_BASH);
    }
}

void __creature_x0_ch_hen_block()
//:://////////////////////////////////////////////////
//:: X0_CH_HEN_BLOCK
/*
  OnBlocked handler for henchmen/associates.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/06/2003
//:://////////////////////////////////////////////////
{
    object oDoor = GetBlockingDoor();
    int nInt = GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE);
    int nStr = GetAbilityScore(OBJECT_SELF, ABILITY_STRENGTH);

    if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN) &&  nInt >= 3) {
        DoDoorAction(oDoor, DOOR_ACTION_OPEN);
    }

    else if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH) && nStr >= 16) {
        DoDoorAction(oDoor, DOOR_ACTION_BASH);
    }
}

void __creature_x2_def_onblocked()
//::///////////////////////////////////////////////
//:: Name x2_def_onblocked
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default OnBlocked script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    __creature_nw_c2_defaulte();
    //ExecuteScript("nw_c2_defaulte", OBJECT_SELF);
}

// -----------------------------------------------------------------------------
//                              Perception
// -----------------------------------------------------------------------------

void __creature_nw_c2_default2()
//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT2
/*
  Default OnPerception event handler for NPCs.

  Handles behavior when perceiving a creature for the
  first time.
 */
//:://////////////////////////////////////////////////
{
// * if not runnning normal or better Ai then exit for performance reasons
    // * if not runnning normal or better Ai then exit for performance reasons
    if (GetAILevel() == AI_LEVEL_VERY_LOW) return;

    object oPercep = GetLastPerceived();
    int bSeen = GetLastPerceptionSeen();
    int bHeard = GetLastPerceptionHeard();
    if (bHeard == FALSE)
    {
        // Has someone vanished in front of me?
        bHeard = GetLastPerceptionVanished();
    }

    // This will cause the NPC to speak their one-liner
    // conversation on perception even if they are already
    // in combat.
    if(GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION)
       && GetIsPC(oPercep)
       && bSeen)
    {
        SpeakOneLinerConversation();
    }

    // March 5 2003 Brent
    // Had to add this section back in, since  modifications were not taking this specific
    // example into account -- it made invisibility basically useless.
    //If the last perception event was hearing based or if someone vanished then go to search mode
    if ((GetLastPerceptionVanished()) && GetIsEnemy(GetLastPerceived()))
    {
        object oGone = GetLastPerceived();
        if((GetAttemptedAttackTarget() == GetLastPerceived() ||
           GetAttemptedSpellTarget() == GetLastPerceived() ||
           GetAttackTarget() == GetLastPerceived()) && GetArea(GetLastPerceived()) != GetArea(OBJECT_SELF))
        {
           ClearAllActions();
           DetermineCombatRound();
        }
    }

    // This section has been heavily revised while keeping the
    // pre-existing behavior:
    // - If we're in combat, keep fighting.
    // - If not and we've perceived an enemy, start to fight.
    //   Even if the perception event was a 'vanish', that's
    //   still what we do anyway, since that will keep us
    //   fighting any visible targets.
    // - If we're not in combat and haven't perceived an enemy,
    //   see if the perception target is a PC and if we should
    //   speak our attention-getting one-liner.
    if (GetIsInCombat(OBJECT_SELF))
    {
        // don't do anything else, we're busy
        //MyPrintString("GetIsFighting: TRUE");

    }
    // * BK FEB 2003 Only fight if you can see them. DO NOT RELY ON HEARING FOR ENEMY DETECTION
    else if (GetIsEnemy(oPercep) && bSeen)
    { // SpawnScriptDebugger();
        //MyPrintString("GetIsEnemy: TRUE");
        // We spotted an enemy and we're not already fighting
        if(!GetHasEffect(EFFECT_TYPE_SLEEP)) {
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL))
            {
                //MyPrintString("DetermineSpecialBehavior");
                DetermineSpecialBehavior();
            } else
            {
                //MyPrintString("DetermineCombatRound");
                SetFacingPoint(GetPosition(oPercep));
                SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
                DetermineCombatRound();
            }
        }
    }
    else
    {
        if (bSeen)
        {
            //MyPrintString("GetLastPerceptionSeen: TRUE");
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) {
                DetermineSpecialBehavior();
            } else if (GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION)
                       && GetIsPC(oPercep))
            {
                // The NPC will speak their one-liner conversation
                // This should probably be:
                // SpeakOneLinerConversation(oPercep);
                // instead, but leaving it as is for now.
                ActionStartConversation(OBJECT_SELF);
            }
        }
        else
        // * July 14 2003: Some minor reactions based on invisible creatures being nearby
        if (bHeard && GetIsEnemy(oPercep))
        {
           // SpeakString("vanished");
            // * don't want creatures wandering too far after noises
            if (GetDistanceToObject(oPercep) <= 7.0)
            {
//                if (GetHasSpell(SPELL_TRUE_SEEING) == TRUE)
                if (GetHasSpell(SPELL_TRUE_SEEING))
                {
                    ActionCastSpellAtObject(SPELL_TRUE_SEEING, OBJECT_SELF);
                }
                else
//                if (GetHasSpell(SPELL_SEE_INVISIBILITY) == TRUE)
                if (GetHasSpell(SPELL_SEE_INVISIBILITY))
                {
                    ActionCastSpellAtObject(SPELL_SEE_INVISIBILITY, OBJECT_SELF);
                }
                else
//                if (GetHasSpell(SPELL_INVISIBILITY_PURGE) == TRUE)
                if (GetHasSpell(SPELL_INVISIBILITY_PURGE))
                {
                    ActionCastSpellAtObject(SPELL_INVISIBILITY_PURGE, OBJECT_SELF);
                }
                else
                {
                    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 0.5);
                    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 0.5);
                    ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD, 0.5);
                }
            }
        }

        // activate ambient animations or walk waypoints if appropriate
       if (!IsInConversation(OBJECT_SELF)) {
           if (GetIsPostOrWalking()) {
               WalkWayPoints();
           } else if (GetIsPC(oPercep) &&
               (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)
                || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)
                || GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS)
                || GetIsEncounterCreature()))
           {
                SetAnimationCondition(NW_ANIM_FLAG_IS_ACTIVE);
           }
        }
    }

    // Send the user-defined event if appropriate
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT) && GetLastPerceptionSeen())
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_PERCEIVE));
    }
}

void __creature_nw_ch_ac2()
//::///////////////////////////////////////////////
//:: Associate: On Percieve
//:: NW_CH_AC2
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
{
    //This is the equivalent of a force conversation bubble, should only be used if you want an NPC
    //to say something while he is already engaged in combat.
    if(GetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION))
    {
        ActionStartConversation(OBJECT_SELF);
    }
    
    // * July 2003
    // * If in Stealth mode, don't attack enemies. Wait for player to attack or
    // * for you to be attacked. (No point hiding anymore if you've been detected)
    if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND) && GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH)== FALSE)
    {
        //Do not bother checking the last target seen if already fighting
        if(!GetIsObjectValid(GetAttemptedAttackTarget()) &&
           !GetIsObjectValid(GetAttackTarget()) &&
           !GetIsObjectValid(GetAttemptedSpellTarget()))
        {
            //Check if the last percieved creature was actually seen
            if(GetLastPerceptionSeen())
            {
                if(GetIsEnemy(GetLastPerceived()))
                {
                    SetFacingPoint(GetPosition(GetLastPerceived()));
                    HenchmenCombatRound(OBJECT_INVALID);
                }
                //Linked up to the special conversation check to initiate a special one-off conversation
                //to get the PCs attention
                else if(GetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION) && GetIsPC(GetLastPerceived()))
                {
                    ActionStartConversation(OBJECT_SELF);
                }
            }
        }
    }
    if(GetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1002));
    }
}

void __creature_x0_ch_hen_percep()
//:://////////////////////////////////////////////////
//:: X0_CH_HEN_PERCEP
/*

  OnPerception event handler for henchmen/associates.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/05/2003
//:://////////////////////////////////////////////////
{
    // * if henchman is dying and Player disappears
    // * then force a respawn of the henchman
    if (GetIsHenchmanDying(OBJECT_SELF) == TRUE)
    {   //SpawnScriptDebugger();
        // * the henchman must be removed otherwise their corpse will follow
        // * the player
        object oOldMaster = GetMaster();
        object oPC = GetLastPerceived();
        int bVanish = GetLastPerceptionVanished();
        if (GetIsObjectValid(oPC) && bVanish == TRUE)
        {
            if (oPC == oOldMaster)
            {
                RemoveHenchman(oPC, OBJECT_SELF);
                // * only in chapter 1
                if (GetTag(GetModule()) == "x0_module1")
                {
                    SetCommandable(TRUE);
                    DoRespawn(oPC,  OBJECT_SELF); // * should teleport henchman back
                }
            }
        }
    }

    __creature_nw_ch_ac2();
	//ExecuteScript("nw_ch_ac2", OBJECT_SELF);
}

void __creature_x2_def_percept()
//::///////////////////////////////////////////////
//:: Name x2_def_percept
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On Perception script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    __creature_nw_c2_default2();
    //ExecuteScript("nw_c2_default2", OBJECT_SELF);
}

// -----------------------------------------------------------------------------
//                              Rested
// -----------------------------------------------------------------------------

void __creature_nw_c2_defaulta()
//::///////////////////////////////////////////////
//:: Default: On Rested
//:: NW_C2_DEFAULTA
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    after having just rested.
*/
//:://////////////////////////////////////////////
//:: Created By: Don Moar
//:: Created On: April 28, 2002
//:://////////////////////////////////////////////
{
    // enter desired behaviour here

    return;

}

void __creature_nw_ch_aca()
//::///////////////////////////////////////////////
//:: Name x2_def_rested
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On Rested script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    __creature_nw_c2_defaulta();
    //ExecuteScript("nw_c2_defaulta", OBJECT_SELF);
}

void __creature_x0_ch_rest()
//:://////////////////////////////////////////////////
//:: X0_CH_HEN_REST
/*
  OnRest event handler for henchmen/associates.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/06/2003
//:://////////////////////////////////////////////////
{
    // Nothing at present

    // We'll just point it at the primary
    __creature_nw_c2_defaulta();
}

void __creature_x2_def_rested()
//::///////////////////////////////////////////////
//:: Name x2_def_rested
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On Rested script
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: June 11/03
//:://////////////////////////////////////////////
{
    __creature_nw_c2_defaulta();
    //ExecuteScript("nw_c2_defaulta", OBJECT_SELF);
}

// -----------------------------------------------------------------------------
//                              Spawn
// -----------------------------------------------------------------------------

#include "x0_i0_anims"
#include "x0_i0_treasure"
#include "x2_inc_switches"
#include "nw_o2_coninclude"
#include "x2_inc_banter"
#include "x2_inc_globals"
#include "x2_inc_summscale"

void __creature_nw_c2_bat9()
//::///////////////////////////////////////////////
//:: Default: On Spawn In
//:: NW_C2_HERBIVORE
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    after having just been spawned in for Herbivores
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 21, 2001
//:://////////////////////////////////////////////
{
// OPTIONAL BEHAVIORS (Comment In or Out to Activate ) ****************************************************************************
     //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
     //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
                // This causes the creature to say a special greeting in their conversation file
                // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
                // greeting in order to designate it. As the creature is actually saying this to
                // himself, don't attach any player responses to the greeting.
     //SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);
                // This will set the listening pattern on the NPC to attack when allies call
     //SetSpawnInCondition(NW_FLAG_STEALTH);
                // If the NPC has stealth and they are a rogue go into stealth mode
     //SetSpawnInCondition(NW_FLAG_SEARCH);
                // If the NPC has Search go into Search Mode
     //SetSpawnInCondition(NW_FLAG_SET_WARNINGS);
                // This will set the NPC to give a warning to non-enemies before attacking
     //SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that these animations will play automatically for Encounter Creatures.
     //SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that NPCs using this form of ambient animations will not move to other NPCs.
    SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);

    // NOTE: ONLY ONE OF THE FOLOOWING ESCAPE COMMANDS SHOULD EVER BE ACTIVATED AT ANY ONE TIME.
    //SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);    // OPTIONAL BEHAVIOR (Flee to a way point and return a short time later.)
    //SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);     // OPTIONAL BEHAVIOR (Flee to a way point and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);   // OPTIONAL BEHAVIOR (Teleport to safety and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);  // OPTIONAL BEHAVIOR (Teleport to safety and return a short time later.)

// SPECIAL BEHAVIOR SECTION
/*
    The following section outlines the various special behaviors that can be placed on a creature.  To activate one of the special
    behaviors:
        1.  Comment in  SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
        2.  Comment in one other special behavior setting (ONLY ONE).
*/
    SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
    //SetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE); //Creature will only attack those that close within 5m and are not friends,
                                                   //Rangers or Druids.
    SetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE);//Creature will flee those that close within 7m if they are not friends,
                                                   //Rangers or Druids.

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1001
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007

// DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) *****************************************************************************************
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.
    WalkWayPoints();           // Optional Parameter: void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
                               // 1. Looks to see if any Way Points in the module have the tag "WP_" + NPC TAG + "_0X", if so walk them
                               // 2. If the tag of the Way Point is "POST_" + NPC TAG the creature will return this way point after
                               //    combat.
}

void __creature_nw_c2_default9()
//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT9
/*
 * Default OnSpawn handler with XP1 revisions.
 * This corresponds to and produces the same results
 * as the default OnSpawn handler in the OC.
 *
 * This can be used to customize creature behavior in three main ways:
 *
 * - Uncomment the existing lines of code to activate certain
 *   common desired behaviors from the moment when the creature
 *   spawns in.
 *
 * - Uncomment the user-defined event signals to cause the
 *   creature to fire events that you can then handle with
 *   a custom OnUserDefined event handler script.
 *
 * - Add new code _at the end_ to alter the initial
 *   behavior in a more customized way.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/11/2002
//:://////////////////////////////////////////////////
//:: Updated 2003-08-20 Georg Zoeller: Added check for variables to active spawn in conditions without changing the spawnscript
{
    // ***** Spawn-In Conditions ***** //

    // * REMOVE COMMENTS (// ) before the "Set..." functions to activate
    // * them. Do NOT touch lines commented out with // *, those are
    // * real comments for information.

    // * This causes the creature to say a one-line greeting in their
    // * conversation file upon perceiving the player. Put [NW_D2_GenCheck]
    // * in the "Text Seen When" field of the greeting in the conversation
    // * file. Don't attach any player responses.
    // *
    // SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);

    // * Same as above, but for hostile creatures to make them say
    // * a line before attacking.
    // *
    // SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);

    // * This NPC will attack when its allies call for help
    // *
    // SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);

    // * If the NPC has the Hide skill they will go into stealth mode
    // * while doing WalkWayPoints().
    // *
    // SetSpawnInCondition(NW_FLAG_STEALTH);

    //--------------------------------------------------------------------------
    // Enable stealth mode by setting a variable on the creature
    // Great for ambushes
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_STEALTH) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_STEALTH);
    }
    // * Same, but for Search mode
    // *
    // SetSpawnInCondition(NW_FLAG_SEARCH);

    //--------------------------------------------------------------------------
    // Make creature enter search mode after spawning by setting a variable
    // Great for guards, etc
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_SEARCH) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_SEARCH);
    }
    // * This will set the NPC to give a warning to non-enemies
    // * before attacking.
    // * NN -- no clue what this really does yet
    // *
    // SetSpawnInCondition(NW_FLAG_SET_WARNINGS);

    // * Separate the NPC's waypoints into day & night.
    // * See comment on WalkWayPoints() for use.
    // *
    // SetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING);

    // * If this is set, the NPC will appear using the "EffectAppear"
    // * animation instead of fading in, *IF* SetListeningPatterns()
    // * is called below.
    // *
    //SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);

    // * This will cause an NPC to use common animations it possesses,
    // * and use social ones to any other nearby friendly NPCs.
    // *
    // SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);

    //--------------------------------------------------------------------------
    // Enable immobile ambient animations by setting a variable
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_AMBIENT_IMMOBILE) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
    }
    // * Same as above, except NPC will wander randomly around the
    // * area.
    // *
    // SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);


    //--------------------------------------------------------------------------
    // Enable mobile ambient animations by setting a variable
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_USE_SPAWN_AMBIENT) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
    }
    // **** Animation Conditions **** //
    // * These are extra conditions you can put on creatures with ambient
    // * animations.

    // * Civilized creatures interact with placeables in
    // * their area that have the tag "NW_INTERACTIVE"
    // * and "talk" to each other.
    // *
    // * Humanoid races are civilized by default, so only
    // * set this flag for monster races that you want to
    // * behave the same way.
    // SetAnimationCondition(NW_ANIM_FLAG_IS_CIVILIZED);

    // * If this flag is set, this creature will constantly
    // * be acting. Otherwise, creatures will only start
    // * performing their ambient animations when they
    // * first perceive a player, and they will stop when
    // * the player moves away.
    // SetAnimationCondition(NW_ANIM_FLAG_CONSTANT);

    // * Civilized creatures with this flag set will
    // * randomly use a few voicechats. It's a good
    // * idea to avoid putting this on multiple
    // * creatures using the same voiceset.
    // SetAnimationCondition(NW_ANIM_FLAG_CHATTER);

    // * Creatures with _immobile_ ambient animations
    // * can have this flag set to make them mobile in a
    // * close range. They will never leave their immediate
    // * area, but will move around in it, frequently
    // * returning to their starting point.
    // *
    // * Note that creatures spawned inside interior areas
    // * that contain a waypoint with one of the tags
    // * "NW_HOME", "NW_TAVERN", "NW_SHOP" will automatically
    // * have this condition set.
    // SetAnimationCondition(NW_ANIM_FLAG_IS_MOBILE_CLOSE_RANGE);


    // **** Special Combat Tactics *****//
    // * These are special flags that can be set on creatures to
    // * make them follow certain specialized combat tactics.
    // * NOTE: ONLY ONE OF THESE SHOULD BE SET ON A SINGLE CREATURE.

    // * Ranged attacker
    // * Will attempt to stay at ranged distance from their
    // * target.
    // SetCombatCondition(X0_COMBAT_FLAG_RANGED);

    // * Defensive attacker
    // * Will use defensive combat feats and parry
    // SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE);

    // * Ambusher
    // * Will go stealthy/invisible and attack, then
    // * run away and try to go stealthy again before
    // * attacking anew.
    // SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER);

    // * Cowardly
    // * Cowardly creatures will attempt to flee
    // * attackers.
    // SetCombatCondition(X0_COMBAT_FLAG_COWARDLY);


    // **** Escape Commands ***** //
    // * NOTE: ONLY ONE OF THE FOLLOWING SHOULD EVER BE SET AT ONE TIME.
    // * NOTE2: Not clear that these actually work. -- NN

    // * Flee to a way point and return a short time later.
    // *
    // SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);

    // * Flee to a way point and do not return.
    // *
    // SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);

    // * Teleport to safety and do not return.
    // *
    // SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);

    // * Teleport to safety and return a short time later.
    // *
    // SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);



    // ***** CUSTOM USER DEFINED EVENTS ***** /


    /*
      If you uncomment any of these conditions, the creature will fire
      a specific user-defined event number on each event. That will then
      allow you to write custom code in the "OnUserDefinedEvent" handler
      script to go on top of the default NPC behaviors for that event.

      Example: I want to add some custom behavior to my NPC when they
      are damaged. I uncomment the "NW_FLAG_DAMAGED_EVENT", then create
      a new user-defined script that has something like this in it:

      if (GetUserDefinedEventNumber() == 1006) {
          // Custom code for my NPC to execute when it's damaged
      }

      These user-defined events are in the range 1001-1007.
    */

    // * Fire User Defined Event 1001 in the OnHeartbeat
    // *
    // SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);

    // * Fire User Defined Event 1002
    // *
    // SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);

    // * Fire User Defined Event 1005
    // *
    // SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);

    // * Fire User Defined Event 1006
    // *
    // SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);

    // * Fire User Defined Event 1008
    // *
    // SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);

    // * Fire User Defined Event 1003
    // *
    // SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT);

    // * Fire User Defined Event 1004
    // *
    // SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);



    // ***** DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) ***** //

    // * Goes through and sets up which shouts the NPC will listen to.
    // *
    SetListeningPatterns();

    // * Walk among a set of waypoints.
    // * 1. Find waypoints with the tag "WP_" + NPC TAG + "_##" and walk
    // *    among them in order.
    // * 2. If the tag of the Way Point is "POST_" + NPC TAG, stay there
    // *    and return to it after combat.
    //
    // * Optional Parameters:
    // * void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
    //
    // * If "NW_FLAG_DAY_NIGHT_POSTING" is set above, you can also
    // * create waypoints with the tags "WN_" + NPC Tag + "_##"
    // * and those will be walked at night. (The standard waypoints
    // * will be walked during the day.)
    // * The night "posting" waypoint tag is simply "NIGHT_" + NPC tag.
    WalkWayPoints();

    //* Create a small amount of treasure on the creature
    if ((GetLocalInt(GetModule(), "X2_L_NOTREASURE") == FALSE)  &&
        (GetLocalInt(OBJECT_SELF, "X2_L_NOTREASURE") == FALSE)   )
    {
        CTG_GenerateNPCTreasure(TREASURE_TYPE_MONSTER, OBJECT_SELF);
    }


    // ***** ADD ANY SPECIAL ON-SPAWN CODE HERE ***** //

    // * If Incorporeal, apply changes
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL) == TRUE)
    {
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        eConceal = ExtraordinaryEffect(eConceal);
        effect eGhost = EffectCutsceneGhost();
        eGhost = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, OBJECT_SELF);

    }

    // * Give the create a random name.
    // * If you create a script named x3_name_gen in your module, you can
    // * set the value of the variable X3_S_RANDOM_NAME on OBJECT_SELF inside
    // * the script to override the creature's default name.
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_RANDOMIZE_NAME) == TRUE)
    {
        ExecuteScript("x3_name_gen",OBJECT_SELF);
        string sName = GetLocalString(OBJECT_SELF,"X3_S_RANDOM_NAME");
        if ( sName == "" )
        {
            sName = RandomName();
        }
        SetName(OBJECT_SELF,sName);
    }
}

void __creature_nw_c2_dimdoors()
//::///////////////////////////////////////////////
//:: NW_C2_DIMDOORS.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   OnSpawnIn, sets up creature to teleport
   during combat (requires NW_C2_DIMDOOR.nss on the
   user defined event for the creature)
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
{
// OPTIONAL BEHAVIORS (Comment In or Out to Activate ) ****************************************************************************
     //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
     //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
                // This causes the creature to say a special greeting in their conversation file
                // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
                // greeting in order to designate it. As the creature is actually saying this to
                // himself, don't attach any player responses to the greeting.
     //SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);
                // This will set the listening pattern on the NPC to attack when allies call
     //SetSpawnInCondition(NW_FLAG_STEALTH);
                // If the NPC has stealth and they are a rogue go into stealth mode
     //SetSpawnInCondition(NW_FLAG_SEARCH);
                // If the NPC has Search go into Search Mode
     //SetSpawnInCondition(NW_FLAG_SET_WARNINGS);
                // This will set the NPC to give a warning to non-enemies before attacking
     SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that these animations will play automatically for Encounter Creatures.
    // NOTE: ONLY ONE OF THE FOLOOWING ESCAPE COMMANDS SHOULD EVER BE ACTIVATED AT ANY ONE TIME.
    //SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);    // OPTIONAL BEHAVIOR (Flee to a way point and return a short time later.)
    //SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);     // OPTIONAL BEHAVIOR (Flee to a way point and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);   // OPTIONAL BEHAVIOR (Teleport to safety and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);  // OPTIONAL BEHAVIOR (Teleport to safety and return a short time later.)

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007

// DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) *****************************************************************************************
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.
    WalkWayPoints();           // Optional Parameter: void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
                               // 1. Looks to see if any Way Points in the module have the tag "WP_" + NPC TAG + "_0X", if so walk them
                               // 2. If the tag of the Way Point is "POST_" + NPC TAG the creature will return this way point after
                               //    combat.
}

void __creature_nw_c2_dropin9()
//::///////////////////////////////////////////////
//:: Default: On Spawn In
//:: NW_C2_DEFAULT9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    after having just been spawned in
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 25, 2001
//:://////////////////////////////////////////////
{
// OPTIONAL BEHAVIORS (Comment In or Out to Activate ) ****************************************************************************
     //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
     //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
                // This causes the creature to say a special greeting in their conversation file
                // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
                // greeting in order to designate it. As the creature is actually saying this to
                // himself, don't attach any player responses to the greeting.
     //SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);
                // This will set the listening pattern on the NPC to attack when allies call
     //SetSpawnInCondition(NW_FLAG_STEALTH);
                // If the NPC has stealth and they are a rogue go into stealth mode
     //SetSpawnInCondition(NW_FLAG_SEARCH);
                // If the NPC has Search go into Search Mode
     //SetSpawnInCondition(NW_FLAG_SET_WARNINGS);
                // This will set the NPC to give a warning to non-enemies before attacking
     //SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that these animations will play automatically for Encounter Creatures.
     //SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that NPCs using this form of ambient animations will not move to other NPCs.
    SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);

    // NOTE: ONLY ONE OF THE FOLOOWING ESCAPE COMMANDS SHOULD EVER BE ACTIVATED AT ANY ONE TIME.
    //SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);    // OPTIONAL BEHAVIOR (Flee to a way point and return a short time later.)
    //SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);     // OPTIONAL BEHAVIOR (Flee to a way point and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);   // OPTIONAL BEHAVIOR (Teleport to safety and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);  // OPTIONAL BEHAVIOR (Teleport to safety and return a short time later.)

// SPECIAL BEHAVIOR SECTION
/*
    The following section outlines the various special behaviors that can be placed on a creature.  To activate one of the special
    behaviors:
        1.  Comment in  SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
        2.  Comment in one other special behavior setting (ONLY ONE).
*/
    //SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
    //SetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE); //Creature will only attack those that close within 5m and are not friends,
                                                   //Rangers or Druids.
    //SetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE);//Creature will flee those that close within 7m if they are not friends,
                                                   //Rangers or Druids.

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1001
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007

// DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) *****************************************************************************************
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.
    WalkWayPoints();           // Optional Parameter: void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
                               // 1. Looks to see if any Way Points in the module have the tag "WP_" + NPC TAG + "_0X", if so walk them
                               // 2. If the tag of the Way Point is "POST_" + NPC TAG the creature will return this way point after
                               //    combat.

    GenerateNPCTreasure(); //* Use this to create a small amount of treasure on the creature
}

void __creature_nw_c2_gated()
//::///////////////////////////////////////////////
//:: Gated Demon: On Heartbeat
//:: NW_C2_GATED.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script will have people perform default
    animations. For the Gated Balor this script
    will check if the master is protected from
    by Protection from Evil.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:://////////////////////////////////////////////
{
    object oMaster = GetMaster(OBJECT_SELF);
    if(!GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, oMaster) &&
       !GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL, oMaster) &&
       !GetHasSpellEffect(SPELL_HOLY_AURA, oMaster))
    {
        RemoveSummonedAssociate(oMaster, OBJECT_SELF);
        SetIsTemporaryEnemy(oMaster);
        DetermineCombatRound(oMaster);
    }
    else
    {
        SetIsTemporaryFriend(oMaster);
        //Do not bother checking the last target seen if already fighting
        if(
           !GetIsObjectValid(GetAttackTarget()) &&
           !GetIsObjectValid(GetAttemptedSpellTarget()) &&
           !GetIsObjectValid(GetAttemptedAttackTarget()) &&
           !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN))
          )
        {
            if(GetAssociateState(NW_ASC_HAVE_MASTER))
            {
                if(!GetIsInCombat() || !GetAssociateState(NW_ASC_IS_BUSY))
                {
                    if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
                    {
                        if(GetDistanceToObject(GetMaster()) > GetFollowDistance())
                        {
                            //SpeakString("DEBUG: I am moving to master");
                            ClearAllActions();
                            ActionForceMoveToObject(GetMaster(), TRUE, GetFollowDistance());
                        }
                    }
                }
            }
        }
        if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
        {
            SignalEvent(OBJECT_SELF, EventUserDefined(1001));
        }
    }
}

void __creature_nw_c2_gatedbad()
//::///////////////////////////////////////////////
//:: Custom On Spawn In
//:: nw_c2_gatedbad
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Balor will destroy self after 1 minute
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
{
// OPTIONAL BEHAVIORS (Comment In or Out to Activate ) ****************************************************************************
     //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
     //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
                // This causes the creature to say a special greeting in their conversation file
                // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
                // greeting in order to designate it. As the creature is actually saying this to
                // himself, don't attach any player responses to the greeting.

     //SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);
                // This will set the listening pattern on the NPC to attack when allies call
     //SetSpawnInCondition(NW_FLAG_STEALTH);
                // If the NPC has stealth and they are a rogue go into stealth mode
     //SetSpawnInCondition(NW_FLAG_SEARCH);
                // If the NPC has Search go into Search Mode
     //SetSpawnInCondition(NW_FLAG_SET_WARNINGS);
                // This will set the NPC to give a warning to non-enemies before attacking

     //SetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING);
     //SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);
     //SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
     //SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that these animations will play automatically for Encounter Creatures.

    // NOTE: ONLY ONE OF THE FOLOOWING ESCAPE COMMANDS SHOULD EVER BE ACTIVATED AT ANY ONE TIME.
    //SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);    // OPTIONAL BEHAVIOR (Flee to a way point and return a short time later.)
    //SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);     // OPTIONAL BEHAVIOR (Flee to a way point and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);   // OPTIONAL BEHAVIOR (Teleport to safety and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);  // OPTIONAL BEHAVIOR (Teleport to safety and return a short time later.)

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1001
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007

// DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) *****************************************************************************************
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.
    WalkWayPoints();           // Optional Parameter: void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
                               // 1. Looks to see if any Way Points in the module have the tag "WP_" + NPC TAG + "_0X", if so walk them
                               // 2. If the tag of the Way Point is "POST_" + NPC TAG the creature will return this way point after
                               //    combat.
    GenerateNPCTreasure();     //* Use this to create a small amount of treasure on the creature

    DestroyObject(OBJECT_SELF, 60.0);
    effect e = EffectVisualEffect(VFX_IMP_UNSUMMON);
    location lLoc = GetLocation(OBJECT_SELF);
    DelayCommand(59.5, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, e, lLoc));
}

void __creature_nw_c2_herbivore()
//::///////////////////////////////////////////////
//:: Default: On Spawn In
//:: NW_C2_HERBIVORE
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    after having just been spawned in for Herbivores

    2007-12-31: Deva Winblood
    Modified to look for X3_HORSE_OWNER_TAG and if
    it is defined look for an NPC with that tag
    nearby or in the module (checks near first).
    It will make that NPC this horse's master.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 21, 2001
//:://////////////////////////////////////////////
{
    string sTag;
    object oNPC;
// OPTIONAL BEHAVIORS (Comment In or Out to Activate ) ****************************************************************************
     //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
     //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
                // This causes the creature to say a special greeting in their conversation file
                // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
                // greeting in order to designate it. As the creature is actually saying this to
                // himself, don't attach any player responses to the greeting.
     //SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);
                // This will set the listening pattern on the NPC to attack when allies call
     //SetSpawnInCondition(NW_FLAG_STEALTH);
                // If the NPC has stealth and they are a rogue go into stealth mode
     //SetSpawnInCondition(NW_FLAG_SEARCH);
                // If the NPC has Search go into Search Mode
     //SetSpawnInCondition(NW_FLAG_SET_WARNINGS);
                // This will set the NPC to give a warning to non-enemies before attacking
     //SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that these animations will play automatically for Encounter Creatures.
     //SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that NPCs using this form of ambient animations will not move to other NPCs.

    // NOTE: ONLY ONE OF THE FOLOOWING ESCAPE COMMANDS SHOULD EVER BE ACTIVATED AT ANY ONE TIME.
    //SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);    // OPTIONAL BEHAVIOR (Flee to a way point and return a short time later.)
    //SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);     // OPTIONAL BEHAVIOR (Flee to a way point and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);   // OPTIONAL BEHAVIOR (Teleport to safety and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);  // OPTIONAL BEHAVIOR (Teleport to safety and return a short time later.)

// SPECIAL BEHAVIOR SECTION
/*
    The following section outlines the various special behaviors that can be placed on a creature.  To activate one of the special
    behaviors:
        1.  Comment in  SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
        2.  Comment in one other special behavior setting (ONLY ONE).
*/
    SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
    //SetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE); //Creature will only attack those that close within 5m and are not friends,
                                                   //Rangers or Druids.
    SetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE);//Creature will flee those that close within 7m if they are not friends,
                                                   //Rangers or Druids.

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1001
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007
    sTag=GetLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
    if (GetStringLength(sTag)>0)
    { // look for master
        oNPC=GetNearestObjectByTag(sTag);
        if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
        { // master found
            AddHenchman(oNPC);
        } // master found
        else
        { // look in module
            oNPC=GetObjectByTag(sTag);
            if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
            { // master found
                AddHenchman(oNPC);
            } // master found
            else
            { // master does not exist - remove X3_HORSE_OWNER_TAG
                DeleteLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
            } // master does not exist - remove X3_HORSE_OWNER_TAG
        } // look in module
    } // look for master
// DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) *****************************************************************************************
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.
    WalkWayPoints();           // Optional Parameter: void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
                               // 1. Looks to see if any Way Points in the module have the tag "WP_" + NPC TAG + "_0X", if so walk them
                               // 2. If the tag of the Way Point is "POST_" + NPC TAG the creature will return this way point after
                               //    combat.
    GenerateNPCTreasure();     //* Use this to create a small amount of treasure on the creature
}

void __creature_nw_c2_lycan_9()
//::///////////////////////////////////////////////
//:: Lycanthrope Spawn In
//:: NW_C2_LYCAN_9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
{
// OPTIONAL BEHAVIORS (Comment In or Out to Activate ) ****************************************************************************
     //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
     //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
                // This causes the creature to say a special greeting in their conversation file
                // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
                // greeting in order to designate it. As the creature is actually saying this to
                // himself, don't attach any player responses to the greeting.
     //SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);
                // This will set the listening pattern on the NPC to attack when allies call
     //SetSpawnInCondition(NW_FLAG_STEALTH);
                // If the NPC has stealth and they are a rogue go into stealth mode
     //SetSpawnInCondition(NW_FLAG_SEARCH);
                // If the NPC has Search go into Search Mode
     //SetSpawnInCondition(NW_FLAG_SET_WARNINGS);
                // This will set the NPC to give a warning to non-enemies before attacking
     //SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
     //SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that these animations will play automatically for Encounter Creatures.
    // NOTE: ONLY ONE OF THE FOLOOWING ESCAPE COMMANDS SHOULD EVER BE ACTIVATED AT ANY ONE TIME.
    //SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);    // OPTIONAL BEHAVIOR (Flee to a way point and return a short time later.)
    //SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);     // OPTIONAL BEHAVIOR (Flee to a way point and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);   // OPTIONAL BEHAVIOR (Teleport to safety and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);  // OPTIONAL BEHAVIOR (Teleport to safety and return a short time later.)

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1001
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007

// DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) *****************************************************************************************
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.
    WalkWayPoints();           // Optional Parameter: void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
                               // 1. Looks to see if any Way Points in the module have the tag "WP_" + NPC TAG + "_0X", if so walk them
                               // 2. If the tag of the Way Point is "POST_" + NPC TAG the creature will return this way point after
                               //    combat.
}

void __creature_nw_c2_omnivore()
//::///////////////////////////////////////////////
//:: Default: On Spawn In
//:: NW_C2_OMNIVORE
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    after having just been spawned in for Omniivores
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 21, 2001
//:://////////////////////////////////////////////
{
// OPTIONAL BEHAVIORS (Comment In or Out to Activate ) ****************************************************************************
     //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
     //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
                // This causes the creature to say a special greeting in their conversation file
                // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
                // greeting in order to designate it. As the creature is actually saying this to
                // himself, don't attach any player responses to the greeting.
     //SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);
                // This will set the listening pattern on the NPC to attack when allies call
     //SetSpawnInCondition(NW_FLAG_STEALTH);
                // If the NPC has stealth and they are a rogue go into stealth mode
     //SetSpawnInCondition(NW_FLAG_SEARCH);
                // If the NPC has Search go into Search Mode
     //SetSpawnInCondition(NW_FLAG_SET_WARNINGS);
                // This will set the NPC to give a warning to non-enemies before attacking
     //SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that these animations will play automatically for Encounter Creatures.
     //SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
                //This will play Ambient Animations until the NPC sees an enemy or is cleared.
                //NOTE that NPCs using this form of ambient animations will not move to other NPCs.
     
    // NOTE: ONLY ONE OF THE FOLOOWING ESCAPE COMMANDS SHOULD EVER BE ACTIVATED AT ANY ONE TIME.
    //SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);    // OPTIONAL BEHAVIOR (Flee to a way point and return a short time later.)
    //SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);     // OPTIONAL BEHAVIOR (Flee to a way point and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);   // OPTIONAL BEHAVIOR (Teleport to safety and do not return.)
    //SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);  // OPTIONAL BEHAVIOR (Teleport to safety and return a short time later.)

// SPECIAL BEHAVIOR SECTION
/*
    The following section outlines the various special behaviors that can be placed on a creature.  To activate one of the special
    behaviors:
        1.  Comment in  SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
        2.  Comment in one other special behavior setting (ONLY ONE).
*/
    SetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL);
    SetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE); //Creature will only attack those that close within 5m and are not friends,
                                                   //Rangers or Druids.
    //SetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE);//Creature will flee those that close within 7m if they are not friends,
                                                   //Rangers or Druids.

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1001
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007

// DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) *****************************************************************************************
    SetListeningPatterns();    // Goes through and sets up which shouts the NPC will listen to.
    WalkWayPoints();           // Optional Parameter: void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
                               // 1. Looks to see if any Way Points in the module have the tag "WP_" + NPC TAG + "_0X", if so walk them
                               // 2. If the tag of the Way Point is "POST_" + NPC TAG the creature will return this way point after
                               //    combat.
    GenerateNPCTreasure();     //* Use this to create a small amount of treasure on the creature
}

void __creature_nw_c2_vampireg9()
//::///////////////////////////////////////////////
//:: NW_C2_VAMPIREG9.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Vampire gas, when spawned in tries to
    move coffin with same name as self
*/
//:://////////////////////////////////////////////
//:: Created By:  Brent
//:: Created On:   January 2002
//:://////////////////////////////////////////////
{
    // * search for nearest coffin
    int bFound = FALSE;
    int nCount = 0;
    while (bFound == FALSE)
    {
        object oCoffin = GetObjectByTag(GetTag(OBJECT_SELF),nCount);
        nCount++;
        if (GetIsObjectValid(oCoffin) && (GetObjectType(oCoffin) == OBJECT_TYPE_PLACEABLE))
        {
            bFound = TRUE;
            ActionMoveToObject(oCoffin, FALSE, 3.0);    //* moving this number too close will make this break
            ActionDoCommand(SignalEvent(OBJECT_SELF, EventUserDefined(7777)));
            SetCommandable(FALSE);
        }
        else
        // * if no coffin then destroy self
        if (GetIsObjectValid(oCoffin) == FALSE)
        {
            bFound = TRUE;
            DestroyObject(OBJECT_SELF, 0.1);
        }
    }
}

void __creature_nw_ch_ac9()
//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

    2007-12-31: Deva Winblood
    Modified to look for X3_HORSE_OWNER_TAG and if
    it is defined look for an NPC with that tag
    nearby or in the module (checks near first).
    It will make that NPC this horse's master.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
{
    string sTag;
    object oNPC;
    SetAssociateListenPatterns();//Sets up the special henchmen listening patterns

    bkSetListeningPatterns();      // Goes through and sets up which shouts the NPC will listen to.

    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE); //User ranged weapons by default if true.
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);

    // April 2002: Summoned monsters, associates and familiars need to stay
    // further back due to their size.
    int nType = GetAssociateType(OBJECT_SELF);
    switch (nType)
    {
        case ASSOCIATE_TYPE_ANIMALCOMPANION:
        case ASSOCIATE_TYPE_DOMINATED:
        case ASSOCIATE_TYPE_FAMILIAR:
        case ASSOCIATE_TYPE_SUMMONED:
            SetAssociateState(NW_ASC_DISTANCE_4_METERS);
            break;

    }
    sTag=GetLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
    if (GetStringLength(sTag)>0)
    { // look for master
        oNPC=GetNearestObjectByTag(sTag);
        if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
        { // master found
            AddHenchman(oNPC);
        } // master found
        else
        { // look in module
            oNPC=GetObjectByTag(sTag);
            if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
            { // master found
                AddHenchman(oNPC);
            } // master found
            else
            { // master does not exist - remove X3_HORSE_OWNER_TAG
                DeleteLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
            } // master does not exist - remove X3_HORSE_OWNER_TAG
        } // look in module
    } // look for master
/*    if (GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, GetMaster()) == OBJECT_SELF  ||
        GetAssociate(ASSOCIATE_TYPE_DOMINATED, GetMaster()) == OBJECT_SELF  ||
        GetAssociate(ASSOCIATE_TYPE_FAMILIAR, GetMaster()) == OBJECT_SELF  ||
        GetAssociate(ASSOCIATE_TYPE_SUMMONED, GetMaster()) == OBJECT_SELF)
    {
            SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    }
*/
    // * Feb 2003: Set official campaign henchmen to have no inventory
    SetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY", 10) ;

    //SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
    SetAssociateStartLocation();
    // SPECIAL CONVERSATION SETTTINGS
    //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
    //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
            // This causes the creature to say a special greeting in their conversation file
            // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
            // greeting in order to designate it. As the creature is actually saying this to
            // himself, don't attach any player responses to the greeting.


// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007
}

void __creature_nw_ch_acani9()
//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/* 

This must support the OC henchmen and all summoned/companion
creatures. 

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
{
    //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);

    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Distance: make henchmen stick closer
    SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    if (GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN)
    {
    	SetAssociateState(NW_ASC_DISTANCE_2_METERS);
    }

    // Set starting location
    SetAssociateStartLocation();
}

void __creature_nw_ch_acgs9()
//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_ACGS9 (On Spawn In for the Giant Spider
//:: Animal Companion)
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Apr 19, 2002
//:://////////////////////////////////////////////
{
    SetAssociateListenPatterns();//Sets up the special henchmen listening patterns
    SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);
    SetListeningPatterns();      // Goes through and sets up which shouts the NPC will listen to.

    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS, FALSE);
    SetAssociateState(NW_ASC_DISARM_TRAPS, FALSE);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE); //User ranged weapons by default if true.

    //SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
    SetAssociateStartLocation();
    // SPECIAL CONVERSATION SETTTINGS
    //SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);
    //SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);
            // This causes the creature to say a special greeting in their conversation file
            // upon Perceiving the player. Attach the [NW_D2_GenCheck.nss] script to the desired
            // greeting in order to designate it. As the creature is actually saying this to
            // himself, don't attach any player responses to the greeting.
    

// CUSTOM USER DEFINED EVENTS
/*
    The following settings will allow the user to fire one of the blank user defined events in the NW_D2_DefaultD.  Like the
    On Spawn In script this script is meant to be customized by the end user to allow for unique behaviors.  The user defined
    events user 1000 - 1010
*/
    //SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);         //OPTIONAL BEHAVIOR - Fire User Defined Event 1002
    //SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);           //OPTIONAL BEHAVIOR - Fire User Defined Event 1005
    //SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);          //OPTIONAL BEHAVIOR - Fire User Defined Event 1006
    //SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);        //OPTIONAL BEHAVIOR - Fire User Defined Event 1008
    //SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT); //OPTIONAL BEHAVIOR - Fire User Defined Event 1003
    //SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);      //OPTIONAL BEHAVIOR - Fire User Defined Event 1004
    //SetSpawnInCondition(NW_FLAG_DEATH_EVENT);            //OPTIONAL BEHAVIOR - Fire User Defined Event 1007
}

void __creature_nw_ch_summon_9()
//::///////////////////////////////////////////////
//:: Associate: On Spawn In
//:: NW_CH_AC9
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

This must support the OC henchmen and all summoned/companion
creatures.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//:: Updated By: Georg Zoeller, 2003-08-20: Added variable check for spawn in animation
{
     //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);

    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Distance: make henchmen stick closer
    SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    if (GetAssociate(ASSOCIATE_TYPE_HENCHMAN, GetMaster()) == OBJECT_SELF) {
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);
    }

    // * If Incorporeal, apply changes
    if (GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL) == TRUE)
    {
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        eConceal = ExtraordinaryEffect(eConceal);
        effect eGhost = EffectCutsceneGhost();
        eGhost = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, OBJECT_SELF);
    }

    // Set starting location
    SetAssociateStartLocation();
}

//void __creature_x0_ch_hen_spawn()
//:://////////////////////////////////////////////////
//:: X0_CH_HEN_SPAWN
//:: Copyright (c) 2002 Floodgate Entertainment
//:://////////////////////////////////////////////////
/*
Henchman-specific OnSpawn handler for XP1. Based on NW_CH_AC9 by Bioware.
 */
//:://////////////////////////////////////////////////
//:: Created By: Naomi Novik
//:: Created On: 10/09/2002
//:://////////////////////////////////////////////////

// * there are only a couple potential interjections henchmen can say in c3
void StrikeOutStrings(object oNathyrra)
{
    SetLocalString(oNathyrra, "X2_L_RANDOMONELINERS", "26|27|28|29|30|");
    SetLocalString(oNathyrra, "X2_L_RANDOM_INTERJECTIONS", "6|7|");
}
            
void __creature_x0_ch_hen_spawn()
{
    string sAreaTag = GetTag(GetArea(OBJECT_SELF));
    string sModuleTag = GetTag(GetModule());
    string sMyTag = GetTag(OBJECT_SELF);


    // * Setup how many random interjectiosn and popups they have
    if (sMyTag == "x2_hen_deekin")
    {
        SetNumberOfRandom("X2_L_RANDOMONELINERS", OBJECT_SELF, 50);
        SetNumberOfRandom("X2_L_RANDOM_INTERJECTIONS", OBJECT_SELF, 10);
    }
    else
    if (sMyTag == "x2_hen_daelan")
    {
        SetNumberOfRandom("X2_L_RANDOMONELINERS", OBJECT_SELF, 20);
        SetNumberOfRandom("X2_L_RANDOM_INTERJECTIONS", OBJECT_SELF, 2);
    }
    else
    if (sMyTag == "x2_hen_linu")
    {
        SetNumberOfRandom("X2_L_RANDOMONELINERS", OBJECT_SELF, 20);
        SetNumberOfRandom("X2_L_RANDOM_INTERJECTIONS", OBJECT_SELF, 2);
    }
    else
    if (sMyTag == "x2_hen_sharwyn")
    {
        SetNumberOfRandom("X2_L_RANDOMONELINERS", OBJECT_SELF, 20);
        SetNumberOfRandom("X2_L_RANDOM_INTERJECTIONS", OBJECT_SELF, 4);
    }
    else
    if (sMyTag == "x2_hen_tomi")
    {
        SetNumberOfRandom("X2_L_RANDOMONELINERS", OBJECT_SELF, 20);
        SetNumberOfRandom("X2_L_RANDOM_INTERJECTIONS", OBJECT_SELF, 4);
    }
    else
    if (sMyTag == "H2_Aribeth")
    {
        SetNumberOfRandom("X2_L_RANDOMONELINERS", OBJECT_SELF, 20);
        SetNumberOfRandom("X2_L_RANDOM_INTERJECTIONS", OBJECT_SELF, 2);
    }
    else
    // * valen and Nathyrra have certain random lines that only show up in
    // * in Chapter 2 (Chapter 3 they'll get this variable set on them
    // * as well, with different numbers)
    // * Basically #1-5 are Chapter 2 only, 26-30 are Chapter 3 only. The rest can show up anywhere
    if (sMyTag == "x2_hen_nathyra" || sMyTag == "x2_hen_valen")
    {
        // * only fire this in Chapter 2. THey setup differently in the transition from C2 to C3
        if (GetTag(GetModule()) == "x0_module2")
        {
            SetNumberOfRandom("X2_L_RANDOMONELINERS", OBJECT_SELF, 25);
            SetNumberOfRandom("X2_L_RANDOM_INTERJECTIONS", OBJECT_SELF, 3);
        }
        else
        {
            StrikeOutStrings(OBJECT_SELF);
        }

    }

    //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    
    // * July 2003. Set this to true so henchmen
    // * will hopefully run off a little less often
    // * by default
    // * September 2003. Bad decision. Reverted back
    // * to original. This mode too often looks like a bug
    // * because they hang back and don't help each other out.
    //SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, TRUE);
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);

    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Set starting location
    SetAssociateStartLocation();

    // Set respawn location
    SetRespawnLocation();

    // For some general behavior while we don't have a master,
    // let's do some immobile animations
    SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);

    // **************************************
    // * CHAPTER 1
    // * Kill henchmen who spawn in
    // * to any area for the first time
    // * in Undermountain.
    // **************************************
    SetIsDestroyable(FALSE, TRUE, TRUE);
    
    // * September 2003
    // * Scan through all equipped items and make
    // * sure they are identified
    int i = 0;
    object oItem;
    for (i = INVENTORY_SLOT_HEAD; i<=INVENTORY_SLOT_CARMOUR; i++)
    {
        oItem = GetItemInSlot(i, OBJECT_SELF);
        if (GetIsObjectValid(oItem) == TRUE)
            SetIdentified( oItem, TRUE);
    }
    
    // *
    // * Special CHAPTER 1 - XP2
    // * Levelup code
    // *
    if (sModuleTag == "x0_module1" && GetLocalInt(GetModule(), "X2_L_XP2") == TRUE)
    {
        if (GetLocalInt(OBJECT_SELF, "X2_KilledInUndermountain") == 1)
            return;
        SetLocalInt(OBJECT_SELF, "X2_KilledInUndermountain", 1);

        //Level up henchman to level 13   if in Starting Room
        //Join script will level them up correctly once hired
        if (sAreaTag == "q2a_yawningportal" )
        {
            int nLevel = 1;
            for (nLevel = 1; nLevel < 14; nLevel++)
            {
                LevelUpHenchman(OBJECT_SELF);
            }
        }
        //'kill the henchman'
        
        // * do not kill if spawning in main room
        string szAreaTag = GetTag(GetArea(OBJECT_SELF));
        if (szAreaTag != "q2a_yawningportal" && szAreaTag != "q2c_um2east")
        {
            effect eDamage = EffectDamage(500);
            DelayCommand(10.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, OBJECT_SELF));
        }
    }
    
    // * Nathyrra in Chapter 1 is not allowed to have her inventory fiddled with
    if (sMyTag == "x2_hen_nathyrra" && sModuleTag == "x0_module1")
    {
        SetLocalInt(OBJECT_SELF, "X2_JUST_A_DISABLEEQUIP", 1);
    }
    
    
    // *
    // * if I am Aribeth then do my special level-up
    // *
    if (sMyTag == "H2_Aribeth")
    {
        LevelUpAribeth(OBJECT_SELF);
    }
}

//void __creature_x2_ch_summon_sld()
//::///////////////////////////////////////////////
//:: XP2 Associate: On Spawn In
//:: x2_ch_summon_sld
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

   Special Spawn in script for scaled epic shadow
   lord.

   It will always be 1 level below the character's
   shadowdancer level

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-24
//:://////////////////////////////////////////////
void DoScaleESL(object oSelf)
{
    if (GetStringLowerCase(GetTag(oSelf))== "x2_s_eshadlord")
    {
        SSMScaleEpicShadowLord(oSelf);

        // Epic Shadow Lord is incorporeal and gets a concealment bonus.
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        eConceal = ExtraordinaryEffect(eConceal);
        effect eGhost = EffectCutsceneGhost();
        eGhost = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, oSelf);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oSelf);
    }
    else if (GetStringLowerCase(GetTag(oSelf))== "x2_s_vrock")
    {
        SSMScaleEpicFiendishServant(oSelf);
    }
}

void __creature_x2_ch_summon_sld()
{
    //Sets up the special henchmen listening patterns
    SetAssociateListenPatterns();

    // Set additional henchman listening patterns
    bkSetListeningPatterns();

    // Default behavior for henchmen at start
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);

    //Use melee weapons by default
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE);

    // Distance: make henchmen stick closer
    SetAssociateState(NW_ASC_DISTANCE_4_METERS);
    if (GetAssociate(ASSOCIATE_TYPE_HENCHMAN, GetMaster()) == OBJECT_SELF) {
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);
    }

    // Set starting location
    SetAssociateStartLocation();

    // GZ 2003-07-25:
    // There is a timing issue with the GetMaster() function not returning the master of a creature
    // immediately after spawn. Some code which might appear to make no sense has been added
    // to the nw_ch_ac1 and x2_inc_summon files to work around this
    // it is also the reason for the delaycommand below:
    object oSelf = OBJECT_SELF;
    DelayCommand(1.0f,DoScaleESL(oSelf));
}

void __creature_x2_def_spawn()
//::///////////////////////////////////////////////
//:: Name x2_def_spawn
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default On Spawn script


    2003-07-28: Georg Zoeller:

    If you set a ninteger on the creature named
    "X2_USERDEFINED_ONSPAWN_EVENTS"
    The creature will fire a pre and a post-spawn
    event on itself, depending on the value of that
    variable
    1 - Fire Userdefined Event 1510 (pre spawn)
    2 - Fire Userdefined Event 1511 (post spawn)
    3 - Fire both events

    2007-12-31: Deva Winblood
    Modified to look for X3_HORSE_OWNER_TAG and if
    it is defined look for an NPC with that tag
    nearby or in the module (checks near first).
    It will make that NPC this horse's master.

*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner, Georg Zoeller
//:: Created On: June 11/03
//:://////////////////////////////////////////////

//Pre and post spawn functions can be done through the framework
//const int EVENT_USER_DEFINED_PRESPAWN = 1510;
//const int EVENT_USER_DEFINED_POSTSPAWN = 1511;
{
    string sTag;
    object oNPC;
    /* User defined OnSpawn event requested? 
    int nSpecEvent = GetLocalInt(OBJECT_SELF,"X2_USERDEFINED_ONSPAWN_EVENTS");


    // Pre Spawn Event requested
    if (nSpecEvent == 1  || nSpecEvent == 3  )
    {
    SignalEvent(OBJECT_SELF,EventUserDefined(EVENT_USER_DEFINED_PRESPAWN ));
    }*/

    sTag=GetLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
    if (GetStringLength(sTag)>0)
    { // look for master
        oNPC=GetNearestObjectByTag(sTag);
        if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
        { // master found
            AddHenchman(oNPC);
        } // master found
        else
        { // look in module
            oNPC=GetObjectByTag(sTag);
            if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
            { // master found
                AddHenchman(oNPC);
            } // master found
            else
            { // master does not exist - remove X3_HORSE_OWNER_TAG
                DeleteLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
            } // master does not exist - remove X3_HORSE_OWNER_TAG
        } // look in module
    } // look for master

    /*  Fix for the new golems to reduce their number of attacks */

    int nNumber = GetLocalInt(OBJECT_SELF,CREATURE_VAR_NUMBER_OF_ATTACKS);
    if (nNumber >0 )
    {
        SetBaseAttackBonus(nNumber);
    }

    // Execute default OnSpawn script.
    __creature_nw_c2_default9();
    //ExecuteScript("nw_c2_default9", OBJECT_SELF);

/*
    //Post Spawn event requeste
    if (nSpecEvent == 2 || nSpecEvent == 3)
    {
    SignalEvent(OBJECT_SELF,EventUserDefined(EVENT_USER_DEFINED_POSTSPAWN));
    }
*/
}

void __creature_x2_spawn_genie()
// * Apply neat-o visual effects to genie
{
    effect eVis = EffectVisualEffect(423);
    effect eVis2 = EffectVisualEffect(479);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis, OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVis2, OBJECT_SELF);
}

// -----------------------------------------------------------------------------
//                              UserDefined
// -----------------------------------------------------------------------------

//__creature_nw_c2_dimdoor
//::///////////////////////////////////////////////
//:: NW_C2_DIMDOOR.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
     Creature randomly hops around
     to enemies during combat.
*/
//:://////////////////////////////////////////////
//:: Created By:  Brent
//:: Created On:  January 2002
//:://////////////////////////////////////////////

void JumpToWeakestEnemy(object oTarget)
{
    object oTargetVictim = GetFactionMostDamagedMember(oTarget);
    // * won't jump if closer than 4 meters to victim
    if ((GetDistanceToObject(oTargetVictim) > 4.0)   && (GetObjectSeen(oTargetVictim) == TRUE))
    {
        ClearAllActions();
        effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);

//        SpeakString("Jump to " + GetName(oTargetVictim));
        DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF));
        DelayCommand(0.3,ActionJumpToObject(oTargetVictim));
        DelayCommand(0.5,ActionAttack(oTargetVictim));
    }
}
void __creature_nw_c2_dimdoor()
{
    // * During Combat try teleporting around
    if (GetUserDefinedEventNumber() == 1003)
    {
        // * if random OR heavily wounded then teleport to next enemy
        if ((Random(100) < 50)  ||  ( (GetCurrentHitPoints() / GetMaxHitPoints()) * 100 < 50) )
        {
           JumpToWeakestEnemy(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY));
        }
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("resources");

    // ----- Module Events -----
    //RegisterEventScripts(oPlugin, EVENT_CONSTANT, "function_name", 4.0);

    // ----- Heartbeat Events -----
    RegisterLibraryScript("x2_def_heartbeat",       1);
    RegisterLibraryScript("nw_c2_default1",         2);
    RegisterLibraryScript("nw_ch_ac1",              3);
    RegisterLibraryScript("x0_ch_hen_heart",        4);
    RegisterLibraryScript("x3_c2_pm_hb",            5);
    RegisterLibraryScript("x0_wyrm_heart",          6);
    RegisterLibraryScript("nw_c2_gargoyle",         7);
    RegisterLibraryScript("x2_c2_gcube_hbt",        8);

    // ----- Spell Cast At Events -----
    RegisterLibraryScript("nw_c2_defaultb",         10);
    RegisterLibraryScript("nw_ch_acb",              11);
    RegisterLibraryScript("nw_ch_fmb",              12);
    RegisterLibraryScript("nw_nw_acb",              13);
    RegisterLibraryScript("nw_ochrejlly_osc",       14);
    RegisterLibraryScript("q2_spell_djinn",         15);
    RegisterLibraryScript("x2_bb_spellcast",        16);
    RegisterLibraryScript("x2_def_spellcast",       17);
    RegisterLibraryScript("x2_hen_spell",           18);

    // ----- Physical Attacked Events -----
    RegisterLibraryScript("nw_c2_default5",         20);
    RegisterLibraryScript("nw_ch_ac5",              21);
    RegisterLibraryScript("nw_ch_acd",              22);
    RegisterLibraryScript("nw_e0_default5",         23);
    RegisterLibraryScript("nw_ochrejlly_opa",       24);
    RegisterLibraryScript("q2_attack_djinn",        25);
    RegisterLibraryScript("x0_ch_hen_attack",       26);
    RegisterLibraryScript("x2_def_attacked",        27);

    // ----- Damaged Events -----
    RegisterLibraryScript("nw_c2_default6",         30);
    //RegisterLibraryScript("nw_ch_ac5",              31); <-- shared with physical attacked
    RegisterLibraryScript("nw_ch_ac6",              32);
    RegisterLibraryScript("x0_ch_hen_damage",       33);
    RegisterLibraryScript("x0_hatch_dam",           34);
    RegisterLibraryScript("x2_def_ondamage",        35);

    // ----- Death Events -----
    RegisterLibraryScript("nw_c2_default7",         40);
    RegisterLibraryScript("nw_c2_stnkbtdie",        41);
    RegisterLibraryScript("nw_c2_vampire7",         42);
    RegisterLibraryScript("nw_ch_ac7",              43);
    RegisterLibraryScript("nw_s3_balordeth",        44);
    //RegisterLibraryScript("x0_hatch_dam",           45); <-- shared with damaged above
    RegisterLibraryScript("x2_def_ondeath",         46);
    RegisterLibraryScript("x2_hen_death",           47);
    RegisterLibraryScript("x3_c2_pm_death",         48);

    // ----- Conversation Events -----
    RegisterLibraryScript("nw_ch_ac4",              51);
    RegisterLibraryScript("nw_c2_default4",         51);
    RegisterLibraryScript("x2_def_onconv",          52);
    RegisterLibraryScript("x0_ch_hen_conv",         53);
    RegisterLibraryScript("nw_ch_fm4",              54);
    RegisterLibraryScript("x0_cheatlisten",         55);


    RegisterLibraryScript("nw_ch_ac8",              60);
    RegisterLibraryScript("nw_c2_default8",         61);
    RegisterLibraryScript("x2_def_ondisturb",       62);
    RegisterLibraryScript("x0_ch_hen_distrb",       63);
    RegisterLibraryScript("nw_e0_default8",         64);

    // ----- End Combat Round Events -----
    RegisterLibraryScript("nw_c2_default3",         70);
    RegisterLibraryScript("nw_ch_ac3",              71);
    RegisterLibraryScript("nw_ch_fm3",              72);
    RegisterLibraryScript("x0_ch_hen_combat",       73);
    RegisterLibraryScript("x2_def_endcombat",       74);

    // ----- Blocked Events -----
    RegisterLibraryScript("nw_c2_default3",         80);
    RegisterLibraryScript("nw_ch_ace",              80);
    RegisterLibraryScript("x0_ch_hen_block",        82);
    RegisterLibraryScript("x2_def_onblocked",       83);

    // ----- Perception Events -----
    RegisterLibraryScript("nw_c2_default2",         90);
    RegisterLibraryScript("nw_ch_ac2",              91);
    RegisterLibraryScript("x0_ch_hen_percep",       92);
    RegisterLibraryScript("x2_def_percept",         93);

    // ----- Rested Events -----
    RegisterLibraryScript("nw_c2_defaulta",         100);
    RegisterLibraryScript("nw_ch_aca",              101);
    RegisterLibraryScript("x0_ch_hen_rest",         102);
    RegisterLibraryScript("x2_def_rested",          103);

    // ----- Spawn Events -----
    RegisterLibraryScript("nw_c2_bat9",             120);
    RegisterLibraryScript("nw_c2_default9",         121);
    RegisterLibraryScript("nw_c2_dimdoors",         122);
    RegisterLibraryScript("nw_c2_dropin9",          123);
    RegisterLibraryScript("nw_c2_gated",            124);
    RegisterLibraryScript("nw_c2_gatedbad",         125);
    RegisterLibraryScript("nw_c2_herbivore",        126);
    RegisterLibraryScript("nw_c2_lycan_9",          127);
    RegisterLibraryScript("nw_c2_omnivore",         128);
    RegisterLibraryScript("nw_c2_vampireg9",        129);
    RegisterLibraryScript("nw_ch_ac9",              130);
    RegisterLibraryScript("nw_ch_acani9",           131);
    RegisterLibraryScript("nw_ch_acgs9",            132);
    RegisterLibraryScript("nw_ch_summon_9",         133);
    RegisterLibraryScript("x0_ch_hen_spawn",        134);
    RegisterLibraryScript("x2_ch_summon_sld",       135);
    RegisterLibraryScript("x2_def_spawn",           136);
    RegisterLibraryScript("x2_spawn_genie",         137);

    // ----- User Defined Events -----
    RegisterLibraryScript("nw_c2_dimdoor",          150);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Heartbeat Events -----
        case 1:   //x2_def_heartbeat calls nw_c2_default1
        case 2:   __creature_nw_c2_default1(); break;
        case 3:   __creature_nw_ch_ac1(); break;
        case 4:   __creature_x0_ch_hen_heart(); break;
        case 5:   __creature_x3_c2_pm_hb(); break;
        case 6:   __creature_x0_wyrm_heart(); break;
        case 7:   __creature_nw_c2_gargoyle(); break;
        case 8:   __creature_x2_c2_gcube_hbt(); break;

        // ----- Spell Cast At Events -----
        case 10:  __creature_nw_c2_defaultb();
        case 11:  __creature_nw_ch_acb(); break;
        case 12:  __creature_nw_ch_fmb(); break;
        case 13:  __creature_nw_nw_acb(); break;
        case 14:  __creature_nw_ochrejlly_osc(); break;
        case 15:  __creature_q2_spell_djinn(); break;
        case 16:  __creature_x2_bb_spellcast(); break;
        case 17:  __creature_x2_def_spellcast(); break;
        case 18:  __creature_x2_hen_spell(); break;

        // ----- Physical Attacked Events -----
        case 20:  __creature_nw_c2_default5();
        case 21:  __creature_nw_ch_ac5(); break;
        case 22:  __creature_nw_ch_acd(); break;
        case 23:  __creature_nw_e0_default5(); break;
        case 24:  __creature_nw_ochrejlly_opa(); break;
        case 25:  __creature_q2_attack_djinn(); break;
        case 26:  __creature_x0_ch_hen_attack(); break;
        case 27:  __creature_x2_def_attacked(); break;

        // ----- Damaged Events -----
        case 30:  __creature_nw_c2_default6(); break;
        //case 31:  __creature_nw_ch_ac5(); break;
        case 32:  __creature_nw_ch_ac6(); break;
        case 33:  __creature_x0_ch_hen_damage(); break;
        case 34:  __creature_x0_hatch_dam(); break;
        case 35:  __creature_x2_def_ondamage(); break;

        // ----- Death Events -----
        case 40:  __creature_nw_c2_default7(); break;
        case 41:  __creature_nw_c2_stnkbtdie(); break;
        case 42:  __creature_nw_c2_vampire7(); break;
        case 43:  __creature_nw_ch_ac7(); break;
        case 44:  __creature_nw_s3_balordeth(); break;
        //case 45:  __creature_x0_hatch_dam(); break;
        case 46:  __creature_x2_def_ondeath(); break;
        case 47:  __creature_x2_hen_death(); break;
        case 48:  __creature_x3_c2_pm_death(); break;

        // ----- Conversation Events -----
        case 50:  __creature_nw_ch_ac4(); break;
        case 51:  __creature_nw_c2_default4(); break;
        case 52:  __creature_x2_def_onconv(); break;
        case 53:  __creature_x0_ch_hen_conv(); break;
        case 54:  __creature_nw_ch_fm4(); break;
        case 55:  __creature_x0_cheatlisten(); break;

        // ----- Disturbed Events -----
        case 60:  __creature_nw_ch_ac8(); break;
        case 61:  __creature_nw_c2_default8(); break;
        case 62:  __creature_x2_def_ondisturb(); break;
        case 63:  __creature_x0_ch_hen_distrb(); break;
        case 64:  __creature_nw_e0_default8(); break;

        // ----- End Combat Round Events -----
        case 70:  __creature_nw_c2_default3(); break;
        case 71:  __creature_nw_ch_ac3(); break;
        case 72:  __creature_nw_ch_fm3(); break;
        case 73:  __creature_x0_ch_hen_combat(); break;
        case 74:  __creature_x2_def_endcombat(); break;

        // ----- Blocked Events -----
        case 80:  __creature_nw_c2_defaulte(); break;
        case 81:  __creature_nw_ch_ace(); break;
        case 82:  __creature_x0_ch_hen_block(); break;
        case 83:  __creature_x2_def_onblocked(); break;

        // ----- Perception Events -----
        case 90:  __creature_nw_c2_default2(); break;
        case 91:  __creature_nw_ch_ac2(); break;
        case 92:  __creature_x0_ch_hen_percep(); break;
        case 93:  __creature_x2_def_percept(); break;

        // ----- Rested Events -----
        case 100: __creature_nw_c2_defaulta(); break;
        case 101: __creature_nw_ch_aca(); break;
        case 102: __creature_x0_ch_rest(); break;
        case 103: __creature_x2_def_rested(); break;

        // ----- Spawn Events -----
        case 120: __creature_nw_c2_bat9(); break;
        case 121: __creature_nw_c2_default9(); break;
        case 122: __creature_nw_c2_dimdoors(); break;
        case 123: __creature_nw_c2_dropin9(); break;
        case 124: __creature_nw_c2_gated(); break;
        case 125: __creature_nw_c2_gatedbad(); break;
        case 126: __creature_nw_c2_herbivore(); break;
        case 127: __creature_nw_c2_lycan_9(); break;
        case 128: __creature_nw_c2_omnivore(); break;
        case 129: __creature_nw_c2_vampireg9(); break;
        case 130: __creature_nw_ch_ac9(); break;
        case 131: __creature_nw_ch_acani9(); break;
        case 132: __creature_nw_ch_acgs9(); break;
        case 133: __creature_nw_ch_summon_9(); break;
        case 134: __creature_x0_ch_hen_spawn(); break;
        case 135: __creature_x2_ch_summon_sld(); break;
        case 136: __creature_x2_def_spawn(); break;
        case 137: __creature_x2_spawn_genie(); break;

        // ----- User Defined Events -----
        case 150: __creature_nw_c2_dimdoor(); break;

        default: CriticalError("Library function " + sScript + " not found");
    }
}
