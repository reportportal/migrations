CREATE TABLE IF NOT EXISTS tms_sync_job (
    id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL REFERENCES project(id) ON DELETE CASCADE,
    integration_id BIGINT REFERENCES integration(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    direction VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    scope_config JSONB,
    counters JSONB,
    error_log JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP WITHOUT TIME ZONE,
    completed_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_tms_sync_job_project_id ON tms_sync_job(project_id);
CREATE INDEX IF NOT EXISTS idx_tms_sync_job_status ON tms_sync_job(status);

ALTER TABLE tms_test_case ADD COLUMN IF NOT EXISTS source_updated_at TIMESTAMP WITHOUT TIME ZONE;

INSERT INTO integration_type (id, enabled, name, creation_date, group_type, plugin_type, details)
VALUES (100, TRUE, 'qa-space', CURRENT_TIMESTAMP, 'IMPORT', 'BUILT_IN', '{"details": {"id": "qa-space", "name": "QA Space"}}')
ON CONFLICT (name) DO NOTHING;

ALTER TABLE tms_test_folder ADD COLUMN IF NOT EXISTS external_id VARCHAR(255);
