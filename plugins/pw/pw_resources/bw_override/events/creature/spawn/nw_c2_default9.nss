
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_SPAWN, "nw_c2_default9:last");
    ExecuteScript("hook_creature11", OBJECT_SELF);
}
