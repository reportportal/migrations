ALTER TABLE ticket
    DROP CONSTRAINT ticket_submitter_id_fkey;

ALTER TABLE ticket
    RENAME COLUMN submitter_id TO submitter;

ALTER TABLE ticket
    ALTER COLUMN submitter TYPE VARCHAR
