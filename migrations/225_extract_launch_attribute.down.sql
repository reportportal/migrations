ALTER TABLE item_attribute
    ADD COLUMN IF NOT EXISTS launch_id BIGINT REFERENCES launch (id) ON DELETE CASCADE,
    ALTER COLUMN item_id DROP NOT NULL;

INSERT INTO item_attribute (key, value, item_id, launch_id, system)
SELECT key, value, NULL, launch_id, system
FROM launch_attribute;

DROP TABLE IF EXISTS launch_attribute;

ALTER TABLE item_attribute
    ADD CONSTRAINT item_attribute_check
        CHECK ((item_id IS NOT NULL AND launch_id IS NULL) OR (item_id IS NULL AND launch_id IS NOT NULL));

CREATE INDEX IF NOT EXISTS item_attr_launch_idx
    ON item_attribute (launch_id NULLS LAST);
