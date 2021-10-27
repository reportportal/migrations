CREATE TABLE IF NOT EXISTS clusters
(
    id         BIGINT PRIMARY KEY,
    project_id BIGINT NOT NULL,
    launch_id  BIGINT NOT NULL,
    message    TEXT   NOT NULL
);

CREATE INDEX cluster_project_idx ON clusters (project_id);
CREATE INDEX cluster_launch_idx ON clusters (launch_id);

ALTER TABLE log
    ADD COLUMN cluster_id BIGINT;

CREATE INDEX log_cluster_idx ON log (cluster_id);