/// ----------------------------------------------------------------------------
/// @file   pw_e_eventman.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Event Manager (events).
/// ----------------------------------------------------------------------------

#include "core_i_framework"
#include "pw_i_eventman"

// -----------------------------------------------------------------------------
//                        Event Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

/// eventman is for really big picture stuff that affects multiple systems, like
///     always checking that OnClientEnter is a PC, etc.
/// Maybe on module heartbeat, if there are no players, do nothing!

void eventman_OnModuleLoad()
{

}

void eventman_OnClientEnter()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC))
        SetEventState(EVENT_STATE_ABORT);
}

void eventman_OnClientLeave()
{
    object oPC = GetExitingObject();
    if (!GetIsPC(oPC))
        SetEventState(EVENT_STATE_ABORT);
}

void eventman_OnPlayerDeath()
{

}

void eventman_OnPlayerReSpawn()
{

}

void eventman_OnPlayerLevelUp()
{

}

void eventman_OnPlayerRestFinished()
{

}

void eventman_Sync_OnTimerExpire()
{
}
