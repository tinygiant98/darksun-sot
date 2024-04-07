/// -----------------------------------------------------------------------------
/// @file:  hcr_i_corpse.nss
/// @brief: HCR2 Corpse Token System (core)
/// -----------------------------------------------------------------------------

#include "util_i_data"
#include "core_i_framework"
#include "hcr_c_corpse"
#include "hcr_i_core"
#include "x0_i0_position"
#include "x2_inc_switches"

// -----------------------------------------------------------------------------
//                         Variable Name Constants
// -----------------------------------------------------------------------------

// Item Tags
const string H2_PC_CORPSE_ITEM = "h2_pccorpseitem";
const string H2_DEATH_CORPSE = "h2_deathcorpse";
const string H2_DEATH_CORPSE2 = "h2_deathcorpse2";

// Variable Names
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

/// @brief This function handles moving a dead player-charcter's corpse token
///     into another player's inventory and cleaning up the corpse token's
///     container.
/// @param oCorpseToken The corpse token being picked up.
void h2_PickUpPlayerCorpse(object oCorpseToken);

/// @brief This function handles dropping a dead player-character's corpse token
///     from another player's inventory and creating the corpse token's
///     inventory container.
/// @param oCorpseToken The corpse token being dropped.
void h2_DropPlayerCorpse(object oCorpseToken);

/// @brief This function handles creating a corpse token of a dead player-charcter,
///     creating the corpse token inventory container.
/// @param oPC Player-character to create the corpse token for.
void h2_CreatePlayerCorpse(object oPC);

/// @brief This function handles using a corpse token on a healing NPC.
void h2_CorpseTokenActivatedOnNPC();

/// @brief Determines the amount of XP that a resurrected player-charcter should suffer
///     after being successfully resurrected by a healing NPC or another PC.
/// @param oRaisedPC Player-character being resurrected.
/// @returns The amount of XP the resurrected character will lose.
int h2_XPLostForRessurection(object oRaisedPC);

/// @brief Determines the amount of gold that a player-character must pay in
///     order to raise or resurrect another player via the corpse token system.
/// @param oCaster Player-character casting a raise or resurrect spell.
/// @param nSpellID Spell ID of the cast spell.
/// @returns The amount of GP the casting character will lose.
int h2_GoldCostForRessurection(object oCaster, int nSpellID);

/// @brief Handles all functions required when a player or DM casts a raise or
///     resurrect spell on a dead player-character.
/// @param nSpellID Spell ID of the cast spell.
/// @param oToken Corpose token of the player-character to be raised or resurrected.
///     If oToken is not passed, the spell target will be used instead.
void h2_RaiseSpellCastOnCorpseToken(int nSpellID, object oToken = OBJECT_INVALID);

/// @brief Handles all functions required to raise or resurrect a player that
///     is not currently logged in to the server (offline resurrection).  This
///     function sets the appropriate variables which will cause the desired
///     outcome the next time the player logs into the server.
/// @param oPC Player-character to be resurrected.
/// @param l Location the player-character will be transported to when raised or
///     resurrected.
void h2_PerformOffLineRessurectionLogin(object oPC, location l);

/// @brief Event script for the module-level OnClientEnter event.  Performs
///     raise/resurrection if the player was marked for offline resurrection and
///     ensure entering characters do not have corpse tokens in their inventory.
void corpse_OnClientEnter();

/// @brief Event script for the module-level OnClientLeave event.  Ensures
///     leaving characters do not have corpse tokens in ther inventory.
void corpse_OnClientLeave();

/// @brief Event script for the module-level OnPlayerDeath event.  Creates the
///     corpse token upon a player-character's death.
void corpse_OnPlayerDeath();

/// @brief Tag-based script for pc corpse token item functions.
void corpse_pccorpseitem();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_PickUpPlayerCorpse(object oCorpseToken)
{
    string sPCID = GetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID);
    object oDC = GetObjectByTag(H2_CORPSE + sPCID);

    if (GetIsObjectValid(oDC))
    {
        AssignCommand(oDC, SetIsDestroyable(TRUE, FALSE));
        DestroyObject(oDC);
    }
}

