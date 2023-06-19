DROP TABLE IF EXISTS activity;

CREATE TABLE activity
(
    id bigserial CONSTRAINT activity_pk PRIMARY KEY,
    created_at timestamp NOT NULL,
    action varchar(24) NOT NULL,
    event_name varchar(32) NOT NULL,
    priority varchar(12) NOT NULL,
    object_id bigint NULL,
    object_name varchar(128) NOT NULL,
    object_type varchar(24) NOT NULL,
    project_id bigint REFERENCES project (id) ON DELETE CASCADE NULL,
    details jsonb NULL,
    subject_id bigint NULL,
    subject_name varchar(128) NOT NULL,
    subject_type varchar(32) NOT NULL
);

CREATE INDEX activity_project_idx ON activity (project_id);

CREATE INDEX activity_created_at_idx ON activity (created_at);

CREATE INDEX activity_object_idx ON activity (object_id);