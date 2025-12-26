/// ----------------------------------------------------------------------------
/// @file   pw_e_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (events).
/// ----------------------------------------------------------------------------

#include "pw_c_metrics"
#include "pw_i_metrics"

#include "chat_i_main"

#include "core_i_framework"

// -----------------------------------------------------------------------------
//                        Event Function Prototypes
// -----------------------------------------------------------------------------

/// @note Generally, convenience functions should be used to provide metrics to
///     the system, however, if necessary, a metrics skeleton object can be
///     retrieved for a player, character or server metric and use to manually
///     populate and submit metrics data.

/// @brief Retrieve a player metrics schema skeleton object.
json metrics_GetPlayerObject();

/// @brief Retrieve a character metrics schema skeleton object.
json metrics_GetCharacterObject();

/// @brief Retrieve a server metrics schema skeleton object.
json metrics_GetServerObject();

// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

/// @private 
void metrics_OnModuleLoad()
{
    /// @note Ensure all required metrics tables exist, both on disk and in the
    ///     module's volatile sqlite database.
    metrics_CreateTables();

    /// @note Metrics syncs occur on a specified interval.
    metrics_StartSyncTimer();
}

void metrics_OnClientEnter()
{
    object oPC = GetEnteringObject();

}

void metrics_OnClientLeave()
{

}


void metrics_OnPlayerDeath()
{

}

void metrics_OnPlayerReSpawn()
{

}

void metrics_OnPlayerLevelUp()
{

}

void metrics_OnPlayerRestFinished()
{

}

void metrics_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    if (HasChatOption(oPC, "testSync"))
        metrics_PowerOnSelfTest();
}

void metrics_Sync_OnTimerExpire()
{
    Notice("Metrics Sync Timer Expired.  Syncing metrics data...");


    metrics_SyncBuffer(METRICS_SYNC_CHUNK_SIZE);
}

void metrics_OnModulePOST()
{
    metrics_PowerOnSelfTest();
}