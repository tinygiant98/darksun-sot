
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_HEARTBEAT, "x2_c2_gcube_hbt:last");
    ExecuteScript("hook_creature07", OBJECT_SELF);
}
