CREATE INDEX IF NOT EXISTS log_project_id_log_time_idx
    ON log (project_id, log_time);

CREATE INDEX IF NOT EXISTS attachment_project_id_creation_time_idx
    ON attachment (project_id, creation_date);