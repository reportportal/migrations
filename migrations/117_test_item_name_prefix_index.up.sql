DROP INDEX IF EXISTS idx_test_item_name_trgm;

CREATE INDEX IF NOT EXISTS idx_test_item_name_lower_prefix
    ON test_item (lower(name) varchar_pattern_ops)
    WHERE has_children = false
      AND has_stats = true
      AND retry_of IS NULL
      AND type = 'STEP';