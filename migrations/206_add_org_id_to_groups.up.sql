ALTER TABLE groups
    ADD COLUMN org_id INTEGER,
    ADD CONSTRAINT groups_org_id_fkey
    FOREIGN KEY (org_id)
    REFERENCES organization(id)
    ON DELETE CASCADE;