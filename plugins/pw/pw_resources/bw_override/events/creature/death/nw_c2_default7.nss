
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_DEATH, "nw_c2_default7:last");
    ExecuteScript("hook_creature05", OBJECT_SELF);
}
