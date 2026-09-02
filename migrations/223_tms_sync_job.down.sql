DELETE FROM integration_type WHERE name = 'qa-space';

ALTER TABLE tms_test_case DROP COLUMN IF EXISTS source_updated_at;

DROP INDEX IF EXISTS idx_tms_sync_job_status;
DROP INDEX IF EXISTS idx_tms_sync_job_project_id;
DROP TABLE IF EXISTS tms_sync_job;

ALTER TABLE tms_test_folder DROP COLUMN IF EXISTS external_id;