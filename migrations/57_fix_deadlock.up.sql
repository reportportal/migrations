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

--------------------------------------------

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

    defect_field := (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$',
                                   lower(public.issue_type.locator))
                     FROM issue_type JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                     WHERE issue_type.id = new.issue_type);

    defect_field_old_id := (SELECT sf_id FROM statistics_field
                            WHERE statistics_field.name =
                                  (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$',
                                                 lower(public.issue_type.locator))
                                   FROM issue_type JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                   WHERE issue_type.id = old.issue_type) LIMIT 1);

    defect_field_total := (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$total')
                           FROM issue_type JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                           WHERE issue_type.id = new.issue_type);

    defect_field_old_total_id := (SELECT sf_id
                                  FROM statistics_field
                                  WHERE statistics_field.name =
                                        (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$total')
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

---------------------------------------------

CREATE OR REPLACE FUNCTION delete_defect_statistics()
    RETURNS TRIGGER AS
$$
DECLARE
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
                                  (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$',
                                                 lower(public.issue_type.locator))
                                   FROM issue_type
                                            JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                   WHERE issue_type.id = old.issue_type) LIMIT 1);

    defect_field_old_total_id := (SELECT sf_id
                                  FROM statistics_field
                                  WHERE statistics_field.name =
                                        (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$total')
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

------------------------------------------------

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

------------------------------------------------

CREATE OR REPLACE FUNCTION handle_retry(retry_id BIGINT, retry_parent_id BIGINT)
    RETURNS INTEGER
AS
$$
DECLARE
    current_retry_id BIGINT;
    new_parent_path  LTREE;
BEGIN

    IF retry_id IS NULL OR retry_parent_id IS NULL
    THEN
        RETURN 1;
    END IF;

    current_retry_id := (SELECT retry_of FROM test_item WHERE item_id = retry_id FOR UPDATE);

    IF (current_retry_id IS NOT NULL)
    THEN
        retry_id := (SELECT item_id FROM test_item WHERE item_id = current_retry_id FOR UPDATE);
    END IF;

    PERFORM delete_item_statistics(retry_id);

    new_parent_path := (SELECT path FROM test_item WHERE item_id = retry_parent_id);

    UPDATE test_item
    SET retry_of    = retry_parent_id,
        launch_id   = NULL,
        has_retries = FALSE,
        path        = (new_parent_path :: TEXT || '.' || item_id) :: LTREE
    WHERE item_id IN (SELECT item_id
                      FROM test_item
                      WHERE retry_of = retry_id
                      ORDER BY item_id);

    UPDATE test_item
    SET retry_of    = retry_parent_id,
        launch_id   = NULL,
        has_retries = FALSE,
        path        = (new_parent_path :: TEXT || '.' || item_id) :: LTREE
    WHERE item_id = retry_id;

    UPDATE test_item
    SET has_retries = TRUE
    WHERE item_id = retry_parent_id;

    RETURN 0;
END;
$$
    LANGUAGE plpgsql;

------------------------------------------------

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

------------------------------------------------

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

    SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$', lower(public.issue_type.locator)) AS defect_field,
           concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$total') AS defect_field_total
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

    IF defect_field_total IS NULL
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

------------------------------------------------
