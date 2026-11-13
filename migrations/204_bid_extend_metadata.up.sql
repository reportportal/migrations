UPDATE public.user_creation_bid ucb
SET "metadata" = metadata || jsonb_set(metadata, '{metadata, organizations}',
                                       jsonb_build_array(jsonb_build_object('id', (select prj.id
                                                                                   from project prj
                                                                                   where project_name = prj.name)::integer,
                                                                            'role',
                                                                            organization_role)));
UPDATE public.user_creation_bid ucb
SET "metadata" = metadata || jsonb_set(metadata, '{metadata, projects}',
                                       jsonb_build_array(jsonb_build_object('id', organization_id, 'role', "role")));

ALTER TABLE public.user_creation_bid DROP COLUMN IF EXISTS "role";
ALTER TABLE public.user_creation_bid DROP COLUMN IF EXISTS "project_name";
ALTER TABLE public.user_creation_bid DROP COLUMN IF EXISTS "organization_id";
ALTER TABLE public.user_creation_bid DROP COLUMN IF EXISTS "organization_role";
