
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_PHYSICAL_ATTACKED, "x0_ch_hen_attack:last");
    ExecuteScript("hook_creature09", OBJECT_SELF);
}
