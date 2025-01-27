CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
);

CREATE TABLE group_users (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_group_users_user_id ON group_users(user_id);
CREATE INDEX idx_group_users_group_id ON group_users(group_id);

CREATE TABLE group_projects (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT NOT NULL,
    project_id BIGINT NOT NULL,
    project_role VARCHAR(255) NOT NULL,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE INDEX idx_group_projects_group_id ON group_projects(group_id);
CREATE INDEX idx_group_projects_project_id ON group_projects(project_id);

-- SELECT 
--     gu.group_id,
--     gp.project_role
-- FROM 
--     group_users gu
-- JOIN 
--     group_projects gp ON gu.group_id = gp.group_id
-- WHERE 
--     gu.user_id = <user_id> AND gp.project_id = <project_id>;