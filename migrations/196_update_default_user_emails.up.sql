UPDATE users
SET email = 
    CASE login
        WHEN 'superadmin' THEN 'admin@reportportal.internal'
        WHEN 'default' THEN 'default@reportportal.internal'
    END
WHERE login IN ('superadmin', 'default');