ALTER TABLE ticket
    ALTER COLUMN bts_url TYPE VARCHAR(1024),
    ALTER COLUMN bts_project TYPE VARCHAR(1024),
    ALTER COLUMN url TYPE VARCHAR(1024),
    ALTER COLUMN ticket_id TYPE VARCHAR(256);

ALTER TABLE test_item
    ALTER COLUMN unique_id TYPE VARCHAR(1024);

CREATE OR REPLACE FUNCTION multi_nextval(use_seqname REGCLASS,
                                         use_increment INTEGER) RETURNS BIGINT AS
$$
DECLARE
    reply   BIGINT;
    lock_id BIGINT := (use_seqname::BIGINT - 2147483648)::INTEGER;
BEGIN
    PERFORM pg_advisory_lock(lock_id);
    reply := nextval(use_seqname);
    PERFORM setval(use_seqname, reply + use_increment - 1, TRUE);
    PERFORM pg_advisory_unlock(lock_id);
    RETURN reply;
END;
$$ LANGUAGE plpgsql;