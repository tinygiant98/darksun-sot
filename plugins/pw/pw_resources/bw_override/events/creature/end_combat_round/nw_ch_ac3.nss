
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_COMBAT_ROUND_END, "nw_ch_ac3:last");
    ExecuteScript("hook_creature02", OBJECT_SELF);
}
