CREATE TABLE role_templates
(
    organization_id UUID,
    id              UUID,
    name            TEXT,
    description     TEXT,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    PRIMARY KEY ((organization_id), id)
) WITH CLUSTERING ORDER BY (id ASC)
   AND compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Defines a reusable role template that can be assigned to users';

CREATE TABLE template_permissions
(
    template_id UUID,
    scope_id    UUID,
    granted_at  TIMESTAMP,
    granted_by  UUID,
    PRIMARY KEY ((template_id), granted_at, scope_id)
) WITH CLUSTERING ORDER BY (granted_at DESC, scope_id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 7}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Links role templates to specific permission scopes, defining what actions the role can perform';

CREATE TABLE role_assignments
(
    user_id         UUID,
    organization_id UUID,
    project_id      UUID, -- If NULL, the role is granted at the organization level
    id              UUID,
    template_id     UUID,
    assigned_at     TIMESTAMP,
    assigned_by     UUID,
    expires_at      TIMESTAMP,
    PRIMARY KEY ((user_id, organization_id, project_id), expires_at, template_id, id)
) WITH CLUSTERING ORDER BY (expires_at DESC, template_id ASC, id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 30}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Assigns a role to a user, either organization-wide or within a specific project';
