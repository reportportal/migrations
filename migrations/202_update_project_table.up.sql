ALTER TABLE project ADD COLUMN "updated_at" TIMESTAMP DEFAULT now() NOT NULL;
ALTER TABLE project RENAME COLUMN "creation_date" TO "created_at";
ALTER TABLE project DROP COLUMN IF EXISTS "project_type";
