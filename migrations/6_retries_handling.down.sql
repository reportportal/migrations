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
    WHERE item_id = itemid
    INTO newitemid, newitemname, newitemstarttime, newitemlaunchid, newitemuniqueid, newitempathlevel;

    SELECT item_id, start_time
    FROM test_item
    WHERE launch_id = newitemlaunchid
      AND unique_id = newitemuniqueid
      AND name = newitemname
      AND item_id != newitemid
      AND nlevel(path) = newitempathlevel
    ORDER BY start_time DESC, item_id DESC
    LIMIT 1
    INTO itemidwithmaxstarttime, maxstarttime;

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

        PERFORM retries_statistics(newitemlaunchid);
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

BEGIN
    IF exists(SELECT 1
              FROM test_item
              WHERE (test_item.parent_id = new.result_id
                  AND test_item.has_stats)
                 OR (test_item.item_id = new.result_id AND (NOT test_item.has_stats OR
                                                            (test_item.type != 'TEST' :: TEST_ITEM_TYPE_ENUM AND
                                                             test_item.type != 'SCENARIO' :: TEST_ITEM_TYPE_ENUM AND
                                                             test_item.type != 'STEP' :: TEST_ITEM_TYPE_ENUM)))
              LIMIT 1)
    THEN
        RETURN new;
    END IF;

    IF exists(SELECT 1
              FROM test_item
              WHERE item_id = new.result_id
                AND retry_of IS NOT NULL
              LIMIT 1)
    THEN
        RETURN new;
    END IF;

    cur_launch_id := (SELECT launch_id FROM test_item WHERE test_item.item_id = new.result_id);

    IF new.status = 'INTERRUPTED' :: STATUS_ENUM
    THEN
        executions_field := 'statistics$executions$failed';
    ELSE
        executions_field := concat('statistics$executions$', lower(new.status :: VARCHAR));
    END IF;

    executions_field_total := 'statistics$executions$total';

    INSERT INTO statistics_field (name) VALUES (executions_field) ON CONFLICT DO NOTHING;

    INSERT INTO statistics_field (name) VALUES (executions_field_total) ON CONFLICT DO NOTHING;

    executions_field_id = (SELECT DISTINCT ON (statistics_field.name) sf_id
                           FROM statistics_field
                           WHERE statistics_field.name = executions_field);
    executions_field_total_id = (SELECT DISTINCT ON (statistics_field.name) sf_id
                                 FROM statistics_field
                                 WHERE statistics_field.name = executions_field_total);

    IF old.status = 'IN_PROGRESS' :: STATUS_ENUM
    THEN
        INSERT INTO statistics (s_counter, statistics_field_id, item_id)
            (SELECT 1, executions_field_id, item_id
             FROM (SELECT item_id FROM test_item WHERE path @> (SELECT path FROM test_item WHERE item_id = new.result_id)) AS temp_bulk)
        ON CONFLICT (statistics_field_id,
            item_id)
            DO UPDATE SET s_counter = statistics.s_counter + 1;

        INSERT INTO statistics (s_counter, statistics_field_id, item_id)
            (SELECT 1, executions_field_total_id, item_id
             FROM (SELECT item_id FROM test_item WHERE path @> (SELECT path FROM test_item WHERE item_id = new.result_id)) AS temp_bulk)
        ON CONFLICT (statistics_field_id,
            item_id)
            DO UPDATE SET s_counter = statistics.s_counter + 1;

        /* increment launch executions statistics for concrete field */
        INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
        VALUES (1, executions_field_id, cur_launch_id)
        ON CONFLICT (statistics_field_id,
            launch_id)
            DO UPDATE SET s_counter = statistics.s_counter + 1;
        /* increment launch executions statistics for total field */
        INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
        VALUES (1, executions_field_total_id, cur_launch_id)
        ON CONFLICT (statistics_field_id,
            launch_id)
            DO UPDATE SET s_counter = statistics.s_counter + 1;
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

        executions_field_old_id = (SELECT DISTINCT ON (statistics_field.name) sf_id
                                   FROM statistics_field
                                   WHERE statistics_field.name = executions_field_old);

        SELECT s_counter
        INTO counter_decrease
        FROM statistics
        WHERE item_id = new.result_id
          AND statistics_field_id = executions_field_old_id;

        /* decrease item executions statistics for old field */
        UPDATE statistics
        SET s_counter = s_counter - counter_decrease
        WHERE statistics_field_id = executions_field_old_id
          AND item_id IN (SELECT item_id FROM test_item WHERE path @> (SELECT path FROM test_item WHERE item_id = new.result_id));

        /* increment item executions statistics for concrete field */
        INSERT INTO statistics (s_counter, statistics_field_id, item_id)
            (SELECT 1, executions_field_id, item_id
             FROM (SELECT item_id FROM test_item WHERE path @> (SELECT path FROM test_item WHERE item_id = new.result_id)) AS temp_bulk)
        ON CONFLICT (statistics_field_id,
            item_id)
            DO UPDATE SET s_counter = statistics.s_counter + 1;


        /* decrease item executions statistics for old field */
        UPDATE statistics
        SET s_counter = s_counter - counter_decrease
        WHERE statistics_field_id = executions_field_old_id
          AND launch_id = cur_launch_id;
        /* increment launch executions statistics for concrete field */
        INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
        VALUES (1, executions_field_id, cur_launch_id)
        ON CONFLICT (statistics_field_id,
            launch_id)
            DO UPDATE SET s_counter = statistics.s_counter + 1;
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

