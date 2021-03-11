ALTER TABLE log
    DROP COLUMN IF EXISTS projectId;

ALTER TABLE attachment
    DROP COLUMN IF EXISTS creation_date;