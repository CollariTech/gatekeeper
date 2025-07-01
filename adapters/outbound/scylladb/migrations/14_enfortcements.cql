CREATE TABLE account_enforcements
(
    user_id     UUID,
    enforced_at TIMESTAMP,
    id          UUID,
    action_type TINYINT, -- Enforcement action: 1: SUSPENSION, 2: BAN, 3: WARNING, 4: RESTRICTION, 5: TEMPORARY_LOCK, 0: OTHER
    reason      TEXT,
    enforced_by UUID,
    expires_at  TIMESTAMP,
    revoked_at  TIMESTAMP,
    revoked_by  UUID,
    PRIMARY KEY ((user_id), enforced_at, id)
) WITH CLUSTERING ORDER BY (enforced_at DESC, id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 30}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'A detailed, auditable log of all moderation actions on user accounts';
