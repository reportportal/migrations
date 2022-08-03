CREATE TABLE organization
(
    id bigserial PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE organization_attribute
(
    id bigserial PRIMARY KEY,
    key varchar(256) NOT NULL,
    value varchar(256) NOT NULL,
    system boolean,
    organization_id bigint,
    FOREIGN KEY (organization_id)
        REFERENCES organization(id)
);

CREATE TYPE ORGANIZATION_ROLE_ENUM AS ENUM ('PROJECT_MANAGER', 'MEMEBER');

CREATE TABLE organization_user
(
    user_id BIGSERIAL REFERENCES users (id) ON DELETE CASCADE NOT NULL,
    organization_id BIGINT REFERENCES organization (id) ON DELETE CASCADE NOT NULL,
    organization_role ORGANIZATION_ROLE_ENUM NOT NULL,
    CONSTRAINT organization_user_pk PRIMARY KEY (user_id, organization_id)
);

ALTER TABLE users
    ADD COLUMN organization_id BIGINT
    FOREIGN KEY (organization_id) REFERENCES organization (id);

ALTER TABLE project
    DROP COLUMN organization;