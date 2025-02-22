/// ----------------------------------------------------------------------------
/// @file   ds_i_core.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Dark Sun PW (core)
/// ----------------------------------------------------------------------------

#include "core_i_framework"

#include "nwnx_admin"

void ds_DelayStableEvent()
{
    //RunEvent(MODULE_EVENT_ON_MODULE_STABLE);
}

void ds_OnClientEnter()
{

}

void ds_OnModuleStable()
{
    NWNX_Administration_SetPlayerPassword("a");
}

void ds_OnHeartbeat()
{
    if (GetLocalInt(GetModule(), "MODULE_STABLE") == FALSE)
    {
        SetLocalInt(GetModule(), "MODULE_STABLE", TRUE);
        DelayCommand(5.0, ds_DelayStableEvent());
    }
}

void ds_OnPlayerChat()
{

}
