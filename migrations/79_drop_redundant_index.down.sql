CREATE INDEX path_idx IF NOT EXISTS
    ON test_item
        USING btree (path);