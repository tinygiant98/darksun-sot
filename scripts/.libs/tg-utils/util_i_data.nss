// -----------------------------------------------------------------------------
//    File: util_i_data.nss
//  System: PW Administration (identity and data management)
// -----------------------------------------------------------------------------
// Description:
//  Include for primary data control functions.
// -----------------------------------------------------------------------------
// Builder Use:
//  This include should be "included" in just about every script in the system.
// -----------------------------------------------------------------------------

#include "core_i_constants"
#include "util_i_debug"
#include "util_i_variables"

const string IS_DEVELOPER = "IS_DEVELOPER";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

object MODULE = GetModule();

// ---< _GetIsDM >---
// A module-level function intended to replace the game's GetIsDM() function.
//  Checks for GetIsDM and GetIsDMPossessed.  If the player is found to be logged
//  in as a DM, it will also check the customized 2DA file to determine if the PC
//  is on the authorized DM team.
int _GetIsDM(object oPC);

// ---< _GetIsPC >---
// A module-level function intended to repalce the game's GetIsPC() function.
//  Checks to see if oPC is a player character that is not DM-controlled.
int _GetIsPC(object oPC);

// ---< _GetIsRegisteredDM >---
// Returns whether the CD Key associated with oPC is on the list of registered
// DMs in the custom 2DA file.
int _GetIsRegisteredDM(object oPC);

// ---< _GetIsDeveloper >---
// A module-level function which queries a custom 2DA file to determine whether
// a specific PC is on the development team.
int _GetIsDeveloper(object oPC);

// ---< _GetIsPartyMember >---
// A module-level function intended to determine if oPC is a member of
//  oKnownPartyMember's party/faction.
int _GetIsPartyMember(object oPC, object oKnownPartyMember);

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

int _GetIsDM(object oPC)
{
    return GetLocalInt(oPC, IS_DM) || (GetIsDM(oPC) || GetIsDMPossessed(oPC));
}

int _GetIsPC(object oPC)
{
    return GetLocalInt(oPC, IS_PC) || (GetIsPC(oPC) && !_GetIsDM(oPC));
}

int Get2DAInt(object oPC, string sFile, string sColumn = "Value")
{
    int n;
    string sCDKey = GetPCPublicCDKey(oPC, TRUE);
    string sRegisteredKey = Get2DAString(sFile, sColumn, n);

    while (sRegisteredKey != "")
    {
        if (sCDKey == sRegisteredKey)
            return TRUE;

        sRegisteredKey = Get2DAString(sFile, sColumn, ++n);
    }
    
    return FALSE;
}

int GetIsRegisteredDM(object oPC)
{
    return Get2DAInt(oPC, "env_dm");
}

int GetIsDeveloper(object oPC)
{
    return GetLocalInt(oPC, IS_DEVELOPER) ? TRUE : Get2DAInt(oPC, "env_dev");
}

int _GetIsPartyMember(object oPC, object oKnownPartyMember)
{
    object oPartyMember = GetFirstFactionMember(oKnownPartyMember);

    while (GetIsObjectValid(oPartyMember))
    {
        if (oPartyMember == oPC)
            return TRUE;

        oPartyMember = GetNextFactionMember(oKnownPartyMember);
    }

    return FALSE;
}