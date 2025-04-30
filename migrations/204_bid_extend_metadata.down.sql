-- previous data changes are irreversible
DELETE FROM public.user_creation_bid;

ALTER TABLE public.user_creation_bid ADD COLUMN "role" VARCHAR NOT NULL;
ALTER TABLE public.user_creation_bid ADD COLUMN "project_name" VARCHAR NOT NULL;
ALTER TABLE public.user_creation_bid ADD COLUMN organization_id BIGINT;
ALTER TABLE public.user_creation_bid ADD COLUMN organization_role ORGANIZATION_ROLE_ENUM;
