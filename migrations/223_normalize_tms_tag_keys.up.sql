-- Normalize TMS tag keys to the lowercase representation exposed by the tags API.
-- TMS tags are attributes with a NULL value. Merge case-only duplicates before
-- normalizing keys to preserve all existing test case, scenario, and test plan associations.

CREATE TEMP TABLE tms_tag_duplicate_mapping ON COMMIT DROP AS
SELECT duplicate_attribute.id AS duplicate_attribute_id,
       canonical_attribute.canonical_attribute_id
FROM tms_attribute AS duplicate_attribute
JOIN (
    SELECT project_id,
           lower(key) AS normalized_key,
           MIN(id) AS canonical_attribute_id
    FROM tms_attribute
    WHERE value IS NULL
    GROUP BY project_id, lower(key)
) AS canonical_attribute
    ON canonical_attribute.project_id = duplicate_attribute.project_id
    AND canonical_attribute.normalized_key = lower(duplicate_attribute.key)
WHERE duplicate_attribute.value IS NULL
  AND duplicate_attribute.id <> canonical_attribute.canonical_attribute_id;

INSERT INTO tms_test_case_attribute (attribute_id, test_case_id)
SELECT mapping.canonical_attribute_id, relation.test_case_id
FROM tms_test_case_attribute AS relation
JOIN tms_tag_duplicate_mapping AS mapping
    ON mapping.duplicate_attribute_id = relation.attribute_id
ON CONFLICT DO NOTHING;

INSERT INTO tms_manual_scenario_attribute (attribute_id, manual_scenario_id)
SELECT mapping.canonical_attribute_id, relation.manual_scenario_id
FROM tms_manual_scenario_attribute AS relation
JOIN tms_tag_duplicate_mapping AS mapping
    ON mapping.duplicate_attribute_id = relation.attribute_id
ON CONFLICT DO NOTHING;

INSERT INTO tms_test_plan_attribute (attribute_id, test_plan_id)
SELECT mapping.canonical_attribute_id, relation.test_plan_id
FROM tms_test_plan_attribute AS relation
JOIN tms_tag_duplicate_mapping AS mapping
    ON mapping.duplicate_attribute_id = relation.attribute_id
ON CONFLICT DO NOTHING;

DELETE FROM tms_test_case_attribute AS relation
USING tms_tag_duplicate_mapping AS mapping
WHERE relation.attribute_id = mapping.duplicate_attribute_id;

DELETE FROM tms_manual_scenario_attribute AS relation
USING tms_tag_duplicate_mapping AS mapping
WHERE relation.attribute_id = mapping.duplicate_attribute_id;

DELETE FROM tms_test_plan_attribute AS relation
USING tms_tag_duplicate_mapping AS mapping
WHERE relation.attribute_id = mapping.duplicate_attribute_id;

DELETE FROM tms_attribute AS attribute
USING tms_tag_duplicate_mapping AS mapping
WHERE attribute.id = mapping.duplicate_attribute_id;

UPDATE tms_attribute
SET key = lower(key)
WHERE value IS NULL
  AND key <> lower(key);
