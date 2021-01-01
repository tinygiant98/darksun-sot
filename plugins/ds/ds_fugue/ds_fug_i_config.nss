// -----------------------------------------------------------------------------
// File: ds_fug_i_config.nss
// System: Fugue Death and Resurrection (configuration)
// -----------------------------------------------------------------------------
// Description:
//      The Fugue System for use with the Dark Sun Module.  This will override the
//      PW Fugue system and introduce some new capabilities into the Death System.
//      The intention of this death system is to allow for the PC to be respawned
//      either in the Fugue with certain penalties or, under certain conditions,
//      respawned in the Angel's Home with a different set of penalties or not...
// -----------------------------------------------------------------------------
// Builder Use:
//  Set the variables below as directed in the comments for each variable.
//  The General Fugue subsystem is turned on in the pw_fugue_config.nss file.
//  The waypoints for the Fugue itself are set there.
// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------
// Turn on / off the Angel system
const int USE_ANGEL_SYSTEM = TRUE;

// Tag of the area to be used as the Angel's Home.
const string ANGEL_PLANE = "angelhome";

// Tag of the waypoint in the Angel's Home to send the PC to upon death.
const string WP_ANGEL = "ah_death";

// Chance that a player will be sent to the Angel versus the Fugue
const int DS_FUGUE_ANGEL_CHANCE = 50;
