
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, PLACEABLE_EVENT_ON_DEATH, "x0_o0_death:last");
    ExecuteScript("hook_placeable04", OBJECT_SELF);
}
