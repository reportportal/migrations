CREATE TABLE IF NOT EXISTS tms_test_case_execution_comment_bts_ticket
(
    id          BIGSERIAL
        CONSTRAINT tms_test_case_execution_comment_bts_ticket_pk PRIMARY KEY,
    comment_id  bigint NOT NULL
        CONSTRAINT tms_test_case_execution_comment_bts_ticket_fk_comment REFERENCES tms_test_case_execution_comment ON DELETE CASCADE,
    url         varchar(255)
);

CREATE INDEX IF NOT EXISTS idx_tms_test_case_execution_comment_bts_ticket_comment_id
    ON tms_test_case_execution_comment_bts_ticket (comment_id);
