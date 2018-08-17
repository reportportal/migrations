INSERT INTO filter (id, name, project_id, target, description) VALUES (1, 'launch name', 1, 'com.epam.ta.reportportal.entity.launch.Launch', null);
INSERT INTO filter (id, name, project_id, target, description) VALUES (2, 'launch_name_filter', 1, 'com.epam.ta.reportportal.entity.Activity', null);
INSERT INTO user_filter(id) VALUES (1);
INSERT INTO user_filter(id) VALUES (2);
INSERT INTO filter_condition (id, filter_id, condition, value, field, negative) VALUES (8, 1, 'NOT_EQUALS', 'IN_PROGRESS', 'status', false);
INSERT INTO filter_condition (id, filter_id, condition, value, field, negative) VALUES (7, 1, 'EQUALS', 'DEFAULT', 'mode', false);
INSERT INTO filter_condition (id, filter_id, condition, value, field, negative) VALUES (6, 1, 'EQUALS', '1', 'project_id', false);
INSERT INTO filter_condition (id, filter_id, condition, value, field, negative) VALUES (10, 2, 'EQUALS', '1', 'project_id', false);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (2, 'start', null, 'launch_statistics', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (4, 'start', null, 'passing_rate_per_launch', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (5, 'start', null, 'passing_rate_summary', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (6, 'start', null, 'cases_trend', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (7, 'my widget', null, 'bug_trend', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (3, 'start', null, 'investigated_trend', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (12, 'table', null, 'launches_table', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (8, 'comparison', null, 'launches_comparison_chart', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (9, 'duration', null, 'launches_duration_chart', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (10, 'not passed', null, 'not_passed', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (11, 'not passed', null, 'most_failed_test_cases', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (17, 'table', null, 'activity_stream', 1000, 1, 2);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (1, 'start', null, 'overall_statistics', 1000, 1, 1);
INSERT INTO widget (id, name, description, widget_type, items_count, project_id, filter_id) VALUES (18, 'unique', null, 'unique_bug_table', 1000, 1, 2);
INSERT INTO widget_option (id, widget_id, option) VALUES (1, 1, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (2, 2, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (3, 3, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (5, 5, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (6, 6, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (7, 7, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (9, 9, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (10, 10, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (11, 11, 'launch_name_filter');
INSERT INTO widget_option (id, widget_id, option) VALUES (12, 12, 'filterName');
INSERT INTO widget_option (id, widget_id, option) VALUES (8, 8, 'launch_name_filter');
INSERT INTO widget_option (id, widget_id, option) VALUES (4, 4, 'launch_name_filter');
INSERT INTO widget_option (id, widget_id, option) VALUES (17, 17, 'login');
INSERT INTO widget_option (id, widget_id, option) VALUES (18, 17, 'activity_type');
INSERT INTO widget_option_value (id, value) VALUES (1, 'New_filter');
INSERT INTO widget_option_value (id, value) VALUES (2, 'New_filter');
INSERT INTO widget_option_value (id, value) VALUES (3, 'New_filter');
INSERT INTO widget_option_value (id, value) VALUES (4, 'launch name');
INSERT INTO widget_option_value (id, value) VALUES (5, 'New filter');
INSERT INTO widget_option_value (id, value) VALUES (6, 'New filter');
INSERT INTO widget_option_value (id, value) VALUES (7, 'New filter');
INSERT INTO widget_option_value (id, value) VALUES (8, 'launch name');
INSERT INTO widget_option_value (id, value) VALUES (9, 'New filter');
INSERT INTO widget_option_value (id, value) VALUES (10, 'New filter');
INSERT INTO widget_option_value (id, value) VALUES (11, 'launch name');
INSERT INTO widget_option_value (id, value) VALUES (12, 'New filter');
INSERT INTO widget_option_value (id, value) VALUES (17, 'default');
INSERT INTO widget_option_value (id, value) VALUES (18, 'CREATE_ITEM');
INSERT INTO widget_option_value (id, value) VALUES (18, 'UPDATE_LAUNCH');


INSERT INTO content_field (id, field) VALUES (2,  'statistics$executions$passed');
INSERT INTO content_field (id, field) VALUES (2,  'statistics$defects$automation_bug$AB001');
INSERT INTO content_field (id,  field) VALUES ( 4, 'statistics$executions$failed');
INSERT INTO content_field (id,  field) VALUES ( 5, 'statistics$executions$skipped');
INSERT INTO content_field (id,  field) VALUES ( 6, 'statistics$executions$passed');
INSERT INTO content_field (id,  field) VALUES ( 7, 'statistics$defects$automation_bug$AB002');
INSERT INTO content_field (id,  field) VALUES ( 8, 'statistics$executions$passed');
INSERT INTO content_field (id,  field) VALUES ( 9, 'statistics$executions$failed');
INSERT INTO content_field (id,  field) VALUES ( 10, 'statistics$executions$passed');
INSERT INTO content_field (id,  field) VALUES ( 12, 'statistics$executions$skipped');
INSERT INTO content_field (id,  field) VALUES ( 12, 'statistics$defects$product_bug$PB001');
INSERT INTO content_field (id,  field) VALUES ( 8, 'groups');
INSERT INTO content_field (id,  field) VALUES (12, 'columns');


INSERT INTO issue_group(issue_group_id, issue_group) VALUES (1, 'TO_INVESTIGATE');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (2, 'AUTOMATION_BUG');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (3, 'PRODUCT_BUG');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (4, 'NO_DEFECT');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (5, 'SYSTEM_ISSUE');
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
BEGIN
  WHILE counter < 20 LOOP
    INSERT INTO launch (uuid, project_id, user_id, name, description, start_time, end_time, "number", mode, status)
    VALUES
      ('fc51ec81-de6f-4f3b-9630-f3f3a3490def', 1, 1, 'launch name', 'Description', now(), now(), counter+1, 'DEFAULT',
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

      INSERT INTO test_item_structure (parent_id, launch_id) VALUES (cur_item_id, cur_launch_id);
      cur_step_id = (SELECT currval(pg_get_serial_sequence('test_item_structure', 'structure_id')));

      INSERT INTO test_item (item_id, NAME, TYPE, start_time, description, last_modified, unique_id)
      VALUES (cur_step_id, 'Step', 'STEP', now(), 'description', now(), 'uniqueId3');

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

SELECT initSteps();