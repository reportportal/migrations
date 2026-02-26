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
	AFTER INSERT OR UPDATE ON launch
	FOR EACH ROW
	EXECUTE FUNCTION update_last_modified_from_launch();
