
-- ============================================================================
-- REVERT LAUNCH TABLE CHANGES
-- ============================================================================

ALTER TABLE launch DROP COLUMN IF EXISTS test_plan_id;
ALTER TABLE launch DROP COLUMN IF EXISTS launch_type;

-- ============================================================================
-- DROP EXECUTION COMMENTS
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_execution_comment_attachment_attachment_id;
DROP INDEX IF EXISTS idx_tms_execution_comment_attachment_comment_id;
DROP TABLE IF EXISTS tms_test_case_execution_comment_attachment;

DROP INDEX IF EXISTS idx_tms_test_case_execution_comment_bts_ticket_comment_id;
DROP TABLE IF EXISTS tms_test_case_execution_comment_bts_ticket;

DROP INDEX IF EXISTS idx_tms_test_case_execution_comment_execution_id;
DROP TABLE IF EXISTS tms_test_case_execution_comment;

-- ============================================================================
-- DROP TEST CASE EXECUTION
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_case_execution_snapshot;
DROP INDEX IF EXISTS idx_tms_test_case_execution_launch_case;
DROP INDEX IF EXISTS idx_tms_test_case_execution_version_id;
DROP INDEX IF EXISTS idx_tms_test_case_execution_launch_id;
DROP INDEX IF EXISTS idx_tms_test_case_execution_test_item_id;
DROP INDEX IF EXISTS idx_tms_test_case_execution_test_case_id;
DROP TABLE IF EXISTS tms_test_case_execution;

-- ============================================================================
-- DROP ATTRIBUTE RELATIONSHIPS
-- ============================================================================

DROP TABLE IF EXISTS tms_test_plan_attribute;
DROP TABLE IF EXISTS tms_test_case_attribute;
DROP TABLE IF EXISTS tms_manual_scenario_attribute;

-- ============================================================================
-- DROP ATTACHMENT RELATIONSHIPS
-- ============================================================================

DROP INDEX IF EXISTS idx_preconditions_attachment_attachment_id;
DROP INDEX IF EXISTS idx_preconditions_attachment_preconditions_id;
DROP TABLE IF EXISTS tms_manual_scenario_preconditions_attachment;

DROP INDEX IF EXISTS idx_tms_text_manual_scenario_attachment_attachment_id;
DROP INDEX IF EXISTS idx_tms_text_manual_scenario_attachment_scenario_id;
DROP TABLE IF EXISTS tms_text_manual_scenario_attachment;

DROP INDEX IF EXISTS idx_tms_step_attachment_attachment_id;
DROP INDEX IF EXISTS idx_tms_step_attachment_step_id;
DROP TABLE IF EXISTS tms_step_attachment;

-- ============================================================================
-- DROP ATTACHMENTS
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_attachment_path;
DROP INDEX IF EXISTS idx_tms_attachment_expires_at;
DROP TABLE IF EXISTS tms_attachment;

-- ============================================================================
-- DROP STEP EXECUTION
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_step_execution_tms_step;
DROP INDEX IF EXISTS idx_tms_step_execution_launch;
DROP INDEX IF EXISTS idx_tms_step_execution_test_item;
DROP INDEX IF EXISTS idx_tms_step_execution_test_case;
DROP TABLE IF EXISTS tms_step_execution;

-- ============================================================================
-- DROP STEPS
-- ============================================================================

DROP TABLE IF EXISTS tms_step;

-- ============================================================================
-- DROP MANUAL SCENARIO TYPES
-- ============================================================================

DROP TABLE IF EXISTS tms_steps_manual_scenario;
DROP TABLE IF EXISTS tms_text_manual_scenario;

-- ============================================================================
-- DROP MANUAL SCENARIO PRECONDITIONS
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_manual_scenario_preconditions_scenario_unique;
DROP TABLE IF EXISTS tms_manual_scenario_preconditions;

