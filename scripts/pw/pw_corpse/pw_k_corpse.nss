/// ----------------------------------------------------------------------------
/// @file   pw_k_corpse.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Corpse Library (constants)
/// ----------------------------------------------------------------------------

// ----- Items -----
const string H2_PC_CORPSE_ITEM = "h2_pccorpseitem";
const string H2_DEATH_CORPSE = "h2_deathcorpse";
const string H2_DEATH_CORPSE2 = "h2_deathcorpse2";

// ----- Variables -----
const string H2_WP_DEATH_CORPSE = "H2_PLAYERCORPSE";
const string H2_DEAD_PLAYER_ID = "H2_DEAD_PLAYER_ID";
const string H2_PCCORPSE_ITEM_ACTIVATOR = "H2_PCCORPSE_ITEM_ACTIVATOR";
const string H2_PCCORPSE_ITEM_ACTIVATED = "H2_PCCORPSE_ITEM_ACTIVATED";
const string H2_CORPSE = "H2_CORPSE";
const string H2_CORPSE_DC = "H2_CORPSE_DC";
const string H2_LAST_DROP_LOCATION = "H2_LAST_DROP_LOCATION";
const string H2_CORPSE_TOKEN = "H2_CORPSE_TOKEN";

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
