// -----------------------------------------------------------------------------
//    File: util_i_override.nss
//  System: PW Administration (identity and data management)
// -----------------------------------------------------------------------------
// Description:
//  Overrides for organic Bioware functions
// -----------------------------------------------------------------------------
// Builder Use:
//  This include should be "included" in just about every script in the system.
// -----------------------------------------------------------------------------

#include "util_i_debug" 
#include "util_i_csvlists"    

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< _SetLocked >---
// Given a command delimited liste of object tags (sObjects) and an option to
//  lock the object in question (nLock), this procedure locks the object, if
//  it's lockable.  If closable, closes the object and plays the appropriate
//  animation.
void _SetLocked(string sObjects, int nLock = TRUE);

// ---< _DestroyObject >---
// Designed for ensuring the one-ring system functions properly and if the item
//  is destroyed, the ring is replaced to a random location.  If the object is
//  placeable, the inventory is destroyed by-item.
void _DestroyObject(object oObject);

// ---< _CreateItemOnObject >---
// Alias for Bioware function of the same name to allow delay.
void _CreateItemOnObject(string sItem, object oTarget, int nStack = 1, string sTag = "");

// ---< _CreateObject >---
// Alias for Bioware function of the same name to allow delay.
void _CreateObject(int nType, string sTemplate, location lLocation, int nAnimate = FALSE, string sTag = "");

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void _SetLocked(string sObjects, int nLock = TRUE)
{
    object oObject;
    string sObject;
    int i, nCount = CountList(sObjects);

    for (i = 0; i < nCount; i++)
    {
        sObject = GetListItem(sObjects, i);
        SetLocked(oObject, nLock);

        if (nLock)
        {
            switch (GetObjectType(oObject))
            {
                case OBJECT_TYPE_DOOR:
                    AssignCommand(oObject, ActionCloseDoor(oObject));
                    break;
                case OBJECT_TYPE_PLACEABLE:
                    AssignCommand(oObject, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
                    break;
            }
        }
    }
}

//TODO this goes into lotr, not here in util
void _DestroyObject(object oObject)
{
    if (!GetIsObjectValid(oObject))
        return;
    
    string sTag = GetTag(oObject);

    //Check for the one ring
    if (sTag == "one_ring" || sTag == "unided_ring")
        RunLibraryScript("PlaceOneRing", GetModule());

    //If the object is a placeable, destroy it's inventory
    if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE)
    {
        object oItem = GetFirstItemInInventory(oObject);
        while (GetIsObjectValid(oItem))
        {
            _DestroyObject(oItem);
            oItem = GetNextItemInInventory(oObject);
        }
    }

    DestroyObject(oObject);
}

void _CreateItemOnObject(string sItem, object oTarget, int nStack = 1, string sTag = "")
{
    CreateItemOnObject(sItem, oTarget, nStack, sTag);
}

void _CreateObject(int nType, string sTemplate, location lLocation, int nAnimate = FALSE, string sTag = "")
{
    CreateObject(nType, sTemplate, lLocation, nAnimate, sTag);
}
