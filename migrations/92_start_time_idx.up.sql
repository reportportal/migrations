CREATE INDEX CONCURRENTLY IF NOT EXISTS test_item_start_time_idx ON test_item (start_time);
CREATE INDEX CONCURRENTLY IF NOT EXISTS item_attribute_key_value_idx ON item_attribute (key, value);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_test_item_name_trgm ON public.test_item USING gin (name gin_trgm_ops);
