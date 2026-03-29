CREATE OR REPLACE FUNCTION decrease_statistics()
    RETURNS TRIGGER AS
$$
DECLARE
    cur_launch_id         BIGINT;
    DECLARE
    cur_statistics_fields RECORD;
    DECLARE
    processed_test_item RECORD;
BEGIN

    SELECT item_id, launch_id, has_stats, retry_of, ('{' || replace(path::TEXT, '.', ',') || '}')::bigint[] AS arr_path INTO processed_test_item FROM test_item WHERE item_id = old.result_id FOR UPDATE;

    cur_launch_id := processed_test_item.launch_id;
    IF cur_launch_id IS NULL
    THEN
        RETURN old;
    END IF;

    IF NOT processed_test_item.has_stats OR processed_test_item.retry_of IS NOT NULL
    THEN
        RETURN old;
    END IF;

    FOR cur_statistics_fields IN (SELECT statistics_field_id, s_counter
                                  FROM statistics
                                  WHERE item_id = old.result_id
                                  ORDER BY statistics_field_id)
        LOOP
            UPDATE statistics
            SET s_counter = s_counter - cur_statistics_fields.s_counter
            WHERE statistics.statistics_field_id = cur_statistics_fields.statistics_field_id
              AND (launch_id = cur_launch_id
                OR
                   (item_id = ANY(processed_test_item.arr_path) AND item_id != old.result_id)
                );
        END LOOP;

    DELETE FROM statistics WHERE item_id = old.result_id;

    RETURN old;
END;
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_defect_statistics()
    RETURNS TRIGGER AS
$$
DECLARE
    defect_field              VARCHAR;
    DECLARE
    defect_field_total        VARCHAR;
    DECLARE
    defect_field_old_id       BIGINT;
    DECLARE
    defect_field_old_total_id BIGINT;
    DECLARE
    defect_field_id           BIGINT;
    DECLARE
    defect_field_total_id     BIGINT;
    DECLARE
    cur_launch_id             BIGINT;
    DECLARE
    processed_test_item RECORD;
