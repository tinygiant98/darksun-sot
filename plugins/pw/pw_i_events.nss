// -----------------------------------------------------------------------------
//    File: pw_i_events.nss
//  System: PW Administration (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "x2_inc_switches"
#include "pw_i_core"
#include "core_i_constants"
#include "core_c_config"
#include "util_i_chat"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< pw_OnModuleLoad >---
void pw_OnModuleLoad();

// ---< pw_OnModuleHeartbeat >---
void pw_OnModuleHeartbeat();

// ---< pw_OnClientEnter >---
void pw_OnClientEnter();

// ---< pw_OnClientLeave >---
void pw_OnClientLeave();

// ---< pw_OnPlayerDying >---
void pw_OnPlayerDying();

// ---< pw_OnPlayerDeath >---
void pw_OnPlayerDeath();

// ---< pw_OnPlayerReSpawn >---
void pw_OnPlayerReSpawn();

// ---< pw_OnPlayerLevelUp >---
void pw_OnPlayerLevelUp();

// ---< pw_OnPlayerRest >---
void pw_OnPlayerRest();

// ---< pw_OnPlayerChat >---
// Controls the chat command system.  Determines if a passed chat line is an attempt
//  at a command and, if so, runs the appropraite events
void chat_OnPlayerChat();

// ---< pw_playerdataitem >---
// Tag based scripting for the player-data item.
void pw_playerdataitem();

// ---< pw_ExportPCs_OnTimerExpire >---
// Timer expiration event for exporting PCs.
void pw_ExportPCs_OnTimerExpire();

// ---< pw_SavePCLocation_OnTimerExpire >---
// Timer expiration event for saving PC location.
void pw_SavePCLocation_OnTimerExpire();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Module Events -----

void pw_OnModuleLoad()
{
    h2_SaveServerEpoch();
    h2_RestoreSavedCalendar();
    h2_SaveServerStartTime();
    h2_StartCharExportTimer();
    h2_StartSavePCLocationTimer();
}

void pw_OnModuleHeartbeat()
{
    if (H2_FORCE_CLOCK_UPDATE)
        SetTime(GetTimeHour(), GetTimeMinute(), GetTimeSecond(), GetTimeMillisecond());
    
    h2_SaveCurrentCalendar();
}

void pw_OnClientEnter()
{
    object oPC = GetEnteringObject();
    h2_CreatePlayerDataItem(oPC);

    int bIsDM = _GetIsDM(oPC);
    int iNameLength = GetStringLength(GetName(oPC));
    if (iNameLength > H2_MAX_LENGTH_PCNAME)
    {
        _SetLocalInt(oPC, LOGIN_BOOT, TRUE);
        h2_BootPlayer(oPC, H2_TEXT_PCNAME_TOO_LONG);
        return;
    }

    string sBannedByCDKey = GetDatabaseString(H2_BANNED_PREFIX + GetPCPublicCDKey(oPC));
    string sBannedByIPAddress = GetDatabaseString(H2_BANNED_PREFIX + GetPCIPAddress(oPC));
    
    if (sBannedByCDKey != "" || sBannedByIPAddress != "")
    {
        _SetLocalInt(oPC, LOGIN_BOOT, TRUE);
        h2_BootPlayer(oPC, H2_TEXT_YOU_ARE_BANNED);
        return;
    }

    if (!bIsDM && h2_MaximumPlayersReached())
    {
        _SetLocalInt(oPC, LOGIN_BOOT, TRUE);
        h2_BootPlayer(oPC, H2_TEXT_SERVER_IS_FULL, 10.0);
        return;
    }

    if (!bIsDM && _GetLocalInt(MODULE, H2_MODULE_LOCKED))
    {
        _SetLocalInt(oPC, LOGIN_BOOT, TRUE);
        h2_BootPlayer(oPC, H2_TEXT_MODULE_LOCKED, 10.0);
        return;
    }

    int iPlayerState = _GetLocalInt(oPC, H2_PLAYER_STATE);
    if (!bIsDM && iPlayerState == H2_PLAYER_STATE_RETIRED)
    {
        _SetLocalInt(oPC, LOGIN_BOOT, TRUE);
        h2_BootPlayer(oPC, H2_TEXT_RETIRED_PC_BOOT, 10.0);
        return;
    }

    if (!bIsDM && H2_REGISTERED_CHARACTERS_ALLOWED > 0 && !_GetLocalInt(oPC, H2_REGISTERED))
    {
        int registeredCharCount = GetDatabaseInt(GetPCPlayerName(oPC) + H2_REGISTERED_CHAR_SUFFIX);
        if (registeredCharCount >= H2_REGISTERED_CHARACTERS_ALLOWED)
        {
            _SetLocalInt(oPC, LOGIN_BOOT, TRUE);
            h2_BootPlayer(oPC, H2_TEXT_TOO_MANY_CHARS_BOOT, 10.0);
            return;
        }
    }
    
    _SetLocalString(oPC, H2_PC_PLAYER_NAME, GetPCPlayerName(oPC));
    _SetLocalString(oPC, H2_PC_CD_KEY, GetPCPublicCDKey(oPC));

    if (!bIsDM)
    {
        h2_SetPlayerID(oPC);
        h2_InitializePC(oPC);
    }

    string sTime = FormatSystemTime("h:mmtt on dddd, MMMM d, yyyy", GetSystemTime());
    string sMessage = "Today is " + sTime;
    SendMessageToPC(oPC, sMessage);
}

