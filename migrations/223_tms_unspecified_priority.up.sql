UPDATE tms_test_case
SET priority = 'UNSPECIFIED'
WHERE priority IS NULL OR btrim(priority) = '';

UPDATE tms_test_case_execution
SET priority = 'UNSPECIFIED'
WHERE priority IS NULL OR btrim(priority) = '';

ALTER TABLE tms_test_case
    ALTER COLUMN priority SET DEFAULT 'UNSPECIFIED',
    ALTER COLUMN priority SET NOT NULL;

ALTER TABLE tms_test_case_execution
    ALTER COLUMN priority SET DEFAULT 'UNSPECIFIED',
    ALTER COLUMN priority SET NOT NULL;
