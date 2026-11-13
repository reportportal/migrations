-- ============================================================================
-- REVERT CASCADE DELETE OF TMS ATTACHMENT LINKS
-- ============================================================================

ALTER TABLE tms_test_case_execution_comment_attachment
    DROP CONSTRAINT tms_test_case_execution_comment_attachment_fk_attachment,
    ADD CONSTRAINT tms_test_case_execution_comment_attachment_fk_attachment
        FOREIGN KEY (attachment_id) REFERENCES tms_attachment (id);

ALTER TABLE tms_manual_scenario_preconditions_attachment
    DROP CONSTRAINT tms_manual_scenario_preconditions_attachment_fk_attachment,
    ADD CONSTRAINT tms_manual_scenario_preconditions_attachment_fk_attachment
        FOREIGN KEY (attachment_id) REFERENCES tms_attachment (id);

ALTER TABLE tms_step_attachment
    DROP CONSTRAINT tms_step_attachment_fk_attachment,
    ADD CONSTRAINT tms_step_attachment_fk_attachment
        FOREIGN KEY (attachment_id) REFERENCES tms_attachment (id);

ALTER TABLE tms_text_manual_scenario_attachment
    DROP CONSTRAINT tms_text_manual_scenario_attachment_fk_attachment,
    ADD CONSTRAINT tms_text_manual_scenario_attachment_fk_attachment
        FOREIGN KEY (attachment_id) REFERENCES tms_attachment (id);
