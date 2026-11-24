-- ============================================================================
-- PIPELINE ITERATION: summary, description and details
--
--   summary      one line outcome of the run, e.g. "Passed · $17.82 · 15.4M tokens"
--   description  what the run is for, e.g. "Implement test case · EPMRPP-105554: Invite user modal"
--   details      information about the run as a whole that applies to all its stages,
--                e.g. "orchestrator $1.81 + 6 stages $16.01"
--
-- The new status categories TIMED_OUT and INTERRUPTED need no change here: status_category is a plain
-- VARCHAR(16) with no check constraint.
-- ============================================================================

ALTER TABLE pipeline_iteration
    ADD COLUMN IF NOT EXISTS summary     VARCHAR(512),
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS details     TEXT;
