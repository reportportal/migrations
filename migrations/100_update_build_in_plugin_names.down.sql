UPDATE integration_type
SET details = jsonb_set(details, '{details}', (details->'details') - 'id' - 'name')
WHERE name = 'email';

UPDATE integration_type
SET details = '{}'::jsonb
WHERE name IN ('ldap', 'ad', 'saml');