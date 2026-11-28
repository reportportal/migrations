-- ============================================================================
-- TMS TEST CASE CUSTOM ORDER INSIDE A FOLDER
-- ============================================================================
-- Nullable on purpose: test cases without a position come after the ordered ones,
-- in creation order. Older service-api versions keep working without the column value.

ALTER TABLE tms_test_case ADD COLUMN IF NOT EXISTS position BIGINT;

CREATE INDEX IF NOT EXISTS idx_tms_test_case_folder_position ON tms_test_case (test_folder_id, position);
