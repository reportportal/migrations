UPDATE users
SET email = 
    CASE login
        WHEN 'superadmin' THEN 'superadminemail@domain.com'
        WHEN 'default' THEN 'defaultemail@domain.com'
    END
WHERE login IN ('superadmin', 'default');