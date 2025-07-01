CREATE TABLE projects
(
    organization_id   UUID,
    id                UUID,
    parent_project_id UUID,
    created_by        UUID,
    name              TEXT,
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,
    PRIMARY KEY ((organization_id), created_at, id)
) WITH CLUSTERING ORDER BY (created_at DESC, id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 7}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Represents logical projects or applications within an organization';

CREATE INDEX project_name ON projects (name);