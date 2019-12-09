ALTER TABLE test_item
    ADD COLUMN test_case_hash INTEGER NOT NULL DEFAULT 0;

UPDATE test_item
SET test_case_hash=test_case_id
WHERE test_case_id IS NOT NULL;

ALTER TABLE test_item
    ALTER COLUMN test_case_id TYPE VARCHAR(256);

CREATE INDEX test_case_hash_idx ON test_item (test_case_hash);
CREATE INDEX test_case_hash_launch_id_idx ON test_item (test_case_hash, launch_id);