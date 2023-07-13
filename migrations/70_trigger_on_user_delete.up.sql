CREATE OR REPLACE FUNCTION change_user_name_on_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE owned_entity
    SET owner = 'deleted_user'
    WHERE owner = OLD.login;

    UPDATE integration
    SET creator = 'deleted_user'
    WHERE creator = OLD.login;

    UPDATE activity
    SET subject_name = 'deleted_user'
    WHERE subject_name = OLD.login;

    UPDATE activity
    SET object_name = 'deleted_user'
    WHERE object_name = OLD.full_name;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_owner_name_on_user_delete
AFTER DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION change_user_name_on_delete();