BEGIN
    IF old.issue_type = new.issue_type
    THEN
        RETURN new;
    END IF;

    SELECT item_id, launch_id, has_stats, retry_of, ('{' || replace(path::TEXT, '.', ',') || '}')::bigint[] AS arr_path INTO processed_test_item FROM test_item WHERE item_id = new.issue_id FOR UPDATE;

    cur_launch_id := processed_test_item.launch_id;
    IF cur_launch_id IS NULL
    THEN
        RETURN new;
    END IF;

    IF NOT processed_test_item.has_stats OR processed_test_item.retry_of IS NOT NULL
    THEN
        RETURN new;
    END IF;

    IF exists(SELECT 1
              FROM test_item AS parent
                       JOIN test_item AS child ON parent.item_id = child.parent_id
              WHERE (parent.item_id = new.issue_id AND child.has_stats)
        )
    THEN
        RETURN new;
    END IF;

    defect_field := (SELECT concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$',
                                   lower(issue_type.locator))
                     FROM issue_type JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                     WHERE issue_type.id = new.issue_type);

    defect_field_old_id := (SELECT sf_id FROM statistics_field
                            WHERE statistics_field.name =
                                  (SELECT concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$',
                                                 lower(issue_type.locator))
                                   FROM issue_type JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                   WHERE issue_type.id = old.issue_type) LIMIT 1);

    defect_field_total := (SELECT concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$total')
                           FROM issue_type JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                           WHERE issue_type.id = new.issue_type);

    defect_field_old_total_id := (SELECT sf_id
                                  FROM statistics_field
                                  WHERE statistics_field.name =
                                        (SELECT concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$total')
                                         FROM issue_type JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                         WHERE issue_type.id = old.issue_type) LIMIT 1);

    defect_field_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field LIMIT 1);
    IF defect_field_id IS NULL
    THEN
        INSERT INTO statistics_field (name) VALUES (defect_field) ON CONFLICT DO NOTHING;
        defect_field_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field LIMIT 1);
    END IF;

    defect_field_total_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field_total LIMIT 1);
    IF defect_field_total_id IS NULL
    THEN
        INSERT INTO statistics_field (name) VALUES (defect_field_total) ON CONFLICT DO NOTHING;
        defect_field_total_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field_total LIMIT 1);
    END IF;

    /* decrease item defects statistics for concrete field */
    UPDATE statistics SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_id
      AND statistics.item_id = ANY(processed_test_item.arr_path);

    /* increment item defects statistics for concrete field */
    INSERT INTO statistics (s_counter, statistics_field_id, item_id)
    VALUES (1, defect_field_id, unnest(processed_test_item.arr_path))
    ON CONFLICT (statistics_field_id,item_id) DO UPDATE SET s_counter = statistics.s_counter + 1;

    /* decrease item defects statistics for total field */
    UPDATE statistics
    SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_total_id
      AND item_id = ANY(processed_test_item.arr_path);

    /* increment item defects statistics for total field */
    INSERT INTO statistics (s_counter, statistics_field_id, item_id)
    VALUES (1, defect_field_total_id, unnest(processed_test_item.arr_path))
    ON CONFLICT (statistics_field_id,item_id) DO UPDATE SET s_counter = statistics.s_counter + 1;

    /* decrease launch defects statistics for concrete field */
    UPDATE statistics SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_id AND launch_id = cur_launch_id;

    /* increment launch defects statistics for concrete field */
    INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
    VALUES (1, defect_field_id, cur_launch_id)
    ON CONFLICT (statistics_field_id,launch_id) DO UPDATE SET s_counter = statistics.s_counter + 1;

    /* decrease launch defects statistics for total field */
    UPDATE statistics SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_total_id AND launch_id = cur_launch_id;

    /* increment launch defects statistics for total field */
    INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
    VALUES (1, defect_field_total_id, cur_launch_id)
    ON CONFLICT (statistics_field_id,launch_id) DO UPDATE SET s_counter = statistics.s_counter + 1;
    RETURN new;
END;
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_defect_statistics()
    RETURNS TRIGGER AS
$$
DECLARE
    cur_launch_id             BIGINT;
    DECLARE
    defect_field_old_id       BIGINT;
    DECLARE
    defect_field_old_total_id BIGINT;
    DECLARE
    processed_test_item RECORD;
BEGIN
    SELECT item_id, launch_id, has_stats, retry_of, ('{' || replace(path::TEXT, '.', ',') || '}')::bigint[] AS arr_path
    INTO processed_test_item FROM test_item WHERE item_id = old.issue_id FOR UPDATE;

    cur_launch_id := processed_test_item.launch_id;
    IF cur_launch_id IS NULL
    THEN
        RETURN old;
    END IF;

    IF NOT processed_test_item.has_stats OR processed_test_item.retry_of IS NOT NULL
    THEN
        RETURN old;
    END IF;

    defect_field_old_id := (SELECT sf_id
                            FROM statistics_field
                            WHERE statistics_field.name =
                                  (SELECT concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$',
                                                 lower(issue_type.locator))
                                   FROM issue_type
                                            JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                   WHERE issue_type.id = old.issue_type) LIMIT 1);

    defect_field_old_total_id := (SELECT sf_id
                                  FROM statistics_field
                                  WHERE statistics_field.name =
                                        (SELECT concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$total')
                                         FROM issue_type
                                                  JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                         WHERE issue_type.id = old.issue_type) LIMIT 1);

    /* decrease item defects statistics for concrete field */
    UPDATE statistics
    SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_id AND statistics.item_id = ANY(processed_test_item.arr_path);

    /* decrease item defects statistics for total field */
    UPDATE statistics
    SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_total_id AND item_id = ANY(processed_test_item.arr_path);

    /* decrease launch defects statistics for concrete field */
    UPDATE statistics
    SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_id AND launch_id = cur_launch_id;

    /* decrease launch defects statistics for total field */
    UPDATE statistics
    SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_total_id AND launch_id = cur_launch_id;
    RETURN old;
