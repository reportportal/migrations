CREATE TABLE organization
(
    id bigserial PRIMARY KEY,
    creation_date TIMESTAMP DEFAULT now() NOT NULL,
    name TEXT NOT NULL UNIQUE,
    organization_type text NOT NULL,
    slug TEXT NOT NULL UNIQUE
);

CREATE INDEX IF NOT EXISTS organization_slug_idx ON organization(slug);

CREATE TYPE ORGANIZATION_ROLE_ENUM AS ENUM ('MANAGER', 'MEMBER');

CREATE TABLE IF NOT EXISTS organization_user
(
    user_id BIGSERIAL REFERENCES users (id) ON DELETE CASCADE NOT NULL,
    organization_id BIGINT REFERENCES organization (id) ON DELETE CASCADE NOT NULL,
    organization_role ORGANIZATION_ROLE_ENUM NOT NULL,
    CONSTRAINT organization_user_pk PRIMARY KEY (user_id, organization_id)
);

ALTER TABLE project ADD COLUMN "organization_id" BIGINT;
ALTER TABLE project ADD COLUMN "slug" TEXT;
ALTER TABLE project ADD COLUMN "key" TEXT UNIQUE;

ALTER TABLE project DROP CONSTRAINT project_name_key;

CREATE INDEX IF NOT EXISTS project_key_idx ON project(key);
