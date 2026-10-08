ALTER TABLE groups
    DROP CONSTRAINT groups_slug_key,
    ADD CONSTRAINT groups_slug_org_id_key UNIQUE (slug, org_id);