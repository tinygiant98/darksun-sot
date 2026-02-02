/// ----------------------------------------------------------------------------
/// @file   pw_p_core.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Persistent World Administration (plugin).
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_argstack"
#include "core_i_framework"
#include "pw_e_core"

/// @brief Library function to set character state.
/// @note Before calling this function, the following values must be
///     pushed onto the argument stack:
///         oPC (object) - The player-character object whose state is to be changed.
///         nDesiredState (int) - The desired character state PW_CHARACTER_STATE_*.
/// @note This function pushes the following value onto the argument stack:
///         nCurrentState (int) - The current state of the player-character object
///             after nDesiredState has been applied.
/// @warning Calling functions must use PopInt() to retrieve the current state in
///     order to clear the argument stack.
/// @returns The current character state, or PW_CHARACTER_STATE_ERROR on error.
void SetCharacterState()
{
    object oPC = PopObject();
    if (!GetIsObjectValid(oPC) || GetIsDM(oPC))
    {
        PushInt(PW_CHARACTER_STATE_ERROR);
        return;
    }

    int nDesiredState = PopInt();
    if (nDesiredState < PW_CHARACTER_STATE_ALIVE || nDesiredState > PW_CHARACTER_STATE_STABLE)
    {
        PushInt(PW_CHARACTER_STATE_ERROR);
        return;
    }

    PushInt(pw_SetCharacterState(oPC, nDesiredState));
}

/// @brief Library function to retrieve a character state.
/// @note Before calling this function, the following value must be
///     pushed onto the argument stack:
///         oPC (object) - The player-character object whose state is to be retrieved.
/// @note This function pushes the following value onto the argument stack:
///         nCurrentState (int) - The current state of the player-character object.
/// @warning Calling functions must use PopInt() to retrieve the current state in
///     order to clear the argument stack.
/// @returns The current character state, or PW_CHARACTER_STATE_ERROR on error.
void GetCharacterState()
{
    object oPC = PopObject();
    if (!GetIsObjectValid(oPC) || GetIsDM(oPC))
    {
        PushInt(PW_CHARACTER_STATE_ERROR);
        return;
    }

    PushInt(pw_GetCharacterState(oPC));
}

// -----------------------------------------------------------------------------
//                           Library Definition
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("pw"))
    {
        object oPlugin = CreatePlugin("pw");
        SetName(oPlugin, "[Plugin] PW :: Core");
        SetDescription(oPlugin,
            "This plugin controls basic functions of the persistent world system.");
        SetDebugPrefix(HexColorString("[PW]", COLOR_BLUE_SLATE_MEDIUM));

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,          "pw_OnClientEnter",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE,          "pw_OnClientLeave",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_HEARTBEAT,             "pw_OnModuleHeartbeat",     10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,           "pw_OnModuleLoad",          10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,          "pw_OnPlayerDeath",         10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,          "pw_OnPlayerDying",         9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP,       "pw_OnPlayerLevelUp",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,        "pw_OnPlayerReSpawn",       10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST,           "pw_OnPlayerRest",          EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_STARTED,   "pw_OnPlayerRestStarted",   EVENT_PRIORITY_LAST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_CANCELLED, "pw_OnPlayerRestCancelled", 10.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST_FINISHED,  "pw_OnPlayerRestFinished",  10.0);

        RegisterEventScript(oPlugin, H2_SAVE_LOCATION_ON_TIMER_EXPIRE, "pw_SavePCLocation_OnTimerExpire", 10.0);
        RegisterEventScript(oPlugin, H2_EXPORT_CHAR_ON_TIMER_EXPIRE,   "pw_ExportPCs_OnTimerExpire",      10.0);

        int n;
        RegisterLibraryScript("pw_OnClientEnter",         n++);
        RegisterLibraryScript("pw_OnClientLeave",         n++);
        RegisterLibraryScript("pw_OnModuleHeartbeat",     n++);
        RegisterLibraryScript("pw_OnModuleLoad",          n++);
        RegisterLibraryScript("pw_OnPlayerDeath",         n++);
        RegisterLibraryScript("pw_OnPlayerDying",         n++);
        RegisterLibraryScript("pw_OnPlayerLevelUp",       n++);
        RegisterLibraryScript("pw_OnPlayerReSpawn",       n++);
        RegisterLibraryScript("pw_OnPlayerRest",          n++);
        RegisterLibraryScript("pw_OnPlayerRestStarted",   n++);
        RegisterLibraryScript("pw_OnPlayerRestCancelled", n++);
        RegisterLibraryScript("pw_OnPlayerRestFinished",  n++);

        n = 100;
        RegisterLibraryScript("pw_SavePCLocation_OnTimerExpire", n++);
        RegisterLibraryScript("pw_ExportPCs_OnTimerExpire",      n++);

        n = 200;
        RegisterLibraryScript("SetCharacterState", n++);
        RegisterLibraryScript("GetCharacterState", n++);

        LoadLibrariesByPattern("pw_p_*");
    }
}

// -----------------------------------------------------------------------------
//                           Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) pw_OnClientEnter();
            else if (nEntry == n++) pw_OnClientLeave();
            else if (nEntry == n++) pw_OnModuleHeartbeat();
            else if (nEntry == n++) pw_OnModuleLoad();
            else if (nEntry == n++) pw_OnPlayerDeath();
            else if (nEntry == n++) pw_OnPlayerDying();
            else if (nEntry == n++) pw_OnPlayerLevelUp();
            else if (nEntry == n++) pw_OnPlayerReSpawn();
            else if (nEntry == n++) pw_OnPlayerRest();
            else if (nEntry == n++) pw_OnPlayerRestStarted();
            else if (nEntry == n++) pw_OnPlayerRestCancelled();
            else if (nEntry == n++) pw_OnPlayerRestFinished();
        } break;

        case 100:
        {
            if      (nEntry == n++) pw_SavePCLocation_OnTimerExpire();
            else if (nEntry == n++) pw_ExportPCs_OnTimerExpire();
        } break;

        case 200:
        {
            if      (nEntry == n++) SetCharacterState();
            else if (nEntry == n++) GetCharacterState();
        }

        default: CriticalError("[" + __FILE__ + "]: Library function " + sScript + " not found; nEntry = " + IntToString(nEntry) + ")");
    }
}
