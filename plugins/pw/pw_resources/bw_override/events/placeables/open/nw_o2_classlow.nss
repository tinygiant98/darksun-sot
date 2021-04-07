
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, PLACEABLE_EVENT_ON_OPEN, "nw_o2_classlow:last");
    ExecuteScript("hook_placeable09", OBJECT_SELF);
}
