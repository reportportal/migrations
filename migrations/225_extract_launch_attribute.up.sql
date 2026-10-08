CREATE TABLE launch_attribute (
    id        BIGSERIAL
        CONSTRAINT launch_attribute_pk PRIMARY KEY,
    key       VARCHAR,
    value     VARCHAR NOT NULL,
    launch_id BIGINT REFERENCES launch (id) ON DELETE CASCADE NOT NULL,
    system    BOOLEAN DEFAULT FALSE
);

INSERT INTO launch_attribute (key, value, launch_id, system)
SELECT key, value, launch_id, system
FROM item_attribute
WHERE launch_id IS NOT NULL;

CREATE INDEX launch_attr_launch_idx
    ON launch_attribute (launch_id NULLS LAST);
CREATE INDEX launch_attribute_key_value_idx
    ON launch_attribute (key, value);

DELETE FROM item_attribute
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

DROP INDEX IF EXISTS item_attr_launch_idx;

ALTER TABLE item_attribute
    DROP CONSTRAINT IF EXISTS item_attribute_launch_id_fkey,
    DROP CONSTRAINT IF EXISTS item_attribute_check,
    ALTER COLUMN item_id SET NOT NULL,
    DROP COLUMN IF EXISTS launch_id;
