INSERT INTO project (name, additional_info, creation_date) VALUES ('default_personal', 'additional info', now());
INSERT INTO project_configuration (id, project_type, interrupt_timeout, keep_logs_interval, keep_screenshots_interval, created_on)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 'PERSONAL', '1 day', '1 month', '2 weeks', now());

INSERT INTO issue_group(issue_group_id, issue_group) VALUES (1, 'TO_INVESTIGATE');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (2, 'AUTOMATION_BUG');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (3, 'PRODUCT_BUG');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (4, 'NO_DEFECT');
INSERT INTO issue_group(issue_group_id, issue_group) VALUES (5, 'SYSTEM_ISSUE');

INSERT INTO issue_type (id, issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (1, 1, 'TI001', 'To Investigate', 'TI', '#ffb743');
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 1);

INSERT INTO issue_type (id, issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (2, 2, 'AB001', 'Automation Bug', 'AB', '#f7d63e');
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 2);

INSERT INTO issue_type (id, issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (3, 3, 'PB001', 'Product Bug', 'PB', '#ec3900');
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 3);

INSERT INTO issue_type (id, issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (4, 4, 'ND001', 'No Defect', 'ND', '#777777');
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 4);

INSERT INTO issue_type (id, issue_group_id, locator, issue_name, abbreviation, hex_color)
VALUES (5, 5, 'SI001', 'System Issue', 'SI', '#0274d1');
INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 5);


INSERT INTO users (login, password, email, role, type, default_project_id, full_name, expired)
VALUES ('default', '3fde6bb0541387e4ebdadf7c2ff31123', 'defaultemail@domain.com', 'USER', 'INTERNAL',
        (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'tester', false);

INSERT INTO project_user (user_id, project_id, project_role)
VALUES ((SELECT currval(pg_get_serial_sequence('users', 'id'))), (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'MEMBER');

INSERT INTO project (name, additional_info, creation_date) VALUES ('superadmin_personal', 'another additional info', now());
INSERT INTO project_configuration (id, project_type, interrupt_timeout, keep_logs_interval, keep_screenshots_interval, created_on)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 'PERSONAL', '1 day', '1 month', '2 weeks', now());


INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 1);

INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 2);

INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 3);

INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 4);

INSERT INTO issue_type_project_configuration (configuration_id, issue_type_id)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 5);

INSERT INTO users (login, password, email, role, type, default_project_id, full_name, expired)
VALUES ('superadmin', '5d39d85bddde885f6579f8121e11eba2', 'superadminemail@domain.com', 'ADMINISTRATOR', 'INTERNAL',
        (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'tester', false);

INSERT INTO project_user (user_id, project_id, project_role) VALUES
  ((SELECT currval(pg_get_serial_sequence('users', 'id'))), (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'PROJECT_MANAGER');

INSERT INTO integration_type(
	name, auth_flow, creation_date, group_type)
	VALUES ('test integration type', 'LDAP', now(), 'NOTIFICATION');

INSERT INTO integration(
	project_id, type, enabled, creation_date)
	VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), (SELECT currval(pg_get_serial_sequence('integration_type', 'id'))), true, now());

INSERT INTO ldap_synchronization_attributes(
	email, full_name, photo)
	VALUES ('mail', 'displayName', 'thumbnailPhoto');
