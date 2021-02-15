// -----------------------------------------------------------------------------
//    File: quest_i_events.nss
//  System: Quest Persistent World Subsystem (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "quest_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void quest_OnModuleLoad()
{
    DefineQuests();
}

void quest_OnClientEnter()
{
    
}

void quest_OnPlayerChat()
{
    object oTarget, oPC = GetPCChatSpeaker();
    if ((oTarget = GetChatTarget(oPC)) == OBJECT_INVALID)
        return;

    int n, nProperty, nProperties, nCount, nPropertyCount;
    string sCategoryList, sKeyList, sValueList, sResult, sAdd;

    if (HasChatOption(oPC, "dump"))
    {
        string sTag;

        if (HasChatKey(oPC, "tag"))
            sTag = GetChatKeyValue(oPC, "tag");
        
        if (sTag == "")
            Notice("sTag is Empty, dumping all quests");

        object oDataItem = GetFirstItemInInventory(QUESTS);
        while (GetIsObjectValid(oDataItem))
        {
            if (sTag != "" && GetLocalString(oDataItem, QUEST_TAG) != sTag)
            {
                oDataItem = GetNextItemInInventory(QUESTS);
                continue;
            }

            Notice("Dumping Quest Data from " + GetLocalString(oDataItem, QUEST_TAG) +
                    "\n  Title -> " + GetLocalString(oDataItem, QUEST_TITLE) +
                    "\n  Active -> " + (GetLocalInt(oDataItem, QUEST_ACTIVE) ? "TRUE":"FALSE") +
                    "\n  Repititions -> " + IntToString(GetLocalInt(oDataItem, QUEST_REPETITIONS)) +
                    "\n  Step Order -> " + (GetLocalInt(oDataItem, QUEST_STEP_ORDER) == 1 ? "SEQUENTIAL":"RANDOM"));

            nCount = CountIntList(oDataItem, QUEST_STEP_ID);
            for (n = 0; n <= nCount; n++)
            {   // TODO need to add an index find or something
                sCategoryList = QUEST_STEP + IntToString(n) + "_CATEGORY";
                sKeyList = QUEST_STEP + IntToString(n) + "_KEYS";
                sValueList = QUEST_STEP + IntToString(n) + "_VALUES";
            
                Notice("Loop Number " + IntToString(n) + ":" +
                        "\n  sCategoryList -> " + sCategoryList +
                        "\n  sKeyList -> " + sKeyList +
                        "\n  sValueList -> " + sValueList);

                if (n == 0)
                    sResult = "Quest-Level Properties:\n";
                else
                    sResult = "Quest Step-Level Properties (Step " + IntToString(n - 1) + "):" +
                                "\n  Step ID -> " + IntToString(GetListInt(oDataItem, n - 1, QUEST_STEP_ID)) +
                                "\n  Journal Entry -> " + GetListString(oDataItem, n - 1, QUEST_STEP_JOURNAL_ENTRY) +
                                "\n  Time Limit -> " + (GetListString(oDataItem, n - 1, QUEST_STEP_TIME_LIMIT) != "" ? GetListString(oDataItem, n, QUEST_STEP_TIME_LIMIT) : "[none]") +
                                "\n  Allow Party Completion -> " + (GetListInt(oDataItem, n - 1, QUEST_STEP_PARTY_COMPLETION) ? "TRUE":"FALSE") +
                                "\n";

                nPropertyCount = CountIntList(oDataItem, sCategoryList);
                for (nProperty = 0; nProperty < nPropertyCount; nProperty++)
                {
                    sAdd += "  Category -> " + _GetStringFromCategory(GetListInt(oDataItem, nProperty, sCategoryList)) + 
                                "\n  Keys -> " + GetListString(oDataItem, nProperty, sKeyList) +
                                "\n  Values -> " + GetListString(oDataItem, nProperty, sValueList);
                }

                Notice(sResult + sAdd);
                sAdd = "";
            }
            
            oDataItem = GetNextItemInInventory(QUESTS);
        }
    }

    if (HasChatKey(oPC, "values"))
    {
        
        
        /*int nCount = GetChatKeyValueInt(oPC, "values");
        int nEncoded = _EncodeNumbers(nCount);

        string sAdd, sMessage = "Encoding " + IntToString(nCount) + " numbers" +
                                "\n  Encoded Integer -> " + IntToString(nEncoded);
        int n;
        for (n = 0; n < nCount; n++)
            sAdd += "\n  Position " + IntToString(n + 1) + " -> " + IntToString(_GetEncodedNumber(nEncoded, nCount, n));

        Notice(sMessage + sAdd);*/
    }

    if (HasChatOption(oPC, "test"))
    {
        _RunEncodingTest();
    }
}

