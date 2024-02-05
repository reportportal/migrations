UPDATE
  widget
SET
  widget_options = widget_options #- '{options,excludeSkipped}'
WHERE
  widget_type IN ('componentHealthCheck', 'componentHealthCheckTable')
AND
  widget_options ? 'options'
AND
  (widget_options->'options'->>'excludeSkipped' IS NOT NULL);
