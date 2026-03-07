DROP INDEX IF EXISTS path_gist_idx;

CREATE INDEX CONCURRENTLY IF NOT EXISTS test_item_path_idx
ON test_item ((path::text) text_pattern_ops);
