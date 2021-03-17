CREATE OR REPLACE FUNCTION fill_log_project_id() RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
    prj_id BIGINT;
BEGIN

    FOR prj_id IN (SELECT id FROM project ORDER BY id)
        LOOP
            UPDATE log
            SET project_id = prj_id
            WHERE item_id IN (SELECT ti.item_id
                              FROM launch
                                       JOIN test_item ti ON launch.id = ti.launch_id
                              WHERE launch.project_id = prj_id);

            UPDATE log
            SET project_id = prj_id
            WHERE item_id IN (SELECT retry.item_id
                              FROM launch
                                       JOIN test_item ti ON launch.id = ti.launch_id
                                       JOIN test_item retry ON ti.item_id = retry.retry_of
                              WHERE launch.project_id = prj_id);

            UPDATE log
            SET project_id = prj_id
            WHERE launch_id IN (SELECT id
                                FROM launch
                                WHERE launch.project_id = prj_id);

        END LOOP;

    RETURN 0;
END;
$$;

SELECT fill_log_project_id();