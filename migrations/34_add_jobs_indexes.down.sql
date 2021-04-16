DROP INDEX IF EXISTS log_project_id_log_time_idx;
DROP INDEX IF EXISTS attachment_project_id_creation_time_idx;
DROP INDEX IF EXISTS launch_project_start_time_idx;
CREATE INDEX IF NOT EXISTS launch_project_idx ON launch (project_id);