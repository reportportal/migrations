CREATE OR REPLACE FUNCTION get_last_launch_number()
  RETURNS TRIGGER AS
$BODY$
BEGIN
  new.number = (SELECT number
                FROM launch
                WHERE name = new.name
                  AND project_id = new.project_id
                ORDER BY number DESC
                LIMIT 1) + 1;
  new.number = CASE
                 WHEN new.number IS NULL
                   THEN 1
                 ELSE new.number END;
  RETURN new;
END;
$BODY$
  LANGUAGE plpgsql;

CREATE TRIGGER last_launch_number_trigger
  BEFORE INSERT
  ON launch
  FOR EACH ROW
EXECUTE PROCEDURE get_last_launch_number();