// -----------------------------------------------------------------------------
//    File: hook_trigger04.nss
//  System: Core Framework (event script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// Trigger OnHeartbeat event script. Place this script on the OnHeartbeat event
// under Trigger Properties.
// -----------------------------------------------------------------------------

#include "pw_k_rest"
#include "core_i_framework"

void main()
{
    RunEvent(REST_EVENT_ON_TRIGGER_HEARTBEAT);
}
