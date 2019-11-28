ALTER TABLE ticket
    ALTER COLUMN bts_url TYPE VARCHAR(256),
    ALTER COLUMN bts_project TYPE VARCHAR(256),
    ALTER COLUMN url TYPE VARCHAR(256),
    ALTER COLUMN ticket_id TYPE VARCHAR(64);

ALTER TABLE test_item
    ALTER COLUMN unique_id TYPE VARCHAR(256);

DROP INDEX IF EXISTS log_attach_id_idx;

DROP INDEX IF EXISTS log_launch_id_idx;

DROP INDEX IF EXISTS activity_creation_date_idx;
DROP INDEX IF EXISTS activity_object_idx;