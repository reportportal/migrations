ALTER TABLE pipeline_iteration
    DROP COLUMN IF EXISTS details,
    DROP COLUMN IF EXISTS description,
    DROP COLUMN IF EXISTS summary;
