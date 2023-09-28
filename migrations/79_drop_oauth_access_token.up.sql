CREATE OR REPLACE FUNCTION drop_table_if_empty()
RETURNS void AS $$
DECLARE
  row_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO row_count FROM oauth_access_token;

  IF row_count = 0 THEN
    EXECUTE 'DROP TABLE oauth_access_token;';
  END IF;
END;
$$ LANGUAGE plpgsql;

SELECT drop_table_if_empty();

DROP FUNCTION IF EXISTS drop_table_if_empty;