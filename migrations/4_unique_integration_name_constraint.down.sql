ALTER TABLE integration
    DROP CONSTRAINT not_empty_name;
DROP INDEX IF EXISTS unique_global_integration_name;
DROP INDEX IF EXISTS unique_project_integration_name;