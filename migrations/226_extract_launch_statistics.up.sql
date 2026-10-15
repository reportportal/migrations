CREATE TABLE launch_statistics (
    s_id                BIGSERIAL
        CONSTRAINT launch_statistics_pk PRIMARY KEY,
    s_counter           INT DEFAULT 0,
    launch_id           BIGINT REFERENCES launch (id) ON DELETE CASCADE NOT NULL,
    statistics_field_id BIGINT REFERENCES statistics_field (sf_id) ON DELETE CASCADE,
    CONSTRAINT unique_launch_stats UNIQUE (statistics_field_id, launch_id),
    CHECK (launch_statistics.s_counter >= 0)
);

INSERT INTO launch_statistics (s_counter, launch_id, statistics_field_id)
SELECT s_counter, launch_id, statistics_field_id
FROM statistics
WHERE launch_id IS NOT NULL;

CREATE INDEX launch_statistics_launch_idx
    ON launch_statistics (launch_id NULLS LAST);

DELETE FROM statistics
WHERE launch_id IS NOT NULL;

DO
$$
DECLARE
    matview RECORD;
BEGIN
    FOR matview IN
        SELECT schemaname, matviewname
        FROM pg_matviews
        WHERE matviewname LIKE 'widget_%'
           OR matviewname LIKE 'hct_%'
    LOOP
        EXECUTE format('DROP MATERIALIZED VIEW IF EXISTS %I.%I CASCADE', matview.schemaname, matview.matviewname);
    END LOOP;
END;
$$;

DROP INDEX IF EXISTS statistics_launch_idx;

ALTER TABLE statistics
    DROP CONSTRAINT IF EXISTS statistics_launch_id_fkey,
    DROP CONSTRAINT IF EXISTS unique_stats_launch,
    DROP CONSTRAINT IF EXISTS statistics_check,
    ALTER COLUMN item_id SET NOT NULL,
    DROP COLUMN IF EXISTS launch_id;

ALTER TABLE statistics
    ADD CONSTRAINT statistics_check CHECK (s_counter >= 0);
