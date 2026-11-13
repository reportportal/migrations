ALTER TABLE statistics
    DROP CONSTRAINT IF EXISTS statistics_check;

ALTER TABLE statistics
    ADD COLUMN IF NOT EXISTS launch_id BIGINT REFERENCES launch (id) ON DELETE CASCADE,
    ALTER COLUMN item_id DROP NOT NULL;

INSERT INTO statistics (s_counter, item_id, launch_id, statistics_field_id)
SELECT s_counter, NULL, launch_id, statistics_field_id
FROM launch_statistics;

DROP TABLE IF EXISTS launch_statistics;

ALTER TABLE statistics
    ADD CONSTRAINT unique_stats_launch UNIQUE (statistics_field_id, launch_id),
    ADD CONSTRAINT statistics_check
        CHECK (s_counter >= 0 AND ((item_id IS NOT NULL AND launch_id IS NULL) OR (launch_id IS NOT NULL AND item_id IS NULL)));

CREATE INDEX IF NOT EXISTS statistics_launch_idx
    ON statistics (launch_id NULLS LAST);
