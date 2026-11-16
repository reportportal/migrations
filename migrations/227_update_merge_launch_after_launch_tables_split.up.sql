-- Plan-stable merge_launch (follow-up of 122/227), same behavior.
--
-- Previous version joined temporary tables with test_item/statistics/log/attachment and let planner pick the
-- join method. With production statistics (big tables, underestimated n_distinct of parent_id/retry_of)
-- planner preferred hash and merge joins that read whole tables or whole indexes:
--  * recursive CTE collecting nested steps: worktable size can't be estimated (trillions of rows in estimate),
--    so recursion steps got hash joins over sequential scans of test_item spilling to disk, or merge joins
--    over full ti_retry_of_idx (PostgreSQL 18: ~400 s and ~22M blocks read for a 5 x 1000 tests DEEP merge);
--  * moving children of merged items: merge join over full ti_parent_idx.
--
-- Now access to a big table never depends on join method choice:
--  * reads are LATERAL subqueries referencing the row of a temporary table and fenced with OFFSET 0, so they
--    can't be pulled up into a plain join: the only possible plan is a nested loop with parameterized index scans;
--  * UPDATE/DELETE targets are additionally restricted with "indexed column = ANY(ARRAY(SELECT ... FROM temporary
--    table))", so the target table is read by an index scan on the given keys and is joined only to a small set;
--  * nested steps are collected level by level into a temporary table instead of a recursive CTE.

CREATE OR REPLACE FUNCTION merge_launch(launchid BIGINT)
    RETURNS INTEGER
    LANGUAGE plpgsql
    -- JIT compilation costs more than execution
    SET jit = off
