-- Generic step tree for pipeline_stage: a stage may nest other stages (close to
-- an OpenTelemetry span tree / a Temporal activity tree), so any business
-- process -- not just test-case generation/grading -- can be modelled. Mirrors
-- the existing test_item.path (ltree) convention: parent_stage_id + path are
-- maintained in application code, no DB trigger.
--
-- graders/agent/note are dropped: they fold losslessly into the new free-form
-- attributes column (already the convention on pipeline_iteration.attributes)
-- or the existing metrics column -- genericity means no fixed grading-specific
-- columns, not that the data can no longer be reported.

ALTER TABLE pipeline_stage
    ADD COLUMN IF NOT EXISTS parent_stage_id BIGINT NULL REFERENCES pipeline_stage (id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS path LTREE NULL,
    ADD COLUMN IF NOT EXISTS attributes JSONB NULL,
    ADD COLUMN IF NOT EXISTS result_type VARCHAR(64) NULL,
    ADD COLUMN IF NOT EXISTS result_ref VARCHAR(255) NULL;

CREATE INDEX IF NOT EXISTS idx_pipeline_stage_parent_stage_id ON pipeline_stage (parent_stage_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_stage_path ON pipeline_stage USING GIST (path);

-- Backfill: rows created before this migration have no nesting, so they're all top-level.
-- text2ltree(...), not a plain ::ltree cast: an UPDATE's SET expression is explicitly typed
-- text (unlike an INSERT's untyped string literal, which ltree's input function parses for
-- free), and Postgres has no implicit text->ltree assignment cast -- same convention already
-- used by 115_remove_gist_index_on_path.up.sql for test_item.path.
UPDATE pipeline_stage SET path = text2ltree(id::text) WHERE path IS NULL;

ALTER TABLE pipeline_stage
    DROP COLUMN IF EXISTS graders,
    DROP COLUMN IF EXISTS agent,
    DROP COLUMN IF EXISTS note;

-- quality_gate was always computed identically to status (same worst-of-stages
-- aggregate) -- redundant even before this change. Genericity removes the
-- separate "gate" concept entirely; status alone still says whether the run
-- succeeded.
ALTER TABLE pipeline_iteration
    DROP COLUMN IF EXISTS quality_gate;
