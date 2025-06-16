ALTER TABLE organization
    ADD CONSTRAINT fk_organization_user
        FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE;