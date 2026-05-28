DROP INDEX IF EXISTS idx_test_item_name_lower_prefix;

CREATE INDEX IF NOT EXISTS idx_test_item_name_trgm ON test_item USING gin (name gin_trgm_ops);
