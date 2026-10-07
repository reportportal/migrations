DROP TABLE IF EXISTS tms_test_case_generation_metadata;
DROP TABLE IF EXISTS tms_test_case_quality_score;

DROP TABLE IF EXISTS tms_quality_standard_criterion;
DROP TABLE IF EXISTS tms_quality_standard;

ALTER TABLE tms_test_case_version
    DROP COLUMN IF EXISTS updated_at;

ALTER TABLE tms_test_case
    DROP COLUMN IF EXISTS status,
    DROP COLUMN IF EXISTS origin;

DELETE FROM integration_type WHERE name IN ('github-actions', 'gitlab-ci');

DROP TABLE IF EXISTS pipeline_stage_test_case;
DROP TABLE IF EXISTS pipeline_stage;
DROP TABLE IF EXISTS pipeline_iteration;
DROP TABLE IF EXISTS pipeline;
