CREATE INDEX IF NOT EXISTS log_item_level_idx ON log (item_id, log_level);

DROP INDEX IF EXISTS log_ti_idx;
