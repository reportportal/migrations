DROP TRIGGER IF EXISTS after_project_insert ON public.project;
DROP FUNCTION IF EXISTS attach_default_tariff_to_project();

DROP TRIGGER IF EXISTS after_project_attribute_insert ON public.project_attribute;
DROP FUNCTION IF EXISTS update_project_attribute_retention();
