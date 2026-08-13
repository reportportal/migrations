DROP INDEX IF EXISTS log_item_level_idx;

CREATE INDEX log_ti_idx ON log (item_id);
