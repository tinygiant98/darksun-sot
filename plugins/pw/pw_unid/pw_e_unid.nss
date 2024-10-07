// -----------------------------------------------------------------------------
//    File: pw_e_unid.nss
//  System: UnID Item on Drop (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "pw_i_unid"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< unid_OnUacquireItem >---
// Wrapper function for module-level OnUnacquireItem event.  This function is
//  registered as a library function and an event function in unid_l_plugin.
void unid_OnUacquireItem();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void unid_OnUnacquireItem()
{
    h2_UnIDOnDrop(GetModuleItemLost());
}
