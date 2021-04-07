
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_DAMAGED, "nw_ch_ac6:last");
    ExecuteScript("hook_creature04", OBJECT_SELF);
}
