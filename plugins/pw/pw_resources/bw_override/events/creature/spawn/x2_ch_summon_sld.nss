
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_SPAWN, "c2_ch_summon_sld:last");
    ExecuteScript("hook_creature11", OBJECT_SELF);
}
