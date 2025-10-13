CREATE TABLE IF NOT EXISTS organization_settings
(
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT       NOT NULL,
    setting_key     VARCHAR(255) NOT NULL,
    setting_value   text         NOT NULL,
    UNIQUE (organization_id, setting_key)
);


INSERT INTO organization_settings (organization_id, setting_key, setting_value)
SELECT p.organization_id, 'retention_launches', MAX(CAST(value AS BIGINT))
FROM project p
         JOIN project_attribute pa
              ON p.id = pa.project_id
WHERE pa.attribute_id = 2
GROUP BY p.organization_id
ON CONFLICT DO NOTHING;

INSERT INTO organization_settings (organization_id, setting_key, setting_value)
SELECT p.organization_id, 'retention_logs', MAX(CAST(value AS BIGINT))
FROM project p
         JOIN project_attribute pa
              ON p.id = pa.project_id
WHERE pa.attribute_id = 3
GROUP BY p.organization_id
ON CONFLICT DO NOTHING;


INSERT INTO organization_settings (organization_id, setting_key, setting_value)
SELECT p.organization_id, 'retention_attachments', MAX(CAST(value AS BIGINT))
FROM project p
         JOIN project_attribute pa
              ON p.id = pa.project_id
WHERE pa.attribute_id = 4
GROUP BY p.organization_id
ON CONFLICT DO NOTHING




