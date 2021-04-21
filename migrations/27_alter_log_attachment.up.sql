ALTER TABLE log
    ADD COLUMN project_id BIGINT REFERENCES project (id);

ALTER TABLE attachment
    ADD COLUMN creation_date TIMESTAMP;