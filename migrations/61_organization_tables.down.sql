DROP TABLE IF EXISTS organization_attribute;

DROP TABLE IF EXISTS organization_user;

DROP TABLE IF EXISTS organization;

DROP TYPE IF EXISTS ORGANIZATION_ROLE_ENUM;

ALTER TABLE project DROP COLUMN organization_id;
