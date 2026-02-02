/// ----------------------------------------------------------------------------
/// @file   hcr_i_corpse.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Corpse System (core).
/// ----------------------------------------------------------------------------

/// @todo get rid of x2_inc_switch
/// @todo maybe get rid of x0_i0_position?
///     These scripts over overridable by user-provided scripts, so they may
///     created unintended consequences if used in the corpse system.

#include "x2_inc_switches"
#include "x0_i0_position"

#include "hcr_c_corpse"
#include "pw_i_core"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

/// @todo Move all these variables to a single json object?  Easier to delete/manage?

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
//                        System Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Move a dead character's corpse copy and clean up the death corpse
///     container whenever oCorpseToken is picked up by a PC.
/// @param oCorpseToken The corpse token item being picked up.
void corpse_PickUpCorpse(object oCorpseToken);

/// @brief Move a dead character's corpse copy and create the death corpse
///     container whenever oCorpseToken is dropped by a PC.
/// @param oCorpseToken The corpse token item being dropped.
void corpse_DropCorpse(object oCorpseToken);

/// @brief Handles the creation of the corpse copy of oPC, creation of the death
///     corpse container, and the token item used to move the corpse copy around by
///     other players when a character dies.
/// @param oPC The player character that has died.
void corpse_CreateCorpse(object oPC);

/// @brief Handle raising or ressurrection of a player character when a corpse
///     token is activated on an NPC target.
void h2_CorpseTokenActivatedOnNPC();

/// @brief Returns the amount of XP that should be lost based on the level of the
///     character being raised or ressurected.
/// @param oPC The player character being raised or ressurected.
int h2_XPLostForRessurection(object oPC);

/// @brief Returns the smount of GP that should be lost based on the level of the
///     raised PC.
/// @param oCaster The character casting the raise or ressurection spell.
/// @param nSpellID The spell being cast (SPELL_RAISE_DEAD or SPELL_RESURRECTION).
int h2_GoldCostForRessurection(object oCaster, int nSpellID);

/// @brief Handles all functions required when a player or DM casts a raise spell
///     on a dead player's corpse token.
/// @param nSpellID The spell being cast (SPELL_RAISE_DEAD or SPELL_RESURRECTION).
/// @param oToken (Optional) The corpse token item being targeted by the spell.  If
///     not proviced, the spell target object will be used.
void h2_RaiseSpellCastOnCorpseToken(int nSpellID, object oToken = OBJECT_INVALID);

/// @brief Sets variables required for a logged out player to be raised or
///     resurrected on their next login, simluating that the player had been
///     logged in when the raise or ressurection occurred.
/// @param oPC The player character being raised or ressurected.
/// @param l The location where the player will be placed on their next login.
void h2_PerformOffLineRessurectionLogin(object oPC, location l);

// -----------------------------------------------------------------------------
//                        Private Function Definitions
// -----------------------------------------------------------------------------

void corpse_PickUpCorpse(object oCorpseToken)
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

void corpse_DropCorpse(object oCorpseToken)
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

void corpse_CreateCorpse(object oPC)
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

        /// @todo change this to a framework event.
        SignalEvent(oTarget, EventUserDefined(H2_PCCORPSE_ITEM_ACTIVATED_EVENT_NUMBER));
    }
}

int h2_XPLostForRessurection(object oPC)
{
    int xplevel = 0;

    int i; for (i = 1; i < GetHitDice(oPC); i++)
    {
        xplevel = xplevel + 1000 * (i - 1);
    }

    xplevel = xplevel + 500 * (i - 1);
    return GetXP(oPC) - xplevel;
}

int h2_GoldCostForRessurection(object oCaster, int nSpellID)
{
    if (nSpellID == SPELL_RAISE_DEAD)
    {
        if (GetGold(oCaster) < H2_GOLD_COST_FOR_RAISE_DEAD)
            return 0;
        return H2_GOLD_COST_FOR_RAISE_DEAD;
    }
    else if (nSpellID == SPELL_RESURRECTION)
    {
        if (GetGold(oCaster) < H2_GOLD_COST_FOR_RESSURECTION)
            return 0;
        return H2_GOLD_COST_FOR_RESSURECTION;
    }

    return -1;
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
        if (!H2_CORPSE_ALLOW_PLAYER_RESSURECTION && _GetIsPC(oPC))
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
            /// @todo pretty sure you can give -xp.  Likely have to use SetXP.
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
        pw_SetCharacterState(oPC, PW_CHARACTER_STATE_ALIVE);
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
void h2_PerformOffLineRessurectionLogin(object oPC, location l)
{
    // TODO
    /*
    string uniquePCID = GetPlayerString(oPC, H2_UNIQUE_PC_ID);
    DeleteDatabaseVariable(uniquePCID + H2_RESS_LOCATION);
    pw_SetCharacterState(oPC, PW_CHARACTER_STATE_ALIVE);
    SendMessageToPC(oPC, H2_TEXT_YOU_HAVE_BEEN_RESSURECTED);
    DelayCommand(H2_CLIENT_ENTER_JUMP_DELAY, AssignCommand(oPC, JumpToLocation(l)));
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
//                        Event Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Check if the entering player has a pending offline ressurection
///     and perform it.  Also ensure the player does not have any corpse
///     items in their inventory.
void corpse_OnClientEnter();

/// @brief Prevent leaving players from keeping corpse items in their
///     inventory while offline.  Any corpse items found are dropped
///     at the leaving player's last location.
void corpse_OnClientLeave();

/// @brief Create the player corpse system elements when a player dies.
void corpse_OnPlayerDeath();

/// @brief Event handler for when a player is resurrected.  Cleans up any
///     remaining corpse system elements for the resurrected player.
void corpse_OnPlayerLives();

/// @brief Tag-based scripting function for the PC corpse item.
void corpse_pccorpseitem();

// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

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
            corpse_DropCorpse(oNewToken);
        }

        oItem = GetNextItemInInventory(oPC);
    }
}

void corpse_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    object oArea = GetArea(oPC);

    if (pw_GetCharacterState(oPC) != PW_CHARACTER_STATE_DEAD)
        return;

    if (GetLocalInt(oArea, H2_DO_NOT_CREATE_CORPSE_IN_AREA))
        return;
        
    if (!GetPlayerInt(oPC, H2_LOGIN_DEATH))
        corpse_CreateCorpse(oPC);
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
        corpse_PickUpCorpse(oItem);
    }
    else if (nEvent == X2_ITEM_EVENT_UNACQUIRE)
    {
        oItem = GetModuleItemLost();
        object oPossessor = GetItemPossessor(oItem);
        if (oPossessor == OBJECT_INVALID)
            corpse_DropCorpse(oItem);
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
        int nSpellID = GetSpellId();
        if (nSpellID == SPELL_RAISE_DEAD || nSpellID == SPELL_RESURRECTION)
        {
            h2_RaiseSpellCastOnCorpseToken(nSpellID);
            //Now abort the original spell script since the above handled it.
            SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
        }
    }
}
