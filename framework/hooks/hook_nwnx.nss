// -----------------------------------------------------------------------------
//    File: hook_nwnx.nss
//  System: Core Framework (event script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// Trigger OnUserDefined event script. Place this script on the OnUserDefined
// event under Trigger Properties.
// -----------------------------------------------------------------------------

#include "core_i_framework"
#include "nwnx_events"

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();
    
    Notice("Ping from NWNX Events:  " + sEvent);
    RunEvent(sEvent);
}
