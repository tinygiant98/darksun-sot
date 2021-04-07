
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_USER_DEFINED, "nw_c2_dimdoor:last");
    ExecuteScript("hook_creature13", OBJECT_SELF);
}
