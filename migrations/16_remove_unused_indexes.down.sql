ALTER TABLE log ADD CONSTRAINT log_uuid_key UNIQUE (uuid);

CREATE INDEX test_case_hash_idx ON test_item (test_case_hash);
CREATE INDEX item_test_case_id_idx ON test_item (test_case_id);
CREATE INDEX test_item_unique_id_idx ON test_item (unique_id);

CREATE INDEX pattern_item_pattern_id_idx ON pattern_template_test_item (pattern_id);