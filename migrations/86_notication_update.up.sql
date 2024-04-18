ALTER TABLE sender_case
    ADD rule_type VARCHAR(55) NOT NULL DEFAULT 'email';

ALTER TABLE sender_case
    ADD rule_details JSONB NULL;

DROP INDEX unique_rule_name_per_project;

CREATE UNIQUE INDEX unique_rule_name_per_project_rule_type
    ON sender_case (rule_name, project_id, rule_type);

DO $$
DECLARE
    new_attribute_id BIGINT;
    old_attribute_id BIGINT;
BEGIN
    INSERT INTO attribute (name)
    VALUES ('notifications.email.enabled')
    RETURNING id INTO new_attribute_id;

    SELECT id INTO old_attribute_id
    FROM attribute
    WHERE name = 'notifications.enabled';

    INSERT INTO project_attribute (attribute_id, value, project_id)
    SELECT new_attribute_id, value, project_id
    FROM project_attribute
    WHERE attribute_id = old_attribute_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END
$$ LANGUAGE plpgsql;