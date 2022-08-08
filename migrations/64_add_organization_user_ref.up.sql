CREATE TYPE ORGANIZATION_ROLE_ENUM AS ENUM ('PROJECT_MANAGER', 'MEMEBER');

CREATE TABLE IF NOT EXISTS organization_user
(
    user_id BIGSERIAL REFERENCES users (id) ON DELETE CASCADE NOT NULL,
    organization_id BIGINT REFERENCES organization (id) ON DELETE CASCADE NOT NULL,
    organization_role ORGANIZATION_ROLE_ENUM NOT NULL,
    CONSTRAINT organization_user_pk PRIMARY KEY (user_id, organization_id)
);

ALTER TABLE project ADD COLUMN organization_id BIGINT;