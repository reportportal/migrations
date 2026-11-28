-- ============================================================================
-- REVERT TMS MILESTONE AUTOMATIC STATUS OPTIONS
-- ============================================================================

ALTER TABLE tms_milestone
    DROP COLUMN IF EXISTS auto_complete_after_deadline,
    DROP COLUMN IF EXISTS auto_start_on_first_execution,
    DROP COLUMN IF EXISTS auto_start_on_start_date;
