UPDATE project_attribute
SET value = cast(extract(epoch FROM value::interval)::int as varchar)
WHERE attribute_id IN (SELECT id
                       FROM attribute
                       WHERE attribute.name IN ('job.interruptJobTime',
                                                'job.keepLaunches',
                                                'job.keepLogs',
                                                'job.keepScreenshots'))
  and value != 'forever';

UPDATE project_attribute
SET value = '0'
WHERE attribute_id IN (SELECT id
                       FROM attribute
                       WHERE attribute.name IN ('job.interruptJobTime',
                                                'job.keepLaunches',
                                                'job.keepLogs',
                                                'job.keepScreenshots'))
  AND value = 'forever';
