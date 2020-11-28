// -----------------------------------------------------------------------------
// Description:
//      The Fugue System for use with the Dark Sun Module.  This will override the
//      PW Fugue system and introduce some new capabilities into the Death System.
//      The intention of this death system is to allow for the PC to be respawned
//      either in the Fugue with certain penalties or, under certain conditions,
//      respawned in the Angel's Home with a different set of penalties or not...
// -----------------------------------------------------------------------------
//    File: ds_fug_i_config.nss
//  System: Fugue Death and Resurrection (configuration)
// -----------------------------------------------------------------------------
// Builder Use:
//  Set the variables below as directed in the comments for each variable.
//  The General Fugue subsystem is turned on in the pw_fugue_config.nss file.
//  The waypoints for the Fugue itself are set there.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------
// Tag of the area to be used as the Angel's Home.
const string H2_ANGEL_PLANE = "h2_angelhome";

// Tag of the waypoint in the Angel's Home to send the PC
//  to upon death.
const string H2_WP_ANGEL = "ah_death";