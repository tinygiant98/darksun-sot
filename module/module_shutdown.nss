// Module shutdownscript (only works with NWNX). 

#include "core_i_framework"

void main()
{   
    RunEvent("OnModuleShutdown");
    //RunEvent(MODULE_EVENT_ON_MODULE_SHUTDOWN);
}
