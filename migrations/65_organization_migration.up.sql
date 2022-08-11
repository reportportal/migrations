WITH inserted_id AS (INSERT INTO public.organization (name) VALUES ('My organization') RETURNING id)

UPDATE public.project SET organization_id = (SELECT id FROM inserted_id);