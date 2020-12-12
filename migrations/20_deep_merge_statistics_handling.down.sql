CREATE OR REPLACE FUNCTION merge_launch(launchid BIGINT)
    RETURNS INTEGER
AS
$$
DECLARE
    targettestitemcursor CURSOR  (id BIGINT, lvl INT) FOR
        SELECT DISTINCT ON (unique_id) unique_id, item_id, path AS path_value
        FROM test_item parent
        WHERE parent.launch_id = id
          AND nlevel(parent.path) = lvl
          AND has_stats
          AND (parent.type = 'SUITE' OR (SELECT EXISTS(SELECT 1 FROM test_item t WHERE t.parent_id = parent.item_id LIMIT 1)));
    DECLARE
    mergingtestitemcursor CURSOR (uniqueid VARCHAR, lvl INT, launchid BIGINT) FOR
        SELECT item_id, path AS path_value, has_retries
        FROM test_item
        WHERE test_item.unique_id = uniqueid
          AND has_stats
          AND nlevel(test_item.path) = lvl
          AND test_item.launch_id = launchid;
    DECLARE
    targettestitemfield  RECORD;
    DECLARE
    mergingtestitemfield RECORD;
    DECLARE
    maxlevel             BIGINT;
    DECLARE
    firstitemid          VARCHAR;
    DECLARE
    parentitemid         BIGINT;
    DECLARE
    parentitempath       LTREE;
    DECLARE
    concatenated_descr   TEXT;
