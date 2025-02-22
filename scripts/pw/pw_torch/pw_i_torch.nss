/// ----------------------------------------------------------------------------
/// @file   pw_i_torch.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Torch Library (core)
/// ----------------------------------------------------------------------------

#include "util_i_time"

#include "pw_i_core"
#include "pw_c_torch"
#include "pw_k_torch"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Removes ITEM_PROPERTY_LIGHT from the passed object, if it exists.
/// @param oLantern The object to remove the light property from.
void h2_RemoveLight(object oLantern);

/// @brief Adds ItemPropertyLight of normal brightness and color white.
/// @param oLantern The object to add the light property to.
void h2_AddLight(object oLantern);

/// @brief Determines if a light source has the necessary fuel and how much
///     burn time is remaining.
/// @param isLantern TRUE/FALSE Whether the light source is a lantern.
void h2_EquippedLightSource(int isLantern);

/// @brief When a PC stops using a light source, this function sets the appropriate
///     time variables and kills the associated timer.
/// @param isLantern TRUE/FALSE Whether the light source is a lantern.
void h2_UnEquipLightSource(int isLantern);

/// @brief When a light source can no longer function (fuel/time), this function removes
///     the light source itemproperty and either unequips or destroys the light
///     source, depending on the type (lantern = unequip, torch = destroy).
/// @param oLight The light source object.
/// @param isLantern TRUE/FALSE Whether the light source is a lantern.
void h2_BurnOutLightSource(object oLight, int isLantern);

/// @brief When a lantern requires oil, this function will add burn time to the lantern
///     and destroy the oil flask used to fill it.
/// @param oOilFlask The oil flask object.
/// @param oLantern The lantern object.
void h2_FillLantern(object oOilFlask, object oLantern);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void h2_RemoveLight(object oLantern)
{
    itemproperty ip = GetFirstItemProperty(oLantern);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_LIGHT)
            RemoveItemProperty(oLantern, ip);
        ip = GetNextItemProperty(oLantern);
    }
}

void h2_AddLight(object oLantern)
{
    itemproperty ip = ItemPropertyLight(IP_CONST_LIGHTBRIGHTNESS_NORMAL, IP_CONST_LIGHTCOLOR_WHITE);
    AddItemProperty(DURATION_TYPE_PERMANENT, ip, oLantern);
}

void h2_EquippedLightSource(int isLantern)
{
    object oLight = GetPCItemLastEquipped();
    object oPC = GetPCItemLastEquippedBy();
    int nBurnTime = TORCH_BURN_COUNT;

    if (isLantern)
    {
        if (GetLocalInt(oLight, H2_NEEDS_OIL))
        {
            SendMessageToPC(oPC, H2_TEXT_LANTERN_OUT);
            return;
        }
        nBurnTime = LANTERN_BURN_COUNT;
    }
    
    SetLocalString(oLight, H2_LIGHT_EQUIPPED, GetSystemTime());
    int elapsedBurn = GetLocalInt(oLight, H2_ELAPSED_BURN);
    int burnLeft = nBurnTime - elapsedBurn;
    float percentRemaining = (IntToFloat(burnLeft) / IntToFloat(nBurnTime)) * 100.0;
    SendMessageToPC(oPC, H2_TEXT_REMAINING_BURN + FloatToString(percentRemaining, 5, 1));
    
    int timerID = CreateEventTimer(oLight, TORCH_EVENT_ON_TIMER_EXPIRE, IntToFloat(burnLeft), 1);
    StartTimer(timerID, FALSE);
    SetLocalInt(oLight, H2_LIGHT_TIMERID, timerID);
    SetLocalObject(oLight, H2_EQUIPPINGPC, oPC);
    SetPlayerInt(oPC, "TORCH_EQUIPPED", TRUE);
}

void h2_UnEquipLightSource(int isLantern)
{
    object oPC = GetPCItemLastUnequippedBy();
    object oLight  = GetPCItemLastUnequipped();
    if (isLantern && GetLocalInt(oLight, H2_NEEDS_OIL))
        return;

    string timeEquipped = GetLocalString(oLight, H2_LIGHT_EQUIPPED);
    int elapsedBurn = GetLocalInt(oLight, H2_ELAPSED_BURN);
    elapsedBurn += FloatToInt(GetSystemTimeDifferenceIn(TIME_SECONDS, timeEquipped));
    SetLocalInt(oLight, H2_ELAPSED_BURN, elapsedBurn);
    
    int timerID = GetLocalInt(oLight, H2_LIGHT_TIMERID);
    KillTimer(timerID);
    DeletePlayerInt(oPC, "TORCH_EQUIPPED");
}

void h2_BurnOutLightSource(object oLight, int isLantern)
{
    int timerID = GetLocalInt(oLight, H2_LIGHT_TIMERID);
    KillTimer(timerID);

    object oPC = GetLocalObject(oLight, H2_EQUIPPINGPC);
    if (isLantern)
    {
        SendMessageToPC(oPC, H2_TEXT_LANTERN_OUT);
        h2_RemoveLight(oLight);
        SetLocalInt(oLight, H2_NEEDS_OIL, TRUE);
        AssignCommand(oPC, ActionUnequipItem(oLight));
    }
    else
    {
        SendMessageToPC(oPC, H2_TEXT_TORCH_BURNED_OUT);
        AssignCommand(oPC, ActionUnequipItem(oLight));
        DestroyObject(oLight);
    }
}

void h2_FillLantern(object oOilFlask, object oLantern)
{
    object oPC = GetItemActivator();
    if (oPC != GetItemPossessor(oLantern))
    {
        SendMessageToPC(oPC, H2_TEXT_TARGET_ITEM_MUST_BE_IN_INVENTORY);
        return;
    }
    if (!GetLocalInt(oLantern, H2_NEEDS_OIL))
    {
        SendMessageToPC(oPC, H2_TEXT_DOES_NOT_NEED_OIL);
        return;
    }
    if (GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC) == oLantern)
        AssignCommand(oPC, ActionUnequipItem(oLantern));
    h2_AddLight(oLantern);
    DeleteLocalInt(oLantern, H2_ELAPSED_BURN);
    DeleteLocalInt(oLantern, H2_NEEDS_OIL);
    DestroyObject(oOilFlask);
}
