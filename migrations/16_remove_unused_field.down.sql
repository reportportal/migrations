ALTER TABLE log
    ADD uuid VARCHAR(36) NOT NULL UNIQUE DEFAULT gen_random_uuid();

CREATE INDEX IF NOT EXISTS log_uuid_idx ON log USING hash (uuid);

DROP INDEX IF EXISTS launch_uuid_idx;
CREATE INDEX IF NOT EXISTS launch_uuid_idx ON launch USING hash (uuid);

DROP INDEX IF EXISTS ti_uuid_idx;
CREATE INDEX IF NOT EXISTS ti_uuid_idx ON test_item USING hash (uuid);