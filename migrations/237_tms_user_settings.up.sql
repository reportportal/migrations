-- ============================================================================
-- TMS LIST SETTINGS PER USER AND PER PROJECT
-- ============================================================================
-- One row per user and project. "settings" is a flat JSON object of list settings
-- (items per page, sort mode, tree view mode, ...), written by the UI.

CREATE TABLE IF NOT EXISTS tms_user_settings
(
    user_id    bigint    NOT NULL
        CONSTRAINT tms_user_settings_fk_user
            REFERENCES users ON DELETE CASCADE,
    project_id bigint    NOT NULL
        CONSTRAINT tms_user_settings_fk_project
            REFERENCES project ON DELETE CASCADE,
    settings   jsonb     NOT NULL DEFAULT '{}'::jsonb,
    updated_at timestamp NOT NULL DEFAULT now(),
    CONSTRAINT tms_user_settings_pk PRIMARY KEY (user_id, project_id)
);

CREATE INDEX IF NOT EXISTS idx_tms_user_settings_project_id ON tms_user_settings (project_id);
