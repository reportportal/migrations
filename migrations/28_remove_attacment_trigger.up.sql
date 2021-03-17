DROP TRIGGER IF EXISTS after_attachment_inserted ON attachment;
DROP TRIGGER IF EXISTS after_attachment_removed ON attachment;
DROP FUNCTION IF EXISTS increment_allocated_size();
DROP FUNCTION IF EXISTS decrease_allocated_size();

CREATE TABLE IF NOT EXISTS shedlock (
    name       VARCHAR(64)  NOT NULL,
    lock_until TIMESTAMP    NOT NULL,
    locked_at  TIMESTAMP    NOT NULL,
    locked_by  VARCHAR(255) NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS attachment_tombstone AS
    TABLE attachment
    WITH NO DATA;