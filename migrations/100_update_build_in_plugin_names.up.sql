UPDATE integration_type
SET details = jsonb_set(
    COALESCE(details, '{}'),
    '{details}',
    COALESCE(details->'details', '{}')::jsonb ||
    jsonb_build_object(
        'name',
        CASE name
            WHEN 'email' THEN 'Email Server'
            WHEN 'ldap' THEN 'LDAP'
            WHEN 'ad' THEN 'Active Directory'
            WHEN 'saml' THEN 'SAML'
            END,
        'id', name
    )
)
WHERE name IN ('email', 'ldap', 'ad', 'saml');