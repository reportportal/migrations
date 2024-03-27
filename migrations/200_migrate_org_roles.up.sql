-- BACKUP project roles
ALTER TABLE public.project_user ADD COLUMN "project_role_backup" TEXT;
UPDATE public.project_user SET "project_role_backup" = "project_role";


-- Extend project roles
ALTER TYPE project_role_enum RENAME TO PROJECT_ROLE_ENUM_OLD;
CREATE TYPE PROJECT_ROLE_ENUM AS ENUM ('OPERATOR', 'CUSTOMER', 'MEMBER', 'PROJECT_MANAGER', 'EDITOR', 'VIEWER');

ALTER TABLE public.project_user
    ALTER COLUMN project_role TYPE PROJECT_ROLE_ENUM
        USING (project_role::text::PROJECT_ROLE_ENUM);

-- Populate project 'key', 'slug' and 'organization_id'
WITH org_id AS (INSERT INTO public.organization (name, slug, organization_type)
VALUES ('My organization', 'my-organization', 'INTERNAL') RETURNING id)
UPDATE public.project AS prj
SET "organization_id" = (SELECT id FROM org_id),
    "key" = slugify(name);

UPDATE project SET "slug" = "key";


-- Update community projects:
-- set organization roles
INSERT INTO organization_user (user_id, organization_id, organization_role)
SELECT DISTINCT pu.user_id,
                (SELECT o.id FROM organization o LIMIT 1),
                'MEMBER'::public."organization_role_enum"
FROM project_user pu;


-- set project role Editor
UPDATE public.project_user pu
SET project_role = 'EDITOR'::public."project_role_enum"
WHERE project_role IN (
    'PROJECT_MANAGER'::public."project_role_enum",
    'MEMBER'::public."project_role_enum",
    'CUSTOMER'::public."project_role_enum");


-- Set project role Viewer
UPDATE public.project_user pu
SET project_role = 'VIEWER'::public."project_role_enum"
WHERE project_role = 'OPERATOR'::public."project_role_enum";


-- Remove deprecated project roles
CREATE TYPE PROJECT_ROLE_ENUM_NEW AS ENUM ('EDITOR', 'VIEWER');

ALTER TABLE public.project_user
ALTER COLUMN project_role TYPE PROJECT_ROLE_ENUM_NEW
    USING (project_role::text::PROJECT_ROLE_ENUM_NEW);
ALTER TABLE public.project_user ALTER COLUMN project_role SET NOT NULL;

DROP TYPE PROJECT_ROLE_ENUM;
ALTER TYPE PROJECT_ROLE_ENUM_NEW RENAME TO PROJECT_ROLE_ENUM;
