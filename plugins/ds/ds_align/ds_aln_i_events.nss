// -----------------------------------------------------------------------------
//    File: ds_align_i_events.nss
//  System: Alignment System
// -----------------------------------------------------------------------------
// Description:
<<<<<<< HEAD
//  Event functions for DS Align Subsystem.
// -----------------------------------------------------------------------------
// The goal is to keep the game engine from running away with the PCs alignment.
// Our module alignment functions will always attempt to write the PCs new alignment
// to the DB and then set the engine alignment to match.  Scripters should be a little
// careful with this.  You can easily slide the PCs alignment way out of bounds if you
// move the alignment more than a very small amount.  You should really only be adjusting
// the PC's alignment for significant transgressions against alignment.
=======
//  Event functions for DS Subsystem.
>>>>>>> 871c710d539c53e8242f2a73b0374483213bc17b
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
//
#include "ds_aln_i_main"
<<<<<<< HEAD
// al_OnEnterArea() Runs when the PC gets into an area.
=======
// al_OnEnterArea() Runs when the PC gets into an area.  
//         TODO - Sets an alignment set of
// variables so that the Alignment system doesn't run away with the PC's alignment
>>>>>>> 871c710d539c53e8242f2a73b0374483213bc17b
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
        _SetAlignment(iGE, iLC, oPC);
    }
    else
    {
        //The PC has alignment values stored.  Set their alignment values in the engine
        Notice(GetName(oPC) + " has Alignment Values in the DB: \n GE Value: " + IntToString(idbGE) + "\n LC Value: " + IntToString(idbLC));
        //If the player's current values are the same as what's in the DB, then we do not do anything
        if (idbGE == iGE && idbLC == iLC)
            return;
<<<<<<< HEAD
        //TODO - If the engine and the database do not match, override the engine with what we stored in the DB
=======
>>>>>>> 871c710d539c53e8242f2a73b0374483213bc17b
    }
}
