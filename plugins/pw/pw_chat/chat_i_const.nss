// -----------------------------------------------------------------------------
//    File: chat_i_const.nss
//  System: Chat Command System (constants)
// -----------------------------------------------------------------------------
// Description:
//  Constants for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

const string CHAT_PREFIX = "CHAT_";

struct COMMAND_LINE
{
    string chatLine;
    string cmdChar;
    string cmd;
    //string shortOpts;
    //string longOpts;
    string options;
    string pairs;
    string args;
};

const string COMMAND_INVALID = "COMMAND_INVALID";
const string TOKEN_INVALID = "TOKEN_INVALID";

const int CHAT_ARGUMENTS = 0x01;
const int CHAT_OPTIONS   = 0x02;
const int CHAT_PAIRS     = 0x04;
