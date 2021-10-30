create table onboarding
(
    id smallserial constraint onboarding_pk primary key,
    data text,
    page varchar(50) not null,
    available_from timestamp,
    available_to timestamp
);

-- make onboarding available for 3 days from superadmin project creation date
INSERT INTO onboarding (id, data, page, available_from, available_to) VALUES (
      1, '[{"problem": "Issues with instance performance", "link": "https://reportportal.io/docs/Optimal-Performance-Hardware"},{"problem": "How to configure test reporting?", "link": "https://reportportal.io/docs/Test-Framework-Integration"},{"problem": "Issues with service analyzer", "link": "https://reportportal.io/docs/Resolve-Analyzer-Known"},{"problem": "How to integrate ReportPortal with Jira?", "link": "https://reportportal.io/docs/Jira-Integration"},{"problem": "How to configure TLS/SSL certificate setup?", "link": "https://reportportal.io/docs/Setup-TLS(SSL)-in"},{"problem": "Questions regarding File storage options", "link": "https://reportportal.io/docs/ReportPortal-5.0-File"},{"problem": "Can not find your question?", "link": ""}]', 'GENERAL',
      (select creation_date from project where id=1), (select creation_date from project where id=1) + INTERVAL '3 DAYS'
);
