DROP TRIGGER IF EXISTS last_launch_number_trigger
    ON launch;

DROP FUNCTION IF EXISTS get_last_launch_number();