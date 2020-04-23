UPDATE test_item_results
SET status = 'PASSED'
WHERE status = ANY (array ['INFORMATION', 'WARNING']::status_enum[]);

DELETE
FROM pg_enum
WHERE (enumlabel = 'INFORMATION' OR enumlabel = 'WARNING')
  AND enumtypid = (
    SELECT oid
    FROM pg_type
    WHERE typname = 'status_enum'
);