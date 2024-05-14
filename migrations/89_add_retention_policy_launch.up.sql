CREATE TYPE RETENTION_POLICY_ENUM AS ENUM ('IMPORTANT', 'REGULAR');
ALTER TABLE launch
    ADD COLUMN retention_policy RETENTION_POLICY_ENUM;
ALTER TABLE launch
    ALTER COLUMN retention_policy SET DEFAULT 'REGULAR';
UPDATE launch
SET retention_policy = 'REGULAR';