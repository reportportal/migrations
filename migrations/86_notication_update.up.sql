ALTER TABLE sender_case
    ADD rule_type VARCHAR(55) NOT NULL DEFAULT 'email';

ALTER TABLE sender_case
    ADD rule_details JSONB NULL;

DROP INDEX unique_rule_name_per_project;

CREATE UNIQUE INDEX unique_rule_name_per_project_rule_type
    ON sender_case (rule_name, project_id, rule_type);