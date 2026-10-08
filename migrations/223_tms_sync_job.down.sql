DELETE FROM integration_type WHERE name = 'qa-space';

DROP INDEX IF EXISTS idx_tms_sync_job_status;
DROP INDEX IF EXISTS idx_tms_sync_job_project_id;
DROP TABLE IF EXISTS tms_sync_job;