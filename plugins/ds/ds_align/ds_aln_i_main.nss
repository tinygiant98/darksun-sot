// -----------------------------------------------------------------------------
//    File: ds_align_i_main.nss
//  System: Alignment System
// -----------------------------------------------------------------------------
// Description:
//  Core functions for DS Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
#include "ds_i_const"
#include "ds_aln_i_const"
#include "ds_aln_i_config"
#include "ds_aln_i_text"
#include "pw_i_core"
#include "util_i_color"
// -----------------------------------------------------------------------------
<<<<<<< HEAD
//                             Alignment Continuum
//                                      ^ Lawful (100)
//                                      |
//                                      |
//                                      |
//                 Evil (1) <-----------|-----------> Good (100)
//                                      |
//                                      |
//                                      |
//                                      v Chaotic (1)
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
=======
>>>>>>> 871c710d539c53e8242f2a73b0374483213bc17b
//                              Function Prototypes
// -----------------------------------------------------------------------------
// This function will update the database and set the game alignment engine to
// the same value.
void _SetAlignment(int iGE, int iLC, object oPC);
// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------
void _SetAlignment(int iGE, int iLC, object oPC)
{
    // Get the current alignment values from the engine.
    int iengGE = GetGoodEvilValue(oPC);
    int iengLC = GetLawChaosValue(oPC);
    SetDatabaseInt("GE", iGE, oPC);
    SetDatabaseInt("LC", iLC, oPC);
    // If the values match, just write to the database and return.
    if (iGE == iengGE && iLC == iengLC)
    {
        Notice(GetName(oPC) + " needs no alignment change.");
        return;
    }
    // If the engine is more good than the player, adjust down by the right amount,
    // set the engine's value and write to the DB
    if (iengGE > iGE)
    {
        int iDiff = iengGE - iGE;
        AdjustAlignment(oPC, ALIGNMENT_EVIL, iDiff, FALSE);
        Notice(GetName(oPC) + " had alignment moved toward evil by " + IntToString(iDiff));
    }
    else
    {
        int iDiff = iGE - iengGE;
        AdjustAlignment(oPC, ALIGNMENT_GOOD, iDiff, FALSE);
        Notice(GetName(oPC) + " had alignment moved toward good by " + IntToString(iDiff));
    }
    // If the engine is more Lawful than the player, 
    if (iengLC > iLC)
    {
        int iDiff = iengLC - iLC;
        AdjustAlignment(oPC, ALIGNMENT_CHAOTIC, iDiff, FALSE);
        Notice(GetName(oPC) + " had alignment moved toward chaotic by " + IntToString(iDiff));
    }
    else
    {
        int iDiff = iLC - iengLC;
        AdjustAlignment(oPC, ALIGNMENT_LAWFUL, iDiff, FALSE);
        Notice(GetName(oPC) + " had alignment moved toward lawful by " + IntToString(iDiff));
    }
}