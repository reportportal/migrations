-- restore project roles from backup
ALTER TABLE public.project_user DROP COLUMN IF EXISTS "project_role";
DROP TYPE PROJECT_ROLE_ENUM;

CREATE TYPE PROJECT_ROLE_ENUM AS ENUM ('OPERATOR', 'CUSTOMER', 'MEMBER', 'PROJECT_MANAGER');

ALTER TABLE public.project_user ADD COLUMN "project_role" PROJECT_ROLE_ENUM;
UPDATE public.project_user SET "project_role" = "project_role_backup"::project_role_enum
    WHERE "project_role_backup" IS NOT NULL;

ALTER TABLE public.project_user DROP COLUMN IF EXISTS "project_role_backup";


-- clean organization-related data
UPDATE public.project SET "organization" = null;
UPDATE public.project SET "organization_id" = null;
UPDATE public.project SET "key" = null;
UPDATE public.project SET "slug" = null;

DELETE FROM public.organization_user;
DELETE FROM public.organization;