AS
$$
DECLARE
    max_level    INTEGER;
    nested_level INTEGER;
    inserted     BIGINT;
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
    -- (renamed from merge_launch_nested: it has a different structure)
    CREATE TEMP TABLE IF NOT EXISTS merge_launch_nested_step
    (
        item_id    BIGINT PRIMARY KEY,
        owner_id   BIGINT,
        owner_path LTREE,
        step_level INTEGER
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

            -- sublinks in SET are executed per row as parameterized index scans
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
                         string_agg(i.description, chr(10) ORDER BY mi.item_id) AS description,
                         min(i.start_time)                                      AS start_time
                  FROM merge_launch_item mi
                           CROSS JOIN LATERAL (SELECT i.description, i.start_time
                                               FROM test_item i
                                               WHERE i.item_id = mi.item_id
                                               OFFSET 0) i
                  WHERE mi.target_has_children
                    AND mi.has_children
                  GROUP BY mi.target_id) agg
            WHERE ti.item_id = agg.target_id
              AND ti.item_id = ANY (ARRAY(SELECT mi.target_id
                                          FROM merge_launch_item mi
                                          WHERE mi.target_has_children
                                            AND mi.has_children));

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
                           CROSS JOIN LATERAL (SELECT r.end_time, r.status
                                               FROM test_item_results r
                                               WHERE r.result_id = mi.item_id
                                               OFFSET 0) r
                  WHERE mi.target_has_children
                    AND mi.has_children
                  GROUP BY mi.target_id) agg
            WHERE tir.result_id = agg.target_id
              AND tir.result_id = ANY (ARRAY(SELECT mi.target_id
                                             FROM merge_launch_item mi
                                             WHERE mi.target_has_children
                                               AND mi.has_children));

            INSERT INTO statistics (statistics_field_id, item_id, s_counter)
            SELECT s.statistics_field_id, mi.target_id, sum(s.s_counter)
            FROM merge_launch_item mi
                     CROSS JOIN LATERAL (SELECT s.statistics_field_id, s.s_counter
                                         FROM statistics s
                                         WHERE s.item_id = mi.item_id
                                         OFFSET 0) s
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
              AND c.parent_id = ANY (ARRAY(SELECT m.item_id FROM merge_launch_item m WHERE m.is_container))
              AND nlevel(c.path) = lvl + 1
              AND c.has_stats
              AND c.retry_of IS NULL;

            UPDATE test_item c
            SET parent_id = mi.target_id,
                path      = text2ltree(concat(mi.target_path :: TEXT, '.', c.retry_of :: TEXT, '.', c.item_id :: TEXT))
            FROM merge_launch_item mi
            WHERE mi.is_container
              AND c.parent_id = mi.item_id
              AND c.parent_id = ANY (ARRAY(SELECT m.item_id FROM merge_launch_item m WHERE m.is_container))
              AND c.retry_of IS NOT NULL;

            UPDATE attachment a
            SET item_id = mi.target_id
            FROM merge_launch_item mi
            WHERE mi.is_container
              AND mi.item_id != mi.target_id
              AND a.item_id = mi.item_id
              AND a.item_id = ANY (ARRAY(SELECT m.item_id
                                         FROM merge_launch_item m
                                         WHERE m.is_container
                                           AND m.item_id != m.target_id));

            UPDATE log l
            SET item_id = mi.target_id
            FROM merge_launch_item mi
            WHERE mi.is_container
              AND mi.item_id != mi.target_id
              AND l.item_id = mi.item_id
              AND l.item_id = ANY (ARRAY(SELECT m.item_id
                                         FROM merge_launch_item m
                                         WHERE m.is_container
                                           AND m.item_id != m.target_id));

            DELETE
            FROM test_item ti
            WHERE ti.item_id = ANY (ARRAY(SELECT m.item_id
                                          FROM merge_launch_item m
                                          WHERE m.is_container
                                            AND m.item_id != m.target_id))
              AND ti.has_stats;

            -- Fix paths of retries and nested steps of not merged items which parents were moved
            UPDATE test_item r
            SET path = text2ltree(concat(mi.path :: TEXT, '.', r.item_id :: TEXT))
            FROM merge_launch_item mi
            WHERE NOT mi.is_container
              AND mi.has_retries
              AND r.retry_of = mi.item_id
              AND r.retry_of = ANY (ARRAY(SELECT m.item_id
                                          FROM merge_launch_item m
                                          WHERE NOT m.is_container
                                            AND m.has_retries));

            TRUNCATE merge_launch_nested_step;

            -- Nested steps of not merged items
            INSERT INTO merge_launch_nested_step (item_id, owner_id, owner_path, step_level)
            SELECT n.item_id, mi.item_id, mi.path, 0
            FROM merge_launch_item mi
                     CROSS JOIN LATERAL (SELECT c.item_id
                                         FROM test_item c
                                         WHERE c.parent_id = mi.item_id
                                           AND NOT c.has_stats
                                         OFFSET 0) n
            WHERE NOT mi.is_container
            ON CONFLICT (item_id) DO NOTHING;

            -- Retries of not merged items which have nested steps
            INSERT INTO merge_launch_nested_step (item_id, owner_id, owner_path, step_level)
            SELECT r.item_id, mi.item_id, mi.path, 0
            FROM merge_launch_item mi
                     CROSS JOIN LATERAL (SELECT c.item_id
                                         FROM test_item c
                                         WHERE c.retry_of = mi.item_id
                                           AND NOT c.has_stats
                                         OFFSET 0) r
            WHERE NOT mi.is_container
              AND EXISTS(SELECT 1 FROM merge_launch_nested_step o WHERE o.owner_id = mi.item_id)
            ON CONFLICT (item_id) DO NOTHING;

            -- Descendants of collected nested steps and retries, one nesting level per statement
            nested_level := 0;
            LOOP
                INSERT INTO merge_launch_nested_step (item_id, owner_id, owner_path, step_level)
                SELECT ch.item_id, n.owner_id, n.owner_path, nested_level + 1
                FROM merge_launch_nested_step n
                         CROSS JOIN LATERAL (SELECT c.item_id
                                             FROM test_item c
                                             WHERE c.parent_id = n.item_id
                                               AND NOT c.has_stats
                                             OFFSET 0) ch
                WHERE n.step_level = nested_level
                ON CONFLICT (item_id) DO NOTHING;

                GET DIAGNOSTICS inserted = ROW_COUNT;
                EXIT WHEN inserted = 0;
                nested_level := nested_level + 1;
            END LOOP;

            ANALYZE merge_launch_nested_step;

            UPDATE test_item d
            SET path = text2ltree(concat(n.owner_path :: TEXT, '.', subpath(d.path, lvl) :: TEXT))
            FROM merge_launch_nested_step n
            WHERE d.item_id = n.item_id
              AND d.item_id = ANY (ARRAY(SELECT s.item_id FROM merge_launch_nested_step s))
              AND nlevel(d.path) > lvl
              AND ltree2text(subpath(d.path, lvl - 1, 1)) = n.owner_id :: TEXT;

        END LOOP;

    INSERT INTO launch_statistics (statistics_field_id, launch_id, s_counter)
    SELECT s.statistics_field_id, launchid, sum(s.s_counter)
    FROM test_item ti
             CROSS JOIN LATERAL (SELECT s.statistics_field_id, s.s_counter
                                 FROM statistics s
                                 WHERE s.item_id = ti.item_id
                                 OFFSET 0) s
    WHERE ti.launch_id = launchid
      AND ti.has_stats
      AND ti.parent_id IS NULL
    GROUP BY s.statistics_field_id
    ON CONFLICT ON CONSTRAINT unique_launch_stats DO UPDATE
        SET s_counter = excluded.s_counter;

    RETURN 0;
END;
$$;
