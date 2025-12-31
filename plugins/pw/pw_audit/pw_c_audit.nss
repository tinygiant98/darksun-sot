/// ----------------------------------------------------------------------------
/// @file   pw_c_audit.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Audit System (configuration).
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                         Configuration Settings
// -----------------------------------------------------------------------------

/// @brief This setting determines whether the audit system is loaded
///     during the module load process.
///     TRUE: Enable the audit system.
///     FALSE: Disable the audit system.
const int AUDIT_ENABLE_SYSTEM = TRUE;

/// @brief This setting determines the time, in real-world seconds, between
///     automatic syncs of audit data from the module's volatile sqlite
///     database to the persistent on-disk database.
const float AUDIT_FLUSH_INTERVAL = 60f;

/// @brief This setting determines the chunk size, in number of audit records,
///     that will be synced from the module's volatile sqlite database to the
///     persistent on-disk database in a single operation.
const int AUDIT_FLUSH_CHUNK_SIZE = 250;

/// @brief The audit trail can get rather ridiculously large over time.  This
///     setting determines the default expiry period for audit records.  After
///     this period, records will be automatically purged from the audit trail.
/// @note To keep a permanent record of a specific event, set its expiry to
///     NULL when creating the audit record.
const string AUDIT_EXPIRY_DEFAULT_MODIFIER = "+30 days";

/// @brief Keywords that indicate an audit record should be permanent (i.e.,
///     never expire).  Any record containing these keywords will not be purged.
json AUDIT_EXPIRY_PERMANENT_KEYWORDS = JsonParse(r"
    [
        ""permanent"",
        ""forever"",
        ""never"",
        ""null"",
        ""no""
    ]
");
