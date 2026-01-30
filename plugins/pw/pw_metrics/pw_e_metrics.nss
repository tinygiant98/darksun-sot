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

}

void metrics_OnClientLeave()
{
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

void metrics_OnPlayerDeleted()
{
    string sUUID = GetObjectUUID(OBJECT_SELF);
    string s = r"
        DELETE FROM player_metrics
        WHERE player_id = :player_id;
    ";
    sqlquery q = pw_PrepareCampaignQuery(s);
    SqlBindString(q, ":player_id", sUUID);
    SqlStep(q);
}
