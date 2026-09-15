ALTER TABLE tms_test_case
    ALTER COLUMN priority DROP NOT NULL,
    ALTER COLUMN priority DROP DEFAULT;

ALTER TABLE tms_test_case_execution
    ALTER COLUMN priority DROP NOT NULL,
    ALTER COLUMN priority DROP DEFAULT;
