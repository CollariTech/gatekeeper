CREATE TABLE mfa_methods
(
    user_id      UUID,
    id           UUID,
    method_type  TINYINT, -- MFA method type: 0: OTHER, 1: TOTP, 2: SMS, 3: EMAIL, 4: PUSH_NOTIFICATION, 5: WEBAUTHN, 6: RECOVERY_CODES
    secret       TEXT,    -- Stored encrypted; the TOTP secret or recovery codes
    is_primary   BOOLEAN,
    is_enabled   BOOLEAN,
    created_at   TIMESTAMP,
    last_used_at TIMESTAMP,
    PRIMARY KEY ((user_id), is_primary, id)
) WITH CLUSTERING ORDER BY (is_primary DESC, id ASC)
   AND compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Stores all registered MFA methods for a user, including TOTP, SMS, and WebAuthn/Passkey';

CREATE TABLE webauthn_credentials
(
    user_id           UUID,
    id                UUID,
    credential_raw_id TEXT,         -- A unique, public identifier for the credential, used for lookups
    public_key        BLOB,         -- The public key part of the credential
    attestation_type  TINYINT,      -- Attestation trust level: 0: OTHER, 1: NONE, 2: INDIRECT, 3: DIRECT, 4: ATTCA
    aaguid            TEXT,         -- Authenticator Attestation Globally Unique Identifier
    counter           BIGINT,       -- A signature counter to prevent credential cloning
    transports        SET<TINYINT>, -- Authenticator transport methods: 0: OTHER, 1: USB, 2: NFC, 3: BLE, 4: SMART_CARD, 5: HYBRID, 6: INTERNAL
    device_name       TEXT,
    created_at        TIMESTAMP,
    last_used_at      TIMESTAMP,
    PRIMARY KEY ((user_id), created_at, id)
) WITH CLUSTERING ORDER BY (created_at DESC, id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 7}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Stores WebAuthn/Passkey credentials for passwordless authentication, including public keys and metadata';

CREATE MATERIALIZED VIEW webauthn_by_credential AS
SELECT credential_raw_id,
       user_id,
       id,
       public_key,
       counter,
       device_name,
       created_at,
       last_used_at
FROM webauthn_credentials
WHERE credential_raw_id IS NOT NULL
  AND user_id IS NOT NULL
  AND created_at IS NOT NULL
  AND id IS NOT NULL
PRIMARY KEY (credential_raw_id, user_id, created_at, id)
WITH CLUSTERING ORDER BY (user_id ASC, created_at DESC, id ASC)
 AND compaction = {'class': 'SizeTieredCompactionStrategy'}
 AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
 AND bloom_filter_fp_chance = 0.01
 AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
 AND comment = 'Passwordless login by looking up a user directly from their credential ID';
