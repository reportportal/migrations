-- ============================================================================
-- PIPELINE STAGE TRACE EVENT: unit_key
--
-- Ties an event to one unit of the stage, so the events of a stage that delegates to several sub-agents
-- can be told apart. The value is the key of a row in the stage's units section,
-- e.g. 'test-case-review-single#2#1'. NULL means the event belongs to the stage itself
-- (the orchestrator's reasoning, the delegate calls).
-- It is free text, not a foreign key: the trace may be reported before the units table is complete.
-- ============================================================================

ALTER TABLE pipeline_stage_trace_event
    ADD COLUMN IF NOT EXISTS unit_key VARCHAR(256) NULL;
