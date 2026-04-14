drop table if exists launches_modified;

CREATE OR REPLACE FUNCTION public.update_last_modified_from_item_attribute()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
  $function$
;
