CREATE OR REPLACE FUNCTION initSteps()
  RETURNS INT8 AS
$BODY$
DECLARE   counter       INT = 0;
  DECLARE step_counter  INT = 0;
  DECLARE cur_launch_id BIGINT;
  DECLARE cur_suite_id  BIGINT;
  DECLARE cur_item_id   BIGINT;
  DECLARE cur_step_id   BIGINT;
  DECLARE rand_status   STATUS_ENUM;
  DECLARE rand_name VARCHAR;
BEGIN
  WHILE counter < 20 LOOP
    INSERT INTO launch (uuid, project_id, user_id, name, description, start_time, end_time, number, mode, status)
    VALUES
      ('fc51ec81-de6f-4f3b-9630-f3f3a3490def', 1, 1, 'launch name', 'Description', now(), now(), 1, 'DEFAULT',
       'FAILED');
    cur_launch_id = (SELECT currval(pg_get_serial_sequence('launch', 'id')));

    INSERT INTO test_item_structure (launch_id) VALUES (cur_launch_id);
    cur_suite_id = (SELECT currval(pg_get_serial_sequence('test_item_structure', 'structure_id')));
    INSERT INTO test_item (item_id, name, type, start_time, description, last_modified, unique_id)
    VALUES (cur_suite_id, 'First suite', 'SUITE', now(), 'description', now(), 'uniqueId1');
    INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (cur_suite_id, 'FAILED', 0.35, now());

    INSERT INTO test_item_structure (parent_id, launch_id) VALUES (cur_suite_id, cur_launch_id);
    cur_item_id = (SELECT currval(pg_get_serial_sequence('test_item_structure', 'structure_id')));
    INSERT INTO test_item (item_id, name, type, start_time, description, last_modified, unique_id)
    VALUES (cur_item_id, 'First test', 'TEST', now(), 'description', now(), 'uniqueId2');
    INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (cur_item_id, 'FAILED', 0.35, now());

    WHILE step_counter < 250 LOOP
      rand_status = (ARRAY ['PASSED' :: STATUS_ENUM, 'SKIPPED' :: STATUS_ENUM, 'FAILED' :: STATUS_ENUM]) [floor(random() * 3) + 1];
      rand_name = (ARRAY ['step1', 'step2', 'step3', 'step4', 'step5']) [floor(random() * 5) + 1];

      INSERT INTO test_item_structure (parent_id, launch_id) VALUES (cur_item_id, cur_launch_id);
      cur_step_id = (SELECT currval(pg_get_serial_sequence('test_item_structure', 'structure_id')));

      INSERT INTO test_item (item_id, NAME, TYPE, start_time, description, last_modified, unique_id)
      VALUES (cur_step_id, rand_name, 'STEP', now(), 'description', now(), rand_name);

      INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (cur_step_id, rand_status, 0.35, now());

      UPDATE test_item_results
      SET status = rand_status
      WHERE result_id = cur_step_id;

      IF rand_status = 'FAILED'
      THEN
        INSERT INTO issue (issue_id, issue_type, issue_description) VALUES (cur_step_id, floor(random() * 6 + 1), 'issue description');
      END IF;

      step_counter = step_counter + 1;
    END LOOP;
    step_counter = 0;
    counter = counter + 1;
  END LOOP;
  RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql;


INSERT INTO oauth_registration (id, client_id, client_secret, token_uri, user_info_endpoint_uri, auth_grant_type, client_auth_method)
VALUES ('github', 'f4cec43d4541283879c4', 'a31aa6de3e27c11d90762cad11936727d6b0759e',
        'https://github.com/login/oauth/access_token', 'https://api.github.com/use', 'authorization_code', 'basic');

INSERT INTO oauth_registration_scope (id, oauth_registration_fk, scope) VALUES (1, 'github', 'user');

INSERT INTO project (name) VALUES ('default_personal');
INSERT INTO project_configuration (id, project_type, interrupt_timeout, keep_logs_interval, keep_screenshots_interval)
VALUES (1, 'PERSONAL', '1 day', '1 day', '1 day');

INSERT INTO users (id, login, password, email, role, type, default_project_id, full_name)
VALUES (1, 'vasia', '698d51a19d8a121ce581499d7b701668', 'vasia@domain.com', 'USER', 'INTERNAL', 1, 'Vasia Vasia');

INSERT INTO project_user (user_id, project_id, project_role) VALUES (1, 1, 'MEMBER');

INSERT INTO issue_group (issue_group) VALUES ('TO_INVESTIGATE');
INSERT INTO issue_group (issue_group) VALUES ('AUTOMATION_BUG');
INSERT INTO issue_group (issue_group) VALUES ('PRODUCT_BUG');
INSERT INTO issue_group (issue_group) VALUES ('NO_DEFECT');
INSERT INTO issue_group (issue_group) VALUES ('SYSTEM_ISSUE');


INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (1, 'TI001', 'To Investigate', 'TI', '#ffb743');
INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (2, 'AB001', 'Automation Bug', 'AB', '#f7d63e');
INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (3, 'PB001', 'Product Bug', 'PB', '#ec3900');
INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (4, 'ND001', 'No Defect', 'ND', '#777777');
INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (5, 'SI001', 'System Issue', 'SI', '#0274d1');
INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (2, 'AB002', 'My custom automation', 'CA', '#0276d1');
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id) VALUES (1, 1);
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id) VALUES (1, 2);
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id) VALUES (1, 3);
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id) VALUES (1, 4);
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id) VALUES (1, 5);
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id) VALUES (1, 6);

SELECT initSteps();



