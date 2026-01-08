	CREATE index if not EXISTS test_item_last_modified_idx ON public.test_item USING btree (last_modified);

	-- TEST_ITEM_RESULTS
	CREATE OR REPLACE FUNCTION update_last_modified_from_results()
	RETURNS TRIGGER AS $$
	BEGIN
	    UPDATE test_item
	    SET last_modified = CURRENT_TIMESTAMP
	    WHERE item_id = NEW.result_id OR item_id = OLD.result_id;

	    RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER trg_update_test_item_last_modified_on_results
	AFTER INSERT OR UPDATE ON test_item_results
	FOR EACH ROW
	EXECUTE FUNCTION update_last_modified_from_results();


	-- LAUNCH
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


	-- ISSUE
	CREATE OR REPLACE FUNCTION update_last_modified_from_issue()
	RETURNS TRIGGER AS $$
	BEGIN
	    UPDATE test_item
	    SET last_modified = CURRENT_TIMESTAMP
	    WHERE item_id = OLD.issue_id OR item_id = NEW.issue_id;

	    RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER trg_update_test_item_last_modified_on_issue
	AFTER INSERT OR UPDATE OR DELETE ON issue
	FOR EACH ROW
	EXECUTE FUNCTION update_last_modified_from_issue();


	-- ISSUE_TICKET
	CREATE TRIGGER trg_update_test_item_last_modified_on_issue
	AFTER INSERT OR UPDATE OR DELETE ON issue_ticket
	FOR EACH ROW
	EXECUTE FUNCTION update_last_modified_from_issue();



	-- pattern_template_test_item
	CREATE OR REPLACE FUNCTION update_last_modified_from_pattern_template_test_item()
	RETURNS TRIGGER AS $$
	BEGIN
	    UPDATE test_item
	    SET last_modified = CURRENT_TIMESTAMP
	    WHERE item_id = OLD.item_id OR item_id = NEW.item_id;

	    RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER trg_update_test_item_last_modified_on_pattern_template_test_item
	AFTER INSERT OR UPDATE OR DELETE ON pattern_template_test_item
	FOR EACH ROW
	EXECUTE FUNCTION update_last_modified_from_pattern_template_test_item();



	--item_attribute/launch_attribute
  CREATE OR REPLACE FUNCTION update_last_modified_from_item_attribute()
  RETURNS TRIGGER AS $$
  BEGIN
      IF NEW.item_id IS NOT NULL OR OLD.item_id IS NOT NULL THEN
          UPDATE test_item
          SET last_modified = CURRENT_TIMESTAMP
          WHERE item_id = COALESCE(NEW.item_id, OLD.item_id);
      END IF;

      IF NEW.launch_id IS NOT NULL OR OLD.launch_id IS NOT NULL THEN
          UPDATE test_item
          SET last_modified = CURRENT_TIMESTAMP
          WHERE launch_id = COALESCE(NEW.launch_id, OLD.launch_id);
      END IF;

      RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

	CREATE TRIGGER trg_update_test_item_last_modified_on_item_attribute
	AFTER INSERT OR UPDATE OR DELETE ON item_attribute
	FOR EACH ROW
	EXECUTE FUNCTION update_last_modified_from_item_attribute();


  -- Handle updates to the `name` column in pattern_template
  CREATE OR REPLACE FUNCTION update_last_modified_from_pattern_template()
  RETURNS TRIGGER AS $$
  BEGIN
      UPDATE test_item
      SET last_modified = CURRENT_TIMESTAMP
      WHERE item_id IN (
          SELECT item_id
          FROM pattern_template_test_item
          WHERE pattern_id = OLD.id
      );

      RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

  CREATE TRIGGER trg_update_test_item_last_modified_on_pattern_template
  AFTER UPDATE OF name ON pattern_template
  FOR EACH ROW
  EXECUTE FUNCTION update_last_modified_from_pattern_template();
