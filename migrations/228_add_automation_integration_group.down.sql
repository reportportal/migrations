-- PostgreSQL does not support removing a value from an enum type directly,
-- so the enum is recreated without 'AUTOMATION'.

DELETE FROM integration_type WHERE group_type = 'AUTOMATION';

ALTER TYPE INTEGRATION_GROUP_ENUM RENAME TO integration_group_enum_old;

CREATE TYPE INTEGRATION_GROUP_ENUM AS ENUM ('BTS', 'NOTIFICATION', 'AUTH', 'OTHER', 'IMPORT');

ALTER TABLE integration_type
    ALTER COLUMN group_type TYPE INTEGRATION_GROUP_ENUM USING group_type::text::INTEGRATION_GROUP_ENUM;

DROP TYPE integration_group_enum_old;
