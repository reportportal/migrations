CREATE TABLE launch_number (
    id          BIGSERIAL
        CONSTRAINT launch_number_pk PRIMARY KEY,
    project_id  BIGINT REFERENCES project (id) ON DELETE CASCADE NOT NULL,
    launch_name VARCHAR(256)                                     NOT NULL,
    number      INTEGER                                          NOT NULL,
    CONSTRAINT unq_project_name UNIQUE (project_id, launch_name)
);

INSERT INTO launch_number(project_id, launch_name, number)
SELECT project_id, name, max(number)
FROM launch
GROUP BY name, project_id;

ALTER TABLE launch
    DROP CONSTRAINT unq_name_number;

ALTER TABLE launch
    ADD CONSTRAINT unq_name_number UNIQUE (name, number, project_id);

CREATE OR REPLACE FUNCTION get_last_launch_number()
    RETURNS TRIGGER AS
$BODY$
BEGIN
    INSERT INTO launch_number (project_id, launch_name, number)
    VALUES (new.project_id, new.name, 1)
    ON CONFLICT (project_id, launch_name) DO UPDATE SET number = launch_number.number + 1;
    new.number = (SELECT number FROM launch_number WHERE project_id = new.project_id AND launch_name = new.name);
    RETURN new;
END;
$BODY$
    LANGUAGE plpgsql;