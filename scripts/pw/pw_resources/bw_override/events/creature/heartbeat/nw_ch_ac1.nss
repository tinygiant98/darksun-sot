
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_HEARTBEAT, "nw_ch_ac1:last");
    ExecuteScript("hook_creature07", OBJECT_SELF);
}
