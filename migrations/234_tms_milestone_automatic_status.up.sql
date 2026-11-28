-- ============================================================================
-- TMS MILESTONE AUTOMATIC STATUS OPTIONS
-- ============================================================================
-- Three independent options of a milestone, all off by default (status changed manually).
-- NOT NULL with DEFAULT FALSE: existing milestones keep the manual behaviour, and older
-- service-api versions that do not know the columns can still insert milestones.

ALTER TABLE tms_milestone
    ADD COLUMN IF NOT EXISTS auto_start_on_start_date      BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS auto_start_on_first_execution BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS auto_complete_after_deadline  BOOLEAN NOT NULL DEFAULT FALSE;
