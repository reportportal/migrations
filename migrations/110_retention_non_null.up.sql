DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_launch ON launch;
DROP FUNCTION IF EXISTS update_last_modified_from_launch();

UPDATE launch SET retention_policy = 'REGULAR' WHERE retention_policy IS NULL;

ALTER TABLE launch ALTER COLUMN retention_policy SET NOT NULL;

CREATE OR REPLACE FUNCTION update_last_modified_from_launch()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE test_item
    SET last_modified = CURRENT_TIMESTAMP
    WHERE launch_id = NEW.id OR launch_id = OLD.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_test_item_last_modified_on_launch
AFTER UPDATE ON launch
FOR EACH ROW
WHEN (OLD.mode IS DISTINCT FROM NEW.mode)
EXECUTE FUNCTION update_last_modified_from_launch();