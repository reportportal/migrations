drop table IF EXISTS activity;

create TABLE activity
(
    id bigserial CONSTRAINT activity_pk PRIMARY KEY,
    user_id bigint REFERENCES users (id) ON delete CASCADE,
    username varchar,
    project_id bigint REFERENCES project (id) ON delete CASCADE NULL,
    entity varchar(128) NOT NULL,
    action varchar(128) NOT NULL,
    details jsonb NULL,
    creation_date timestamp NOT NULL,
    object_id bigint NULL
);

create index activity_project_idx on activity (project_id);

create index activity_creation_date_idx on activity (creation_date);

create index activity_object_idx on activity (object_id);