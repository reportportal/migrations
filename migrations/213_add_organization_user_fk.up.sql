ALTER TABLE organization ADD COLUMN user_id INTEGER;

ALTER TABLE organization
    ADD CONSTRAINT fk_organization_user
        FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE;

ALTER TABLE organization
    ADD CONSTRAINT uq_organization_user_id
        UNIQUE (user_id);