BEGIN
    IF exists(SELECT 1
              FROM test_item AS parent
                       JOIN test_item AS child ON parent.item_id = child.parent_id
              WHERE (parent.item_id = new.issue_id AND child.has_stats)
              LIMIT 1)
    THEN
        RETURN new;
    END IF;

    IF exists(SELECT 1
              FROM test_item
              WHERE item_id = new.issue_id
                AND retry_of IS NOT NULL
              LIMIT 1)
    THEN
        RETURN new;
    END IF;

    cur_launch_id := (SELECT launch_id FROM test_item WHERE test_item.item_id = new.issue_id);

    defect_field := (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$',
                                   lower(public.issue_type.locator))
                     FROM issue
                              JOIN issue_type ON issue.issue_type = issue_type.id
                              JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                     WHERE issue.issue_id = new.issue_id);

    defect_field_total := (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$total')
                           FROM issue
                                    JOIN issue_type ON issue.issue_type = issue_type.id
                                    JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                           WHERE issue.issue_id = new.issue_id);

    INSERT INTO statistics_field (name) VALUES (defect_field) ON CONFLICT DO NOTHING;

    INSERT INTO statistics_field (name) VALUES (defect_field_total) ON CONFLICT DO NOTHING;

    defect_field_id = (SELECT DISTINCT ON (statistics_field.name) sf_id FROM statistics_field WHERE statistics_field.name = defect_field);

    defect_field_total_id = (SELECT DISTINCT ON (statistics_field.name) sf_id
                             FROM statistics_field
                             WHERE statistics_field.name = defect_field_total);

    INSERT INTO statistics (s_counter, statistics_field_id, item_id)
        (SELECT 1, defect_field_id, item_id
         FROM (SELECT item_id FROM test_item WHERE path @> (SELECT path FROM test_item WHERE item_id = new.issue_id)) AS temp_bulk)
    ON CONFLICT (statistics_field_id,
        item_id)
        DO UPDATE SET s_counter = statistics.s_counter + 1;

    INSERT INTO statistics (s_counter, statistics_field_id, item_id)
        (SELECT 1, defect_field_total_id, item_id
         FROM (SELECT item_id FROM test_item WHERE path @> (SELECT path FROM test_item WHERE item_id = new.issue_id)) AS temp_bulk)
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

CREATE OR REPLACE FUNCTION update_defect_statistics()
    RETURNS TRIGGER AS
$$
DECLARE
    cur_id                    BIGINT;
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

