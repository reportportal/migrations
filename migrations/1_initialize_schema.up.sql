-- hello world


CREATE TYPE PROJECT_TYPE_ENUM AS ENUM ('INTERNAL', 'PERSONAL', 'UPSA');

CREATE TYPE USER_ROLE_ENUM AS ENUM ('ADMINISTRATOR', 'USER');

CREATE TYPE USER_TYPE_ENUM AS ENUM ('INTERNAL', 'UPSA', 'GITHUB', 'LDAP');

CREATE TYPE PROJECT_ROLE_ENUM AS ENUM ('OPERATOR', 'CUSTOMER', 'MEMBER', 'PROJECT_MANAGER');

-- CREATE TABLE defect_type (
--
-- )

CREATE TABLE bug_tracking_system (
  id   SERIAL CONSTRAINT bug_tracking_system_pk PRIMARY KEY,
  url  VARCHAR NOT NULL,
  type VARCHAR NOT NULL
  --   project ref?

);

CREATE TABLE defect_form_field (
  id                 SERIAL CONSTRAINT defect_form_field_pk PRIMARY KEY,
  bugtracking_system INT REFERENCES bug_tracking_system (id) ON DELETE CASCADE,
  field_id           VARCHAR       NOT NULL,
  type               VARCHAR       NOT NULL,
  required           BOOLEAN       NOT NULL DEFAULT FALSE,
  values             VARCHAR ARRAY NOT NULL
);

CREATE TABLE defect_field_allowed_value (
  id                SERIAL CONSTRAINT defect_field_allowed_value_pk PRIMARY KEY,
  defect_form_field INT REFERENCES defect_form_field (id) ON DELETE CASCADE,
  value_id          VARCHAR NOT NULL,
  value_name        VARCHAR NULL
);


CREATE TABLE project_email_configuration (
  id         SERIAL CONSTRAINT project_email_configuration_pk PRIMARY KEY,
  enabled    BOOLEAN DEFAULT FALSE NOT NULL,
  recipients VARCHAR ARRAY         NOT NULL
  --   email cases?
);

CREATE TABLE project_configuration (
  id                        SERIAL CONSTRAINT project_configuration_pk PRIMARY KEY,
  project_type              PROJECT_TYPE_ENUM          NOT NULL,
  interrupt_timeout         INTERVAL                   NOT NULL,
  keep_logs_interval        INTERVAL                   NOT NULL,
  keep_screenshots_interval INTERVAL                   NOT NULL,
  aa_enabled                BOOLEAN DEFAULT TRUE       NOT NULL,
  metadata                  JSONB                      NULL,
  email_configuration_id    INT REFERENCES project_email_configuration (id) ON DELETE CASCADE,
  --   statistics sub type ???
  created_on                TIMESTAMP DEFAULT now()    NOT NULL
);


CREATE TABLE project (
  id                       SERIAL CONSTRAINT project_pk PRIMARY KEY,
  name                     VARCHAR                 NOT NULL,
  metadata                 JSONB                   NULL,
  created_on               TIMESTAMP DEFAULT now() NOT NULL,
  project_configuration_id INT REFERENCES project_configuration (id) ON DELETE CASCADE
);


CREATE TABLE profile (
  id                 SERIAL CONSTRAINT profile_pk PRIMARY KEY,
  login              VARCHAR        NOT NULL UNIQUE,
  password           VARCHAR        NOT NULL,
  email              VARCHAR        NOT NULL,
  -- photos ?
  role               USER_ROLE_ENUM NOT NULL,
  type               USER_TYPE_ENUM NOT NULL,
  -- isExpired ?
  default_project_id INT REFERENCES project (id) ON DELETE CASCADE,
  full_name          VARCHAR        NOT NULL,
  metadata           JSONB          NULL
);

CREATE TABLE profile_project (
  profile_id   INT REFERENCES profile (id) ON UPDATE CASCADE ON DELETE CASCADE,
  project_id   INT REFERENCES project (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT profile_project_pk PRIMARY KEY (profile_id, project_id),
  project_role PROJECT_ROLE_ENUM NOT NULL
  -- proposed role ??
);

CREATE TABLE activity (
  id            SERIAL CONSTRAINT activity_pk PRIMARY KEY,
  profile_id    INT REFERENCES profile (id) ON DELETE CASCADE,
  project_id    INT REFERENCES project (id) ON DELETE CASCADE,
  last_modified TIMESTAMP DEFAULT now() NOT NULL,
  object_type   VARCHAR                 NOT NULL,
  action_type   VARCHAR                 NOT NULL,
  name          VARCHAR                 NOT NULL
  -- history ??
)