// -----------------------------------------------------------------------------
//    File: bleed_i_config.nss
//  System: Bleed Persistent World Subsystem (configuration)
// -----------------------------------------------------------------------------
// Description:
//  Configuration values for PW Subsystem
// -----------------------------------------------------------------------------
// Builder Use:
//  Everything!  Set these values to work in your world!
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//  TRANSLATABLE TEXT
// -----------------------------------------------------------------------------

const string H2_TEXT_RECOVERED_FROM_DYING = "You have become revived and are no longer in danger of bleeding to death.";
const string H2_TEXT_PLAYER_STABLIZED = "Your wounds have stopped bleeding, and you are stable, but still unconcious.";
const string H2_TEXT_WOUNDS_BLEED = "Your wounds continue to bleed. You get ever closer to death.";
const string H2_TEXT_FIRST_AID_SUCCESS = "You have sucessfully rendered aid.";
const string H2_TEXT_FIRST_AID_FAILED = "You have failed to render aid.";
const string H2_TEXT_ALREADY_TENDED = "This person has already been tended to.";
const string H2_TEXT_CANNOT_RENDER_AID = "It is too late to render any aid for this person.";
const string H2_TEXT_DOES_NOT_NEED_AID = "This person is not in need of any aid.";
const string H2_TEXT_ATTEMPT_LONG_TERM_CARE = "You have attempted to provide long-term care to this person.";
const string H2_TEXT_RECEIVE_LONG_TERM_CARE = "An attempt to provide you with long-term care has been made.";

// -----------------------------------------------------------------------------
//  CONFIGURATION
// -----------------------------------------------------------------------------

// Set this to false if you don't want to use bleed system.
const int H2_USE_BLEED_SYSTEM = TRUE;

//Amount of time in seconds between when the player character bleeds while dying.
//Note this is seconds in real time, not game time.
//Recommend value: 6 seconds (1 heartbeat/round)
const float H2_BLEED_DELAY = 6.0;

//Amount of time in seconds between when a stable player character nexts checks to see if they begin to recover.
//Note this is seconds in real time, not game time.
//Recommended Equation: [Minutes per game hour] * 60 seconds = HoursToSeconds(1).
//float H2_STABLE_DELAY = HoursToSeconds(1);
float H2_STABLE_DELAY = H2_BLEED_DELAY * 2.0;

//Percent chance a player character will self stabilize and stop bleedng when dying.
//Range of values is 0 - 100
//Recommended value: 10 (as per 3.5 rules giving 10% chance)
const int H2_SELF_STABILIZE_CHANCE = 10;

//Percent chance a player character will regain conciousness and begin recovery after self-stabilizing.
//Range of values is 0 - 100
//Recommended value: 10 (as per 3.5 rules giving 10% chance)
const int H2_SELF_RECOVERY_CHANCE = 10;

//Amount of hitpoints lost when a player character bleeds.
//Recomended value: 1
const int H2_BLEED_BLOOD_LOSS = 1;

//Heal check DC to provide first aid to a dying charcater to stablize them.
//Default value is 15.
const int H2_FIRST_AID_DC = 15;

//Heal check DC to provide long term care to an injured character.
//Default value is 15.
const int H2_LONG_TERM_CARE_DC = 15;