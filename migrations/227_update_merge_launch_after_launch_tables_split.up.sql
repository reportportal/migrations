-- Set-based rewrite of merge_launch. Previous implementation iterated over every merged item with
-- cursors and executed several queries per item filtered by an expression on test_case_id/test_case_hash,
-- so each of them scanned the whole launch. Now every tree level is processed with a fixed number of
-- statements over a temporary, analyzed mapping of merged items to their target items.
-- The merged launch is new, so planner has no statistics for its launch_id: launch items are read only once
-- per level, all other statements are driven by the temporary table through item_id/parent_id/retry_of indexes.

CREATE OR REPLACE FUNCTION merge_launch(launchid BIGINT)
    RETURNS INTEGER
    LANGUAGE plpgsql
    -- row estimates of recursive queries are inaccurate, JIT compilation costs more than execution
    SET jit = off
AS
$$
DECLARE
    max_level INTEGER;
BEGIN
    max_level := (SELECT MAX(nlevel(path))
                  FROM test_item
                  WHERE launch_id = launchid
                    AND has_stats);
    IF max_level IS NULL
    THEN
        RETURN 0;
    END IF;

    -- Items of the current level grouped by test case with the item all of them are merged into
    CREATE TEMP TABLE IF NOT EXISTS merge_launch_item
    (
        item_id             BIGINT PRIMARY KEY,
        merge_key           VARCHAR,
        path                LTREE,
        is_suite            BOOLEAN,
        has_retries         BOOLEAN,
        has_children        BOOLEAN,
        has_any_child       BOOLEAN,
        is_container        BOOLEAN,
        target_id           BIGINT,
        target_path         LTREE,
        target_has_children BOOLEAN
    ) ON COMMIT DROP;

    -- Nested steps and retries of not merged items with the item they belong to
    CREATE TEMP TABLE IF NOT EXISTS merge_launch_nested
    (
        item_id    BIGINT PRIMARY KEY,
        owner_id   BIGINT,
        owner_path LTREE
    ) ON COMMIT DROP;

    FOR lvl IN 1..max_level
        LOOP
            TRUNCATE merge_launch_item;

            INSERT INTO merge_launch_item (item_id, merge_key, path, is_suite, has_retries, has_children)
            SELECT ti.item_id,
                   COALESCE(ti.test_case_id, CAST(ti.test_case_hash AS VARCHAR)),
                   ti.path,
                   ti.type = 'SUITE',
                   ti.has_retries,
                   ti.has_children
            FROM test_item ti
            WHERE ti.launch_id = launchid
              AND ti.has_stats
              AND nlevel(ti.path) = lvl;

            ANALYZE merge_launch_item;

            UPDATE merge_launch_item mi
            SET has_any_child = EXISTS(SELECT 1 FROM test_item c WHERE c.parent_id = mi.item_id),
                is_container  = mi.is_suite OR EXISTS(SELECT 1
                                                      FROM test_item c
                                                      WHERE c.parent_id = mi.item_id
                                                        AND c.has_stats);

            UPDATE merge_launch_item mi
            SET target_id           = t.item_id,
                target_path         = t.path,
                target_has_children = t.has_children
            FROM (SELECT DISTINCT ON (merge_key) merge_key, item_id, path, has_children
                  FROM merge_launch_item
                  WHERE merge_key IS NOT NULL
                    AND (is_suite OR has_any_child)
                  ORDER BY merge_key, item_id) t
            WHERE mi.merge_key = t.merge_key;

            DELETE FROM merge_launch_item WHERE target_id IS NULL;

            ANALYZE merge_launch_item;

            -- Aggregate description, start time, end time, status and statistics of merged containers into target
            UPDATE test_item ti
            SET description = agg.description,
                start_time  = agg.start_time
            FROM (SELECT mi.target_id,
                         string_agg(i.description, chr(10) ORDER BY i.item_id) AS description,
                         min(i.start_time)                                     AS start_time
                  FROM merge_launch_item mi
                           JOIN test_item i ON i.item_id = mi.item_id
                  WHERE mi.target_has_children
                    AND mi.has_children
                  GROUP BY mi.target_id) agg
            WHERE ti.item_id = agg.target_id;

            UPDATE test_item_results tir
            SET end_time = agg.end_time,
                status   = agg.status
            FROM (SELECT mi.target_id,
                         max(r.end_time)                                                 AS end_time,
                         CAST(CASE
                                  WHEN bool_or(r.status != 'PASSED' AND r.status != 'SKIPPED') THEN 'FAILED'
                                  WHEN bool_or(r.status != 'PASSED') THEN 'SKIPPED'
                                  ELSE 'PASSED' END AS STATUS_ENUM)                      AS status
                  FROM merge_launch_item mi
                           JOIN test_item_results r ON r.result_id = mi.item_id
                  WHERE mi.target_has_children
                    AND mi.has_children
                  GROUP BY mi.target_id) agg
            WHERE tir.result_id = agg.target_id;

            INSERT INTO statistics (statistics_field_id, item_id, s_counter)
            SELECT s.statistics_field_id, mi.target_id, sum(s.s_counter)
            FROM merge_launch_item mi
                     JOIN statistics s ON s.item_id = mi.item_id
            WHERE mi.target_has_children
              AND mi.has_children
            GROUP BY s.statistics_field_id, mi.target_id
            ON CONFLICT ON CONSTRAINT unique_stats_item DO UPDATE
                SET s_counter = excluded.s_counter;

            -- Move children of merged containers to target
            UPDATE test_item c
            SET parent_id = mi.target_id,
                path      = text2ltree(concat(mi.target_path :: TEXT, '.', c.item_id :: TEXT))
            FROM merge_launch_item mi
            WHERE mi.is_container
              AND c.parent_id = mi.item_id
              AND nlevel(c.path) = lvl + 1
              AND c.has_stats
              AND c.retry_of IS NULL;

            UPDATE test_item c
            SET parent_id = mi.target_id,
                path      = text2ltree(concat(mi.target_path :: TEXT, '.', c.retry_of :: TEXT, '.', c.item_id :: TEXT))
            FROM merge_launch_item mi
            WHERE mi.is_container
              AND c.parent_id = mi.item_id
              AND c.retry_of IS NOT NULL;

            UPDATE attachment a
            SET item_id = mi.target_id
            FROM merge_launch_item mi
            WHERE mi.is_container
              AND mi.item_id != mi.target_id
              AND a.item_id = mi.item_id;

            UPDATE log l
            SET item_id = mi.target_id
            FROM merge_launch_item mi
            WHERE mi.is_container
              AND mi.item_id != mi.target_id
              AND l.item_id = mi.item_id;

            DELETE
            FROM test_item ti
                USING merge_launch_item mi
            WHERE mi.is_container
              AND mi.item_id != mi.target_id
              AND ti.item_id = mi.item_id
              AND ti.has_stats;

            -- Fix paths of retries and nested steps of not merged items which parents were moved
            UPDATE test_item r
            SET path = text2ltree(concat(mi.path :: TEXT, '.', r.item_id :: TEXT))
            FROM merge_launch_item mi
            WHERE NOT mi.is_container
              AND mi.has_retries
              AND r.retry_of = mi.item_id;

            TRUNCATE merge_launch_nested;

            INSERT INTO merge_launch_nested (item_id, owner_id, owner_path)
            WITH RECURSIVE nested_owner AS (SELECT mi.item_id, mi.path
                                            FROM merge_launch_item mi
                                            WHERE NOT mi.is_container
                                              AND EXISTS(SELECT 1
                                                         FROM test_item n
                                                         WHERE n.parent_id = mi.item_id
                                                           AND NOT n.has_stats)),
                           nested AS (SELECT n.item_id, o.item_id AS owner_id, o.path AS owner_path
                                      FROM nested_owner o
                                               JOIN test_item n ON n.parent_id = o.item_id
                                      WHERE NOT n.has_stats
                                      UNION ALL
                                      SELECT r.item_id, o.item_id, o.path
                                      FROM nested_owner o
                                               JOIN test_item r ON r.retry_of = o.item_id
                                      WHERE NOT r.has_stats
                                      UNION ALL
                                      SELECT c.item_id, n.owner_id, n.owner_path
                                      FROM nested n
                                               JOIN test_item c ON c.parent_id = n.item_id
                                      WHERE NOT c.has_stats)
            SELECT DISTINCT ON (item_id) item_id, owner_id, owner_path
            FROM nested
            ORDER BY item_id;

            ANALYZE merge_launch_nested;

            UPDATE test_item d
            SET path = text2ltree(concat(n.owner_path :: TEXT, '.', subpath(d.path, lvl) :: TEXT))
            FROM merge_launch_nested n
            WHERE d.item_id = n.item_id
              AND nlevel(d.path) > lvl
              AND ltree2text(subpath(d.path, lvl - 1, 1)) = n.owner_id :: TEXT;

        END LOOP;

    INSERT INTO launch_statistics (statistics_field_id, launch_id, s_counter)
    SELECT s.statistics_field_id, launchid, sum(s.s_counter)
    FROM statistics s
             JOIN test_item ti ON s.item_id = ti.item_id
    WHERE ti.launch_id = launchid
      AND ti.has_stats
      AND ti.parent_id IS NULL
    GROUP BY s.statistics_field_id
    ON CONFLICT ON CONSTRAINT unique_launch_stats DO UPDATE
        SET s_counter = excluded.s_counter;

    RETURN 0;
END;
$$;
