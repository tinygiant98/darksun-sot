
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_PHYSICAL_ATTACKED, "nw_c2_default5:last");
    ExecuteScript("hook_creature09", OBJECT_SELF);
}