BEGIN
    maxlevel := (SELECT MAX(nlevel(path))
                 FROM test_item
                 WHERE launch_id = launchid
                   AND has_stats);
    IF (maxlevel ISNULL)
    THEN
        RETURN 0;
    END IF;

    FOR i IN 1..maxlevel
        LOOP

            OPEN targettestitemcursor(launchid, i);

            LOOP
                FETCH targettestitemcursor INTO targettestitemfield;

                EXIT WHEN NOT found;

                firstitemid := targettestitemfield.unique_id;
                parentitemid := targettestitemfield.item_id;
                parentitempath := targettestitemfield.path_value;

                EXIT WHEN firstitemid ISNULL;

                SELECT string_agg(description, chr(10))
                INTO concatenated_descr
                FROM test_item
                WHERE test_item.unique_id = firstitemid
                  AND has_stats
                  AND nlevel(test_item.path) = i
                  AND test_item.launch_id = launchid;

                UPDATE test_item SET description = concatenated_descr WHERE test_item.item_id = parentitemid;

                UPDATE test_item
                SET start_time = (SELECT min(start_time)
                                  FROM test_item
                                  WHERE test_item.unique_id = firstitemid
                                    AND has_stats
                                    AND nlevel(test_item.path) = i
                                    AND test_item.launch_id = launchid)
                WHERE test_item.item_id = parentitemid;

                UPDATE test_item_results
                SET end_time = (SELECT max(end_time)
                                FROM test_item
                                         JOIN test_item_results result ON test_item.item_id = result.result_id
                                WHERE test_item.unique_id = firstitemid
                                  AND has_stats
                                  AND nlevel(test_item.path) = i
                                  AND test_item.launch_id = launchid)
                WHERE test_item_results.result_id = parentitemid;

                INSERT INTO statistics (statistics_field_id, item_id, launch_id, s_counter)
                SELECT statistics_field_id, parentitemid, NULL, sum(s_counter)
                FROM statistics
                         JOIN test_item ti ON statistics.item_id = ti.item_id
                WHERE ti.unique_id = firstitemid
                  AND ti.launch_id = launchid
                  AND nlevel(ti.path) = i
                  AND ti.has_stats
                GROUP BY statistics_field_id
                ON CONFLICT ON CONSTRAINT unique_stats_item DO UPDATE
                    SET s_counter = excluded.s_counter;

                IF exists(SELECT 1
                          FROM test_item_results
                                   JOIN test_item t ON test_item_results.result_id = t.item_id
                          WHERE (test_item_results.status != 'PASSED' AND test_item_results.status != 'SKIPPED' AND test_item_results.status != 'UNTESTED')
                            AND t.unique_id = firstitemid
                            AND nlevel(t.path) = i
                            AND t.has_stats
                            AND t.launch_id = launchid
                          LIMIT 1)
                THEN
                    UPDATE test_item_results SET status = 'FAILED' WHERE test_item_results.result_id = parentitemid;
                ELSEIF exists(SELECT 1
                              FROM test_item_results
                                       JOIN test_item t ON test_item_results.result_id = t.item_id
                              WHERE (test_item_results.status != 'PASSED' AND test_item_results.status != 'UNTESTED')
                                AND t.unique_id = firstitemid
                                AND nlevel(t.path) = i
                                AND t.has_stats
                                AND t.launch_id = launchid
                              LIMIT 1)
                THEN
                    UPDATE test_item_results SET status = 'SKIPPED' WHERE test_item_results.result_id = parentitemid;
                ELSEIF exists(SELECT 1
                              FROM test_item_results
                                       JOIN test_item t ON test_item_results.result_id = t.item_id
                              WHERE test_item_results.status != 'UNTESTED'
                                AND t.unique_id = firstitemid
                                AND nlevel(t.path) = i
                                AND t.has_stats
                                AND t.launch_id = launchid
                              LIMIT 1)
                THEN
                    UPDATE test_item_results SET status = 'PASSED' WHERE test_item_results.result_id = parentitemid;
                ELSE
                    UPDATE test_item_results SET status = 'UNTESTED' WHERE test_item_results.result_id = parentitemid;
                END IF;

                OPEN mergingtestitemcursor(targettestitemfield.unique_id, i, launchid);

                LOOP

                    FETCH mergingtestitemcursor INTO mergingtestitemfield;

                    EXIT WHEN NOT found;

                    IF (SELECT EXISTS(SELECT 1
                                      FROM test_item t
                                      WHERE (t.parent_id = mergingtestitemfield.item_id
                                          OR (t.item_id = mergingtestitemfield.item_id AND t.type = 'SUITE'))
                                        AND t.has_stats
                                      LIMIT 1))
                    THEN
                        UPDATE test_item
                        SET parent_id = parentitemid,
                            path      = text2ltree(concat(parentitempath :: TEXT, '.', test_item.item_id :: TEXT))
                        WHERE test_item.parent_id = mergingtestitemfield.item_id
                          AND nlevel(test_item.path) = i + 1
                          AND has_stats
                          AND test_item.retry_of IS NULL;
                        DELETE
                        FROM test_item
                        WHERE test_item.path = mergingtestitemfield.path_value
                          AND test_item.has_stats
                          AND test_item.item_id != parentitemid;

                    END IF;

                    IF mergingtestitemfield.has_retries
                    THEN
                        UPDATE test_item
                        SET path = text2ltree(concat(mergingtestitemfield.path_value :: TEXT, '.', test_item.item_id :: TEXT))
                        WHERE test_item.retry_of = mergingtestitemfield.item_id;
                    END IF;

                END LOOP;

                CLOSE mergingtestitemcursor;

            END LOOP;

            CLOSE targettestitemcursor;

        END LOOP;


    INSERT INTO statistics (statistics_field_id, launch_id, s_counter)
    SELECT statistics_field_id, launchid, sum(s_counter)
    FROM statistics
             JOIN test_item ti ON statistics.item_id = ti.item_id
    WHERE ti.launch_id = launchid
      AND ti.has_stats
      AND ti.parent_id IS NULL
    GROUP BY statistics_field_id
    ON CONFLICT ON CONSTRAINT unique_stats_launch DO UPDATE
        SET s_counter = excluded.s_counter;

    RETURN 0;
END;
$$
    LANGUAGE plpgsql;