CREATE INDEX IF NOT EXISTS path_idx
    ON test_item
        USING btree (path);