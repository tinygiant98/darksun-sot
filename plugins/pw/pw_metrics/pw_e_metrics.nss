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
}

void metrics_OnClientEnter()
{
    object oPC = GetEnteringObject();

    /// @note No need to run the sync timer when there are no players in the
    ///     module.
    if (!metrics_IsFlushTimerValid())
        metrics_StartFlushTimer();
}

void metrics_OnClientLeave()
{
    /// If no players remaining, flush the entire sync buffer (since there's no other
    ///     processing going on), then stop the timer.

    /// Q: Will GetFirstPC() return a valid object because the player logging out is
    ///     still "present"?  If so, ignore that, maybe if GetFirstPC() == oLeavingObject, and
    ///     no other characters are available.

    object oExiting = GetExitingObject();
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC))
    {
        if (oPC != oExiting)
            return;

        oPC = GetNextPC();
    }

    int nBuffer = metrics_GetBufferSize();
    if (nBuffer > 0)
        metrics_FlushBuffer(nBuffer);

    metrics_StopFlushTimer();
}

void metrics_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    if (HasChatOption(oPC, "testSync"))
        metrics_POST();
}

void metrics_Flush_OnTimerExpire()
{
    Notice("Metrics Sync Timer Expired.  Syncing metrics data...");


    metrics_FlushBuffer(METRICS_FLUSH_CHUNK_SIZE);
}

void metrics_OnModulePOST()
{
    metrics_POST();
}