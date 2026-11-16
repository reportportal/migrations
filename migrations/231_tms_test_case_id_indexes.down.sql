-- ============================================================================
-- REVERT TMS TEST CASE ID INDEXES
-- ============================================================================

DROP INDEX IF EXISTS idx_tms_test_case_attribute_test_case_id;
DROP INDEX IF EXISTS idx_tms_test_case_version_test_case_id;
