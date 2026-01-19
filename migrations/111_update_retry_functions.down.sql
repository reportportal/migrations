-- DROP FUNCTION public.handle_retries(int8);

CREATE OR REPLACE FUNCTION public.handle_retries(itemid bigint)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    cur_id                 BIGINT;
    max_start_time         TIMESTAMP;
    max_start_time_item_id BIGINT;
    new_item_start_time    TIMESTAMP;
    new_item_launch_id     BIGINT;
    new_item_unique_id     VARCHAR;
    new_item_id            BIGINT;
    new_item_name          VARCHAR;
    new_item_parent_id     BIGINT;
    new_item_path_level    INTEGER;
    path_value             TEXT;
BEGIN

    IF itemid ISNULL
    THEN
        RETURN 1;
    END IF;

    SELECT item_id, name, start_time, launch_id, unique_id, nlevel(path)
    FROM test_item
    WHERE item_id = itemid
    INTO new_item_id, new_item_name, new_item_start_time, new_item_launch_id, new_item_unique_id, new_item_path_level;

    SELECT item_id, start_time
    FROM test_item
    WHERE launch_id = new_item_launch_id
      AND unique_id = new_item_unique_id
      AND name = new_item_name
      AND item_id != new_item_id
      AND nlevel(path) = new_item_path_level
    ORDER BY start_time DESC, item_id DESC
    LIMIT 1
    INTO max_start_time_item_id, max_start_time;

    IF
        max_start_time IS NULL
    THEN
        RETURN 0;
    END IF;

    IF
        max_start_time <= new_item_start_time
    THEN

        UPDATE test_item
        SET retry_of    = NULL,
            has_retries = TRUE,
            launch_id   = new_item_launch_id
        WHERE item_id = new_item_id;

        new_item_parent_id := (SELECT item_id FROM test_item WHERE item_id = (SELECT parent_id FROM test_item WHERE item_id = itemid));
        path_value := (SELECT path FROM test_item WHERE item_id = new_item_id) :: TEXT;

        FOR cur_id IN
            (SELECT item_id
             FROM test_item
             WHERE unique_id = new_item_unique_id
               AND name = new_item_name
               AND parent_id = new_item_parent_id
               AND item_id != new_item_id
             ORDER BY item_id)

            LOOP
                UPDATE test_item
                SET retry_of    = new_item_id,
                    launch_id   = NULL,
                    has_retries = FALSE,
                    path        = (path_value || '.' || item_id) :: LTREE
                WHERE test_item.item_id = cur_id;
            END LOOP;


        PERFORM retries_statistics(new_item_launch_id);
    ELSE

        path_value := (SELECT path FROM test_item WHERE item_id = max_start_time_item_id) :: TEXT;

        UPDATE test_item
        SET retry_of    = max_start_time_item_id,
            launch_id   = NULL,
            has_retries = FALSE,
            path        = (path_value || '.' || item_id) :: LTREE
        WHERE item_id = new_item_id;

        path_value :=
                (SELECT path
                 FROM test_item
                 WHERE item_id = (SELECT parent_id FROM test_item WHERE item_id = max_start_time_item_id)) :: TEXT;

        UPDATE test_item ti
        SET retry_of    = NULL,
            has_retries = TRUE,
            path        = (path_value || '.' || ti.item_id) :: LTREE,
            launch_id   = new_item_launch_id
        WHERE ti.item_id = max_start_time_item_id;
    END IF;
    RETURN 0;
END;
$function$
;

-- DROP FUNCTION public.handle_retry(int8, int8);

CREATE OR REPLACE FUNCTION public.handle_retry(retry_id bigint, retry_parent_id bigint)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    current_retry_id BIGINT;
    new_parent_path  LTREE;
    retry RECORD;
    new_retry RECORD;
BEGIN

    IF retry_id IS NULL OR retry_parent_id IS NULL
    THEN
        RETURN 1;
    END IF;

    current_retry_id := (SELECT retry_of FROM test_item WHERE item_id = retry_id FOR UPDATE);

    IF (current_retry_id IS NOT NULL)
    THEN
        SELECT item_id, start_time INTO retry FROM test_item WHERE item_id = current_retry_id FOR UPDATE;
        retry_id := retry.item_id;
    ELSE
        SELECT item_id, start_time INTO retry FROM test_item WHERE item_id = retry_id FOR UPDATE;
    END IF;

    SELECT path, start_time INTO new_retry FROM test_item WHERE item_id = retry_parent_id;
    new_parent_path := new_retry.path;

    IF (retry.start_time < new_retry.start_time)
    THEN

    PERFORM delete_item_statistics(retry_id);

    UPDATE test_item
    SET retry_of    = retry_parent_id,
        launch_id   = NULL,
        has_retries = FALSE,
        path        = (new_parent_path :: TEXT || '.' || item_id) :: LTREE
    WHERE item_id IN (SELECT item_id
                      FROM test_item
                      WHERE retry_of = retry_id OR item_id = retry_id
                      ORDER BY item_id);

    UPDATE test_item
    SET has_retries = TRUE
    WHERE item_id = retry_parent_id;

    ELSE

    UPDATE test_item
    SET retry_of    = retry_id,
        launch_id   = NULL,
        has_retries = FALSE,
        path        = (new_parent_path :: TEXT || '.' || retry_id) :: LTREE
    WHERE item_id = retry_parent_id;

    END IF;

    RETURN 0;

END;
$function$
;