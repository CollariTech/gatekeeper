CREATE TABLE organizations
(
    organization_id UUID PRIMARY KEY,
    name            TEXT,
    active          BOOLEAN,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Represents a tenant in the system, containing users, projects and configurations';

CREATE TABLE custom_attribute_definitions
(
    organization_id UUID,
    attribute_name  TEXT,
    attribute_type  TINYINT, -- Data type of the attribute: 0: OTHER, 1: TEXT, 2: NUMBER, 3: BOOLEAN, 4: DATE, 5: EMAIL, 6: URL, 7: JSON
    is_required     BOOLEAN,
    is_pii          BOOLEAN, -- Marks if the attribute contains Personally Identifiable Information (for compliance)
    description     TEXT,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    PRIMARY KEY ((organization_id), attribute_name)
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Schema definitions for organization-specific user attributes';

CREATE TABLE user_custom_attributes
(
    user_id         UUID,
    organization_id UUID,
    attribute_name  TEXT,
    attribute_value TEXT, -- The value is always stored as text; the application layer enforces the type
    updated_at      TIMESTAMP,
    PRIMARY KEY ((user_id, organization_id), attribute_name)
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Stores key-value pairs for custom user data';

CREATE INDEX organization_name ON organizations (name);
