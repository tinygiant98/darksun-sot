
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_DISTURBED, "x0_ch_hen_distrb:last");
    ExecuteScript("hook_creature06", OBJECT_SELF);
}
