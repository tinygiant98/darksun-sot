// -----------------------------------------------------------------------------
//    File: hook_aoe03.nss
//  System: Core Framework (event script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// AOE OnExit event script.
// -----------------------------------------------------------------------------

#include "core_i_framework"

void main()
{
    object oPC = GetExitingObject();

    if (GetIsPC(oPC))
        RemoveListObject(OBJECT_SELF, oPC, AOE_ROSTER);

    RunEvent(AOE_EVENT_ON_EXIT, oPC);
}
