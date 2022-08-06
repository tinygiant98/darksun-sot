// -----------------------------------------------------------------------------
//    File: bus_i_config.nss
//  System: Business and NPC Operations
// -----------------------------------------------------------------------------
// Description:
//  Configuration
// -----------------------------------------------------------------------------
// Builder Use:
//  Everything!  Set these up the way you want them.
// -----------------------------------------------------------------------------


// Businesses (which include stores, craft shops and specific NPCs) can be set to
//  open and close at specific times.  If a business profile is registered, but
//  the hours are not passed, these hours will be used.
const int BUSINESS_HOUR_OPEN = 8;
const int BUSINESS_HOUR_CLOSE = 20;

// If businesses are set to all-open or all-close, normal business opening and
//  closing functions will not work.  To ensure everything goes back to normal,
//  the business state flag will be deleted after this amount of time unless
//  the flag is cleared manually.
const float BUSINESS_STATE_FLAG_LIFETIME = 1500.0;


string BUSINESS_CLOSING_SOON = "The business you are currently patronizing will be closing in one hour. " +
    "If you are still in the building when it closes, you will be unceremoniously removed and you may suffer " +
    "the loss of items.";
    
