UPDATE users
SET login = login_backup;
ALTER TABLE users
    DROP COLUMN IF EXISTS login_backup;

UPDATE users
SET email =
        CASE login
            WHEN 'superadmin' THEN 'superadminemail@domain.com'
            WHEN 'default' THEN 'defaultemail@domain.com'
            END
WHERE login IN ('superadmin', 'default');
