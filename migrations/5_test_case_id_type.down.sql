ALTER TABLE test_item
    ALTER COLUMN test_case_id TYPE INTEGER USING test_case_id::INTEGER;
ALTER TABLE test_item
    DROP COLUMN test_case_hash;