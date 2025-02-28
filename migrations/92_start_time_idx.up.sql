CREATE INDEX IF NOT EXISTS test_item_start_time_idx ON test_item (start_time);
CREATE INDEX IF NOT EXISTS item_attribute_key_value_idx ON item_attribute (key, value);