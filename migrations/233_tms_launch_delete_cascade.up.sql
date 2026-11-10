-- ============================================================================
-- CASCADE DELETE OF MANUAL LAUNCH TMS DATA
-- Deleting a launch (e.g. by the retention job) removes its TMS executions,
-- their comments and comment attachment links, step executions and folder links.
-- ============================================================================

-- Remove rows that already point to deleted launches, otherwise the new foreign keys cannot be added.
DELETE
FROM tms_test_case_execution_comment_attachment ca
    USING tms_test_case_execution_comment c, tms_test_case_execution e
WHERE ca.execution_comment_id = c.id
  AND c.execution_id = e.id
  AND NOT EXISTS (SELECT 1 FROM launch l WHERE l.id = e.launch_id);

DELETE
FROM tms_test_case_execution_comment c
    USING tms_test_case_execution e
WHERE c.execution_id = e.id
  AND NOT EXISTS (SELECT 1 FROM launch l WHERE l.id = e.launch_id);

DELETE
FROM tms_test_case_execution e
WHERE NOT EXISTS (SELECT 1 FROM launch l WHERE l.id = e.launch_id);

DELETE
FROM tms_step_execution se
WHERE NOT EXISTS (SELECT 1 FROM launch l WHERE l.id = se.launch_id);

DELETE
FROM tms_test_folder_test_item fti
WHERE NOT EXISTS (SELECT 1 FROM launch l WHERE l.id = fti.launch_id);

-- launch -> TMS tables
ALTER TABLE tms_test_case_execution
    ADD CONSTRAINT tms_test_case_execution_fk_launch
        FOREIGN KEY (launch_id) REFERENCES launch (id) ON DELETE CASCADE;

ALTER TABLE tms_step_execution
    ADD CONSTRAINT tms_step_execution_fk_launch
        FOREIGN KEY (launch_id) REFERENCES launch (id) ON DELETE CASCADE;

ALTER TABLE tms_test_folder_test_item
    ADD CONSTRAINT tms_test_folder_test_item_fk_launch
        FOREIGN KEY (launch_id) REFERENCES launch (id) ON DELETE CASCADE;

-- execution -> comment -> comment attachment link
ALTER TABLE tms_test_case_execution_comment
    DROP CONSTRAINT tms_test_case_execution_comment_fk_execution,
    ADD CONSTRAINT tms_test_case_execution_comment_fk_execution
        FOREIGN KEY (execution_id) REFERENCES tms_test_case_execution (id) ON DELETE CASCADE;

ALTER TABLE tms_test_case_execution_comment_attachment
    DROP CONSTRAINT tms_test_case_execution_comment_attachment_fk_comment,
    ADD CONSTRAINT tms_test_case_execution_comment_attachment_fk_comment
        FOREIGN KEY (execution_comment_id) REFERENCES tms_test_case_execution_comment (id) ON DELETE CASCADE;
