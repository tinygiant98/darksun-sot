/// -----------------------------------------------------------------------------
/// @file:  hcr_c_corpse.nss
/// @brief: HCR2 Corpse Token System (configuration)
/// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                   HCR2 Corpse Token Configuration Options
// -----------------------------------------------------------------------------

/// This value determines whether the corpse token plugin is loaded or not. If you
/// want to control the corpse token system state through the plugin management dialog,
/// set this value to TRUE and deactivate the plugin after loading.  If set to
/// FALSE, the corpse token plugin will not be available to the module.
const int H2_CORPSE_LOAD_PLUGIN = TRUE;

/// This value determines the User-Defined Event number for "using" a PC corpse
/// token on another game object, likely a healer NPC.  Any number not being used
/// for any other user-defined event is valid.
const int H2_PCCORPSE_ITEM_ACTIVATED_EVENT_NUMBER = 2147483500;

/// This value determined whether non-DM PCs make ressurect other player-characters
/// via the corpse token system.  Set to TRUE to allow non-DM PCs to ressurect via
/// corpse token.
const int H2_ALLOW_CORPSE_RESS_BY_PLAYERS = TRUE;

/// This value determines whether a PC that has been raised through the corpse token
/// system will suffer the player handbook-defined XP loss upon being raised or
/// resurrected.  Set to TRUE to apply the XP penalty.
const int H2_APPLY_XP_LOSS_FOR_RESS = TRUE;

/// This value determines whether a PC that is raising or resurrecting another PC
/// through the corpse token system will suffer player handbook-defined gold piece
/// loss for casting the spell.  Set to TRUE to apply the GP penalty.
const int H2_REQUIRE_GOLD_FOR_RESS = TRUE;

/// This value determines the cost a PC must may in order to raise
/// another player through the corpse token system.  If H2_REQUIRE_GOLD_FOR_RESS is
/// FALSE, this value will be ignored.  This value must be positive.
const int H2_GOLD_COST_FOR_RAISE_DEAD = 5000;

/// This value determines the cost a PC must may in order to resurect
/// another player through the corpse token system.  If H2_REQUIRE_GOLD_FOR_RESS is
/// FALSE, this value will be ignored.  This value must be positive.
const int H2_GOLD_COST_FOR_RESSURECTION = 10000;

// -----------------------------------------------------------------------------
//                      HCR2 Corpse Token Translatable Text
// -----------------------------------------------------------------------------
/// @warning If modifying these values to use languages that are encoded using
///     other than Windows-1252, the file must be saved and compiled with the
///     appropriate encoding.

/// @note To use tlk entries for these values, you can modify the construction
///     using the following example:
/// string H2_TEXT_CLERIC_RES_GOLD_COST = GetStringByStrRef(###);

const string H2_TEXT_CLERIC_RES_GOLD_COST = "I can cast raise dead for 5000 coins, or resurrection for 10000.";
const string H2_TEXT_CLERIC_NOT_ENOUGH_GOLD = "I'm sorry you do not have enough gold for me to aid you.";
const string H2_TEXT_OFFLINE_RESS_CASTER_FEEDBACK = "The player is offline but will be ressurected when they next log in.";
const string H2_TEXT_YOU_HAVE_BEEN_RESSURECTED = "You have been ressurected.";
const string H2_TEXT_OFFLINE_RESS_LOGIN = /* GetName(oPC) + "_" + GetPCPlayerName(oPC) + */ " offline ressurection login.";
const string H2_TEXT_RESS_PC_CORPSE_ITEM = /* GetName(oCaster) + "_" + GetPCPlayerName(oCaster) + */
                                           " cast raise dead/ressurection on corpse token of: ";
                                           /* + GetName(oDeadPlayer) + "_" + GetPCPlayerName(oDeadPlayer) OR + H2_TEXT_OFFLINE_PLAYER + " " + uniquePCID */

const string H2_TEXT_CORPSE_TOKEN_USED_BY = /*"NPC " + GetName(oCaster) + " ("*/
                                            "token used by: ";
                                            /*+") " + GetName(oTokenUser) + "_" + GetPCPlayerName(oTokenUser)*/

const string H2_TEXT_CORPSE_OF = "Corpse of "; //"Corpse of " + GetName(oDeadPC)
