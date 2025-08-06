DROP INDEX IF EXISTS idx_tms_test_folder_test_item_test_folder_id;
DROP INDEX IF EXISTS idx_tms_test_folder_test_item_test_item_id;
DROP TABLE IF EXISTS tms_test_folder_test_item;

DROP INDEX IF EXISTS idx_tms_step_test_item_step_id;
DROP INDEX IF EXISTS idx_tms_step_test_item_test_item_id;
DROP TABLE IF EXISTS tms_step_test_item;

DROP INDEX IF EXISTS idx_tms_test_case_test_item_test_case_id;
DROP INDEX IF EXISTS idx_tms_test_case_test_item_test_item_id;
DROP TABLE IF EXISTS tms_test_case_test_item;

DROP INDEX IF EXISTS idx_tms_test_case_search_vector;
DROP INDEX IF EXISTS idx_tms_test_folder_project_id;
DROP TRIGGER IF EXISTS tms_test_case_search_vector_trigger ON tms_test_case;
DROP FUNCTION IF EXISTS update_tms_test_case_search_vector();
DROP TABLE IF EXISTS tms_test_plan_attribute;
DROP TABLE IF EXISTS tms_test_case_attribute;
DROP TABLE IF EXISTS tms_manual_scenario_attribute;
DROP TABLE IF EXISTS tms_attachment;
DROP TABLE IF EXISTS tms_step;

DROP TABLE IF EXISTS tms_steps_manual_scenario;
DROP TABLE IF EXISTS tms_text_manual_scenario;

DROP INDEX IF EXISTS idx_tms_manual_scenario_type;
DROP TABLE IF EXISTS tms_manual_scenario;

DROP TYPE IF EXISTS tms_manual_scenario_type;

DROP INDEX IF EXISTS idx_tms_test_case_version_default;

DROP TABLE IF EXISTS tms_test_case_version;
DROP TABLE IF EXISTS tms_test_case;
DROP TABLE IF EXISTS tms_test_plan_test_folder;
DROP TABLE IF EXISTS tms_test_folder;
DROP TABLE IF EXISTS tms_milestone;
DROP TABLE IF EXISTS tms_test_plan;
DROP TABLE IF EXISTS tms_environment_dataset;
DROP TABLE IF EXISTS tms_environment;
DROP TABLE IF EXISTS tms_product_version;
DROP TABLE IF EXISTS tms_dataset_data;
DROP TABLE IF EXISTS tms_dataset;
DROP TYPE IF EXISTS tms_dataset_type;
DROP TABLE IF EXISTS tms_attribute;
ALTER TABLE launch DROP COLUMN IF EXISTS launch_type;
DROP TYPE IF EXISTS LAUNCH_TYPE_ENUM;
