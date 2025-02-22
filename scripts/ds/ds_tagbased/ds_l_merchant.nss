/// ----------------------------------------------------------------------------
/// @file   ds_l_merchant.nss
/// @author Edward Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Tagbased Scripting (library)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "util_i_library"
#include "util_i_data"

/*
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
    int n;
    // RegisterLibraryScript("merchant_tag", n++);
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            //if      (nEntry == n++) merchant_tag();
            //else if (nEntry == n++) something_else();
        } break;
        default:
            CriticalError("Library function " + sScript + " (" + IntToString(nEntry) + ") " +
                "not found in ds_l_merchant.nss");
    }
}
