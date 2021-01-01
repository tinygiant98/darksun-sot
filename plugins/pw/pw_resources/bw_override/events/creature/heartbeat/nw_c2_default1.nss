
#include "util_i_data"
#include "core_i_constants"
#include "res_i_const"

void main()
{
    _SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    _SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_HEARTBEAT, "nw_c2_default1:last");
    ExecuteScript("hook_creature07", OBJECT_SELF);
}
