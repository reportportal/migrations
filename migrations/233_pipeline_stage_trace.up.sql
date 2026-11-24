-- ============================================================================
-- PIPELINE STAGE TRACE: what the agent of a stage attempt was given, how it reasoned, which tools it
-- called and what it returned (US-AI-FCTRY-021, "Open trace").
--
--   pipeline_stage_trace        one row per reported attempt of a stage: whether its trace arrived
--   pipeline_stage_trace_event  the ordered events of that attempt, text kept in full
--
-- Both are keyed by (iteration_id, stage_key, attempt) like pipeline_stage_attempt, so a trace survives
-- the stage row being recreated and is deleted together with its iteration. They are deliberately not
-- columns of the stage: the iteration list and the stage panel never load event texts.
-- ============================================================================

CREATE TABLE IF NOT EXISTS pipeline_stage_trace (
    id                  BIGSERIAL PRIMARY KEY,
    iteration_id        BIGINT        NOT NULL REFERENCES pipeline_iteration (id) ON DELETE CASCADE,
    stage_key           VARCHAR(128)  NOT NULL,
    attempt             INTEGER       NOT NULL,
    -- REPORTED: events arrived; NOT_REPORTED: the job could not report them, the reason says why
    status              VARCHAR(16)   NOT NULL,
    not_reported_reason TEXT          NULL,
    reported_at         TIMESTAMP     NOT NULL,
    CONSTRAINT unq_pipeline_stage_trace UNIQUE (iteration_id, stage_key, attempt)
);

CREATE TABLE IF NOT EXISTS pipeline_stage_trace_event (
    id           BIGSERIAL PRIMARY KEY,
    iteration_id BIGINT        NOT NULL REFERENCES pipeline_iteration (id) ON DELETE CASCADE,
    stage_key    VARCHAR(128)  NOT NULL,
    attempt      INTEGER       NOT NULL,
    -- position within the attempt; reporting the same seq again replaces the event
    seq          INTEGER       NOT NULL,
    type         VARCHAR(32)   NOT NULL,
    title        VARCHAR(512)  NULL,
    offset_ms    BIGINT        NULL,
    duration_ms  BIGINT        NULL,
    target       VARCHAR(1024) NULL,
    text         TEXT          NULL,
    -- structured part of the event, e.g. per case grader scores {"caseId": "TC-12", "criteria": [...]}
    data         JSONB         NULL,
    CONSTRAINT unq_pipeline_stage_trace_event UNIQUE (iteration_id, stage_key, attempt, seq)
);
