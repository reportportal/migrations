DELETE
FROM quartz.scheduler_simple_triggers
WHERE trigger_name IN ('createCleanLaunchesTrigger', 'createCleanLogsTrigger', 'cleanScreenshotsTrigger');

DELETE
FROM quartz.scheduler_triggers
WHERE scheduler_triggers.job_name IN ('cleanLogsJobBean', 'cleanLaunchesJobBean', 'cleanScreenshotsJobBean');

DELETE
FROM quartz.scheduler_job_details
WHERE job_name IN ('cleanLogsJobBean', 'cleanLaunchesJobBean', 'cleanScreenshotsJobBean')