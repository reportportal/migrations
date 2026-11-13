-- ============================================================================
-- TMS TEST CASE ID INDEXES
-- ============================================================================

CREATE INDEX idx_tms_test_case_version_test_case_id ON tms_test_case_version (test_case_id);
CREATE INDEX idx_tms_test_case_attribute_test_case_id ON tms_test_case_attribute (test_case_id);
