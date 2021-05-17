ALTER TABLE log ADD COLUMN project_id BIGINT;
CREATE INDEX log_project_idx ON log (project_id);

CREATE TABLE item_project (item_id BIGINT NOT NULL, project_id BIGINT NOT NULL);
INSERT INTO item_project(item_id, project_id) SELECT ti.item_id, launch.project_id FROM launch JOIN test_item ti ON launch.id = ti.launch_id;
INSERT INTO item_project(item_id, project_id) SELECT parent.item_id, launch.project_id FROM launch JOIN test_item ti ON launch.id = ti.launch_id
    JOIN test_item parent ON ti.item_id = parent.parent_id;
CREATE INDEX item_idx ON item_project(item_id);

DROP INDEX log_message_trgm_idx;
UPDATE log SET project_id  = (SELECT project_id FROM item_project WHERE item_project.item_id=log.item_id LIMIT 1);
UPDATE log SET project_id = (SELECT project_id FROM launch WHERE id = log.launch_id LIMIT 1) WHERE project_id = 0 OR log.project_id IS NULL;
DROP TABLE item_project;
CREATE INDEX log_message_trgm_idx ON log USING gin (log_message gin_trgm_ops);
ALTER TABLE log ALTER COLUMN project_id SET NOT NULL;