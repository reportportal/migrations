-- ============================================================================
-- REVERT CASCADE DELETE OF MANUAL LAUNCH TMS DATA
-- Rows removed as orphans by the up migration are not restored.
-- ============================================================================

ALTER TABLE tms_test_case_execution_comment_attachment
    DROP CONSTRAINT tms_test_case_execution_comment_attachment_fk_comment,
    ADD CONSTRAINT tms_test_case_execution_comment_attachment_fk_comment
        FOREIGN KEY (execution_comment_id) REFERENCES tms_test_case_execution_comment (id);

ALTER TABLE tms_test_case_execution_comment
    DROP CONSTRAINT tms_test_case_execution_comment_fk_execution,
    ADD CONSTRAINT tms_test_case_execution_comment_fk_execution
        FOREIGN KEY (execution_id) REFERENCES tms_test_case_execution (id);

ALTER TABLE tms_test_folder_test_item
    DROP CONSTRAINT IF EXISTS tms_test_folder_test_item_fk_launch;

ALTER TABLE tms_step_execution
    DROP CONSTRAINT IF EXISTS tms_step_execution_fk_launch;

ALTER TABLE tms_test_case_execution
    DROP CONSTRAINT IF EXISTS tms_test_case_execution_fk_launch;
