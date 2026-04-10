CREATE TABLE IF NOT EXISTS launches_modified
(
    launch_id  BIGINT PRIMARY KEY REFERENCES launch (id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_launches_modified_created_at ON launches_modified (created_at);