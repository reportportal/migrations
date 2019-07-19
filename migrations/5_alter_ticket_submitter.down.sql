ALTER TABLE ticket
    ALTER COLUMN submitter TYPE BIGINT USING coalesce(submitter, '1')::BIGINT;

ALTER TABLE ticket
    RENAME COLUMN submitter TO submitter_id;

ALTER TABLE ticket
    ADD CONSTRAINT ticket_submitter_id_fkey FOREIGN KEY (submitter_id) REFERENCES users (id);