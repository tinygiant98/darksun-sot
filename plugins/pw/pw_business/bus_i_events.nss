// -----------------------------------------------------------------------------
//    File: bus_i_events.nss
//  System: Business and NPC Operations
// -----------------------------------------------------------------------------
// Description:
//  Event handlers
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "bus_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< business_OnModuleLoad >---
// Registers all businesses and business data to the business datapoint.
void business_OnModuleLoad();

// ---< business_OnHour >---
// Sets the business' open/close state based on profile information set
//  OnModuleLoad unless a previous hard state has been set.  This event runs
//  on every game hour.
void business_OnHour();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void business_OnModuleLoad()
{
    RegisterBusinessProfiles();
    RegisterBusinessHolidays();
    RegisterBusinesses();
    SetBusinessState(BUSINESS_ACTION_DEFAULT, TRUE);
}

void business_OnHour()
{
    if (!_GetLocalInt(BUSINESS, BUSINESS_STATE_SET))
        SetBusinessState();
}