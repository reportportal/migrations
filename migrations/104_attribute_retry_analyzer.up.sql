INSERT INTO attribute (id, name) VALUES (25, 'analyzer.largestRetryPriority');
INSERT INTO project_attribute SELECT 25, FALSE, id FROM project;