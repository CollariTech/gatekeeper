CREATE TABLE external_auth_providers
(
    id              UUID PRIMARY KEY,
    organization_id UUID,
    provider_name   TEXT,
    provider_type   TINYINT,         -- Identity provider type: 0: OTHER, 1: OIDC, 2: SAML, 3: OAUTH2, 4: LDAP
    provider_config MAP<TEXT, TEXT>, -- Flexible key-value store for provider-specific settings (endpoints, certificates)
    enabled         BOOLEAN,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Configuration for external identity providers used for social login';

CREATE TABLE user_external_auth
(
    user_id          UUID,
    provider_id      UUID,
    provider_user_id TEXT, -- The unique ID of the user within the external provider
    access_token     TEXT, -- Stored encrypted
    refresh_token    TEXT, -- Stored encrypted
    token_expires_at TIMESTAMP,
    scopes           SET<TEXT>,
    created_at       TIMESTAMP,
    updated_at       TIMESTAMP,
    PRIMARY KEY ((user_id), provider_id)
) WITH compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 1}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Links user accounts to external identity providers';

CREATE TABLE external_provider_attribute_mappings
(
    provider_id        UUID,
    external_attribute TEXT,    -- The name of the attribute in the IdP's token (e.g., 'given_name')
    internal_attribute TEXT,    -- The corresponding attribute in the 'users' table (e.g., 'first_name')
    is_updatable       BOOLEAN, -- If true, the internal attribute is updated with every login
    created_at         TIMESTAMP,
    PRIMARY KEY ((provider_id), external_attribute)
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Controls how external user profile data maps to the internal user schema';