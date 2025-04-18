UPDATE users SET login = login_backup;
ALTER TABLE users DROP COLUMN IF EXISTS login_backup;
