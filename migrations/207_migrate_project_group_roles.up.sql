UPDATE groups_projects
SET project_role = CASE 
    WHEN project_role IN ('PROJECT_MANAGER', 'MEMBER', 'CUSTOMER') THEN 'EDITOR'
    ELSE 'VIEWER'
END;