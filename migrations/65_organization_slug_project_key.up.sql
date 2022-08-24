ALTER TABLE organization
ADD COLUMN slug VARCHAR;

ALTER TABLE project
ADD COLUMN key VARCHAR;

ALTER TABLE project
ADD UNIQUE (organization, key);

UPDATE public.organization
SET slug = REPLACE(LOWER(name), ' ', '-');

UPDATE project
SET key = name;