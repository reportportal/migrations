ALTER TABLE log DROP COLUMN uuid;

DROP INDEX IF EXISTS launch_uuid_idx;
CREATE INDEX IF NOT EXISTS launch_uuid_idx ON launch (uuid);

DROP INDEX IF EXISTS ti_uuid_idx;
CREATE INDEX IF NOT EXISTS ti_uuid_idx ON test_item (uuid);