void pw_OnClientLeave()
{
    object oPC = GetExitingObject();

    if (_GetLocalInt(oPC, LOGIN_BOOT))
        return;

    if (!_GetIsDM(oPC))
        h2_SavePersistentPCData(oPC);
}

void pw_OnPlayerDying()
{
    object oPC = GetLastPlayerDying();
    if (_GetLocalInt(oPC, H2_PLAYER_STATE) != H2_PLAYER_STATE_DEAD)
        _SetLocalInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_DYING);
}

void pw_OnPlayerDeath()
{
    object oPC = GetLastPlayerDied();
    _SetLocalLocation(oPC, H2_LOCATION_LAST_DIED, GetLocation(oPC));
    _SetLocalInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_DEAD);
    h2_RemoveEffects(oPC);
    string deathLog = GetName(oPC) + "_" + GetPCPlayerName(oPC) + H2_TEXT_LOG_PLAYER_HAS_DIED;
    deathLog += GetName(GetLastHostileActor(oPC));
    if (_GetIsPC(GetLastHostileActor(oPC)))
        deathLog += "_" + GetPCPlayerName(GetLastHostileActor(oPC));
    deathLog += H2_TEXT_LOG_PLAYER_HAS_DIED2 + GetName(GetArea(oPC));
    Debug(deathLog);
    SendMessageToAllDMs(deathLog);
}

void pw_OnPlayerReSpawn()
{
    object oPC = GetLastRespawnButtonPresser();
    _SetLocalInt(oPC, H2_PLAYER_STATE, H2_PLAYER_STATE_ALIVE);
    RunEvent(H2_EVENT_ON_PLAYER_LIVES, oPC, oPC);
}

void pw_OnPlayerLevelUp()
{
    object oPC = GetPCLevellingUp();

    if (H2_EXPORT_CHARACTERS_INTERVAL > 0.0)
        ExportSingleCharacter(oPC);
}

void pw_OnPlayerRest()
{
    object oPC = GetLastPCRested();

    h2_SetAllowRest(oPC, TRUE);
    h2_SetAllowSpellRecovery(oPC, TRUE);
    h2_SetAllowFeatRecovery(oPC, TRUE);
    h2_SetPostRestHealAmount(oPC, GetMaxHitPoints(oPC));
}