-- ============================================================================
-- DROP MANUAL SCENARIO REQUIREMENTS
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_manual_scenario_requirement_scenario_id;
DROP TABLE IF EXISTS tms_manual_scenario_requirement;

-- ============================================================================
-- DROP MANUAL SCENARIO
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_manual_scenario_type;
DROP TABLE IF EXISTS tms_manual_scenario;

-- ============================================================================
-- DROP TEST CASE VERSION
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_case_version_default;
DROP TABLE IF EXISTS tms_test_case_version;

-- ============================================================================
-- DROP TEST PLAN - TEST CASE (Many-to-Many)
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_plan_test_case_test_case_id;
DROP INDEX IF EXISTS idx_tms_test_plan_test_case_test_plan_id;
DROP TABLE IF EXISTS tms_test_plan_test_case;

-- ============================================================================
-- DROP TEST CASE
-- ============================================================================

DROP TRIGGER IF EXISTS tms_test_case_search_vector_trigger ON tms_test_case;
DROP FUNCTION IF EXISTS update_tms_test_case_search_vector();
DROP INDEX IF EXISTS idx_tms_test_case_search_vector;
DROP TABLE IF EXISTS tms_test_case;

-- ============================================================================
-- DROP TEST FOLDER TEST ITEM
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_folder_test_item_test_item_id;
DROP INDEX IF EXISTS idx_tms_test_folder_test_item_test_folder_id;
DROP TABLE IF EXISTS tms_test_folder_test_item;

-- ============================================================================
-- DROP TEST FOLDER
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_folder_project_id;
DROP TABLE IF EXISTS tms_test_folder;

-- ============================================================================
-- DROP TEST PLAN
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_plan_milestone_id;
DROP INDEX IF EXISTS idx_tms_test_plan_project_id;
DROP INDEX IF EXISTS idx_tms_test_plan_search_vector;
DROP TRIGGER IF EXISTS tms_test_plan_search_vector_trigger ON tms_test_plan;
DROP FUNCTION IF EXISTS update_tms_test_plan_search_vector();
DROP TABLE IF EXISTS tms_test_plan;

-- ============================================================================
-- DROP MILESTONE
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_milestone_product_version_id;
DROP INDEX IF EXISTS idx_tms_milestone_project_id;
DROP TABLE IF EXISTS tms_milestone;

-- ============================================================================
-- DROP ENVIRONMENT
-- ============================================================================

DROP TABLE IF EXISTS tms_environment_dataset;
DROP TABLE IF EXISTS tms_environment;

-- ============================================================================
-- DROP DATASET
-- ============================================================================

DROP TABLE IF EXISTS tms_dataset_data;
DROP TABLE IF EXISTS tms_dataset;

-- ============================================================================
-- DROP PRODUCT VERSION
-- ============================================================================

DROP TABLE IF EXISTS tms_product_version;

-- ============================================================================
-- DROP ATTRIBUTE
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_attribute_project_value;
DROP INDEX IF EXISTS idx_tms_attribute_value_trgm;
DROP INDEX IF EXISTS idx_tms_attribute_project_key;
DROP INDEX IF EXISTS idx_tms_attribute_key_trgm;
DROP INDEX IF EXISTS idx_tms_attribute_project_id;
DROP TABLE IF EXISTS tms_attribute;

-- ============================================================================
-- DROP ENUMS
-- ============================================================================

DROP TYPE IF EXISTS LAUNCH_TYPE_ENUM;
DROP TYPE IF EXISTS tms_manual_scenario_type;
DROP TYPE IF EXISTS tms_milestone_type;
DROP TYPE IF EXISTS tms_milestone_status;
DROP TYPE IF EXISTS tms_dataset_type;

-- ============================================================================
-- DROP EXTENSIONS (optional)
-- ============================================================================

-- DROP EXTENSION IF EXISTS pg_trgm;

-- ============================================================================
-- END OF DROP SCRIPT
-- ============================================================================
