
#include "util_i_data"
#include "core_i_constants"
#include "res_i_const"

void main()
{
    _SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    _SetLocalString(OBJECT_SELF, PLACEABLE_EVENT_ON_USER_DEFINED, "x2_o0_glyphude:last");
    ExecuteScript("hook_placeable13", OBJECT_SELF);
}
