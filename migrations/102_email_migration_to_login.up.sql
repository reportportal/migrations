ALTER TABLE users ADD COLUMN IF NOT EXISTS login_backup VARCHAR(255) DEFAULT NULL;
UPDATE users SET login_backup = login;
UPDATE users SET login = email;
