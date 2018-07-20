INSERT INTO project (name, additional_info, creation_date) VALUES ('default_personal', 'additional info', '2018-07-19 13:25:00');
INSERT INTO project_configuration (id, project_type, interrupt_timeout, keep_logs_interval, keep_screenshots_interval, created_on)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 'PERSONAL', '1 day', '1 month', '2 weeks', '2018-07-19 13:25:00');

INSERT INTO users (login, password, email, role, type, default_project_id, full_name, expired)
VALUES ('default', '3fde6bb0541387e4ebdadf7c2ff31123', 'defaultemail@domain.com', 'USER', 'INTERNAL',
        (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'tester', false);

INSERT INTO project_user (user_id, project_id, project_role)
VALUES ((SELECT currval(pg_get_serial_sequence('users', 'id'))), (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'MEMBER');

INSERT INTO project (name, additional_info, creation_date) VALUES ('superadmin_personal', 'another additional info', '2018-07-19 14:25:00');
INSERT INTO project_configuration (id, project_type, interrupt_timeout, keep_logs_interval, keep_screenshots_interval, created_on)
VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), 'PERSONAL', '1 day', '1 month', '2 weeks', '2018-07-19 14:25:00');

INSERT INTO users (login, password, email, role, type, default_project_id, full_name, expired)
VALUES ('superadmin', '5d39d85bddde885f6579f8121e11eba2', 'superadminemail@domain.com', 'ADMINISTRATOR', 'INTERNAL',
        (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'tester', false);

INSERT INTO project_user (user_id, project_id, project_role) VALUES
  ((SELECT currval(pg_get_serial_sequence('users', 'id'))), (SELECT currval(pg_get_serial_sequence('project', 'id'))), 'PROJECT_MANAGER');

INSERT INTO integration_type(
	name, auth_flow, creation_date, group_type)
	VALUES ('test integration type', 'LDAP', '2018-07-19 13:25:00', 'NOTIFICATION');

INSERT INTO integration(
	project_id, type, enabled, creation_date)
	VALUES ((SELECT currval(pg_get_serial_sequence('project', 'id'))), (SELECT currval(pg_get_serial_sequence('integration_type', 'id'))), true, '2018-07-19 13:25:00');

INSERT INTO ldap_synchronization_attributes(
	email, full_name, photo)
	VALUES ('mail', 'displayName', 'thumbnailPhoto');

INSERT INTO active_directory_config(
	id, url, base_dn, sync_attributes_id, domain)
	VALUES ((SELECT currval(pg_get_serial_sequence('integration', 'id'))), 'ldap://minsk.epam.com:3268', 'dc=epam,dc=com', (SELECT currval(pg_get_serial_sequence('ldap_synchronization_attributes', 'id'))), 'epam.com');

INSERT INTO auth_config(
	id, ldap_config_id, active_directory_config_id)
	VALUES ('default', null, (SELECT currval(pg_get_serial_sequence('integration', 'id'))));