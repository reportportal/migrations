INSERT INTO attribute (id, name) VALUES (16, 'analyzer.allMessagesShouldMatch');
INSERT INTO project_attribute SELECT 16, FALSE, id FROM project;