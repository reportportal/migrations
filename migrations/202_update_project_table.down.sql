ALTER TABLE project DROP COLUMN IF EXISTS "updated_at";
ALTER TABLE project RENAME COLUMN "created_at" TO "creation_date";
ALTER TABLE project ADD COLUMN project_type VARCHAR NOT NULL;
