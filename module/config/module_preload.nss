// Module pre-load script for DM.  The framework tends to have a lot of TMI,
// which isn't an issue in EE, but can be in 1.69.  This will set the TMI limit
// to a much higher value, allowing the framework to fully load.  This must be
// set before any other framework instructions are run.

#include "nwnx_util"

void DS_Module_Init()
{
    NWNX_Util_SetInstructionLimit(NWNX_Util_GetInstructionLimit() * 64);
    SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_MODULE_LOAD, "hook_nwnx");
}
