ALTER TABLE organization DROP CONSTRAINT IF EXISTS fk_organization_owner;
ALTER TABLE organization DROP CONSTRAINT IF EXISTS uq_organization_owner_id;
ALTER TABLE organization DROP COLUMN IF EXISTS owner_id;