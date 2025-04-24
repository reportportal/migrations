UPDATE users
SET email = 
    CASE login
        WHEN 'superadmin' THEN 'superadmin@example.com'
        WHEN 'default' THEN 'default@example.com'
    END
WHERE login IN ('superadmin', 'default');