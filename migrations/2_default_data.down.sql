DELETE FROM project
WHERE project.name = 'default_personal';

DELETE FROM project
WHERE project.name = 'superadmin_personal';

DELETE FROM users
WHERE login = 'default';

DELETE FROM users
WHERE login = 'superadmin';