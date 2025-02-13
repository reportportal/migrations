DROP TABLE IF EXISTS tms_test_plan_attribute;
DROP TABLE IF EXISTS tms_test_case_attribute;
DROP TABLE IF EXISTS tms_manual_scenario_attribute;
DROP TABLE IF EXISTS tms_attachment;
DROP TABLE IF EXISTS tms_step;
DROP TABLE IF EXISTS tms_manual_scenario;
DROP TABLE IF EXISTS tms_test_case_version;
DROP TABLE IF EXISTS tms_test_case;
DROP TABLE IF EXISTS tms_test_folder;

-- Removing the ALTER statement on tms_environment table
ALTER TABLE tms_environment DROP CONSTRAINT IF EXISTS tms_environment_fk_test_plan;

DROP TABLE IF EXISTS tms_test_plan;
DROP TABLE IF EXISTS tms_environment;
DROP TABLE IF EXISTS tms_product_version;
DROP TABLE IF EXISTS tms_attribute;
