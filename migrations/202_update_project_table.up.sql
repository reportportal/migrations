ALTER TABLE project ADD COLUMN "updated_at" TIMESTAMP DEFAULT now() NOT NULL;
ALTER TABLE project RENAME COLUMN "creation_date" TO "created_at";
ALTER TABLE project DROP COLUMN IF EXISTS "project_type";

ALTER TABLE project ADD CONSTRAINT project_name_unique_key UNIQUE ("name", "organization_id");

ALTER TABLE project
    ADD CONSTRAINT fk_project_organization FOREIGN KEY (organization_id)
        REFERENCES organization (id)
        ON DELETE CASCADE;
