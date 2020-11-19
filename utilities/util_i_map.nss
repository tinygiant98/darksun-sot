
#include "util_i_data"

// ---< InitializeSystem >---
// This function loops through a CSV in INIT_LIST and loads pointers to their
//  objects on the oDataPoint data object.  This function can be run multiple times
//  if the INIT_LIST is modified, but requires bForce = TRUE in order to bypass
//  the initialization check to ensure we're not wasting resources.
int InitializeSystem(object oDatapoint, string INIT_LIST, string LOADED_LIST, string ITEM_PREFIX,
                     string OBJECT_LIST, string INIT_FLAG, int bForce = FALSE)
{
    int i, nItemCount, nCount = CountList(INIT_LIST);
    object oItem;
    string sItem, sItems;

    if (_GetLocalInt(oDatapoint, INIT_FLAG) && !bForce)
        return CountObjectList(oDatapoint, OBJECT_LIST);

    _DeleteLocalString(oDatapoint, LOADED_LIST);
    if (!nCount)
        return FALSE;

    for (i = 0; i < nCount; i++)
    {
        sItem = GetListItem(INIT_LIST, i);
        sItem = GetStringLeft(sItem, 16 - GetStringLength(ITEM_PREFIX));
        oItem = CreateItemOnObject(ITEM_PREFIX + sItem, oDatapoint);

        Debug("Attempting to mount " + ITEM_PREFIX + sItem);

        if (GetIsObjectValid(oItem))
        {
            if (AddListObject(oDatapoint, oItem, OBJECT_LIST, TRUE))
                sItems = AddListItem(sItems, sItem);
            else
                Warning(GetName(oDatapoint) + ":Item '" + GetTag(oItem) + "' found but not " +
                    "loaded due to item duplication.  Check the install list.");
        }
        else
            Warning(GetName(oDatapoint) + ": Item '" + sItem + "' not found.");
    }

    nItemCount = CountObjectList(oDatapoint, OBJECT_LIST);

    _SetLocalString(oDatapoint, LOADED_LIST, sItems);
    _SetLocalInt(oDatapoint, INIT_FLAG, TRUE);

    return nItemCount;
}
