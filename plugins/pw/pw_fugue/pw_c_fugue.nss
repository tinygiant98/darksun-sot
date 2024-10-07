// -----------------------------------------------------------------------------
//    File: pw_c_fugue.nss
//  System: Fugue Death and Resurrection (configuration)
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

// Set to false to not use the fugue system.
const int H2_USE_FUGUE_SYSTEM = TRUE;

// Tag of the area to be used as the fugue plane.
const string H2_FUGUE_PLANE = "h2_fugueplane";

// Tag of the waypoint in the fugue plan (H2_FUGUE_PLANE) to send the PC
//  to upon death.
const string H2_WP_FUGUE = "H2_FUGUE";
