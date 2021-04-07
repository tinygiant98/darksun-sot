
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, PLACEABLE_EVENT_ON_CLOSE, "x0_closeinven:last");
    ExecuteScript("hook_placeable02", OBJECT_SELF);
}
