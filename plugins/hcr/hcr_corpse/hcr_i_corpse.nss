// -----------------------------------------------------------------------------
//    File: pw_i_corpse.nss
//  System: PC Corpse (core)
// -----------------------------------------------------------------------------
// Description:
//  Primary functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  Nothing!  Leave me alone.
// -----------------------------------------------------------------------------

#include "x2_inc_switches"
#include "hcr_c_corpse"
#include "hcr_i_core"
#include "x0_i0_position"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// ----- Items -----
const string H2_PC_CORPSE_ITEM = "h2_pccorpseitem";
const string H2_DEATH_CORPSE = "h2_deathcorpse";
const string H2_DEATH_CORPSE2 = "h2_deathcorpse2";

// ----- Variables -----
const string H2_WP_DEATH_CORPSE = "H2_PLAYERCORPSE";
const string H2_DEAD_PLAYER_ID = "H2_DEAD_PLAYER_ID";
const string H2_PCCORPSE_ITEM_ACTIVATOR = "H2_PCCORPSE_ITEM_ACTIVATOR";
const string H2_PCCORPSE_ITEM_ACTIVATED = "H2_PCCORPSE_ITEM_ACTIVATED";
const string H2_CORPSE = "H2_CORPSE";
const string H2_CORPSE_DC = "H2_CORPSE_DC";
const string H2_LAST_DROP_LOCATION = "H2_LAST_DROP_LOCATION";
const string H2_CORPSE_TOKEN = "H2_CORPSE_TOKEN";



// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< h2_PickUpPlayerCorpse >---
// This handles moving the pc corpse copy and cleaning up the death corpse 
//  container whenever oCorpseToken is picked up by a PC.
void h2_PickUpPlayerCorpse(object oCorpseToken);

// ---< h2_DropPlayerCorpse >---
// This handles moving the pc corpse copy and creating the death corpse container
//  whenever oCorpseToken is dropped by a PC.
void h2_DropPlayerCorpse(object oCorpseToken);

// ---< h2_CreatePlayerCorpse >---
// This handles the creation of the pc corpse copy of oPC, creation of the death
//  corpse container and the token item used to move the corpse copy around by
//  other PCs when the oPC dies.
void h2_CreatePlayerCorpse(object oPC);

// ---< h2_CorpseTokenActivatedOnNPC >---
//Handles when the corpse token is activated and targeted on an NPC.
void h2_CorpseTokenActivatedOnNPC();

// ---< h2_XPLostForRessurection >---
// Returns the amount of XP that should be lost based on the level of the
//  raised PC.
int h2_XPLostForRessurection(object oRaisedPC);

// ---< h2_GoldCostForRessurection >---
// Returns the smount of GP that should be lost based on the level of the
//  raised PC.
int h2_GoldCostForRessurection(object oCaster, int spellID);

// ---< h2_RaiseSpellCastOnCorpseToken >---
// Handles all functions required when a player or DM casts a raise spell
//  on a dead PC's corpse token.
void h2_RaiseSpellCastOnCorpseToken(int spellID, object oToken = OBJECT_INVALID);

// ---< h2_PerformOffLineRessurectionLogin >---
// Sets up all variables for the PC so that the next time the PC logs in,
//  he will be resurrected as if he'd be logged in when it happened.
void h2_PerformOffLineRessurectionLogin(object oPC, location ressLoc);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_PickUpPlayerCorpse(object oCorpseToken)
{
    string uniquePCID = GetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID);
    object oDC = GetObjectByTag(H2_CORPSE + uniquePCID);
    object oWayPt = GetObjectByTag(H2_WP_DEATH_CORPSE);

    if (GetIsObjectValid(oDC))
    {
        AssignCommand(oDC, SetIsDestroyable(TRUE, FALSE));
        DestroyObject(oDC);
    }
}

void h2_DropPlayerCorpse(object oCorpseToken)
{
    string uniquePCID = GetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID);
    object oDeathCorpse, oDC = GetObjectByTag(H2_CORPSE + uniquePCID);

    if (GetIsObjectValid(oDC))
    {   //if the dead player corpse copy exists, use it & the invisible object DC container
        object oDC2 = CopyObject(oDC, GetLocation(oCorpseToken));
        oDeathCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, H2_DEATH_CORPSE, GetLocation(oDC2));
        DestroyObject(oDC);
    }
    else
        oDeathCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, H2_DEATH_CORPSE2, GetRandomLocation(GetArea(oCorpseToken), oCorpseToken, 3.0));

    SetName(oDeathCorpse, GetName(oCorpseToken));
    object oNewToken = CopyItem(oCorpseToken, oDeathCorpse, TRUE);
    SetLocalLocation(oNewToken, H2_LAST_DROP_LOCATION, GetLocation(oDeathCorpse));
    DestroyObject(oCorpseToken);
}

