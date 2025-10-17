INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'ad', now(), 'AUTH', 'BUILT_IN', '{
  "details": {
    "id": "ad",
    "name": "Active Directory"
  }
}');
