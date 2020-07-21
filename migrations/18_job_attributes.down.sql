CREATE OR REPLACE FUNCTION revert_attributes(attribute_name text, default_value text, predefined_values text[]) RETURNS VOID AS
$$
DECLARE
    interval_value interval;
    prj_attr       RECORD;
    counter        BIGINT;
    new_attr_value TEXT;
    result_value   TEXT;
    attr_id        BIGINT;
BEGIN

    SELECT id FROM attribute WHERE name = attribute_name INTO attr_id;

    FOR prj_attr IN SELECT project_attribute.attribute_id, project_attribute.project_id, project_attribute.value
                    FROM project_attribute
                    WHERE attribute_id = attr_id
                      AND value != '0'
        LOOP
            interval_value := justify_interval(prj_attr.value::BIGINT * interval '1 sec');
            SELECT extract(months FROM interval_value) INTO counter;
            IF
                counter > 0
            THEN
                IF counter = 1
                THEN
                    new_attr_value := concat(counter, ' month');
                ELSE
                    new_attr_value := concat(counter, ' months');
                END IF;
            ELSE
                SELECT extract(days FROM interval_value) INTO counter;
                IF counter > 0 THEN
                    IF counter = 1
                    THEN
                        new_attr_value := concat(counter, ' day');
                    ELSEIF counter < 7
                    THEN
                        new_attr_value := concat(counter, ' days');
                    ELSEIF counter / 7 = 1
                    THEN
                        new_attr_value := concat(1, ' week');
                    ELSE
                        new_attr_value := concat(counter / 7, ' weeks');
                    END IF;
                ELSE
                    SELECT extract(hours FROM interval_value) INTO counter;
                    IF counter > 0 THEN
                        IF counter = 1 THEN
                            new_attr_value := concat(counter, ' hour');
                        ELSE
                            new_attr_value := concat(counter, ' hours');
                        end if;
                    END IF;
                END IF;
            END IF;

            IF
                new_attr_value IS NOT NULL AND new_attr_value = ANY (predefined_values)
            THEN
                result_value = new_attr_value;
            ELSE
                result_value = default_value;
            END IF;

            UPDATE project_attribute
            SET value = result_value
            WHERE project_id = prj_attr.project_id
              AND attribute_id = prj_attr.attribute_id;

        END LOOP;

    UPDATE project_attribute SET value = 'forever' WHERE value = '0' AND attribute_id = attr_id;
END;
$$ LANGUAGE plpgsql;

SELECT revert_attributes('job.interruptJobTime', '1 day', ARRAY ['1 hour', '3 hours', '6 hours', '12 hours', '1 day', '1 week']);
SELECT revert_attributes('job.keepLaunches', '3 months', ARRAY ['2 weeks', '1 month', '3 months', '6 months']);
SELECT revert_attributes('job.keepLogs', '3 months', ARRAY ['2 weeks', '1 month', '3 months', '6 months']);
SELECT revert_attributes('job.keepScreenshots', '2 weeks', ARRAY ['1 week', '2 weeks', '3 weeks', '1 month', '3 months']);
DROP FUNCTION IF EXISTS revert_attributes(attribute_name text, default_value text, predefined_values text[]);
