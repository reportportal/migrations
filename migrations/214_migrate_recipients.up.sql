UPDATE recipients r
SET recipient = u.email
FROM users u
WHERE r.recipient = u.login_backup;