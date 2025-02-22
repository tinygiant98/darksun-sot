/// ----------------------------------------------------------------------------
/// @file   pw_e_sky.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Sky Library (events)
/// ----------------------------------------------------------------------------

#include "pw_i_sky"

void sky_OnModuleHeartbeat()
{
    sky_UpdatePlayerShaders();
}
