DO
$$DECLARE
  defaultproject BIGINT;
  superadminproject BIGINT;
  defaultid BIGINT;
  superadmin BIGINT;
  ldap BIGINT;
  rally BIGINT;
  jira BIGINT;
  email BIGINT;
BEGIN

    INSERT INTO server_settings (key, value) VALUES ('server.analytics.all', 'true');
    INSERT INTO server_settings (key, value) VALUES ('server.details.instance', gen_random_uuid());

    INSERT INTO integration_type (enabled, name, auth_flow, creation_date, group_type) VALUES (TRUE, 'test integration type', 'LDAP', now(), 'AUTH');
    ldap := (SELECT currval(pg_get_serial_sequence('integration_type', 'id')));

    INSERT INTO integration_type (enabled, name, auth_flow, creation_date, group_type) VALUES (TRUE, 'RALLY', 'OAUTH', now(), 'BTS') ;
    rally := (SELECT currval(pg_get_serial_sequence('integration_type', 'id')));

    INSERT INTO integration_type (enabled, name, auth_flow, creation_date, group_type) VALUES (TRUE, 'JIRA', 'BASIC', now(), 'BTS');
    jira := (SELECT currval(pg_get_serial_sequence('integration_type', 'id')));

    INSERT INTO integration_type (enabled, name, creation_date, group_type) VALUES (TRUE, 'email', now(), 'NOTIFICATION');
    email := (SELECT currval(pg_get_serial_sequence('integration_type', 'id')));

    INSERT INTO issue_group (issue_group_id, issue_group) VALUES (1, 'TO_INVESTIGATE');
    INSERT INTO issue_group (issue_group_id, issue_group) VALUES (2, 'AUTOMATION_BUG');
    INSERT INTO issue_group (issue_group_id, issue_group) VALUES (3, 'PRODUCT_BUG');
    INSERT INTO issue_group (issue_group_id, issue_group) VALUES (4, 'NO_DEFECT');
    INSERT INTO issue_group (issue_group_id, issue_group) VALUES (5, 'SYSTEM_ISSUE');

    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (1, 'ti001', 'To Investigate', 'TI', '#ffb743');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (2, 'ab001', 'Automation Bug', 'AB', '#f7d63e');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (3, 'pb001', 'Product Bug', 'PB', '#ec3900');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (4, 'nd001', 'No Defect', 'ND', '#777777');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (5, 'si001', 'System Issue', 'SI', '#0274d1');

    INSERT INTO attribute (name) VALUES ('job.interruptJobTime');
    INSERT INTO attribute (name) VALUES ('job.keepLaunches');
    INSERT INTO attribute (name) VALUES ('job.keepLogs');
    INSERT INTO attribute (name) VALUES ('job.keepScreenshots');
    INSERT INTO attribute (name) VALUES ('analyzer.minDocFreq');
    INSERT INTO attribute (name) VALUES ('analyzer.minTermFreq');
    INSERT INTO attribute (name) VALUES ('analyzer.minShouldMatch');
    INSERT INTO attribute (name) VALUES ('analyzer.numberOfLogLines');
    INSERT INTO attribute (name) VALUES ('analyzer.indexingRunning');
    INSERT INTO attribute (name) VALUES ('analyzer.isAutoAnalyzerEnabled');
    INSERT INTO attribute (name) VALUES ('analyzer.autoAnalyzerMode');
    INSERT INTO attribute (name) VALUES ('notifications.enabled');
    INSERT INTO attribute (name) VALUES ('email.from');

    -- Superadmin project and user
    INSERT INTO project (name, project_type, creation_date, metadata) VALUES ('superadmin_personal', 'PERSONAL', now(), '{"metadata": {"additional_info": ""}}');
    superadminproject := (SELECT currval(pg_get_serial_sequence('project', 'id')));

    INSERT INTO users (login, password, email, role, type, full_name, expired, metadata)
    VALUES ('superadmin', '5d39d85bddde885f6579f8121e11eba2', 'superadminemail@domain.com', 'ADMINISTRATOR', 'INTERNAL', 'tester', FALSE,
            '{"metadata": {}}');
    superadmin := (SELECT currval(pg_get_serial_sequence('users', 'id')));

    INSERT INTO project_user (user_id, project_id, project_role) VALUES (superadmin, superadminproject, 'PROJECT_MANAGER');

    -- Default project and user
    INSERT INTO project (name, project_type, creation_date, metadata) VALUES ('default_personal', 'PERSONAL', now(), '{"metadata": {"additional_info": ""}}');
    defaultproject := (SELECT currval(pg_get_serial_sequence('project', 'id')));

    INSERT INTO users (login, password, email, role, type, full_name, expired, metadata)
    VALUES ('default', '3fde6bb0541387e4ebdadf7c2ff31123', 'defaultemail@domain.com', 'USER', 'INTERNAL', 'tester', FALSE,
            '{"metadata": {}}');
    defaultid := (SELECT currval(pg_get_serial_sequence('users', 'id')));

    INSERT INTO project_user (user_id, project_id, project_role) VALUES (defaultid, defaultproject, 'PROJECT_MANAGER');

    -- Project configurations

    INSERT INTO issue_type_project (project_id, issue_type_id) VALUES
    (superadminproject, 1), (superadminproject, 2), (superadminproject, 3), (superadminproject, 4), (superadminproject, 5),
    (defaultproject, 1),(defaultproject, 2),(defaultproject, 3),(defaultproject, 4),(defaultproject, 5);

    INSERT INTO integration (project_id, type, enabled, creation_date) VALUES (superadminproject, rally, FALSE, now()), (defaultproject, rally, FALSE, now());
    INSERT INTO integration (project_id, type, enabled, creation_date) VALUES (superadminproject, jira, FALSE, now()), (defaultproject, jira, FALSE, now());

    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (1, '1 day', defaultproject), (1, '1 day', superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (2, '3 months', defaultproject), (2, '3 months', superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (3, '2 weeks', defaultproject), (3, '2 weeks', superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (4, '2 weeks', defaultproject), (4, '2 weeks', superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (5, 7, defaultproject), (5, 7, superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (6, 1, defaultproject), (6, 1, superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (7, 80, defaultproject), (7, 80, superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (8, 2, defaultproject), (8, 2, superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (9, FALSE, defaultproject), (9, FALSE, superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (10, FALSE, defaultproject), (10, FALSE, superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (11, 'LAUNCH_NAME', defaultproject), (11, 'LAUNCH_NAME', superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (12, 'true', defaultproject), (12, 'true', superadminproject);
    INSERT INTO project_attribute (attribute_id, value, project_id) VALUES (13, 'reportportal@example.com', defaultproject), (13, 'reportportal@example.com', superadminproject);

END
$$;
