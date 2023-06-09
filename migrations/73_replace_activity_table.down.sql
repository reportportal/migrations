drop table if exists activity;

create table activity
(
    id bigserial constraint activity_pk primary key,
    user_id bigint,
    username varchar,
    project_id bigint references project (id) on delete cascade null,
    entity varchar(128) not null,
    action varchar(128) not null,
    details jsonb null,
    creation_date timestamp not null,
    object_id bigint null
);

create index activity_project_idx on activity (project_id);

create index activity_creation_date_idx on activity (creation_date);

create index activity_object_idx on activity (object_id);