END;
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_item_statistics(test_item_id BIGINT)
    RETURNS INTEGER AS
$$
DECLARE
    cur_launch_id         BIGINT;
    cur_statistics_fields RECORD;
    DECLARE processed_test_item RECORD;
BEGIN

    IF test_item_id IS NULL
    THEN
        RETURN 1;
    END IF;

    cur_launch_id := (SELECT test_item.launch_id FROM test_item WHERE test_item.item_id = test_item_id);

    IF cur_launch_id IS NULL
    THEN
        RETURN 1;
    END IF;

    DELETE FROM issue WHERE issue_id = test_item_id;

    SELECT ('{' || replace(path::TEXT, '.', ',') || '}')::bigint[] AS arr_path INTO processed_test_item FROM test_item WHERE item_id = test_item_id;

    FOR cur_statistics_fields IN (SELECT statistics_field_id, s_counter
                                  FROM statistics
                                  WHERE item_id = test_item_id
                                  ORDER BY statistics_field_id)
        LOOP
            UPDATE statistics
            SET s_counter = s_counter - cur_statistics_fields.s_counter
            WHERE statistics.statistics_field_id = cur_statistics_fields.statistics_field_id
              AND (launch_id = cur_launch_id OR (item_id = ANY(processed_test_item.arr_path) AND item_id != test_item_id));
        END LOOP;

    DELETE FROM statistics WHERE item_id = test_item_id;

    RETURN 0;
END;
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_executions_statistics()
    RETURNS TRIGGER AS
$$
DECLARE
    DECLARE
    executions_field          VARCHAR;
    DECLARE
    executions_field_id       BIGINT;
    DECLARE
    executions_field_old      VARCHAR;
    DECLARE
    executions_field_old_id   BIGINT;
    DECLARE
    executions_field_total    VARCHAR;
    DECLARE
    executions_field_total_id BIGINT;
    DECLARE
    cur_launch_id             BIGINT;
    DECLARE
    counter_decrease          INTEGER;
    DECLARE
    processed_test_item RECORD;
