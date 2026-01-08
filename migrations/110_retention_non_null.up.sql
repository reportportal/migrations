UPDATE public.launch SET retention_policy = 'REGULAR' WHERE retention_policy IS NULL;

ALTER TABLE public.launch ALTER COLUMN retention_policy SET NOT NULL;
