CREATE TABLE access_policies
(
    organization_id UUID,
    priority        INT,     -- Determines the order of evaluation; lower numbers are evaluated first.
    id              UUID,
    name            TEXT,
    description     TEXT,
    effect          TINYINT, -- The outcome if the policy matches: 0: ALLOW, 1: DENY
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    PRIMARY KEY ((organization_id), priority, id)
) WITH CLUSTERING ORDER BY (priority DESC, id ASC)
   AND compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Defines high-level access policies for Attribute-Based Access Control (ABAC)';

CREATE TABLE rule_conditions
(
    rule_id          UUID,
    condition_id     UUID,
    attribute_source TINYINT, -- The origin of the attribute: 0: OTHER, 1: SUBJECT, 2: RESOURCE, 3: ENVIRONMENT
    attribute_name   TEXT,    -- The name of the attribute to check (e.g., 'ip_address', 'device_is_trusted')
    operator         TEXT,    -- The comparison operator 1: EQUALS, 2: NOT_EQUALS, 3: IN, 4: NOT_IN, 5: EXISTS, 6: NOT_EXISTS
    value            TEXT,    -- The value to compare against.
    PRIMARY KEY ((rule_id), condition_id)
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Defines a single condition that can be evaluated against an attribute value';


CREATE TABLE policy_rules
(
    policy_id   UUID,
    rule_id     UUID,
    name        TEXT,
    description TEXT,
    PRIMARY KEY ((policy_id), rule_id)
) WITH compaction = {'class': 'SizeTieredCompactionStrategy'}
   AND compression = {'class': 'LZ4Compressor', 'chunk_length_in_kb': 64}
   AND bloom_filter_fp_chance = 0.01
   AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
   AND comment = 'Groups conditions into a logical rule that can be evaluated against attributes';
