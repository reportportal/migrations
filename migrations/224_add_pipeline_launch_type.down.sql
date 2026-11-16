-- PostgreSQL does not support removing a value from an enum type directly,
-- so the enum is recreated without 'PIPELINE'.

UPDATE launch
SET launch_type = 'AUTOMATION'
WHERE launch_type = 'PIPELINE';

ALTER TYPE LAUNCH_TYPE_ENUM RENAME TO launch_type_enum_old;

CREATE TYPE LAUNCH_TYPE_ENUM AS ENUM ('AUTOMATION', 'AGENTIC', 'MANUAL');

ALTER TABLE launch
    ALTER COLUMN launch_type DROP DEFAULT;

ALTER TABLE launch
    ALTER COLUMN launch_type TYPE LAUNCH_TYPE_ENUM USING launch_type::text::LAUNCH_TYPE_ENUM;

ALTER TABLE launch
    ALTER COLUMN launch_type SET DEFAULT 'AUTOMATION';

DROP TYPE launch_type_enum_old;
