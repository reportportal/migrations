ALTER TABLE organization
DROP COLUMN slug;

ALTER TABLE project
DROP COLUMN key;

DROP INDEX IF EXISTS project_key_idx;

DROP INDEX IF EXISTS organization_slug_idx;