void h2_CreatePlayerCorpse(object oPC)
{
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    
    object oDC = GetObjectByTag(H2_CORPSE_DC + uniquePCID);
    if (GetIsObjectValid(oDC))
        return;

    object oDeadPlayer = GetObjectByTag(H2_CORPSE + uniquePCID);
    if (GetIsObjectValid(oDeadPlayer))
        return;

    location loc = GetPlayerLocation(oPC, H2_LOCATION_LAST_DIED);
    oDeadPlayer = CopyObject(oPC, loc, OBJECT_INVALID, H2_CORPSE + uniquePCID);
    SetName(oDeadPlayer, H2_TEXT_CORPSE_OF + GetName(oPC));
    ChangeToStandardFaction(oDeadPlayer, STANDARD_FACTION_COMMONER);
    // remove gold, inventory & equipped items from dead player corpse copy
    h2_DestroyNonDroppableItemsInInventory(oDeadPlayer);
    h2_MovePossessorInventory(oDeadPlayer, TRUE);
    h2_MoveEquippedItems(oDeadPlayer);
    AssignCommand(oDeadPlayer, SetIsDestroyable(FALSE, FALSE));
    AssignCommand(oDeadPlayer, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oDeadPlayer));
    object oDeathCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, H2_DEATH_CORPSE, GetLocation(oDeadPlayer), FALSE, H2_CORPSE_DC + uniquePCID);
    object oCorpseToken = CreateItemOnObject(H2_PC_CORPSE_ITEM, oDeathCorpse, 1, H2_CORPSE_TOKEN + uniquePCID);
    SetName(oCorpseToken, H2_TEXT_CORPSE_OF + GetName(oPC));
    SetName(oDeathCorpse, GetName(oCorpseToken));
    SetLocalLocation(oCorpseToken, H2_LAST_DROP_LOCATION, GetLocation(oDeathCorpse));
    SetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID, uniquePCID);
}

void h2_CorpseTokenActivatedOnNPC()
{
    object oPC = GetItemActivator();
    object oItem = GetItemActivated();
    object oTarget = GetItemActivatedTarget();
    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
    {
        SetLocalObject(oTarget, H2_PCCORPSE_ITEM_ACTIVATOR, oPC);
        SetLocalObject(oTarget, H2_PCCORPSE_ITEM_ACTIVATED, oItem);
        SignalEvent(oTarget, EventUserDefined(H2_PCCORPSE_ITEM_ACTIVATED_EVENT_NUMBER));
    }
}

int h2_XPLostForRessurection(object oRaisedPC)
{
    int xplevel = 0;
    int i;

    for (i = 1; i < GetHitDice(oRaisedPC); i++)
    {
        xplevel = xplevel + 1000 * (i - 1);
    }

    xplevel = xplevel + 500 * (i - 1);
    return GetXP(oRaisedPC) - xplevel;
}

int h2_GoldCostForRessurection(object oCaster, int spellID)
{
    if (spellID == SPELL_RAISE_DEAD)
    {
        if (GetGold(oCaster) < H2_GOLD_COST_FOR_RAISE_DEAD)
            return 0;
        return H2_GOLD_COST_FOR_RAISE_DEAD;
    }
    else
    {
        if (GetGold(oCaster) < H2_GOLD_COST_FOR_RESSURECTION)
            return 0;
        return H2_GOLD_COST_FOR_RESSURECTION;
    }
}

