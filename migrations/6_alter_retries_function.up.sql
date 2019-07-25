CREATE OR REPLACE FUNCTION handle_retries(itemid BIGINT)
  RETURNS INTEGER
AS
$$
DECLARE
  maxstarttime           TIMESTAMP;
  itemidwithmaxstarttime BIGINT;
  newitemstarttime       TIMESTAMP;
  newitemlaunchid        BIGINT;
  newitemuniqueid        VARCHAR;
  newitemid              BIGINT;
  newitemname            VARCHAR;
  newitempathlevel       INTEGER;
BEGIN

  IF itemid ISNULL
  THEN
    RETURN 1;
  END IF;

  SELECT item_id, name, start_time, launch_id, unique_id, nlevel(path)
  FROM test_item
  WHERE item_id = itemid INTO newitemid, newitemname, newitemstarttime, newitemlaunchid, newitemuniqueid, newitempathlevel;

  SELECT item_id, start_time
  FROM test_item
  WHERE launch_id = newitemlaunchid
    AND unique_id = newitemuniqueid
    AND name = newitemname
    AND item_id != newitemid
    AND nlevel(path) = newitempathlevel
  ORDER BY start_time DESC, item_id DESC
  LIMIT 1 INTO itemidwithmaxstarttime, maxstarttime;

  IF
    maxstarttime IS NULL
  THEN
    RETURN 0;
  END IF;

  IF
    maxstarttime <= newitemstarttime
  THEN
    UPDATE test_item
    SET retry_of    = newitemid,
        launch_id   = NULL,
        has_retries = FALSE,
        path        = ((SELECT path FROM test_item WHERE item_id = newitemid) :: TEXT || '.' || item_id) :: LTREE
    WHERE unique_id = newitemuniqueid
      AND (retry_of IN (SELECT DISTINCT retries_parent.item_id
                        FROM test_item retries_parent
                               LEFT JOIN test_item retries ON retries_parent.item_id = retries.retry_of
                        WHERE retries_parent.launch_id = newitemlaunchid
                          AND retries_parent.unique_id = newitemuniqueid)
      OR (retry_of IS NULL AND launch_id = newitemlaunchid))
      AND name = newitemname
      AND item_id != newitemid;

    UPDATE test_item
    SET retry_of    = NULL,
        has_retries = TRUE
    WHERE item_id = newitemid;

    perform retries_statistics(newitemlaunchid);
  ELSE
    UPDATE test_item
    SET retry_of    = itemidwithmaxstarttime,
        launch_id   = NULL,
        has_retries = FALSE,
        path        = ((SELECT path FROM test_item WHERE item_id = itemidwithmaxstarttime) :: TEXT || '.' || item_id) :: LTREE
    WHERE item_id = newitemid;

    UPDATE test_item ti
    SET retry_of    = NULL,
        has_retries = TRUE,
        path        = ((SELECT path FROM test_item WHERE item_id = ti.parent_id) :: TEXT || '.' || ti.item_id) :: LTREE
    WHERE ti.item_id = itemidwithmaxstarttime;
  END IF;
  RETURN 0;
END;
$$
  LANGUAGE plpgsql;