BEGIN
    SELECT item_id, launch_id, has_stats, retry_of, has_children, type::TEXT, ('{' || replace(path::TEXT, '.', ',') || '}')::bigint[] AS arr_path INTO processed_test_item FROM test_item WHERE item_id = new.result_id FOR UPDATE;

    cur_launch_id := processed_test_item.launch_id;
    IF cur_launch_id IS NULL
    THEN
        RETURN new;
    END IF;

    IF NOT processed_test_item.has_stats OR processed_test_item.retry_of IS NOT NULL
    THEN
        RETURN new;
    END IF;

    IF processed_test_item.has_children OR NOT processed_test_item.has_stats
           OR (processed_test_item.type != 'TEST'
               AND processed_test_item.type != 'SCENARIO'
               AND processed_test_item.type != 'STEP')
    THEN
        RETURN new;
    END IF;

    IF new.status = 'INTERRUPTED' :: STATUS_ENUM
    THEN
        executions_field := 'statistics$executions$failed';
    ELSE
        executions_field := concat('statistics$executions$', lower(new.status :: VARCHAR));
    END IF;
    executions_field_total := 'statistics$executions$total';

    executions_field_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = executions_field LIMIT 1);
    IF executions_field_id IS NULL
    THEN
        INSERT INTO statistics_field (name) VALUES (executions_field) ON CONFLICT DO NOTHING;
        executions_field_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = executions_field LIMIT 1);
    END IF;

    executions_field_total_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = executions_field_total LIMIT 1);
    IF executions_field_total_id IS NULL
    THEN
        INSERT INTO statistics_field (name) VALUES (executions_field_total) ON CONFLICT DO NOTHING;
        executions_field_total_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = executions_field_total LIMIT 1);
    END IF;

    IF old.status = 'IN_PROGRESS' :: STATUS_ENUM
    THEN
        INSERT INTO statistics (s_counter, statistics_field_id, item_id)
        VALUES (1, executions_field_id, unnest(processed_test_item.arr_path))
        ON CONFLICT (statistics_field_id,item_id) DO UPDATE SET s_counter = statistics.s_counter + 1;

        INSERT INTO statistics (s_counter, statistics_field_id, item_id)
        VALUES (1, executions_field_total_id, unnest(processed_test_item.arr_path))
        ON CONFLICT (statistics_field_id,item_id) DO UPDATE SET s_counter = statistics.s_counter + 1;

        /* increment launch executions statistics for concrete field */
        INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
        VALUES (1, executions_field_id, cur_launch_id)
        ON CONFLICT (statistics_field_id,launch_id) DO UPDATE SET s_counter = statistics.s_counter + 1;

        /* increment launch executions statistics for total field */
        INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
        VALUES (1, executions_field_total_id, cur_launch_id)
        ON CONFLICT (statistics_field_id,launch_id) DO UPDATE SET s_counter = statistics.s_counter + 1;
        RETURN new;
    END IF;

    IF old.status != 'IN_PROGRESS' :: STATUS_ENUM AND old.status != new.status
    THEN
        IF old.status = 'INTERRUPTED' :: STATUS_ENUM
        THEN
            executions_field_old := 'statistics$executions$failed';
        ELSE
            executions_field_old := concat('statistics$executions$', lower(old.status :: VARCHAR));
        END IF;
        executions_field_old_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = executions_field_old LIMIT 1);

        SELECT s_counter INTO counter_decrease FROM statistics WHERE item_id = new.result_id
                                                                 AND statistics_field_id = executions_field_old_id;

        /* decrease item executions statistics for old field */
        UPDATE statistics SET s_counter = s_counter - counter_decrease
        WHERE statistics_field_id = executions_field_old_id AND item_id = ANY(processed_test_item.arr_path);

        /* increment item executions statistics for concrete field */
        INSERT INTO statistics (s_counter, statistics_field_id, item_id)
        VALUES (1, executions_field_id, unnest(processed_test_item.arr_path))
        ON CONFLICT (statistics_field_id,item_id) DO UPDATE SET s_counter = statistics.s_counter + 1;

        /* decrease item executions statistics for old field */
        UPDATE statistics SET s_counter = s_counter - counter_decrease WHERE statistics_field_id = executions_field_old_id
                                                                         AND launch_id = cur_launch_id;
        /* increment launch executions statistics for concrete field */
        INSERT INTO statistics (s_counter, statistics_field_id, launch_id) VALUES (1, executions_field_id, cur_launch_id)
        ON CONFLICT (statistics_field_id,launch_id) DO UPDATE SET s_counter = statistics.s_counter + 1;
        RETURN new;
    END IF;
    RETURN new;
END;
$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_defect_statistics()
    RETURNS TRIGGER AS
$$
DECLARE
    DECLARE
    defect_field          VARCHAR;
    DECLARE
    defect_field_id       BIGINT;
    DECLARE
    defect_field_total    VARCHAR;
    DECLARE
    defect_field_total_id BIGINT;
    DECLARE
    cur_launch_id         BIGINT;
    DECLARE
    processed_test_item RECORD;
    DECLARE
    defect_info RECORD;

