DELETE
FROM integration_type
WHERE name = in ('ad', 'ldap', 'saml')
  AND group_type = 'AUTH'
  AND plugin_type = 'BUILT_IN';
