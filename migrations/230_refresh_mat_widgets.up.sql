UPDATE widget
SET widget_options = jsonb_set(widget_options, '{options,state}', '"created"')
WHERE widget_type IN ('componentHealthCheckTable', 'cumulative')
  AND widget_options #>> '{options,state}' = 'ready';