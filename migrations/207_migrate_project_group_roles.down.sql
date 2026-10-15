UPDATE groups_projects
SET project_role = CASE 
    WHEN project_role = 'EDITOR' THEN 'MEMBER'
    ELSE 'OPERATOR'
END;