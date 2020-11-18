// -----------------------------------------------------------------------------
//    File: ds_l_placeable.nss
//  System: Event Management
// -----------------------------------------------------------------------------
// Description:
//  Library Functions and Dispatch
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_data"
#include "core_i_framework"

/* Example
void merchant_tag()
{
    string sEvent = GetName(GetCurrentEvent());
    object oPC, oMerchant = OBJECT_SELF;

    if (sEvent == STORE_EVENT_ON_OPEN)
    {
        oPC = GetLastOpenedBy();

    }
    else if (sEvent == STORE_EVENT_ON_CLOSE)
    {
        oPC = GetLastClosedBy();

    }
}
*/

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // RegisterLibraryScript("merchant_tag", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // case 1:  merchant_tag();           break;
        
        default: CriticalError("Library function " + sScript + " not found");
    }
}
