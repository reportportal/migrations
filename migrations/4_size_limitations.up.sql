ALTER TABLE ticket
    ALTER COLUMN bts_url TYPE VARCHAR(1024),
    ALTER COLUMN bts_project TYPE VARCHAR(1024),
    ALTER COLUMN url TYPE VARCHAR(1024);

ALTER TABLE test_item
    ALTER COLUMN unique_id TYPE VARCHAR(1024);