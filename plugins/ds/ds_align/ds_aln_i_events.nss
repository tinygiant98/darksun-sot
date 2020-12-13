// -----------------------------------------------------------------------------
//    File: ds_align_i_events.nss
//  System: Alignment System
// -----------------------------------------------------------------------------
// Description:
//  Event functions for DS Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
//
#include "ds_aln_i_main"
// al_OnEnterArea() Runs when the PC gets into an area.  
//         TODO - Sets an alignment set of
// variables so that the Alignment system doesn't run away with the PC's alignment
void al_OnEnterArea();

// -------------------------------------------------------------------------------
// Function Definitions
// -------------------------------------------------------------------------------
void al_OnEnterArea();
{
    object oPC = GetEnteringObject();

    if (!_GetIsPC(oPC))
        return;

    Notice("In the al_OnEnterArea Script");
}
