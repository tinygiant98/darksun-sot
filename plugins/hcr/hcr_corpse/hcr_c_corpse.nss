// -----------------------------------------------------------------------------
//    File: pw_c_corpse.nss
//  System: PC Corpse (configuration)
// -----------------------------------------------------------------------------
// Description:
//  Configuration File for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  Set the variables below as directed in the comments for each variable.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------

// Set this to false if you do not want to use the corpse system
const int H2_USE_CORPSE_SYSTEM = FALSE;

//User defined event number sent to an NPC when a corpse token is activated on them.
//Pick any integer value that is not being used for another event number.
const int H2_PCCORPSE_ITEM_ACTIVATED_EVENT_NUMBER = 2147483500;

//Can be TRUE or FALSE.
//Set this to FALSE if you do not want to allow PC's to ressurect a corpse token at all.
//Default value is TRUE.
const int H2_ALLOW_CORPSE_RESS_BY_PLAYERS = TRUE;

//Can be TRUE or FALSE.
//Set this to TRUE if you want the raised PC to endure the PHB XP loss upon being raised or ressurected.
const int H2_APPLY_XP_LOSS_FOR_RESS = TRUE;

//Can be TRUE or FALSE.
//Set this to TRUE if you want the caster to lose gold according to the amount the PHB says is required
//for the cast spell.
const int H2_REQUIRE_GOLD_FOR_RESS = TRUE;

//The cost in gold for the raise dead spell. (must be a positive value)
//This only applies if H2_REQUIRE_GOLD_COST_FOR_RESS = TRUE;
const int H2_GOLD_COST_FOR_RAISE_DEAD = 5000;

//The cost in gold for the ressurection spell. (must be a positive value)
//This only applies if H2_REQUIRE_GOLD_COST_FOR_RESS = TRUE;
const int H2_GOLD_COST_FOR_RESSURECTION = 10000;

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string H2_TEXT_CLERIC_RES_GOLD_COST = "I can cast raise dead for 5000 coins, or resurrection for 10000.";
const string H2_TEXT_CLERIC_NOT_ENOUGH_GOLD = "I'm sorry you do not have enough gold for me to aid you.";
const string H2_TEXT_OFFLINE_RESS_CASTER_FEEDBACK = "The player is offline but will be ressurected when they next log in.";
const string H2_TEXT_YOU_HAVE_BEEN_RESSURECTED = "You have been ressurected.";
const string H2_TEXT_OFFLINE_RESS_LOGIN = /*GetName(oPC)+"_"+GetPCPlayerName(oPC)+*/" offline ressurection login.";
const string H2_TEXT_RESS_PC_CORPSE_ITEM = /*GetName(oCaster)+"_"+GetPCPlayerName(oCaster)+*/
                                           " cast raise dead/ressurection on corpse token of: ";
                                           /*+GetName(oDeadPlayer)+"_"+GetPCPlayerName(oDeadPlayer)  OR +H2_TEXT_OFFLINE_PLAYER+" "+uniquePCID*/

const string H2_TEXT_CORPSE_TOKEN_USED_BY = /*"NPC " + GetName(oCaster) + " ("*/
                                            "token used by: ";
                                            /*+") " + GetName(oTokenUser) + "_" + GetPCPlayerName(oTokenUser)*/

const string H2_TEXT_CORPSE_OF = "Corpse of "; //"Corpse of " + GetName(oDeadPC)
