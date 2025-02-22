
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_CONVERSATION, "x2_def_onconv:last");
    ExecuteScript("hook_creature03", OBJECT_SELF);
}
