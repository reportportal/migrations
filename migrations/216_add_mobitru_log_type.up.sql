-- Insert 'mobitru' system log type for every existing project.
-- Idempotent: skip projects that already have a row with the same name or level
-- to avoid violating log_type_project_id_level_unique (project_id, level).
INSERT INTO log_type (project_id, name, level, label_color, background_color, text_color, text_style, is_filterable, is_system)
SELECT p.id, 'mobitru', 90000, '#23A6DE', '#FFFFFF', '#464547', 'normal', false, true
FROM project p
WHERE NOT EXISTS (
    SELECT 1 FROM log_type lt
    WHERE lt.project_id = p.id
      AND (LOWER(lt.name) = 'mobitru' OR lt.level = 90000)
);
