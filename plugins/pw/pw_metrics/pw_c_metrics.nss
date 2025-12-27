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
const float METRICS_FLUSH_INTERVAL = 10f;

/// @brief This setting determines the chunk size, in number of metrics records,
///     that will be synced from the module's volatile sqlite database to the
///     persistent on-disk database in a single operation.
const int METRICS_FLUSH_CHUNK_SIZE = 250;
