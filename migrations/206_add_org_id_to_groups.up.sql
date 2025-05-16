ALTER TABLE groups
    ADD COLUMN org_id INTEGER,
    ADD CONSTRAINT groups_org_id_fk
    FOREIGN KEY (org_id)
    REFERENCES organizations(id)
    ON DELETE CASCADE;