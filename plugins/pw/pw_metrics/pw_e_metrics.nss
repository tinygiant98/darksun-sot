/// ----------------------------------------------------------------------------
/// @file   pw_e_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (events).
/// ----------------------------------------------------------------------------

#include "pw_c_metrics"
#include "pw_i_metrics"

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

    /// @note There are several module-wide metrics schema that we will use to
    ///     track overall player, character and server metrics.  Ensure these
    ///     are registered.
    metrics_RegisterSchemas();
}

void metrics_OnClientEnter()
{
    /// @todo ensure eventman drops this event if the entering object is not a pc!

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

void metrics_Sync_OnTimerExpire()
{
    metrics_SyncModuleBuffer(METRICS_SYNC_CHUNK_SIZE);
}
