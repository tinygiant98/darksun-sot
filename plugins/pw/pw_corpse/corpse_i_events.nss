// -----------------------------------------------------------------------------
//    File: corpse_i_events.nss
//  System: PC Corpse (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "corpse_i_main"

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
