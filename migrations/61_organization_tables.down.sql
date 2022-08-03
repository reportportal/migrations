DROP TABLE IF EXISTS organization_attribute;

DROP TABLE IF EXISTS organization_user;

DROP TABLE IF EXISTS organization;

DROP TYPE IF EXISTS ORGANIZATION_ROLE_ENUM;

ALTER TABLE users DROP COLUMN organization_id;

ALTER TABLE project ADD COLUMN organization VARCHAR;
