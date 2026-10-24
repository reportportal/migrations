ALTER TABLE tms_test_case
    DROP COLUMN IF EXISTS modified_by_agent;

ALTER TABLE tms_test_case_version
    DROP COLUMN IF EXISTS pipeline_iteration_id;

DROP TABLE IF EXISTS tms_test_case_review_comment;
DROP TABLE IF EXISTS tms_test_case_fix_round;
