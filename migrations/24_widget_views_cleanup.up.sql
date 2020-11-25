PREPARE clean_up as SELECT 'DROP MATERIALIZED VIEW ' || string_agg(matviewname, ', ')
FROM pg_matviews
WHERE matviewname LIKE 'widget_%'
   OR matviewname LIKE 'hct_%' AND matviewname
    NOT IN
                                   (SELECT widget_options -> 'options' ->> 'viewName'
                                    FROM widget
                                    WHERE widget_type IN ('componentHealthCheckTable', 'cumulative')
                                      AND widget_options -> 'options' ->> 'viewName' NOTNULL);
EXECUTE clean_up;