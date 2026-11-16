CREATE TABLE onboarding
(
    id             SMALLSERIAL CONSTRAINT onboarding_pk PRIMARY KEY,
    data           TEXT,
    page           VARCHAR(50) NOT NULL,
    available_from TIMESTAMP,
    available_to   TIMESTAMP
);

-- make onboarding available for 3 days from superadmin project creation date
INSERT INTO onboarding (id, data, page, available_from, available_to)
VALUES (1,
        '[{"problem":"Issues with instance performance","link":"https://reportportal.io/docs/installation-steps/OptimalPerformanceHardwareSetup"},{"problem":"How to configure test reporting?","link":"https://reportportal.io/docs/log-data-in-reportportal/test-framework-integration/"},{"problem":"Issues with service Analyzer","link":"https://reportportal.io/docs/issues-troubleshooting/ResolveAnalyzerKnownIssues"},{"problem":"How to integrate ReportPortal with Jira Server?","link":"https://reportportal.io/docs/plugins/AtlassianJiraServer"},{"problem":"How to configure TLS/SSL certificate setup?","link":"https://reportportal.io/docs/installation-steps/SetupTSLSSLInTraefik2.0.x"},{"problem":"Questions regarding File storage options","link":"https://reportportal.io/docs/installation-steps/ReportPortal23.1FileStorageOptions/"},{"problem":"Can not find your question?","link":""}]',
        'GENERAL',
        (SELECT creation_date FROM project WHERE id = 1),
        (SELECT creation_date FROM project WHERE id = 1) + INTERVAL '3 DAYS');
