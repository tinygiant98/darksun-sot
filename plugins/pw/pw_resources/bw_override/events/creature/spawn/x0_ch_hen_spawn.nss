
#include "util_i_data"
#include "core_i_constants"
#include "res_i_const"

void main()
{
    _SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    _SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_SPAWN, "x0_ch_hen_spawn:last");
    ExecuteScript("hook_creature11", OBJECT_SELF);
}
