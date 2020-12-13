// -----------------------------------------------------------------------------
//    File: ds_align_i_events.nss
//  System: Alignment System
// -----------------------------------------------------------------------------
// Description:
//  Event functions for DS Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
//
#include "ds_aln_i_main"
// al_OnEnterArea() Runs when the PC gets into an area.  
//         TODO - Sets an alignment set of
// variables so that the Alignment system doesn't run away with the PC's alignment
void al_OnEnterArea();

// -------------------------------------------------------------------------------
// Function Definitions
// -------------------------------------------------------------------------------
void al_OnEnterArea()
{
    object oPC = GetEnteringObject();

    if (!_GetIsPC(oPC))
        return;

    Notice(GetName(oPC) + " in the al_OnEnterArea Script");
    //Check to see if we have stored this player's alignment already.
    //If yes, read it and adjust the settings.  If not, get the player's current info
    //and write it into the database.
    int idbGE = GetDatabaseInt("GE", oPC);
    int idbLC = GetDatabaseInt("LC", oPC);
    int iGE = GetGoodEvilValue(oPC);
    int iLC = GetLawChaosValue(oPC);
    if (idbGE == 0 || idbLC ==  0)
    {
        //The PC has no alignment value set so we set it to the current player engine alignment
        Notice(GetName(oPC) + " has no Alignment Values in the DB: \n GE Value: " + IntToString(iGE) + "\n LC Value: " + IntToString(iLC));
        SetDatabaseInt("GE", iGE, oPC);
        SetDatabaseInt("LC", iLC, oPC);
    }
    else
    {
        //The PC has alignment values stored.  Set their alignment values in the engine
        Notice(GetName(oPC) + " has Alignment Values in the DB: \n GE Value: " + IntToString(idbGE) + "\n LC Value: " + IntToString(idbLC));
    }
}
