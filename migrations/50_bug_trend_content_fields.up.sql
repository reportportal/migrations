DELETE
FROM content_field
WHERE id IN (SELECT id FROM widget WHERE widget_type = 'bugTrend');

INSERT INTO content_field
SELECT id, 'statistics$executions$failed'
FROM widget
WHERE widget_type = 'bugTrend';