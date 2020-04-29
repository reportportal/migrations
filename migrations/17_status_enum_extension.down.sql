UPDATE test_item_results
SET status = 'PASSED'
WHERE status = ANY (array ['INFO', 'WARN']::status_enum[]);

DELETE
FROM pg_enum
WHERE (enumlabel = 'INFO' OR enumlabel = 'WARN')
  AND enumtypid = (
    SELECT oid
    FROM pg_type
    WHERE typname = 'status_enum'
);