void h2_DropPlayerCorpse(object oCorpseToken)
{
    string sPCID = GetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID);
    object oDeathCorpse, oDC = GetObjectByTag(H2_CORPSE + sPCID);

    if (GetIsObjectValid(oDC))
    {
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
    string sPCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    
    object oDC = GetObjectByTag(H2_CORPSE_DC + sPCID);
    if (GetIsObjectValid(oDC))
        return;

    object oDeadPlayer = GetObjectByTag(H2_CORPSE + sPCID);
    if (GetIsObjectValid(oDeadPlayer))
        return;

    location loc = GetPlayerLocation(oPC, H2_LOCATION_LAST_DIED);
    oDeadPlayer = CopyObject(oPC, loc, OBJECT_INVALID, H2_CORPSE + sPCID);
    SetName(oDeadPlayer, H2_TEXT_CORPSE_OF + GetName(oPC));
    ChangeToStandardFaction(oDeadPlayer, STANDARD_FACTION_COMMONER);
    // remove gold, inventory & equipped items from dead player corpse copy
    h2_DestroyNonDroppableItemsInInventory(oDeadPlayer);
    h2_MovePossessorInventory(oDeadPlayer, TRUE);
    h2_MoveEquippedItems(oDeadPlayer);
    AssignCommand(oDeadPlayer, SetIsDestroyable(FALSE, FALSE));
    AssignCommand(oDeadPlayer, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oDeadPlayer));
    object oDeathCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, H2_DEATH_CORPSE, GetLocation(oDeadPlayer), FALSE, H2_CORPSE_DC + sPCID);
    object oCorpseToken = CreateItemOnObject(H2_PC_CORPSE_ITEM, oDeathCorpse, 1, H2_CORPSE_TOKEN + sPCID);
    SetName(oCorpseToken, H2_TEXT_CORPSE_OF + GetName(oPC));
    SetName(oDeathCorpse, GetName(oCorpseToken));
    SetLocalLocation(oCorpseToken, H2_LAST_DROP_LOCATION, GetLocation(oDeathCorpse));
    SetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID, sPCID);
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
    int i, nXP = 0;

    for (i = 1; i < GetHitDice(oRaisedPC); i++)
        nXP = nXP + 1000 * (i - 1);

    return GetXP(oRaisedPC) - (nXP + 500 * (i - 1));
}

int h2_GoldCostForRessurection(object oCaster, int nSpellID)
{
    if (nSpellID == SPELL_RAISE_DEAD)
    {
        if (GetGold(oCaster) < abs(H2_GOLD_COST_FOR_RAISE_DEAD))
            return 0;
        return abs(H2_GOLD_COST_FOR_RAISE_DEAD);
    }
    else
    {
        if (GetGold(oCaster) < abs(H2_GOLD_COST_FOR_RESSURECTION))
            return 0;
        return abs(H2_GOLD_COST_FOR_RESSURECTION);
    }
}

void h2_RaiseSpellCastOnCorpseToken(int nSpellID, object oToken = OBJECT_INVALID)
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
            int goldCost = h2_GoldCostForRessurection(oCaster, nSpellID);
            if (goldCost <= 0)
            {
                SendMessageToPC(oCaster, H2_TEXT_NOT_ENOUGH_GOLD);
                return;
            }
            else
                TakeGoldFromCreature(goldCost, oCaster, TRUE);
        }

        if (nSpellID == SPELL_RAISE_DEAD)
        {
            int nHP = GetCurrentHitPoints(oPC);
            if (nHP > GetHitDice(oPC))
            {
                effect eDam = EffectDamage(nHP - GetHitDice(oPC));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oPC);
            }
        }
        else
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oPC)), oPC);
        
        if (H2_APPLY_XP_LOSS_FOR_RESS)
            GiveXPToCreature(oPC, -h2_XPLostForRessurection(oPC));
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
        SendMessageToPC(oCaster, H2_TEXT_OFFLINE_RESS_CASTER_FEEDBACK);
        SetPersistentLocation(uniquePCID + H2_RESS_LOCATION, castLoc, H2_VARIABLE_TAG);

        if (_GetIsDM(oCaster))
            SetPersistentInt(uniquePCID + H2_RESS_BY_DM, TRUE, H2_VARIABLE_TAG);
        sMessage += H2_TEXT_OFFLINE_PLAYER + " " + IntToString(GetPersistentInt(uniquePCID, H2_VARIABLE_TAG));
    }
    SendMessageToAllDMs(sMessage);
    Debug(sMessage);
}

void h2_PerformOffLineRessurectionLogin(object oPC, location l)
{
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    DeletePersistentLocation(uniquePCID + H2_RESS_LOCATION, H2_VARIABLE_TAG);
    SetPlayerInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    SendMessageToPC(oPC, H2_TEXT_YOU_HAVE_BEEN_RESSURECTED);
    DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, AssignCommand(oPC, JumpToLocation(l)));
    if (H2_APPLY_XP_LOSS_FOR_RESS && !GetPersistentInt(uniquePCID + H2_RESS_BY_DM, H2_VARIABLE_TAG))
    {
        int lostXP = h2_XPLostForRessurection(oPC);
        GiveXPToCreature(oPC, -lostXP);
    }
    
    DeletePersistentInt(uniquePCID + H2_RESS_BY_DM, H2_VARIABLE_TAG);
    string sMessage = GetName(oPC) + "_" + GetPCPlayerName(oPC) + H2_TEXT_OFFLINE_RESS_LOGIN;
    SendMessageToAllDMs(sMessage);
    Debug(sMessage);
}

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void corpse_OnClientEnter()
{
    object oPC = GetEnteringObject();
    string sUniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    location lRessLoc = GetPersistentLocation(sUniquePCID + H2_RESS_LOCATION, H2_VARIABLE_TAG);
    if (h2_GetIsLocationValid(lRessLoc))
        h2_PerformOffLineRessurectionLogin(oPC, lRessLoc);

    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetTag(oItem) == H2_PC_CORPSE_ITEM)
            DestroyObject(oItem);
        oItem = GetNextItemInInventory(oPC);
    }
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
