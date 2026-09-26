ALTER TABLE pipeline_iteration
    ADD COLUMN IF NOT EXISTS quality_gate VARCHAR(32);

ALTER TABLE pipeline_stage
    ADD COLUMN IF NOT EXISTS agent VARCHAR(256),
    ADD COLUMN IF NOT EXISTS note TEXT,
    ADD COLUMN IF NOT EXISTS graders JSONB;

DROP INDEX IF EXISTS idx_pipeline_stage_path;
DROP INDEX IF EXISTS idx_pipeline_stage_parent_stage_id;

ALTER TABLE pipeline_stage
    DROP COLUMN IF EXISTS result_ref,
    DROP COLUMN IF EXISTS result_type,
    DROP COLUMN IF EXISTS attributes,
    DROP COLUMN IF EXISTS path,
    DROP COLUMN IF EXISTS parent_stage_id;
