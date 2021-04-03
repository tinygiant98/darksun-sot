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

#include "ds_qst_i_main"
#include "quest_i_main"


/* Example
void quest_tag()
{
    int nEvent = GetCurrentQuestEvent();
    object oPC = OBJECT_SELF;
    
    if (sEvent == QUEST_EVENT_ON_ASSIGN)
    {

    }
    else if (sEvent == QUEST_EVENT_ON_ACCEPT)
    {

    }
    else if (sEvent == QUEST_EVENT_ON_ADVANCE)
    {
        int nStep = GetCurrentQuestStep();

    }
    else if (sEvent == QUEST_EVENT_ON_COMPLETE)
    {

    }
    else if (sEvent == QUEST_EVENT_ON_FAIL)
    {

    }
}
*/

void quest_demo_kill()
{
    string sEvent = GetCurrentQuestEvent();
    object oPC = OBJECT_SELF;

    if (sEvent == QUEST_EVENT_ON_ADVANCE)
    {
        int nStep = GetCurrentQuestStep();
        if (nStep == 1)
        {
            SetImmortal(oPC, TRUE);
            
            int n;
            object oWP = GetWaypointByTag("quest_kill_1");
            location lWP = GetLocation(oWP);
            for (n = 0; n < 8; n++)
                CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP);
        }
    }
    else if (sEvent == QUEST_EVENT_ON_COMPLETE)
    {   
        int n = 1;
        object oGoblin = GetNearestObjectByTag("NW_GOBLINA", oPC, n);
        while (GetIsObjectValid(oGoblin))
        {
            DestroyObject(oGoblin);
            oGoblin = GetNearestObjectByTag("NW_GOBLINA", oPC, ++n);
        }

        SetImmortal(oPC, FALSE);
    }
}

void quest_demo_protect()
{
    string sEvent = GetCurrentQuestEvent();
    object oPC = OBJECT_SELF;
    
    if (sEvent == QUEST_EVENT_ON_ADVANCE)
    {
        int nStep = GetCurrentQuestStep();
        if (nStep == 1)
        {
            SetImmortal(oPC, TRUE);
            
            int n;
            object oWP = GetWaypointByTag("quest_kill_1");
            location lWP = GetLocation(oWP);
            for (n = 0; n < 5; n++)
            {
                object oTarget = CreateObject(OBJECT_TYPE_CREATURE, "nw_goblina", lWP);
                SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
            }

            oWP = GetWaypointByTag("quest_kill_2");
            lWP = GetLocation(oWP);
            object oProtect = CreateObject(OBJECT_TYPE_CREATURE, "nw_oldman", lWP);
            SetEventScript(oProtect, EVENT_SCRIPT_CREATURE_ON_DEATH, "hook_creature05");
            SetLocalObject(oProtect, "QUEST_PROTECTOR", oPC);
        }
    }
    else if (sEvent == QUEST_EVENT_ON_COMPLETE)
    {
        SetImmortal(oPC, FALSE);
    }
    else if (sEvent == QUEST_EVENT_ON_FAIL)
    {   
        int n = 1;
        object oGoblin = GetNearestObjectByTag("NW_GOBLINA", oPC, n);
        while (GetIsObjectValid(oGoblin))
        {
            DestroyObject(oGoblin);
            oGoblin = GetNearestObjectByTag("NW_GOBLINA", oPC, ++n);
        }

        SetImmortal(oPC, FALSE);
    }
}

void quest_demo_gather()
{
    string sEvent = GetCurrentQuestEvent();
    object oPC = OBJECT_SELF;

    if (sEvent == QUEST_EVENT_ON_ADVANCE)
    {
        int nStep = GetCurrentQuestStep();
        if (nStep == 1)
            ResetGatherQuestArea(oPC);
    }
    else if (sEvent == QUEST_EVENT_ON_COMPLETE)
        ResetGatherQuestArea(oPC);
}

void quest_demo_deliver()
{
    string sEvent = GetCurrentQuestEvent();
    object oPC = OBJECT_SELF;

    if (sEvent == QUEST_EVENT_ON_ADVANCE)
    {
        int nStep = GetCurrentQuestStep();
        if (nStep == 1)
            ResetGatherQuestArea(oPC);
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript("quest_demo_kill", 2);
    RegisterLibraryScript("quest_demo_protect", 3);
    RegisterLibraryScript("quest_demo_gather", 4);
    RegisterLibraryScript("quest_demo_deliver", 5);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 2: quest_demo_kill(); break;
        case 3: quest_demo_protect(); break;
        case 4: quest_demo_gather(); break;
        case 5: quest_demo_deliver(); break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
