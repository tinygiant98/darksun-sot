
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_PERCEPTION, "nw_c2_default2:last");
    ExecuteScript("hook_creature08", OBJECT_SELF);
}
