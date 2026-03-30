DELETE
FROM integration_type
WHERE name IN ('ad', 'ldap', 'saml')
  AND group_type = 'AUTH'
  AND plugin_type = 'BUILT_IN';
