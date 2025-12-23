/// ----------------------------------------------------------------------------
/// @file   pw_e_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (events).
/// ----------------------------------------------------------------------------

#include "pw_i_audit"

// -----------------------------------------------------------------------------
//                        Event Function Prototypes
// -----------------------------------------------------------------------------

/// @note Generally, convenience functions should be used to provide metrics to
///     the system, however, if necessary, a metrics skeleton object can be
///     retrieved for a player, character or server metric and use to manually
///     populate and submit metrics data.

/// @brief Retrieve a player metrics schema skeleton object.
json audit_GetPlayerObject();

/// @brief Retrieve a character metrics schema skeleton object.
json audit_GetCharacterObject();

/// @brief Retrieve a server metrics schema skeleton object.
json audit_GetServerObject();

// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

/// @private 
void audit_OnModuleLoad()
{
    /// @note Ensure all required metrics tables exist, both on disk and in the
    ///     module's volatile sqlite database.
    audit_CreateTables();
    /// @note There are several module-wide metrics schema that we will use to
    ///     track overall player, character and server metrics.  Ensure these
    ///     are registered.
    audit_RegisterSchemas();
}

void audit_OnClientEnter()
{
    /// @todo ensure eventman drops this event if the entering object is not a pc!

    object oPC = GetEnteringObject();

}

void audit_OnClientLeave()
{

}


void audit_OnPlayerDeath()
{

}

void audit_OnPlayerReSpawn()
{

}

void audit_OnPlayerLevelUp()
{

}

void audit_OnPlayerRestFinished()
{

}

void audit_Sync_OnTimerExpire()
{
    audit_SyncModuleBuffer(AUDIT_SYNC_CHUNK_SIZE);
}
