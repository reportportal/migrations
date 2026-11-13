ALTER TABLE activity
    ADD COLUMN organization_id BIGINT REFERENCES organization (id) ON DELETE CASCADE NULL;

CREATE INDEX IF NOT EXISTS org_id_idx ON activity (organization_id);

UPDATE activity a
SET organization_id = p.organization_id
FROM project p
WHERE (a.project_id = p.id);
