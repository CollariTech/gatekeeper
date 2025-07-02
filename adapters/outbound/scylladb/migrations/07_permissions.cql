CREATE TABLE permission_scopes
(
    organization_id UUID,
    id              UUID,
    name            TEXT,    -- Unique name of the permission (e.g., 'users:create', 'reports:read')
    description     TEXT,
    is_sensitive    BOOLEAN, -- Marks if this permission grants access to sensitive data (for auditing)
    created_at      TIMESTAMP,
    PRIMARY KEY ((organization_id), is_sensitive, id)
) WITH CLUSTERING ORDER BY (is_sensitive DESC, id ASC)
   AND compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Defines granular permission scopes for fine-grained access control';