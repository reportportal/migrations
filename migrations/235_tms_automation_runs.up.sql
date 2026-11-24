-- ============================================================================
-- TMS AUTOMATION RUNS (stories US-AI-FCTRY-015 and US-AI-FCTRY-016)
--
-- "Automate" sends Ready test cases to the Test automation pipeline: ReportPortal creates ONE iteration of that
-- pipeline for all accepted cases and starts the CI job for it.
--
--   tms_test_case_automation_run   one test case sent to automation in one iteration
--
-- A case is "in progress" while the iteration of its latest run has not ended, "Automated" when the iteration
-- passed and "Failed" when it failed; the state is derived from the iteration, nothing here is updated later.
-- ============================================================================

CREATE TABLE IF NOT EXISTS tms_test_case_automation_run (
    id                   BIGSERIAL PRIMARY KEY,
    test_case_id         BIGINT NOT NULL REFERENCES tms_test_case (id) ON DELETE CASCADE,
    project_id           BIGINT NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    -- the automation iteration all cases of one "Automate" belong to; deleting it (a start CI refused) deletes the runs
    iteration_id         BIGINT NOT NULL REFERENCES pipeline_iteration (id) ON DELETE CASCADE,
    -- the stand the autotests run against, one of the environments of the CI connection
    environment          VARCHAR(255) NOT NULL,
    -- the default version of the case when it was sent; a different default version later means
    -- "Scenario changed after automation"
    test_case_version_id BIGINT,
    requested_by         BIGINT NOT NULL,
    requested_at         TIMESTAMP NOT NULL,
    -- where the job was started
    workflow_url         TEXT
);

-- the latest run of a case
CREATE INDEX IF NOT EXISTS idx_tms_test_case_automation_run_case ON tms_test_case_automation_run (test_case_id, id DESC);
CREATE INDEX IF NOT EXISTS idx_tms_test_case_automation_run_iteration ON tms_test_case_automation_run (iteration_id);
