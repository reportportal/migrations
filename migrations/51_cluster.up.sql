CREATE TABLE IF NOT EXISTS clusters
(
    id        BIGINT PRIMARY KEY,
    launch_id BIGINT REFERENCES launch (id),
    message   TEXT NOT NULL
);

ALTER TABLE log
    ADD COLUMN cluster_id BIGINT REFERENCES clusters (id) ON DELETE SET NULL;

CREATE INDEX log_cluster_idx ON log (cluster_id);