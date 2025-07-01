CREATE TABLE users
(
    user_id        UUID PRIMARY KEY,
    email          TEXT,
    username       TEXT,
    phone_number   TEXT,
    password_hash  TEXT,
    first_name     TEXT,
    last_name      TEXT,
    avatar_url     TEXT,
    status         TINYINT, -- User account status: 0: OTHER, 1: ACTIVE, 2: SUSPENDED, 3: PENDING_DELETION, 4: BANNED, 5: DEACTIVATED
    email_verified BOOLEAN,
    phone_verified BOOLEAN,
    auth_version   BIGINT,  -- A version counter to invalidate all active sessions and tokens for a user
    updated_at     TIMESTAMP,
    created_at     TIMESTAMP
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Primary user identity data. Optimized for frequent reads and updates';

CREATE TABLE user_opaque_data
(
    user_id             UUID PRIMARY KEY,
    registration_record TEXT, -- The user's registration data, containing their public key for OPAQUE
    server_private_key  TEXT, -- A unique, per-user secret used by the server in the OPAQUE protocol
    updated_at          TIMESTAMP
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Stores per-user secrets for the OPAQUE password-less authentication protocol';

CREATE TABLE user_deletion_schedule
(
    scheduled_date DATE, -- Partition key for daily batch processing by a cleanup worker
    scheduled_for  TIMESTAMP,
    user_id        UUID,
    user_email     TEXT, -- Stored denormalized for logging or notification purposes
    initiated_at   TIMESTAMP,
    PRIMARY KEY ((scheduled_date), scheduled_for, user_id)
) WITH CLUSTERING ORDER BY (scheduled_for ASC, user_id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 1}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND default_time_to_live = 2592000 -- Automatically purges schedule records after 30 days
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
   AND comment = 'A deletion queue for users, processed by a background job';

CREATE MATERIALIZED VIEW users_by_email AS
SELECT email, user_id, username, status, email_verified, created_at, updated_at
FROM users
WHERE email IS NOT NULL
  AND user_id IS NOT NULL
PRIMARY KEY (email, user_id)
WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
 AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
 AND bloom_filter_fp_chance = 0.01
 AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'};

CREATE MATERIALIZED VIEW users_by_username AS
SELECT username, user_id, email, status, email_verified, created_at, updated_at
FROM users
WHERE username IS NOT NULL
  AND user_id IS NOT NULL
PRIMARY KEY (username, user_id)
WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
 AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
 AND bloom_filter_fp_chance = 0.01
 AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'};

CREATE MATERIALIZED VIEW users_by_phone AS
SELECT phone_number,
       user_id,
       email,
       username,
       status,
       phone_verified,
       created_at,
       updated_at
FROM users
WHERE phone_number IS NOT NULL
  AND user_id IS NOT NULL
PRIMARY KEY (phone_number, user_id)
WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
 AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
 AND bloom_filter_fp_chance = 0.01
 AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'};
