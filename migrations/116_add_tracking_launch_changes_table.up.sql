CREATE TABLE IF NOT EXISTS launches_modified
(
    launch_id  BIGINT PRIMARY KEY REFERENCES launch (id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS idx_launches_modified_created_at ON launches_modified (created_at);

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