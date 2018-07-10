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

-- INSERT INTO launch (uuid, project_id, user_id, name, description, start_time, number, mode, status)
-- VALUES ('fc51ec81-de6f-4f3b-9630-f3f3a3490def', 1, 1, 'First launch', 'Description', now(), 1, 'DEFAULT', 'FAILED');
--
-- INSERT INTO test_item_structure (structure_id) VALUES (1);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (1, 1, 'First suite', 'SUITE', now(), 'description', now(), 'uniqueId1');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (1, 'FAILED', 0.35, now());
--
--
-- INSERT INTO test_item_structure (structure_id, parent_id) VALUES (2, 1);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (2, 1, 'First test', 'TEST', now(), 'description', now(), 'uniqueId2');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (2, 'FAILED', 0.35, now());
--
-- INSERT INTO test_item_structure (structure_id, parent_id) VALUES (3, 2);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (3, 1, 'First step', 'STEP', now(), 'description', now(), 'uniqueId3');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (3, 'PASSED', 0.35, now());
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (1, 1, 'PASSED', TRUE, 3, NULL);
--
-- INSERT INTO test_item_structure (structure_id, parent_id) VALUES (4, 2);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (4, 1, 'Second step', 'STEP', now(), 'description', now(), 'uniqueId4');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (4, 'SKIPPED', 0.35, now());
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (2, 1, 'SKIPPED', TRUE, 4, NULL);
--
--
-- INSERT INTO test_item_structure (structure_id, parent_id) VALUES (5, 2);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (5, 1, 'Third step', 'STEP', now(), 'description', now(), 'uniqueId5');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (5, 'FAILED', 0.35, now());
-- INSERT INTO issue (issue_type, issue_description, issue_id) VALUES (2, 'bug', 5);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (3, 1, 'FAILED', FALSE, 5, NULL);
--
--
-- INSERT INTO test_item_structure (structure_id, parent_id) VALUES (6, 2);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (6, 1, 'Fourth step', 'STEP', now(), 'description', now(), 'uniqueId6');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (6, 'FAILED', 0.35, now());
-- INSERT INTO issue (issue_type, issue_description, issue_id) VALUES (1, 'invest please', 6);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (4, 1, 'FAILED', FALSE, 6, NULL);
--
--
-- INSERT INTO test_item_structure (structure_id, parent_id) VALUES (7, 2);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (7, 1, 'RETRY step', 'STEP', now(), 'description', now(), 'uniqueId7');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (7, 'FAILED', 0.35, now());
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (5, 1, 'FAILED', FALSE, 7, NULL);
--
-- INSERT INTO test_item_structure (structure_id, parent_id, retry_of) VALUES (8, 2, 7);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (8, 1, 'RETRY step', 'STEP', now(), 'description', now(), 'uniqueId7');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (8, 'PASSED', 0.35, now());
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (6, 1, 'PASSED', FALSE, 8, NULL);
--
--
-- INSERT INTO test_item_structure (structure_id, parent_id) VALUES (9, 2);
-- INSERT INTO test_item (item_id, launch_id, name, type, start_time, description, last_modified, unique_id)
-- VALUES (9, 1, 'Fifth step', 'STEP', now(), 'description', now(), 'uniqueId6');
-- INSERT INTO test_item_results (result_id, status, duration, end_time) VALUES (9, 'FAILED', 0.35, now());
-- INSERT INTO issue (issue_type, issue_description, issue_id) VALUES (1, 'invest please', 9);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (7, 1, 'FAILED', FALSE, 9, NULL);
--
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (8, 4, 'FAILED', FALSE, 2, NULL);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (9, 1, 'SKIPPED', FALSE, 2, NULL);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (10, 2, 'PASSED', FALSE, 2, NULL);
--
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (11, 4, 'FAILED', FALSE, 1, NULL);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (12, 1, 'SKIPPED', FALSE, 1, NULL);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (13, 2, 'PASSED', FALSE, 1, NULL);
--
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (14, 4, 'FAILED', FALSE, NULL, 1);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (15, 1, 'SKIPPED', FALSE, NULL, 1);
-- INSERT INTO execution_statistics (id, counter, status, positive, item_id, launch_id) VALUES (16, 2, 'PASSED', FALSE, NULL, 1);
