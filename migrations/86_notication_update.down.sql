DROP INDEX IF EXISTS unique_rule_name_per_project_rule_type;

CREATE UNIQUE INDEX unique_rule_name_per_project
    ON sender_case (rule_name, project_id);

ALTER TABLE sender_case
    DROP COLUMN IF EXISTS rule_details;

ALTER TABLE sender_case
    DROP COLUMN IF EXISTS rule_type;