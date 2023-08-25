DROP TRIGGER IF EXISTS update_owner_name_on_user_delete ON users;

DROP FUNCTION IF EXISTS change_user_name_on_delete();