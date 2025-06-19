ALTER TABLE organization ADD COLUMN owner_id INTEGER;

ALTER TABLE organization
    ADD CONSTRAINT fk_organization_owner
        FOREIGN KEY (owner_id)
            REFERENCES users(id)
            ON DELETE CASCADE;

ALTER TABLE organization
    ADD CONSTRAINT uq_organization_owner_id
        UNIQUE (owner_id);