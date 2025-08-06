WITH inserted_attribute AS (
    INSERT INTO attribute (name)
    VALUES ('analyzer.largestRetryPriority')
    RETURNING id
)
INSERT INTO project_attribute
SELECT inserted_attribute.id, FALSE, project.id
FROM project, inserted_attribute;