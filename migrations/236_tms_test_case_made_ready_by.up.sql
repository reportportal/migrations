-- ============================================================================
-- TMS TEST CASE "MADE READY BY" (stories US-AI-FCTRY-005, -007, -013)
--
-- Who made the case Ready and when: a user (Approve / Mark as ready) or Auto-Ready. Set on the Draft -> Ready change
-- and cleared when the case goes back to Draft. The full history of status changes is kept in the project activity;
-- these columns only make "Made Ready by" cheap to read for a page of cases, and independent of the activity
-- retention period.
-- ============================================================================

ALTER TABLE tms_test_case ADD COLUMN IF NOT EXISTS ready_by_type VARCHAR(16);
ALTER TABLE tms_test_case ADD COLUMN IF NOT EXISTS ready_by_user_id BIGINT;
ALTER TABLE tms_test_case ADD COLUMN IF NOT EXISTS ready_at TIMESTAMP;