void pw_OnPlayerRestStarted()
{
    // This function should be the last RestStarted function to run.
    //  Builders should build their procedure to set whether or not
    //  the PC is allowed to rest by setting h2_SetAllowRest (assumed
    //  true) and letting that permission to flow through to this function.
    // Specifically, do not use SetEventState to change the flow of the
    //  rest system ... allow this function to do that.
    // If you set h2_SetAllowRest to false, cancellation events will not run.

    object oPC = GetLastPCRested();

    if (h2_GetAllowRest(oPC) && !_GetLocalInt(oPC, H2_SKIP_REST_DIALOG) && H2_USE_REST_DIALOG)
        h2_OpenRestDialog(oPC);
    else if (!h2_GetAllowRest(oPC))
    {
        _SetLocalInt(oPC, H2_SKIP_CANCEL_REST, TRUE);
        AssignCommand(oPC, ClearAllActions());
        SendMessageToPC(oPC, H2_TEXT_REST_NOT_ALLOWED_HERE);
    }

    _DeleteLocalInt(oPC, H2_SKIP_REST_DIALOG);
}

void pw_OnPlayerRestCancelled()
{
    object oPC = GetLastPCRested();

    if (_GetLocalInt(oPC, H2_SKIP_CANCEL_REST))
        SetEventState(EVENT_STATE_ABORT);

    _DeleteLocalInt(oPC, H2_SKIP_CANCEL_REST);
}

void pw_OnPlayerRestFinished()
{
    object oPC = GetLastPCRested();

    if (H2_EXPORT_CHARACTERS_INTERVAL > 0.0)
        ExportSingleCharacter(oPC);
}

void pw_OnPlaceableHeartbeat()
{
    if (!GetIsObjectValid(GetFirstItemInInventory(OBJECT_SELF)))
        DestroyObject(OBJECT_SELF);
}

void pw_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    string sMessage = GetPCChatMessage();

    Notice("Running pw_OnPlayerChat");

    if (sMessage == "@")
        sMessage = "@get argument1 \"group 1\" [group 2] {group 3} <group 4> --kill --longOpt:longOptValue -s:shortOptValue -singles -x --int:3 argument2 --float:2.39f";

    if (ParseCommandLine(oPC, sMessage))
    {
        SetPCChatMessage();
        string sDes = GetChatDesignator(oPC);
        string sCmd = GetChatCommand(oPC);

        int nState = RunEvent(CHAT_PREFIX + sDes);
        if (!(nState & EVENT_STATE_DENIED))
            RunEvent(CHAT_PREFIX + sDes + sCmd);
    }
}

// ----- Tag-based Scripting -----

void pw_playerdataitem()
{
    int nEvent = GetUserDefinedItemEventNumber();

    // * This code runs when the Unique Power property of the item is used
    // * Note that this event fires PCs only
    if (nEvent ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC = GetItemActivator();
        _SetLocalObject(oPC, H2_PLAYER_DATA_ITEM_TARGET_OBJECT, GetItemActivatedTarget());
        _SetLocalLocation(oPC, H2_PLAYER_DATA_ITEM_TARGET_LOCATION, GetItemActivatedTargetLocation());
        //TODO conversation for playerdataitem?
        //AssignCommand(oPC, ActionStartConversation(oPC, H2_PLAYER_DATA_ITEM_CONV, TRUE, FALSE));
    }
}

// ----- Timer Events -----

void pw_ExportPCs_OnTimerExpire()
{
    ExportAllCharacters();
}

void pw_SavePCLocation_OnTimerExpire()
{
    object oPlayer, oModule = GetModule();
    int i, nCount = CountObjectList(GetModule(), PLAYER_ROSTER);

    for (i = 0; i < nCount; i++)
    {
        oPlayer = GetListObject(oModule, i, PLAYER_ROSTER);
        if (GetIsObjectValid(oPlayer) && _GetIsPC(oPlayer))
            h2_SavePCLocation(oPlayer);
    }
}
