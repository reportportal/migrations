CREATE OR REPLACE FUNCTION change_user_name_on_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE owned_entity
    SET owner = 'deleted_user'
    WHERE owner = OLD.login;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_owner_name_on_user_delete
AFTER DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION change_user_name_on_delete();