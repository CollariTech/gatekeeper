CREATE TABLE user_consents
(
    user_id        UUID,
    application_id UUID,
    id             UUID,
    granted_scopes SET<TEXT>, -- The specific permissions (scopes) the user approved
    granted_at     TIMESTAMP,
    expires_at     TIMESTAMP,
    revoked_at     TIMESTAMP, -- If not NULL, the user has revoked this consent
    PRIMARY KEY ((user_id, application_id), expires_at, id)
) WITH CLUSTERING ORDER BY (expires_at DESC, id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 30}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Stores a user explicit consent for an application to access their data, including granted scopes and expiration details';

CREATE TABLE user_policy_consents
(
    user_id        UUID,
    policy_type    TINYINT, -- Policy type: 1: TERMS_OF_SERVICE, 2: PRIVACY_POLICY, 3: COOKIE_POLICY, 4: DATA_PROCESSING, 0: OTHER
    policy_version TEXT,    -- The specific version of the policy that was accepted
    status         TINYINT, -- Consent status: 1: GRANTED, 2: REVOKED, 3: EXPIRED, 0: OTHER
    granted_at     TIMESTAMP,
    updated_at     TIMESTAMP,
    PRIMARY KEY ((user_id), updated_at, policy_type)
) WITH CLUSTERING ORDER BY (updated_at DESC, policy_type ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 7}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Tracks user acceptance of legal documents, allowing for versioning and status updates';