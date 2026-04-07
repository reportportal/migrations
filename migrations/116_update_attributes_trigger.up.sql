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
      RETURN NEW;
  END;
  $function$
;