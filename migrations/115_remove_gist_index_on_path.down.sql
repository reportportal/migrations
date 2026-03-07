CREATE INDEX path_gist_idx ON public.test_item USING gist (path);

DROP INDEX IF EXISTS test_item_path_idx;