/// ----------------------------------------------------------------------------
/// @file   pw_c_corpse.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Corpse Library (configuration)
/// ----------------------------------------------------------------------------

/// @brief Set this value to TRUE to load the corpse system.
const int CORPSE_ACTIVE = FALSE;

/// @brief Set this value to the user-defined event number sent to an NPC when a
///     corpse token is activated on them.
/// @warning This value should be deconflicted with any other systems using
///     user-defined events.
const int CORPSE_ITEM_ACTIVATED_EVENT_NUMBER = 99000;

/// @brief Set this value TRUE to allow players to resurrect a player through the
///     use of a corpse token.
const int CORPSE_ALLOW_REZ_BY_PLAYERS = TRUE;

/// @brief Set this value to TRUE to apply an xp loss to the raised player
///     character.
const int CORPSE_APPLY_REZ_XP_LOSS = TRUE;

/// @brief Set this value to TRUE to require a gold cost for raising a player
///     character.
const int CORPSE_REQUIRE_GOLD_FOR_REZ = TRUE;

/// @brief Set this value to the amount of gold required to raise a player
///     character.
/// @note This value will be clamped from 0 to INF.
/// @note If CORPSE_REQUIRE_GOLD_FOR_REZ is FALSE, this value is ignored.
const int CORPSE_GOLD_COST_FOR_RAISE_DEAD = 5000;

/// @brief Set this value to the amount of gold required to resurrect a
///     player character.
/// @note This value will be clamped from 0 to INF.
/// @note If CORPSE_REQUIRE_GOLD_FOR_REZ is FALSE, this value is ignored.
const int CORPSE_GOLD_COST_FOR_REZ = 10000;