BEGIN
    SELECT item_id, launch_id, has_stats, retry_of, ('{' || replace(path::TEXT, '.', ',') || '}')::bigint[] AS arr_path INTO processed_test_item FROM test_item WHERE item_id = new.issue_id FOR UPDATE;

    cur_launch_id := processed_test_item.launch_id;
    IF cur_launch_id IS NULL
    THEN
        RETURN new;
    END IF;

    IF NOT processed_test_item.has_stats OR processed_test_item.retry_of IS NOT NULL
    THEN
        RETURN new;
    END IF;

    IF exists(SELECT 1
              FROM test_item AS parent
                       JOIN test_item AS child ON parent.item_id = child.parent_id
              WHERE (parent.item_id = new.issue_id AND child.has_stats)
        )
    THEN
        RETURN new;
    END IF;

    SELECT concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$', lower(issue_type.locator)) AS defect_field,
           concat('statistics$defects$', lower(issue_group.issue_group :: VARCHAR), '$total') AS defect_field_total
    INTO defect_info
    FROM issue
             JOIN issue_type ON issue.issue_type = issue_type.id
             JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
    WHERE issue.issue_id = new.issue_id;
    defect_field := defect_info.defect_field;
    defect_field_total := defect_info.defect_field_total;

    defect_field_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field LIMIT 1);
    defect_field_total_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field_total LIMIT 1);

    IF defect_field_id IS NULL
    THEN
        INSERT INTO statistics_field (name) VALUES (defect_field) ON CONFLICT DO NOTHING;
        defect_field_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field LIMIT 1);
    END IF;

    IF defect_field_total_id IS NULL
    THEN
        INSERT INTO statistics_field (name) VALUES (defect_field_total) ON CONFLICT DO NOTHING;
        defect_field_total_id = (SELECT sf_id FROM statistics_field WHERE statistics_field.name = defect_field_total LIMIT 1);
    END IF;


    INSERT INTO statistics (s_counter, statistics_field_id, item_id)
        (SELECT 1, defect_field_id, unnest(processed_test_item.arr_path) AS item_id ORDER BY item_id)
    ON CONFLICT (statistics_field_id,item_id)
        DO UPDATE SET s_counter = statistics.s_counter + 1;

    INSERT INTO statistics (s_counter, statistics_field_id, item_id)
        (SELECT 1, defect_field_total_id, unnest(processed_test_item.arr_path) AS item_id ORDER BY item_id)
    ON CONFLICT (statistics_field_id,
        item_id)
        DO UPDATE SET s_counter = statistics.s_counter + 1;

    /* increment launch defects statistics for concrete field */
    INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
    VALUES (1, defect_field_id, cur_launch_id)
    ON CONFLICT (statistics_field_id,
        launch_id)
        DO UPDATE SET s_counter = statistics.s_counter + 1;
    /* increment launch defects statistics for total field */
    INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
    VALUES (1, defect_field_total_id, cur_launch_id)
    ON CONFLICT (statistics_field_id,
        launch_id)
        DO UPDATE SET s_counter = statistics.s_counter + 1;
    RETURN new;
END;
$$
    LANGUAGE plpgsql;

-- retries_statistics (from 1_initialize_schema)
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

-- update_last_modified_on_retry: stub (no trigger dropped in 114; original definition not found in migrations)
CREATE OR REPLACE FUNCTION update_last_modified_on_retry()
    RETURNS TRIGGER AS $$
BEGIN
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- handle_retry, handle_retries (from 111_update_retry_functions.down)
CREATE OR REPLACE FUNCTION handle_retry(retry_id bigint, retry_parent_id bigint)
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

CREATE OR REPLACE FUNCTION handle_retries(itemid bigint)
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

-- Restore triggers (from 1_initialize_schema)
CREATE TRIGGER after_test_results_update
    AFTER UPDATE
    ON test_item_results
    FOR EACH ROW
EXECUTE PROCEDURE update_executions_statistics();

CREATE TRIGGER after_issue_insert
    AFTER INSERT
    ON issue
    FOR EACH ROW
EXECUTE PROCEDURE increment_defect_statistics();

CREATE TRIGGER after_issue_update
    AFTER UPDATE
    ON issue
    FOR EACH ROW
EXECUTE PROCEDURE update_defect_statistics();

CREATE TRIGGER before_issue_delete
    BEFORE DELETE
    ON issue
    FOR EACH ROW
EXECUTE PROCEDURE delete_defect_statistics();

CREATE TRIGGER before_item_delete
    BEFORE DELETE
    ON test_item_results
    FOR EACH ROW
EXECUTE PROCEDURE decrease_statistics();
