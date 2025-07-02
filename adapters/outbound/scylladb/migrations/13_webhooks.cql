CREATE TABLE webhook_endpoints
(
    organization_id UUID,
    is_active       BOOLEAN,
    id              UUID,
    target_url      TEXT,
    secret          TEXT,      -- A secret used to sign webhook payloads, allowing the receiver to verify authenticity
    enabled_events  SET<TEXT>, -- A list of event types this endpoint subscribes to (e.g., 'user.created')
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    PRIMARY KEY ((organization_id), is_active, id)
) WITH CLUSTERING ORDER BY (is_active DESC, id ASC)
   AND compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Stores webhook endpoint configurations, optimized for fast lookups of active endpoints';

CREATE TABLE webhook_event_deliveries
(
    status          TINYINT, -- Delivery status: 1: PENDING, 2: SUCCESS, 3: FAILED, 4: RETRYING, 5: ABANDONED, 0: OTHER
    delivery_date   DATE,
    last_attempt_at TIMESTAMP,
    id              UUID,
    endpoint_id     UUID,
    event_type      TEXT,
    payload         TEXT,    -- The JSON body of the event being delivered
    attempt_count   INT,
    created_at      TIMESTAMP,
    PRIMARY KEY ((status, delivery_date), last_attempt_at, id)
) WITH CLUSTERING ORDER BY (last_attempt_at ASC, id ASC)
   AND compaction = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'HOURS', 'compaction_window_size': 1}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 128}
   AND default_time_to_live = 604800 -- Delivery attempts are abandoned after 7 days
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
   AND comment = 'A persistent queue for delivering webhook events, supporting retries and ensuring reliability';