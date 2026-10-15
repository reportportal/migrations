-- ============================================================================
-- REVERT MANUAL LAUNCH CREATION PERFORMANCE INDEXES
-- ============================================================================

DROP INDEX IF EXISTS idx_launch_test_plan_id;
DROP INDEX IF EXISTS idx_tms_test_folder_test_item_launch_folder;
