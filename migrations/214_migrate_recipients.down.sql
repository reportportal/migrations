UPDATE recipients r
SET recipient = COALESCE(u.login_backup, r.recipient)
FROM users u
WHERE r.recipient = u.email;