-- ============================================================================
-- REVERT TMS TEST CASE CUSTOM ORDER INSIDE A FOLDER
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_case_folder_position;
ALTER TABLE tms_test_case DROP COLUMN IF EXISTS position;
