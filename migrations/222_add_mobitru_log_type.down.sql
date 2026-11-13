DELETE FROM log_type
WHERE LOWER(name) = 'mobitru'
  AND level = 90000
  AND is_system = true;
