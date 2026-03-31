DELETE
FROM integration_type
WHERE name IN ('ad', 'ldap', 'saml')
  AND group_type = 'AUTH'
  AND plugin_type = 'BUILT_IN';

DROP TABLE IF EXISTS oauth_registration_scope;
DROP TABLE IF EXISTS oauth_registration_restriction;
DROP TABLE IF EXISTS oauth_registration;
