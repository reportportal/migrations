ALTER TABLE user_creation_bid
    ADD COLUMN default_project_id BIGINT;

UPDATE user_creation_bid
SET default_project_id = (SELECT id FROM project WHERE project.name = user_creation_bid.project_name);

DELETE
FROM user_creation_bid
WHERE user_creation_bid.default_project_id IS NULL;

ALTER TABLE user_creation_bid
    ADD FOREIGN KEY (default_project_id) REFERENCES project (id);

ALTER TABLE user_creation_bid
    DROP COLUMN project_name;

ALTER TABLE user_creation_bid
    DROP COLUMN metadata;
