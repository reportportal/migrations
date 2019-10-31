DO
$$DECLARE
  ldap BIGINT;
  email BIGINT;
BEGIN

    INSERT INTO integration_type (enabled, name, auth_flow, creation_date, group_type) VALUES (TRUE, 'ldap', 'LDAP', now(), 'AUTH');
    ldap := (SELECT currval(pg_get_serial_sequence('integration_type', 'id')));

    INSERT INTO integration_type (enabled, name, creation_date, group_type) VALUES (TRUE, 'email', now(), 'NOTIFICATION');
    email := (SELECT currval(pg_get_serial_sequence('integration_type', 'id')));

    INSERT INTO issue_group (issue_group_id, issue_group) VALUES (1, 'TO_INVESTIGATE'),
                                                                 (2, 'AUTOMATION_BUG'),
                                                                 (3, 'PRODUCT_BUG'),
                                                                 (4, 'NO_DEFECT'),
                                                                 (5, 'SYSTEM_ISSUE');

    ALTER SEQUENCE issue_group_issue_group_id_seq RESTART WITH 6;

    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (1, 'ti001', 'To Investigate', 'TI', '#ffb743');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (2, 'ab001', 'Automation Bug', 'AB', '#f7d63e');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (3, 'pb001', 'Product Bug', 'PB', '#ec3900');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (4, 'nd001', 'No Defect', 'ND', '#777777');
    INSERT INTO issue_type (issue_group_id, locator, issue_name, abbreviation, hex_color) VALUES (5, 'si001', 'System Issue', 'SI', '#0274d1');

    ALTER SEQUENCE issue_type_id_seq RESTART WITH 6;

    INSERT INTO statistics_field (sf_id, name) VALUES (1, 'statistics$executions$total'),
                                                      (2, 'statistics$executions$passed'),
                                                      (3, 'statistics$executions$skipped'),
                                                      (4, 'statistics$executions$failed'),
                                                      (5, 'statistics$defects$automation_bug$total'),
                                                      (6, 'statistics$defects$automation_bug$ab001'),
                                                      (7, 'statistics$defects$product_bug$total'),
                                                      (8, 'statistics$defects$product_bug$pb001'),
                                                      (9, 'statistics$defects$system_issue$total'),
                                                      (10, 'statistics$defects$system_issue$si001'),
                                                      (11, 'statistics$defects$to_investigate$total'),
                                                      (12, 'statistics$defects$to_investigate$ti001'),
                                                      (13, 'statistics$defects$no_defect$total'),
                                                      (14, 'statistics$defects$no_defect$nd001');

    ALTER SEQUENCE statistics_field_sf_id_seq RESTART WITH 15;

    INSERT INTO attribute (name) VALUES ('job.interruptJobTime');
    INSERT INTO attribute (name) VALUES ('job.keepLaunches');
    INSERT INTO attribute (name) VALUES ('job.keepLogs');
    INSERT INTO attribute (name) VALUES ('job.keepScreenshots');
    INSERT INTO attribute (name) VALUES ('analyzer.minDocFreq');
    INSERT INTO attribute (name) VALUES ('analyzer.minTermFreq');
    INSERT INTO attribute (name) VALUES ('analyzer.minShouldMatch');
    INSERT INTO attribute (name) VALUES ('analyzer.numberOfLogLines');
    INSERT INTO attribute (name) VALUES ('analyzer.indexingRunning');
    INSERT INTO attribute (name) VALUES ('analyzer.isAutoPatternAnalyzerEnabled');
    INSERT INTO attribute (name) VALUES ('analyzer.isAutoAnalyzerEnabled');
    INSERT INTO attribute (name) VALUES ('analyzer.autoAnalyzerMode');
    INSERT INTO attribute (name) VALUES ('notifications.enabled');
    INSERT INTO attribute (name) VALUES ('email.from');

END
$$;
