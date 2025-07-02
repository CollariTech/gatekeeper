CREATE TABLE oauth_applications
(
    organization_id     UUID,
    project_id          UUID,
    id                  UUID,
    name                TEXT,
    client_secret       TEXT,         -- Stored encrypted
    client_type         TINYINT,      -- OAuth client type: 0: OTHER, 1: CONFIDENTIAL, 2: PUBLIC
    redirect_uris       SET<TEXT>,
    allowed_origins     SET<TEXT>,
    allowed_scopes      SET<TEXT>,
    auto_approve        BOOLEAN,      -- If true, skips the user consent screen for first-party apps
    allowed_grant_types SET<TINYINT>, -- OAuth 2.0 grant types: 1: AUTHORIZATION_CODE, 2: CLIENT_CREDENTIALS, 3: REFRESH_TOKEN, 4: DEVICE_CODE, 5: PKCE
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    PRIMARY KEY ((organization_id, project_id), created_at, id)
) WITH CLUSTERING ORDER BY (created_at DESC, id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 7}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Defines OAuth 2.0 client applications, which can be internal services or third-party apps';