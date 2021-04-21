ALTER TABLE log
    DROP COLUMN IF EXISTS project_id;

ALTER TABLE attachment
    DROP COLUMN IF EXISTS creation_date;