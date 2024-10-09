// -----------------------------------------------------------------------------
//    File: ds_c_travel.nss
//  System: Travel (configuration)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Configuration File for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  Set the constants below as directed in the comments for each constant.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------

// The party has a set chance to have an encounter during their overland travel.
//  these settings determine what those chances are.  Setting both of these to
//  0 turns off the encounters.
const int TRAVEL_ENCOUNTER_CHANCE_DAY   = 95;
const int TRAVEL_ENCOUNTER_CHANCE_NIGHT = 95;

// This encounter system uses a timer to check whether the party will have an
//  an encounter.  The encounter check will occur every time this timer
//  expires.  To add some randomness, you can add additional time to each
//  timer cycle.  The jitter constant will add from 0 seconds to your set
//  value to the interval.
const float TRAVEL_ENCOUNTER_TIMER_INTERVAL = 50.0;
const float TRAVEL_ENCOUNTER_TIMER_JITTER   = 30.0;

// This setting will determine the maximum number of encounters that a party can
//  have when travelling on a single map.  A value of 0 means there is no limit.
//  The jitter setting allows some variability in the maximum number.  For
//  example, if you set the limit to 3 and jitter to 1, the maximum number of
//  encounters will be in the range of 2-4.  If you set jitter to 0, the maximum
//  number of encounters will always be the limit setting.
const int TRAVEL_ENCOUNTER_LIMIT        = 3;
const int TRAVEL_ENCOUNTER_LIMIT_JITTER = 1;

// Since encounters require physical proximity, party members must be somewhat
//  near the party member that triggers the encounter.  This variable determines
//  how close those party members need to be.  Additionally, if you set the
//  waypoint include value, party members within that distance of the triggering
//  PC will go to the same waypoint in the encounter area while party members
//  further away *might* go to a different waypoint in the encounter area.  The
//  waypoint value should be greater than 0 and less that the party include value.
const float TRAVEL_ENCOUNTER_PARTY_INCLUDE =    50.0;
const float TRAVEL_ENCOUNTER_WAYPOINT_INCLUDE = 10.0;

// The encounter system uses separate areas to run the encounter because of the
//  limitations of the travel map.  When the encounter is started, all qualified
//  members of the party are removed from the travel map and taken to the
//  encounter area.  This may leave some stranded party members unable to help,
//  even if they re-enter the encounter area radius.  These settings will
//  determine whether a party member can enter the encounter area after the
//  encounter has started and, if so, whether non-party members can also enter.
// If ALLOW_LATE_ENTRY is set to TRUE, an invisible trigger/AOE will be created 
//  at the location of the triggering PC.  If a party member that was outside the
//  required radius returns to the AOE, he will be transported to the encounter
//  area unless the area no longer exists.  If ALLOW_STRANGERS is set to true,
//  any non-DM PC that enters the trigger/AOE will be transported to the encounter
//  area.
const int TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY = TRUE;
const int TRAVEL_ENCOUNTER_ALLOW_STRANGERS = FALSE;
