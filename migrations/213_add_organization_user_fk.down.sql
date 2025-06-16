ALTER TABLE organization DROP CONSTRAINT IF EXISTS fk_organization_user;
ALTER TABLE organization DROP CONSTRAINT IF EXISTS uq_organization_user_id;