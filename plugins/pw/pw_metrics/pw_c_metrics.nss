/// ----------------------------------------------------------------------------
/// @file   pw_c_metrics.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Metrics Management System (configuration).
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                         Configuration Settings
// -----------------------------------------------------------------------------

/// @brief This setting determines whether the metrics bleed system is loaded
///     during the module load process.
///     TRUE: Enable the metrics system.
///     FALSE: Disable the metrics system.
const int METRICS_ENABLE_SYSTEM = TRUE;

/// @brief This setting determines the time, in real-world seconds, between
///     automatic syncs of metrics data from the module's volatile sqlite
///     database to the persistent on-disk database.
const float METRICS_FLUSH_INTERVAL = 60f;

/// @brief This setting determines the chunk size, in number of metrics records,
///     that will be synced from the module's volatile sqlite database to the
///     persistent on-disk database in a single operation.
const int METRICS_FLUSH_CHUNK_SIZE = 250;

/// @brief This setting determines whether metrics will be recorded if NWNX
///     is not available, preventing schema and instances from being validated.
/// @warning Without NWNX's Schema plugin, schema instances provided by plugins
///     could register disallowed metrics operations, or invalid schemas could
///     be generated from the plugin's operations instances.  The value of this
///     options should usually be TRUE; the option is here primarily for testing
///     and development only.
/// @note This setting does not modify system behavior if NWNX is available.  If
///     NWNX is available, it will always be used for schema validation.
const int METRICS_REQUIRE_NWNX = FALSE;