void h2_RaiseSpellCastOnCorpseToken(int spellID, object oToken = OBJECT_INVALID)
{
    if (!GetIsObjectValid(oToken))
        oToken = GetSpellTargetObject();

    object oCaster = OBJECT_SELF;
    location castLoc = GetLocation(oCaster);
    string uniquePCID = GetLocalString(oToken, H2_DEAD_PLAYER_ID);
    object oPC = h2_FindPCWithGivenUniqueID(uniquePCID);
    
    if (!_GetIsDM(oCaster))
    {
        if (H2_ALLOW_CORPSE_RESS_BY_PLAYERS == FALSE && _GetIsPC(oPC))
            return;

        if (H2_REQUIRE_GOLD_FOR_RESS && _GetIsPC(oCaster))
        {
            int goldCost = h2_GoldCostForRessurection(oCaster, spellID);
            if (goldCost <= 0)
            {
                SendMessageToPC(oCaster, H2_TEXT_NOT_ENOUGH_GOLD);
                return;
            }
            else
                TakeGoldFromCreature(goldCost, oCaster, TRUE);
        }

        if (spellID == SPELL_RAISE_DEAD)
        {
            int cHP = GetCurrentHitPoints(oPC);
            if (cHP > GetHitDice(oPC))
            {
                effect eDam = EffectDamage(cHP - GetHitDice(oPC));
                ApplyEffectToObject(DURATION_TYPE_INSTANT,  eDam, oPC);
            }
        }
        else
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        
        if (H2_APPLY_XP_LOSS_FOR_RESS)
        {
            int lostXP = h2_XPLostForRessurection(oPC);
            GiveXPToCreature(oPC, -lostXP);
        }
    }
    else
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);

    effect eVis = EffectVisualEffect(VFX_IMP_RAISE_DEAD);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, castLoc);
    DestroyObject(oToken);
    string sMessage;
    
    if (_GetIsPC(oCaster))
        sMessage = GetName(oCaster) + "_" + GetPCPlayerName(oCaster);
    else
        sMessage = "NPC " + GetName(oCaster) + " (" + H2_TEXT_CORPSE_TOKEN_USED_BY + GetName(oPC) + "_" + GetPCPlayerName(oPC) + ") ";

    sMessage += H2_TEXT_RESS_PC_CORPSE_ITEM;

    if (GetIsObjectValid(oPC) && _GetIsPC(oPC))
    {
        SendMessageToPC(oPC, H2_TEXT_YOU_HAVE_BEEN_RESSURECTED);
        SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
        RunEvent(H2_EVENT_ON_PLAYER_LIVES, oPC, oPC);
        AssignCommand(oPC, JumpToLocation(castLoc));
        sMessage += GetName(oPC) + "_" + GetPCPlayerName(oPC);
    }
    else //player was offline
    {
        // TODO
        /*
        SendMessageToPC(oCaster, H2_TEXT_OFFLINE_RESS_CASTER_FEEDBACK);
        SetDatabaseLocation(uniquePCID + H2_RESS_LOCATION, castLoc);

        if (_GetIsDM(oCaster))
            SetDatabaseInt(uniquePCID + H2_RESS_BY_DM, TRUE);
        sMessage += H2_TEXT_OFFLINE_PLAYER + " " + GetDatabaseString(uniquePCID);
        */
    }
    SendMessageToAllDMs(sMessage);
    Debug(sMessage);
}

// TODO change unqiueid to uuid?
void h2_PerformOffLineRessurectionLogin(object oPC, location ressLoc)
{
    // TODO
    /*
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    DeleteDatabaseVariable(uniquePCID + H2_RESS_LOCATION);
    SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    SendMessageToPC(oPC, H2_TEXT_YOU_HAVE_BEEN_RESSURECTED);
    DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, AssignCommand(oPC, JumpToLocation(ressLoc)));
    if (H2_APPLY_XP_LOSS_FOR_RESS && !GetDatabaseInt(uniquePCID + H2_RESS_BY_DM))
    {
        int lostXP = h2_XPLostForRessurection(oPC);
        GiveXPToCreature(oPC, -lostXP);
    }
    
    DeleteDatabaseVariable(uniquePCID + H2_RESS_BY_DM);
    string sMessage = GetName(oPC) + "_" + GetPCPlayerName(oPC) + H2_TEXT_OFFLINE_RESS_LOGIN;
    SendMessageToAllDMs(sMessage);
    Debug(sMessage);
    */
}

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Module Events -----

// ---< corpse_OnClientEnter >---
// This function is library and event registered on the module-level
//  OnClientEnter event.  This function ensures a PC is resurrected if
//  their corpse item was resurrected while logged out and ensure they
//  do not have corpse items in their inventory
void corpse_OnClientEnter();

// ---< corpse_OnClientLeave >---
// This function is library and event registered on the module-level
//  OnClientLeave event.  This function ensures a player does not log
//  out with a corpse item in their inventory.
void corpse_OnClientLeave();

