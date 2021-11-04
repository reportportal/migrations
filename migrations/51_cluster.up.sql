CREATE TABLE IF NOT EXISTS clusters
(
    id         BIGSERIAL
        CONSTRAINT clusters_pk PRIMARY KEY,
    index_id   BIGINT NOT NULL,
    project_id BIGINT NOT NULL,
    launch_id  BIGINT NOT NULL,
    message    TEXT   NOT NULL,
    CONSTRAINT index_id_launch_id_unq UNIQUE (index_id, launch_id)
);

CREATE INDEX cluster_index_id_idx ON clusters (index_id);
CREATE INDEX cluster_project_idx ON clusters (project_id);
CREATE INDEX cluster_launch_idx ON clusters (launch_id);

ALTER TABLE log
    ADD COLUMN cluster_id BIGINT;

CREATE INDEX log_cluster_idx ON log (cluster_id);