DELETE
FROM integration_type
WHERE name = 'ad'
  AND group_type = cast('AUTH' AS INTEGRATION_GROUP_ENUM);