// ---< corpse_OnPlayerDeath >---
// This function is library and event registered on the module-level
//  OnPlayerDeath event.  This function creates the PC corpse upon
//  player death.
void corpse_OnPlayerDeath();

// ----- Tag-based Scripting -----

// ---< corpse_pccorpseitem >---
// This function is library registered as a tag-based scripting function and
//  handles all actions required for use of the PC corpse item.
void corpse_pccorpseitem();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Module Events -----

void corpse_OnClientEnter()
{
    // TODO
    /*
    object oPC = GetEnteringObject();
    string sUniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    location lRessLoc = GetDatabaseLocation(sUniquePCID + H2_RESS_LOCATION);
    if (h2_GetIsLocationValid(lRessLoc))
        h2_PerformOffLineRessurectionLogin(oPC, lRessLoc);

    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetTag(oItem) == H2_PC_CORPSE_ITEM)
            DestroyObject(oItem);
        oItem = GetNextItemInInventory(oPC);
    }
    */
}

void corpse_OnClientLeave()
{
    object oPC = GetExitingObject();
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetTag(oItem) == H2_PC_CORPSE_ITEM)
        {
            location lLastDrop = GetLocalLocation(oItem, H2_LAST_DROP_LOCATION);
            object oNewToken = CopyObject(oItem, lLastDrop);
            h2_DropPlayerCorpse(oNewToken);
        }

        oItem = GetNextItemInInventory(oPC);
    }
}

void corpse_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    object oArea = GetArea(oPC);

    if (GetPlayerInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        return;

    if (GetLocalInt(oArea, H2_DO_NOT_CREATE_CORPSE_IN_AREA))
        return;
        
    if (!GetPlayerInt(oPC, H2_LOGIN_DEATH))
        h2_CreatePlayerCorpse(oPC);
}

void corpse_OnPlayerLives()
{
    object oPC = OBJECT_SELF;
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    
    object oDC = GetObjectByTag(H2_CORPSE_DC + uniquePCID);
    if (GetIsObjectValid(oDC))
    {
        object oItem = GetFirstItemInInventory(oDC);
        while (GetIsObjectValid(oItem))
        {
            DestroyObject(oItem);
            oItem = GetNextItemInInventory(oDC);
        }

        DestroyObject(oDC);        
    }

    object oDeadPlayer = GetObjectByTag(H2_CORPSE + uniquePCID);
    if (GetIsObjectValid(oDeadPlayer))
    {
        AssignCommand(oDeadPlayer, SetIsDestroyable(TRUE, FALSE));
        DestroyObject(oDeadPlayer);
    }

    int i;
    object oToken = GetObjectByTag(H2_CORPSE_TOKEN + uniquePCID, i++);
    while (GetIsObjectValid(oToken))
    {
        DestroyObject(oToken);
        oToken = GetObjectByTag(H2_CORPSE_TOKEN + uniquePCID, i++) ;
    }
}

// ----- Tag-based Scripting -----

void corpse_pccorpseitem()
{
    int nEvent = GetUserDefinedItemEventNumber();
    object oPC;
    object oItem;

    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
        h2_CorpseTokenActivatedOnNPC();
    else if (nEvent == X2_ITEM_EVENT_ACQUIRE)
    {
        oItem = GetModuleItemAcquired();
        h2_PickUpPlayerCorpse(oItem);
    }
    else if (nEvent == X2_ITEM_EVENT_UNACQUIRE)
    {
        oItem = GetModuleItemLost();
        object oPossessor = GetItemPossessor(oItem);
        if (oPossessor == OBJECT_INVALID)
            h2_DropPlayerCorpse(oItem);
        else if (GetObjectType(oPossessor) == OBJECT_TYPE_PLACEABLE)
        {
            oPC = GetModuleItemLostBy();
            CopyItem(oItem, oPC, TRUE);
            SendMessageToPC(oPC, H2_TEXT_CANNOT_PLACE_THERE);
            DestroyObject(oItem);
        }
    }
    else if (nEvent == X2_ITEM_EVENT_SPELLCAST_AT)
    {
        int spellID = GetSpellId();
        if (spellID == SPELL_RAISE_DEAD || spellID == SPELL_RESURRECTION)
        {
            h2_RaiseSpellCastOnCorpseToken(spellID);
            //Now abort the original spell script since the above handled it.
            SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
        }
    }
}
