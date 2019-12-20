CREATE OR REPLACE FUNCTION retries_statistics(cur_launch_id BIGINT)
    RETURNS INTEGER AS
$$
DECLARE
    cur_id                BIGINT;
    DECLARE
    cur_statistics_fields RECORD;
    DECLARE
    retry_parents         RECORD;
BEGIN

    IF
        cur_launch_id IS NULL
    THEN
        RETURN 1;
    END IF;

    FOR retry_parents IN (SELECT DISTINCT retries.retry_of AS retry_id
                          FROM test_item retries
                                   JOIN test_item item ON retries.retry_of = item.item_id
                          WHERE item.launch_id = cur_launch_id
                            AND retries.retry_of IS NOT NULL)
        LOOP
            FOR cur_statistics_fields IN (SELECT statistics_field_id, sum(s_counter) AS counter_sum
                                          FROM statistics
                                                   JOIN test_item ti ON statistics.item_id = ti.item_id
                                          WHERE ti.retry_of = retry_parents.retry_id
                                          GROUP BY statistics_field_id)
                LOOP
                    UPDATE statistics
                    SET s_counter = s_counter - cur_statistics_fields.counter_sum
                    WHERE statistics.statistics_field_id = cur_statistics_fields.statistics_field_id
                      AND launch_id = cur_launch_id;
                END LOOP;

            FOR cur_id IN
                (SELECT item_id
                 FROM test_item
                 WHERE path @> (SELECT path FROM test_item WHERE item_id = retry_parents.retry_id)
                   AND item_id != retry_parents.retry_id)

                LOOP
                    FOR cur_statistics_fields IN (SELECT statistics_field_id, sum(s_counter) AS counter_sum
                                                  FROM statistics
                                                           JOIN test_item ti ON statistics.item_id = ti.item_id
                                                  WHERE ti.retry_of = retry_parents.retry_id
                                                  GROUP BY statistics_field_id)
                        LOOP
                            UPDATE statistics
                            SET s_counter = s_counter - cur_statistics_fields.counter_sum
                            WHERE statistics.statistics_field_id = cur_statistics_fields.statistics_field_id
                              AND item_id = cur_id;
                        END LOOP;
                END LOOP;

            DELETE FROM issue WHERE issue_id IN (SELECT item_id FROM test_item WHERE retry_of = retry_parents.retry_id);
            DELETE FROM statistics WHERE item_id IN (SELECT item_id FROM test_item WHERE retry_of = retry_parents.retry_id);

        END LOOP;
    RETURN 0;
END;
$$
    LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION handle_retries(itemid BIGINT)
    RETURNS INTEGER
AS
$$
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
$$
    LANGUAGE plpgsql;