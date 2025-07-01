CREATE TABLE user_devices
(
    user_id      UUID,
    device_id    UUID,
    fingerprint  TEXT,    -- A unique hash generated from device characteristics (e.g., browser, OS)
    device_name  TEXT,
    user_agent   TEXT,
    platform     TEXT,
    active       BOOLEAN,
    trusted      BOOLEAN, -- A user-driven flag to mark a device as trusted, reducing MFA friction
    metadata     MAP<TEXT, TEXT>,
    last_used_at TIMESTAMP,
    created_at   TIMESTAMP,
    PRIMARY KEY ((user_id), created_at, device_id)
) WITH CLUSTERING ORDER BY (created_at DESC, device_id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 7}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Stores user device information, optimized for retrieving recent devices.';

CREATE TABLE device_sessions
(
    user_id         UUID,
    session_id      UUID,
    device_id       UUID,
    organization_id UUID,
    ip_addresses    SET<INET>, -- Tracks all IPs used during this session for security analysis
    revoked         BOOLEAN,
    created_at      TIMESTAMP,
    expires_at      TIMESTAMP,
    PRIMARY KEY ((user_id), expires_at, session_id)
) WITH CLUSTERING ORDER BY (expires_at DESC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'HOURS', 'compaction_window_size': 24}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND default_time_to_live = 604800 -- Sessions automatically expire after 7 days
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
   AND comment = 'Manages user sessions, optimized for write-heavy loads and TTL-based cleanup.';