INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'ad', now(), 'AUTH', 'BUILT_IN', '{
  "details": {
    "id": "ad",
    "name": "Active Directory"
  }
}');

INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'ldap', now(), 'AUTH', 'BUILT_IN', '{
  "details": {
    "id": "ldap",
    "name": "LDAP"
  }
}');

INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'saml', now(), 'AUTH', 'BUILT_IN', '{
  "details": {
    "id": "saml",
    "name": "SAML"
  }
}');
