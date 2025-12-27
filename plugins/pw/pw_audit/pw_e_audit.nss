/// ----------------------------------------------------------------------------
/// @file   pw_e_audit.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Audit System (events).
/// ----------------------------------------------------------------------------

#include "pw_i_audit"

// -----------------------------------------------------------------------------
//                        Event Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                        Event Function Definitions
// -----------------------------------------------------------------------------

/// @private
void audit_OnModuleLoad()
{
    /// @note Ensure all required metrics tables exist, both on disk and in the
    ///     module's volatile sqlite database.
    audit_CreateTables();
}

void audit_OnClientEnter()
{
    object oPC = GetEnteringObject();

    /// @note No need to run the sync timer when there are no players in the
    ///     module.
    if (!audit_IsFlushTimerValid())
        audit_StartFlushTimer();
}

void audit_OnClientLeave()
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

    int nBuffer = audit_GetBufferSize();
    if (nBuffer > 0)
    {
        Debug("[AUDIT] No players remaining in module. Flushing " + IntToString(nBuffer) + " audit records from buffer to persistent storage.");
        audit_FlushBuffer(nBuffer);
    }

    audit_StopFlushTimer();
}

void audit_Flush_OnTimerExpire()
{
    audit_FlushBuffer(AUDIT_FLUSH_CHUNK_SIZE);
}
