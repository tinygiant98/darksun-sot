
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_RESTED, "x2_def_rested:last");
    ExecuteScript("hook_creature10", OBJECT_SELF);
}
