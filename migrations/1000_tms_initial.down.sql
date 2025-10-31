-- Drop junction tables first
DROP INDEX IF EXISTS idx_tms_manual_scenario_preconditions_attachment_attachment_id;
DROP INDEX IF EXISTS idx_tms_manual_scenario_preconditions_attachment_preconditions_id;
DROP TABLE IF EXISTS tms_manual_scenario_preconditions_attachment;

DROP INDEX IF EXISTS idx_preconditions_attachment_attachment_id;
DROP INDEX IF EXISTS idx_preconditions_attachment_preconditions_id;
DROP INDEX IF EXISTS idx_tms_text_manual_scenario_attachment_scenario_id;
DROP INDEX IF EXISTS idx_tms_text_manual_scenario_attachment_attachment_id;
DROP TABLE IF EXISTS tms_text_manual_scenario_attachment;

DROP INDEX IF EXISTS idx_tms_step_attachment_attachment_id;
DROP INDEX IF EXISTS idx_tms_step_attachment_step_id;
DROP TABLE IF EXISTS tms_step_attachment;

DROP INDEX IF EXISTS idx_tms_attachment_path;
DROP INDEX IF EXISTS idx_tms_attachment_expires_at;
DROP TABLE IF EXISTS tms_attachment;

DROP INDEX IF EXISTS idx_tms_test_folder_test_item_test_folder_id;
DROP INDEX IF EXISTS idx_tms_test_folder_test_item_test_item_id;
DROP TABLE IF EXISTS tms_test_folder_test_item;

DROP INDEX IF EXISTS idx_tms_step_test_item_step_id;
DROP INDEX IF EXISTS idx_tms_step_test_item_test_item_id;
DROP TABLE IF EXISTS tms_step_test_item;

DROP INDEX IF EXISTS idx_tms_test_case_test_item_test_case_id;
DROP INDEX IF EXISTS idx_tms_test_case_test_item_test_item_id;
DROP TABLE IF EXISTS tms_test_case_test_item;

-- Drop tms_test_case_execution (note: tms_test_case_launch was removed from schema)
DROP INDEX IF EXISTS idx_tms_test_case_execution_snapshot;
DROP INDEX IF EXISTS idx_tms_test_case_execution_launch_case;
DROP INDEX IF EXISTS idx_tms_test_case_execution_launch_id;
DROP INDEX IF EXISTS idx_tms_test_case_execution_version_id;
DROP INDEX IF EXISTS idx_tms_test_case_execution_test_item_id;
DROP INDEX IF EXISTS idx_tms_test_case_execution_test_case_id;
DROP TABLE IF EXISTS tms_test_case_execution;

-- Drop search vectors and indexes
DROP INDEX IF EXISTS idx_tms_test_case_search_vector;
DROP INDEX IF EXISTS idx_tms_test_plan_search_vector;
DROP INDEX IF EXISTS idx_tms_attribute_search_vector;
DROP INDEX IF EXISTS idx_tms_test_folder_project_id;

-- Drop triggers
DROP TRIGGER IF EXISTS tms_test_case_search_vector_trigger ON tms_test_case;
DROP TRIGGER IF EXISTS tms_test_plan_search_vector_trigger ON tms_test_plan;
DROP TRIGGER IF EXISTS tms_attribute_search_vector_trigger ON tms_attribute;

-- Drop functions
DROP FUNCTION IF EXISTS update_tms_test_case_search_vector();
DROP FUNCTION IF EXISTS update_tms_test_plan_search_vector();
DROP FUNCTION IF EXISTS update_tms_attribute_search_vector();

-- Drop attribute tables
DROP TABLE IF EXISTS tms_test_plan_attribute;
DROP TABLE IF EXISTS tms_test_case_attribute;
DROP TABLE IF EXISTS tms_manual_scenario_attribute;

-- Drop step
DROP TABLE IF EXISTS tms_step;

-- Drop manual scenario tables
DROP TABLE IF EXISTS tms_steps_manual_scenario;
DROP TABLE IF EXISTS tms_text_manual_scenario;

DROP INDEX IF EXISTS idx_tms_manual_scenario_preconditions_scenario_unique;
DROP TABLE IF EXISTS tms_manual_scenario_preconditions;

DROP INDEX IF EXISTS idx_tms_manual_scenario_type;
DROP TABLE IF EXISTS tms_manual_scenario;

DROP TYPE IF EXISTS tms_manual_scenario_type;

-- Drop test case version
DROP INDEX IF EXISTS idx_tms_test_case_version_default;
DROP TABLE IF EXISTS tms_test_case_version;

-- Drop test plan test case junction table
DROP INDEX IF EXISTS idx_tms_test_plan_test_case_test_plan_id;
DROP INDEX IF EXISTS idx_tms_test_plan_test_case_test_case_id;
DROP TABLE IF EXISTS tms_test_plan_test_case;

-- Drop main entities
DROP TABLE IF EXISTS tms_test_case;
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

-- Revert launch table changes
ALTER TABLE launch DROP COLUMN IF EXISTS test_plan_id;
ALTER TABLE launch DROP COLUMN IF EXISTS launch_type;
DROP TYPE IF EXISTS LAUNCH_TYPE_ENUM;
