CREATE TYPE PROJECT_TYPE_ENUM AS ENUM ('INTERNAL', 'PERSONAL', 'UPSA');

CREATE TYPE USER_ROLE_ENUM AS ENUM ('ADMINISTRATOR', 'USER');

CREATE TYPE USER_TYPE_ENUM AS ENUM ('INTERNAL', 'UPSA', 'GITHUB', 'LDAP');

CREATE TYPE PROJECT_ROLE_ENUM AS ENUM ('OPERATOR', 'CUSTOMER', 'MEMBER', 'PROJECT_MANAGER');

CREATE TYPE STATUS_ENUM AS ENUM ('IN_PROGRESS', 'PASSED', 'FAILED', 'STOPPED', 'SKIPPED', 'INTERRUPTED', 'RESETED', 'CANCELLED');

CREATE TYPE LAUNCH_MODE_ENUM AS ENUM ('DEFAULT', 'DEBUG');

CREATE TYPE AUTH_TYPE_ENUM AS ENUM ('OAUTH', 'NTLM', 'APIKEY', 'BASIC');

CREATE TYPE ACCESS_TOKEN_TYPE_ENUM AS ENUM ('OAUTH', 'NTLM', 'APIKEY', 'BASIC');

CREATE TYPE ACTIVITY_ENTITY_ENUM AS ENUM ('LAUNCH', 'ITEM');

CREATE TYPE TEST_ITEM_TYPE_ENUM AS ENUM ('SUITE', 'STORY', 'TEST', 'SCENARIO', 'STEP', 'BEFORE_CLASS', 'BEFORE_GROUPS', 'BEFORE_METHOD',
  'BEFORE_SUITE', 'BEFORE_TEST', 'AFTER_CLASS', 'AFTER_GROUPS', 'AFTER_METHOD', 'AFTER_SUITE', 'AFTER_TEST');

CREATE TYPE ISSUE_GROUP_ENUM AS ENUM ('PRODUCT_BUG', 'AUTOMATION_BUG', 'SYSTEM_ISSUE', 'TO_INVESTIGATE', 'NO_DEFECT');

CREATE TYPE INTEGRATION_AUTH_FLOW_ENUM AS ENUM ('OAUTH', 'BASIC', 'TOKEN', 'FORM');

CREATE TYPE INTEGRATION_GROUP_ENUM AS ENUM ('BTS', 'NOTIFICATION');

CREATE TYPE FILTER_CONDITION_ENUM AS ENUM ('EQUALS', 'NOT_EQUALS', 'CONTAINS', 'EXISTS', 'IN', 'HAS', 'GREATER_THAN', 'GREATER_THAN_OR_EQUALS',
  'LOWER_THAN', 'LOWER_THAN_OR_EQUALS', 'BETWEEN');

CREATE TABLE server_settings (
  id    SMALLSERIAL CONSTRAINT server_settings_id PRIMARY KEY,
  key   VARCHAR NOT NULL UNIQUE,
  value VARCHAR
);

---------------------------- Project and users ------------------------------------
CREATE TABLE project (
  id       BIGSERIAL CONSTRAINT project_pk PRIMARY KEY,
  name     VARCHAR NOT NULL,
  metadata JSONB   NULL
);

CREATE TABLE users (
  id                 BIGSERIAL CONSTRAINT users_pk PRIMARY KEY,
  login              VARCHAR        NOT NULL UNIQUE,
  password           VARCHAR        NOT NULL,
  email              VARCHAR        NOT NULL,
  -- photos ?
  role               USER_ROLE_ENUM NOT NULL,
  type               USER_TYPE_ENUM NOT NULL,
  -- isExpired ?
  default_project_id INTEGER REFERENCES project (id) ON DELETE CASCADE,
  full_name          VARCHAR        NOT NULL,
  metadata           JSONB          NULL
);

