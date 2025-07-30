UPDATE users
SET email = 
    CASE login
        WHEN 'superadmin' THEN 'admin@reportportal.internal'
        WHEN 'default' THEN 'default@reportportal.internal'
    END
WHERE login IN ('superadmin', 'default');

ALTER TABLE users ADD COLUMN IF NOT EXISTS login_backup VARCHAR(255) DEFAULT NULL;
UPDATE users SET login_backup = login;
UPDATE users SET login = email;
