ALTER TABLE integration
    ADD CONSTRAINT not_empty_name
        CHECK
            (NOT (
            name IS NULL OR name = '')
            );
CREATE UNIQUE INDEX unique_global_integration_name ON integration (name, type)
    WHERE project_id IS NULL;
CREATE UNIQUE INDEX unique_project_integration_name ON integration (name, type, project_id)
    WHERE project_id IS NOT NULL;