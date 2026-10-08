ALTER TABLE project DROP COLUMN IF EXISTS "updated_at";
ALTER TABLE project RENAME COLUMN "created_at" TO "creation_date";
ALTER TABLE project ADD COLUMN project_type VARCHAR NOT NULL;

ALTER TABLE project DROP CONSTRAINT project_name_unique_key;
ALTER TABLE project DROP CONSTRAINT project_slug_unique_key;
