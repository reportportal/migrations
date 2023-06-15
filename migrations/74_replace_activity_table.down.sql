DROP TABLE IF EXISTS activity;

CREATE TABLE activity
(
    id bigserial CONSTRAINT activity_pk PRIMARY KEY,
    user_id bigint REFERENCES users (id) ON DELETE CASCADE,
    username varchar,
    project_id bigint REFERENCES project (id) ON DELETE CASCADE NULL,
    entity varchar(128) NOT NULL,
    action varchar(128) NOT NULL,
    details jsonb NULL,
    creation_date timestamp NOT NULL,
    object_id bigint NULL
);

CREATE INDEX activity_project_idx ON activity (project_id);

CREATE INDEX activity_creation_date_idx ON activity (creation_date);

CREATE INDEX activity_object_idx ON activity (object_id);