CREATE TABLE project_user (
  user_id      BIGINT REFERENCES users (id) ON DELETE CASCADE,
  project_id   BIGINT REFERENCES project (id) ON DELETE CASCADE,
  CONSTRAINT users_project_pk PRIMARY KEY (user_id, project_id),
  project_role PROJECT_ROLE_ENUM NOT NULL
  -- proposed role ??
);

CREATE TABLE oauth_access_token (
  user_id    BIGINT REFERENCES users (id) ON DELETE CASCADE,
  token      VARCHAR                NOT NULL,
  token_type ACCESS_TOKEN_TYPE_ENUM NOT NULL,
  CONSTRAINT access_tokens_pk PRIMARY KEY (user_id, token_type)
);

CREATE TABLE oauth_registration (
  id                           VARCHAR(64) PRIMARY KEY,
  client_id                    VARCHAR(128) NOT NULL UNIQUE,
  client_secret                VARCHAR(256),
  client_auth_method           VARCHAR(64)  NOT NULL,
  auth_grant_type              VARCHAR(64),
  redirect_uri_template        VARCHAR(256),

  authorization_uri            VARCHAR(256),
  token_uri                    VARCHAR(256),

  user_info_endpoint_uri       VARCHAR(256),
  user_info_endpoint_name_attr VARCHAR(256),

  jwk_set_uri                  VARCHAR(256),
  client_name                  VARCHAR(128)
);

CREATE TABLE oauth_registration_scope (
  id                    SERIAL CONSTRAINT oauth_registration_scope_pk PRIMARY KEY,
  oauth_registration_fk VARCHAR(128) REFERENCES oauth_registration (id) ON DELETE CASCADE,
  scope                 VARCHAR(256)
);
-----------------------------------------------------------------------------------


------------------------------ Project configurations ------------------------------
CREATE TABLE project_email_configuration (
  id         BIGSERIAL CONSTRAINT project_email_configuration_pk PRIMARY KEY,
  enabled    BOOLEAN DEFAULT FALSE NOT NULL,
  recipients VARCHAR ARRAY         NOT NULL
  --   email cases?
);

CREATE TABLE project_configuration (
  id                        BIGINT CONSTRAINT project_configuration_pk PRIMARY KEY REFERENCES project (id) ON DELETE CASCADE UNIQUE,
  project_type              PROJECT_TYPE_ENUM          NOT NULL,
  interrupt_timeout         INTERVAL                   NOT NULL,
  keep_logs_interval        INTERVAL                   NOT NULL,
  keep_screenshots_interval INTERVAL                   NOT NULL,
  aa_enabled                BOOLEAN DEFAULT TRUE       NOT NULL,
  metadata                  JSONB                      NULL,
  email_configuration_id    BIGINT REFERENCES project_email_configuration (id) ON DELETE CASCADE UNIQUE,
  created_on                TIMESTAMP DEFAULT now()    NOT NULL
);
-----------------------------------------------------------------------------------


------------------------------ Bug tracking systems ------------------------------
CREATE TABLE bug_tracking_system (
  id          BIGSERIAL CONSTRAINT bug_tracking_system_pk PRIMARY KEY,
  url         VARCHAR                                          NOT NULL,
  type        VARCHAR                                          NOT NULL,
  bts_project VARCHAR                                          NOT NULL,
  project_id  BIGINT REFERENCES project (id) ON DELETE CASCADE NOT NULL,
  CONSTRAINT unique_bts UNIQUE (url, type, bts_project, project_id)
);

