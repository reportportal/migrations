DROP INDEX IF EXISTS project_key_idx;
ALTER TABLE project DROP COLUMN IF EXISTS "organization_id";
ALTER TABLE project DROP COLUMN IF EXISTS "slug";
ALTER TABLE project DROP COLUMN IF EXISTS "key";

DROP INDEX IF EXISTS organization_slug_idx;

DROP TABLE IF EXISTS organization_user;

DROP TABLE IF EXISTS organization;

DROP TYPE IF EXISTS ORGANIZATION_ROLE_ENUM;