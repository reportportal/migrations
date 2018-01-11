-- hello world


CREATE TYPE PROJECT_TYPE_ENUM AS ENUM ('INTERNAL', 'PERSONAL', 'UPSA');

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
  bugtracking_system SERIAL REFERENCES bug_tracking_system (id) ON DELETE CASCADE,
  field_id           VARCHAR       NOT NULL,
  type               VARCHAR       NOT NULL,
  required           BOOLEAN       NOT NULL DEFAULT FALSE,
  values             VARCHAR ARRAY NOT NULL
);

CREATE TABLE defect_field_allowed_value (
  id                SERIAL CONSTRAINT defect_field_allowed_value_pk PRIMARY KEY,
  defect_form_field SERIAL REFERENCES defect_form_field (id) ON DELETE CASCADE,
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
  email_configuration_id    SERIAL REFERENCES project_email_configuration (id) ON DELETE CASCADE,
  --   statistics sub type ???
  created_on                TIMESTAMP DEFAULT now()    NOT NULL
);


CREATE TABLE project (
  id                       SERIAL CONSTRAINT project_pk PRIMARY KEY,
  name                     VARCHAR                 NOT NULL,
  metadata                 JSONB                   NULL,
  created_on               TIMESTAMP DEFAULT now() NOT NULL,
  project_configuration_id SERIAL REFERENCES project_configuration (id) ON DELETE CASCADE
);