CREATE TABLE defect_form_field (
  id                     BIGSERIAL CONSTRAINT defect_form_field_pk PRIMARY KEY,
  bug_tracking_system_id BIGINT REFERENCES bug_tracking_system (id) ON DELETE CASCADE,
  field_id               VARCHAR NOT NULL,
  type                   VARCHAR NOT NULL,
  required               BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE defect_field_allowed_value (
  id                BIGSERIAL CONSTRAINT defect_field_allowed_value_pk PRIMARY KEY,
  defect_form_field BIGINT REFERENCES defect_form_field (id) ON DELETE CASCADE,
  value_id          VARCHAR NOT NULL,
  value_name        VARCHAR NOT NULL
);

CREATE TABLE defect_form_field_value (
  id     BIGINT REFERENCES defect_form_field (id) ON DELETE CASCADE,
  values VARCHAR NOT NULL
);

-----------------------------------------------------------------------------------


-------------------------- Integrations -----------------------------
CREATE TABLE integration_type (
  id            SERIAL CONSTRAINT integration_type_pk PRIMARY KEY,
  name          VARCHAR(128)               NOT NULL,
  auth_flow     INTEGRATION_AUTH_FLOW_ENUM NOT NULL,
  creation_date TIMESTAMP DEFAULT now()    NOT NULL,
  group_type    INTEGRATION_GROUP_ENUM     NOT NULL,
  details       JSONB
);

CREATE TABLE integration (
  id            SERIAL CONSTRAINT integration_pk PRIMARY KEY,
  project_id    BIGINT REFERENCES project (id) ON DELETE CASCADE,
  type          INTEGER REFERENCES integration_type (id) ON DELETE CASCADE,
  params        JSONB,
  creation_date TIMESTAMP DEFAULT now() NOT NULL
);
-------------------------- Dashboards, widgets, user filters -----------------------------
CREATE TABLE dashboard (
  id            SERIAL CONSTRAINT dashboard_pk PRIMARY KEY,
  name          VARCHAR                 NOT NULL,
  description   VARCHAR,
  project_id    INTEGER REFERENCES project (id) ON DELETE CASCADE,
  creation_date TIMESTAMP DEFAULT now() NOT NULL,
  CONSTRAINT unq_name_project UNIQUE (name, project_id)
  -- acl
);

CREATE TABLE widget (
  id          BIGSERIAL CONSTRAINT widget_id PRIMARY KEY,
  name        VARCHAR NOT NULL,
  description VARCHAR,
  widget_type VARCHAR NOT NULL,
  items_count SMALLINT,
  project_id  BIGINT REFERENCES project (id) ON DELETE CASCADE
);

CREATE TABLE content_field (
  id    BIGINT REFERENCES widget (id) ON DELETE CASCADE,
  field VARCHAR NOT NULL
);

CREATE TABLE widget_option (
  id        BIGSERIAL CONSTRAINT widget_option_pk PRIMARY KEY,
  widget_id BIGINT REFERENCES widget (id) ON DELETE CASCADE,
  option    VARCHAR NOT NULL
);

CREATE TABLE widget_option_value (
  id    BIGINT REFERENCES widget_option (id) ON DELETE CASCADE,
  value VARCHAR NOT NULL
);

CREATE TABLE dashboard_widget (
  dashboard_id      INTEGER REFERENCES dashboard (id) ON DELETE CASCADE,
  widget_id         INTEGER REFERENCES widget (id) ON DELETE CASCADE,
  widget_name       VARCHAR NOT NULL, -- make it as reference ??
  widget_width      INT     NOT NULL,
  widget_height     INT     NOT NULL,
  widget_position_x INT     NOT NULL,
  widget_position_y INT     NOT NULL,
  CONSTRAINT dashboard_widget_pk PRIMARY KEY (dashboard_id, widget_id),
  CONSTRAINT widget_on_dashboard_unq UNIQUE (dashboard_id, widget_name)
);

CREATE TABLE filter (
  id          BIGSERIAL CONSTRAINT filter_pk PRIMARY KEY,
  name        VARCHAR                        NOT NULL,
  project_id  BIGINT REFERENCES project (id) NOT NULL,
  target      VARCHAR                        NOT NULL,
  description VARCHAR
);

CREATE TABLE user_filter (
  id BIGINT NOT NULL CONSTRAINT user_filter_pk PRIMARY KEY CONSTRAINT user_filter_id_fk REFERENCES filter (id)
);

CREATE TABLE filter_condition (
  id        BIGSERIAL CONSTRAINT filter_condition_pk PRIMARY KEY,
  filter_id BIGINT REFERENCES user_filter (id) ON DELETE CASCADE,
  condition FILTER_CONDITION_ENUM NOT NULL,
  value     VARCHAR               NOT NULL,
  field     VARCHAR               NOT NULL,
  negative  BOOLEAN               NOT NULL
);

CREATE TABLE filter_sort (
  id        BIGSERIAL CONSTRAINT filter_sort_pk PRIMARY KEY,
  filter_id BIGINT REFERENCES user_filter (id) ON DELETE CASCADE,
  field     VARCHAR NOT NULL,
  ascending BOOLEAN NOT NULL
);

CREATE TABLE widget_filter (
  widget_id INTEGER REFERENCES widget (id) ON DELETE CASCADE,
  filter_id BIGINT REFERENCES filter (id) ON DELETE CASCADE,
  CONSTRAINT widget_filter_po PRIMARY KEY (widget_id, filter_id)
);
-----------------------------------------------------------------------------------


--------------------------- Launches, items, logs --------------------------------------

CREATE TABLE launch (
  id            BIGSERIAL CONSTRAINT launch_pk PRIMARY KEY,
  uuid          VARCHAR                                                             NOT NULL,
  project_id    BIGINT REFERENCES project (id) ON DELETE CASCADE                    NOT NULL,
  user_id       BIGINT REFERENCES users (id) ON DELETE SET NULL,
  name          VARCHAR(256)                                                        NOT NULL,
  description   TEXT,
  start_time    TIMESTAMP                                                           NOT NULL,
  end_time      TIMESTAMP,
  number        INTEGER                                                             NOT NULL,
  last_modified TIMESTAMP DEFAULT now()                                             NOT NULL,
  mode          LAUNCH_MODE_ENUM                                                    NOT NULL,
  status        STATUS_ENUM                                                         NOT NULL,
  CONSTRAINT unq_name_number UNIQUE (NAME, number, project_id, uuid)
);

CREATE TABLE launch_tag (
  id        BIGSERIAL CONSTRAINT launch_tag_pk PRIMARY KEY,
  value     TEXT NOT NULL,
  launch_id BIGINT REFERENCES launch (id) ON DELETE CASCADE
);


CREATE TABLE test_item (
  item_id       BIGSERIAL CONSTRAINT test_item_pk PRIMARY KEY,
  launch_id     BIGINT REFERENCES launch (id) ON DELETE CASCADE,
  name          VARCHAR(256),
  type          TEST_ITEM_TYPE_ENUM NOT NULL,
  start_time    TIMESTAMP           NOT NULL,
  description   TEXT,
  last_modified TIMESTAMP           NOT NULL,
  unique_id     VARCHAR(256)        NOT NULL
);

CREATE TABLE test_item_structure (
  item_id   BIGINT CONSTRAINT test_item_structure_pk PRIMARY KEY REFERENCES test_item (item_id) ON DELETE CASCADE UNIQUE,
  parent_id BIGINT REFERENCES test_item_structure ON DELETE CASCADE,
  retry_of  BIGINT REFERENCES test_item_structure ON DELETE CASCADE
);

CREATE TABLE test_item_results (
  item_id  BIGINT CONSTRAINT test_item_results_pk PRIMARY KEY REFERENCES test_item (item_id) ON DELETE CASCADE UNIQUE,
  status   STATUS_ENUM NOT NULL,
  end_time TIMESTAMP,
  duration DOUBLE PRECISION
);

CREATE TABLE parameter (
  item_id BIGINT REFERENCES test_item (item_id) ON DELETE CASCADE,
  key     VARCHAR NOT NULL,
  value   VARCHAR NOT NULL
);

CREATE TABLE item_tag (
  id      SERIAL CONSTRAINT item_tag_pk PRIMARY KEY,
  value   TEXT,
  item_id BIGINT REFERENCES test_item (item_id) ON DELETE CASCADE
);


CREATE TABLE log (
  id                  BIGSERIAL CONSTRAINT log_pk PRIMARY KEY,
  log_time            TIMESTAMP                                                NOT NULL,
  log_message         TEXT                                                     NOT NULL,
  item_id             BIGINT REFERENCES test_item (item_id) ON DELETE CASCADE  NOT NULL,
  last_modified       TIMESTAMP                                                NOT NULL,
  log_level           INTEGER                                                  NOT NULL,
  file_path           TEXT,
  thumbnail_file_path TEXT,
  content_type        TEXT
);

CREATE TABLE activity (
  id            BIGSERIAL CONSTRAINT activity_pk PRIMARY KEY,
  user_id       BIGINT REFERENCES users (id) ON DELETE CASCADE           NOT NULL,
  entity        ACTIVITY_ENTITY_ENUM                                     NOT NULL,
  action        VARCHAR(128)                                             NOT NULL,
  details       JSONB                                                    NULL,
  creation_date TIMESTAMP                                                NOT NULL
);

----------------------------------------------------------------------------------------


------------------------------ Issue ticket many to many ------------------------------

CREATE TABLE issue_group (
  issue_group_id SMALLSERIAL CONSTRAINT issue_group_pk PRIMARY KEY,
  issue_group    ISSUE_GROUP_ENUM NOT NULL
);

CREATE TABLE issue_type (
  id             BIGSERIAL CONSTRAINT issue_type_pk PRIMARY KEY,
  issue_group_id SMALLINT REFERENCES issue_group (issue_group_id) ON DELETE CASCADE,
  locator        VARCHAR(64), -- issue string identifier
  issue_name     VARCHAR(256), -- issue full name
  abbreviation   VARCHAR(64), -- issue abbreviation
  hex_color      VARCHAR(7)
);

CREATE TABLE issue_statistics (
  id            BIGSERIAL NOT NULL CONSTRAINT pk_issue_statistics PRIMARY KEY,
  issue_type_id BIGINT REFERENCES issue_type (id),
  counter       INT DEFAULT 0,
  item_id       BIGINT REFERENCES test_item_results (item_id) ON DELETE CASCADE,
  launch_id     BIGINT REFERENCES launch (id) ON DELETE CASCADE,

  CONSTRAINT unique_issue_item UNIQUE (issue_type_id, item_id),
  CONSTRAINT unique_issue_launch UNIQUE (issue_type_id, launch_id),
  CHECK (issue_statistics.counter >= 0)
);

CREATE TABLE issue_type_project_configuration (
  configuration_id BIGINT REFERENCES project_configuration,
  issue_type_id    BIGINT REFERENCES issue_type,
  CONSTRAINT issue_type_project_configuration_pk PRIMARY KEY (configuration_id, issue_type_id)
);

CREATE TABLE execution_statistics (
  id        BIGSERIAL CONSTRAINT pk_execution_statistics PRIMARY KEY,
  counter   INT     DEFAULT 0,
  status    TEXT NOT NULL,
  positive  BOOLEAN DEFAULT FALSE,
  item_id   BIGINT REFERENCES test_item_results (item_id) ON DELETE CASCADE,
  launch_id BIGINT REFERENCES launch (id) ON DELETE CASCADE,

  CONSTRAINT unique_status_item UNIQUE (status, item_id),
  CONSTRAINT unique_status_launch UNIQUE (status, launch_id),
  CHECK (execution_statistics.counter >= 0)
);
----------------------------------------------------------------------------------------


CREATE TABLE issue (
  issue_id          BIGINT CONSTRAINT issue_pk PRIMARY KEY REFERENCES test_item_results (item_id) ON DELETE CASCADE,
  issue_type        BIGINT REFERENCES issue_type (id),
  issue_description TEXT,
  auto_analyzed     BOOLEAN DEFAULT FALSE,
  ignore_analyzer   BOOLEAN DEFAULT FALSE
);

CREATE TABLE ticket (
  id           BIGSERIAL CONSTRAINT ticket_pk PRIMARY KEY,
  ticket_id    VARCHAR(64)                                                   NOT NULL UNIQUE,
  submitter_id INTEGER REFERENCES users (id)                                 NOT NULL,
  submit_date  TIMESTAMP DEFAULT now()                                       NOT NULL,
  bts_id       INTEGER REFERENCES bug_tracking_system (id) ON DELETE CASCADE NOT NULL,
  url          VARCHAR(256)                                                  NOT NULL
);

CREATE TABLE issue_ticket (
  issue_id  BIGINT REFERENCES issue (issue_id),
  ticket_id BIGINT REFERENCES ticket (id),
  CONSTRAINT issue_ticket_pk PRIMARY KEY (issue_id, ticket_id)
);

------- Functions and triggers -----------------------


CREATE OR REPLACE FUNCTION increment_parent_execution_statistics()
  RETURNS TRIGGER AS $$
DECLARE r BIGINT;
BEGIN
  FOR r IN
  (WITH RECURSIVE item_structure(parent_id, item_id) AS (
    SELECT
      parent_id,
      tir.item_id
    FROM test_item_structure tis
      JOIN test_item_results tir ON tis.item_id = tir.item_id
    WHERE tir.item_id = NEW.item_id
    UNION ALL
    SELECT
      tis.parent_id,
      tis.item_id
    FROM item_structure tis_r, test_item_structure tis
      JOIN test_item_results tir ON tis.item_id = tir.item_id
    WHERE tis.item_id = tis_r.parent_id)
  SELECT item_structure.item_id
  FROM item_structure
  WHERE NOT item_id = NEW.item_id)
  LOOP
    INSERT INTO execution_statistics (counter, status, positive, item_id) VALUES (1, new.status, CASE WHEN new.positive = FALSE
      THEN FALSE END, r)
    ON CONFLICT (status, item_id)
      DO UPDATE SET counter = execution_statistics.counter + 1, positive = CASE WHEN new.positive = FALSE
        THEN FALSE END;
  END LOOP;

  INSERT INTO execution_statistics (counter, status, positive, launch_id) VALUES (1, new.status, CASE WHEN new.positive = FALSE
    THEN FALSE END,
                                                                                  (SELECT launch_id
                                                                                   FROM launch
                                                                                     JOIN test_item ON launch.id = test_item.launch_id
                                                                                   WHERE test_item.item_id = new.item_id)
  )
  ON CONFLICT (status, launch_id)
    DO UPDATE SET counter = execution_statistics.counter + 1, positive = CASE WHEN new.positive = FALSE
      THEN FALSE END;
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION increment_parent_execution_statistics()
  RETURNS TRIGGER AS $$
DECLARE r BIGINT;
BEGIN
  FOR r IN
  (WITH RECURSIVE item_structure(parent_id, item_id) AS (
    SELECT
      parent_id,
      tir.item_id
    FROM test_item_structure tis
      JOIN test_item_results tir ON tis.item_id = tir.item_id
    WHERE tir.item_id = NEW.item_id
    UNION ALL
    SELECT
      tis.parent_id,
      tis.item_id
    FROM item_structure tis_r, test_item_structure tis
      JOIN test_item_results tir ON tis.item_id = tir.item_id
    WHERE tis.item_id = tis_r.parent_id)
  SELECT item_structure.item_id
  FROM item_structure
  WHERE NOT item_id = NEW.item_id)
  LOOP
    INSERT INTO execution_statistics (counter, status, positive, item_id) VALUES (1, new.status, CASE WHEN new.positive = FALSE
      THEN FALSE END, r)
    ON CONFLICT (status, item_id)
      DO UPDATE SET counter = execution_statistics.counter + 1, positive = CASE WHEN new.positive = FALSE
        THEN FALSE END;
  END LOOP;

  INSERT INTO execution_statistics (counter, status, positive, launch_id) VALUES (1, new.status, CASE WHEN new.positive = FALSE
    THEN FALSE END,
                                                                                  (SELECT launch_id
                                                                                   FROM launch
                                                                                     JOIN test_item ON launch.id = test_item.launch_id
                                                                                   WHERE test_item.item_id = new.item_id)
  )
  ON CONFLICT (status, launch_id)
    DO UPDATE SET counter = execution_statistics.counter + 1, positive = CASE WHEN new.positive = FALSE
      THEN FALSE END;
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION increment_parent_issue_stats()
  RETURNS TRIGGER AS $$
DECLARE   cur_item_id   BIGINT;
  DECLARE cur_launch_id BIGINT;
BEGIN
  FOR cur_item_id IN

  (WITH RECURSIVE item_structure(parent_id, item_id) AS (
    SELECT
      parent_id,
      tir.item_id
    FROM test_item_structure tis
      JOIN test_item_results tir ON tis.item_id = tir.item_id
    WHERE tir.item_id = NEW.item_id
    UNION ALL
    SELECT
      tis.parent_id,
      tis.item_id
    FROM item_structure tis_r, test_item_structure tis
      JOIN test_item_results tir ON tis.item_id = tir.item_id
    WHERE tis.item_id = tis_r.parent_id)
  SELECT item_structure.item_id
  FROM item_structure
  WHERE NOT item_id = NEW.item_id)

  LOOP

    UPDATE issue_statistics
    SET counter = issue_statistics.counter - 1
    WHERE issue_type_id = old.issue_type_id AND item_id = cur_item_id;

    INSERT INTO issue_statistics (issue_type_id, counter, item_id) VALUES (new.issue_type_id, 1, cur_item_id)
    ON CONFLICT (issue_type_id, item_id)
      DO UPDATE SET counter = issue_statistics.counter + 1;

  END LOOP;

  cur_launch_id = (SELECT launch.id
                   FROM launch
                     JOIN test_item
                       ON launch.id = test_item.launch_id
                   WHERE
                     test_item.item_id = new.item_id);

  UPDATE issue_statistics
  SET counter = issue_statistics.counter - 1
  WHERE issue_type_id = old.issue_type_id AND launch_id = cur_launch_id;

  INSERT INTO issue_statistics (issue_type_id, counter, launch_id) VALUES (new.issue_type_id, 1, cur_launch_id)
  ON CONFLICT (issue_type_id, launch_id)
    DO UPDATE SET counter = issue_statistics.counter + 1;

  RETURN NULL;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_last_launch_number()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  NEW.number = (SELECT number
                FROM launch
                WHERE name = NEW.name AND project_id = NEW.project_id
                ORDER BY number DESC
                LIMIT 1) + 1;
  NEW.number = CASE WHEN NEW.number IS NULL
    THEN 1
               ELSE NEW.number END;
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE FUNCTION check_wired_tickets()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  DELETE FROM ticket
  WHERE (SELECT count(issue_ticket.ticket_id)
         FROM issue_ticket
         WHERE issue_ticket.ticket_id = old.ticket_id) = 0 AND ticket.id = old.ticket_id;
  RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql;


CREATE FUNCTION check_wired_widgets()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  DELETE FROM widget
  WHERE (SELECT count(dashboard_widget.widget_id)
         FROM dashboard_widget
         WHERE dashboard_widget.widget_id = old.widget_id) = 0 AND widget.id = old.widget_id;
  RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER after_ticket_delete
AFTER DELETE
  ON issue_ticket
FOR EACH ROW EXECUTE PROCEDURE check_wired_tickets();


CREATE TRIGGER after_widget_delete
AFTER DELETE
  ON dashboard_widget
FOR EACH ROW EXECUTE PROCEDURE check_wired_widgets();


CREATE TRIGGER last_launch_number_trigger
BEFORE INSERT
  ON launch
FOR EACH ROW
EXECUTE PROCEDURE get_last_launch_number();


CREATE TRIGGER after_update_on_execution_statistics
AFTER UPDATE ON execution_statistics
FOR EACH ROW WHEN (pg_trigger_depth() = 0) EXECUTE PROCEDURE increment_parent_execution_statistics();

CREATE TRIGGER after_update_on_issue_statistics
AFTER UPDATE ON issue_statistics
FOR EACH ROW WHEN (pg_trigger_depth() = 0) EXECUTE PROCEDURE increment_parent_issue_stats();

