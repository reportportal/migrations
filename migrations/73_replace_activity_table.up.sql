drop table if exists activity;

create table activity
(
    id bigserial constraint activity_pk primary key,
    created_at timestamp not null,
    action varchar(24) not null,
    priority varchar(12) null,
    object_id bigint null,
    object_name varchar(128) null,
    object_type varchar(24) not null,
    project_id bigint null,
    details jsonb null,
    subject_id bigint null,
    subject_name varchar(128) null,
    subject_type varchar(32) not null
);

create index activity_project_idx on activity (project_id);

create index activity_created_at_idx on activity (created_at);

create index activity_object_idx on activity (object_id);