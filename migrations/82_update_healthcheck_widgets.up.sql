-- set excludeSkipped flag for previously created healthcheck widgets
UPDATE
  widget
SET
  widget_options = jsonb_set(widget_options, '{options, excludeSkipped}', 'false')
WHERE
  widget_type IN ('componentHealthCheck', 'componentHealthCheckTable')
AND
	(widget_options->'options'->>'excludeSkipped' IS NULL);
