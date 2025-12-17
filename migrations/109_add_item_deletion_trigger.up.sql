CREATE TABLE IF NOT EXISTS test_item_deleted (
    id BIGSERIAL PRIMARY KEY,
    item_id BIGINT NOT NULL UNIQUE,
    deleted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_test_item_deleted_deleted_at
    ON test_item_deleted(deleted_at);

CREATE OR REPLACE FUNCTION track_test_item_deletes()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.has_children = FALSE
       AND OLD.has_stats = TRUE
       AND OLD.retry_of IS NULL
       AND OLD.type NOT IN ('SUITE', 'TEST')
    THEN
        INSERT INTO test_item_deleted (item_id, deleted_at)
        VALUES (OLD.item_id, NOW())
        ON CONFLICT (item_id) DO NOTHING;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER test_item_delete_trigger
AFTER DELETE ON test_item
FOR EACH ROW
EXECUTE FUNCTION track_test_item_deletes();