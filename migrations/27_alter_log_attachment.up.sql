ALTER TABLE log
    ADD COLUMN project_id BIGINT REFERENCES project (id);
CREATE INDEX log_project_id_idx ON log (project_id);

ALTER TABLE attachment
    ADD COLUMN creation_date TIMESTAMP;