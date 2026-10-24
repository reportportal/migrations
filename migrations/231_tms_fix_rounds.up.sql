-- ============================================================================
-- TMS FIX ROUNDS (stories US-AI-FCTRY-011 and US-AI-FCTRY-012)
--
-- A reviewer comments the steps of an AI-generated test case; "Push to agent" starts a fix round that sends the
-- unsent comments to the factory. The agent fixes the case and reports a new pipeline iteration (a re-run of the one that produced the
-- case); the fix lands in the Library as a NEW default version of the same test case.
--
--   tms_test_case_review_comment  one reviewer comment on the precondition or a step of a test case
--   tms_test_case_fix_round       one fix round of one test case (one "Push to agent")
-- ============================================================================

CREATE TABLE IF NOT EXISTS tms_test_case_fix_round (
    id                    BIGSERIAL PRIMARY KEY,
    test_case_id          BIGINT NOT NULL REFERENCES tms_test_case (id) ON DELETE CASCADE,
    project_id            BIGINT NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    -- per test case: the first round is round 1
    round_number          INTEGER NOT NULL,
    -- PENDING while the agent works, then FIXED, FIXED_GRADE_FAILED or FAILED
    status                VARCHAR(24) NOT NULL,
    -- the iteration that produced the case; the agent reports its fix as a re-run of it
    previous_iteration_id BIGINT NOT NULL,
    -- the iteration the agent reported for this round, known once the agent has reported it
    result_iteration_id   BIGINT,
    requested_by          BIGINT NOT NULL,
    requested_at          TIMESTAMP NOT NULL,
    finished_at           TIMESTAMP,
    -- where the job was started (the workflow page; a dispatch does not return the run)
    workflow_url          TEXT,
    failure_reason        TEXT
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_tms_test_case_fix_round_number ON tms_test_case_fix_round (test_case_id, round_number);

-- a test case has at most one round running
CREATE UNIQUE INDEX IF NOT EXISTS unq_tms_test_case_fix_round_pending ON tms_test_case_fix_round (test_case_id) WHERE status = 'PENDING';

CREATE INDEX IF NOT EXISTS idx_tms_test_case_fix_round_pending_since ON tms_test_case_fix_round (requested_at) WHERE status = 'PENDING';

CREATE TABLE IF NOT EXISTS tms_test_case_review_comment (
    id            BIGSERIAL PRIMARY KEY,
    test_case_id  BIGINT NOT NULL REFERENCES tms_test_case (id) ON DELETE CASCADE,
    -- PRECONDITION, STEP (with step_number) or SCENARIO_TEXT (the instructions / expected result block of a Text case)
    target_type   VARCHAR(24) NOT NULL,
    -- 1-based position of the commented step; only for STEP
    step_number   INTEGER,
    comment_text  TEXT NOT NULL,
    author_id     BIGINT NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- NOT_SENT, SENT (agent fixing), ADDRESSED, NOT_ADDRESSED
    state         VARCHAR(16) NOT NULL DEFAULT 'NOT_SENT',
    -- the fix round that carried the comment to the agent, and the agent's answer to it
    fix_round_id  BIGINT REFERENCES tms_test_case_fix_round (id) ON DELETE SET NULL,
    round_number  INTEGER,
    agent_reason  TEXT
);

CREATE INDEX IF NOT EXISTS idx_tms_test_case_review_comment_test_case ON tms_test_case_review_comment (test_case_id);
CREATE INDEX IF NOT EXISTS idx_tms_test_case_review_comment_fix_round ON tms_test_case_review_comment (fix_round_id);

-- the pipeline iteration that produced a version of the test case (the first upload or a fix round)
ALTER TABLE tms_test_case_version
    ADD COLUMN IF NOT EXISTS pipeline_iteration_id BIGINT;

-- "Modified by agent": the case was changed by a fix round
ALTER TABLE tms_test_case
    ADD COLUMN IF NOT EXISTS modified_by_agent BOOLEAN NOT NULL DEFAULT FALSE;
