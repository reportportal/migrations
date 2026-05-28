ALTER TABLE launch DROP COLUMN IF EXISTS launch_type;

DROP TYPE IF EXISTS launch_type_enum;
