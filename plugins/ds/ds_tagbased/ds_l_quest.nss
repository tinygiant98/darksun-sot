// -----------------------------------------------------------------------------
//    File: ds_l_aoe.nss
//  System: Event Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"
#include "quest_i_main"

/* Example
void quest_tag()
{
    int nEvent = GetCurrentQuestEvent();
    object oPC = OBJECT_SELF;
    
    if (nEvent == QUEST_EVENT_ON_ACCEPT)
    {

    }
    else if (nEvent == QUEST_EVENT_ON_ADVANCE)
    {
        int nStep = GetCurrentQuestStep();

    }
    else if (nEvent == QUEST_EVENT_ON_COMPLETE)
    {

    }
    else if (nEvent == QUEST_EVENT_ON_FAIL)
    {

    }
}
*/

void quest_demo_discover()
{
    int nEvent = GetCurrentQuestEvent();
    object oPC = OBJECT_SELF;
    
    if (nEvent == QUEST_EVENT_ON_ACCEPT)
    {

    }
    else if (nEvent == QUEST_EVENT_ON_ADVANCE)
    {
        int nStep = GetCurrentQuestStep();

    }
    else if (nEvent == QUEST_EVENT_ON_COMPLETE)
    {

    }
    else if (nEvent == QUEST_EVENT_ON_FAIL)
    {

    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript("quest_demo_discover", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  quest_demo_discover(); break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