BEGIN
    IF exists(SELECT 1
              FROM test_item AS parent
                       JOIN test_item AS child ON parent.item_id = child.parent_id
              WHERE (parent.item_id = new.issue_id AND child.has_stats)
              LIMIT 1)
    THEN
        RETURN new;
    END IF;

    IF exists(SELECT 1
              FROM test_item
              WHERE item_id = new.issue_id
                AND retry_of IS NOT NULL
              LIMIT 1)
    THEN
        RETURN new;
    END IF;

    IF old.issue_type = new.issue_type
    THEN
        RETURN new;
    END IF;

    cur_launch_id := (SELECT launch_id FROM test_item WHERE test_item.item_id = new.issue_id);

    defect_field := (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$',
                                   lower(public.issue_type.locator))
                     FROM issue_type
                              JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                     WHERE issue_type.id = new.issue_type);

    defect_field_old_id := (SELECT DISTINCT ON (statistics_field.name) sf_id
                            FROM statistics_field
                            WHERE statistics_field.name =
                                  (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$',
                                                 lower(public.issue_type.locator))
                                   FROM issue_type
                                            JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                   WHERE issue_type.id = old.issue_type));

    defect_field_total := (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$total')
                           FROM issue_type
                                    JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                           WHERE issue_type.id = new.issue_type);

    defect_field_old_total_id := (SELECT DISTINCT ON (statistics_field.name) sf_id
                                  FROM statistics_field
                                  WHERE statistics_field.name =
                                        (SELECT concat('statistics$defects$', lower(public.issue_group.issue_group :: VARCHAR), '$total')
                                         FROM issue_type
                                                  JOIN issue_group ON issue_type.issue_group_id = issue_group.issue_group_id
                                         WHERE issue_type.id = old.issue_type));

    INSERT INTO statistics_field (name) VALUES (defect_field) ON CONFLICT DO NOTHING;

    INSERT INTO statistics_field (name) VALUES (defect_field_total) ON CONFLICT DO NOTHING;

    defect_field_id = (SELECT DISTINCT ON (statistics_field.name) sf_id FROM statistics_field WHERE statistics_field.name = defect_field);

    defect_field_total_id = (SELECT DISTINCT ON (statistics_field.name) sf_id
                             FROM statistics_field
                             WHERE statistics_field.name = defect_field_total);

    FOR cur_id IN
        (SELECT item_id FROM test_item WHERE path @> (SELECT path FROM test_item WHERE item_id = new.issue_id))

        LOOP
            /* decrease item defects statistics for concrete field */
            UPDATE statistics
            SET s_counter = s_counter - 1
            WHERE statistics_field_id = defect_field_old_id
              AND statistics.item_id = cur_id;

            /* increment item defects statistics for concrete field */
            INSERT INTO statistics (s_counter, statistics_field_id, item_id)
            VALUES (1, defect_field_id, cur_id)
            ON CONFLICT (statistics_field_id,
                item_id)
                DO UPDATE SET s_counter = statistics.s_counter + 1;

            /* decrease item defects statistics for total field */
            UPDATE statistics
            SET s_counter = s_counter - 1
            WHERE statistics_field_id = defect_field_old_total_id
              AND item_id = cur_id;

            /* increment item defects statistics for total field */
            INSERT INTO statistics (s_counter, statistics_field_id, item_id)
            VALUES (1, defect_field_total_id, cur_id)
            ON CONFLICT (statistics_field_id,
                item_id)
                DO UPDATE SET s_counter = statistics.s_counter + 1;

        END LOOP;

    /* decrease launch defects statistics for concrete field */
    UPDATE statistics
    SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_id
      AND launch_id = cur_launch_id;

    /* increment launch defects statistics for concrete field */
    INSERT INTO statistics (s_counter, statistics_field_id, launch_id)
    VALUES (1, defect_field_id, cur_launch_id)
    ON CONFLICT (statistics_field_id,
        launch_id)
        DO UPDATE SET s_counter = statistics.s_counter + 1;

    /* decrease launch defects statistics for total field */
    UPDATE statistics
    SET s_counter = s_counter - 1
    WHERE statistics_field_id = defect_field_old_total_id
      AND launch_id = cur_launch_id;

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