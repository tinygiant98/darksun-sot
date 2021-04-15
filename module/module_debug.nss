// Module pre-load script for DM.  The framework tends to have a lot of TMI,
// which isn't an issue in EE, but can be in 1.69.  This will set the TMI limit
// to a much higher value, allowing the framework to fully load.  This must be
// set before any other framework instructions are run.

#include "util_i_libraries"

void main()
{
    RunLibraryScript("webhook_OnModuleDebug", OBJECT_SELF);
}
