CREATE OR REPLACE FUNCTION handle_retry(retry_id BIGINT, retry_parent_id BIGINT)
    RETURNS INTEGER
AS
$$
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
$$
    LANGUAGE plpgsql;