// -----------------------------------------------------------------------------
//    File: chat_i_events.nss
//  System: Chat Command System (events)
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "chat_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< chat_OnPlayerChat >---
// Controls the chat command system.  Determines if a passed chat line is an attempt
//  at a command and, if so, runs the appropraite events
void chat_OnPlayerChat();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------
void chat_OnPlayerChat()
{
    string sCommands = "!@#$%^&*;./?`~|\\";
    string sMessage = GetPCChatMessage();
    string sChar = GetStringLeft(sMessage, 1);

    if (FindSubString(sCommands, sChar) > -1)
    {
        // We might have a chat command, so let's figure it all out
        struct COMMAND_LINE cl = ParseCommandLine(sMessage);

        object oPC = GetPCChatSpeaker();
        SaveParsedChatLine(oPC, cl);
        SetPCChatMessage();
        
        int nState = RunEvent("CHAT_" + cl.cmdChar);
        if (!(nState & EVENT_STATE_DENIED))
            RunEvent("CHAT_" + cl.cmdChar + cl.cmd);
    }
}
