
#include "core_i_constants"
#include "res_i_const"

void main()
{
    SetLocalInt(OBJECT_SELF, FRAMEWORK_OUTSIDER, TRUE);
    SetLocalString(OBJECT_SELF, CREATURE_EVENT_ON_PERCEPTION, "x2_def_percept:last");
    ExecuteScript("hook_creature08", OBJECT_SELF);
}
