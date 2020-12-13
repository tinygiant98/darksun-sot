// -----------------------------------------------------------------------------
//    File: ds_align_l_plugin.nss
//  System: Alignment System
// -----------------------------------------------------------------------------
// Description:
//  Library functions for DS Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------
// Jacyn - 2020-12-13  -Added the Registration for the OnEnterArea Handler
// -----------------------------------------------------------------------------
#include "util_i_library"
#include "core_i_framework"
#include "ds_aln_i_events"
// -----------------------------------------------------------------------------
// Library Dispatch
// -----------------------------------------------------------------------------
void OnLibraryLoad() 
{
    if (!USE_ALIGN_SYSTEM)
        return;

    object oPlugin = GetPlugin("ds");
    // ----- Module Events -----
    // No priority needed here.
    RegisterEventScripts(oPlugin, AREA_EVENT_ON_ENTER, "al_OnEnterArea");
    // ----- Module Scripts -----
    RegisterLibraryScript("al_OnEnterArea", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: al_OnEnterArea(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}