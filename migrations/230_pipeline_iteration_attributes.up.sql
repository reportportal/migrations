-- Free-form tag chips on a pipeline iteration (detail view only). Mirrors the
-- existing pipeline_iteration.metrics JSONB column: a flexible string map
-- rather than fixed columns, since the set of attributes is open-ended.
ALTER TABLE pipeline_iteration
    ADD COLUMN IF NOT EXISTS attributes JSONB;
