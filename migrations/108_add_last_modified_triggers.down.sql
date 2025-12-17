-- Revert creation of the index
DROP INDEX IF EXISTS test_item_last_modified_idx;

-- Revert for TEST_ITEM_RESULTS trigger and function
DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_results ON test_item_results;
DROP FUNCTION IF EXISTS update_last_modified_from_results;

-- Revert for LAUNCH trigger and function
DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_launch ON launch;
DROP FUNCTION IF EXISTS update_last_modified_from_launch;

-- Revert for ISSUE/ISSUE_TICKET trigger and function
DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_issue ON issue;
DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_issue ON issue_ticket;
DROP FUNCTION IF EXISTS update_last_modified_from_issue;

-- Revert for pattern_template_test_item trigger and function
DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_pattern_template_test_item ON pattern_template_test_item;
DROP FUNCTION IF EXISTS update_last_modified_from_pattern_template_test_item;

-- Revert for item_attribute trigger and function
DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_item_attribute ON item_attribute;
DROP FUNCTION IF EXISTS update_last_modified_from_item_attribute;

-- Drop the trigger on the pattern_template table
DROP TRIGGER IF EXISTS trg_update_test_item_last_modified_on_pattern_template ON pattern_template;
DROP FUNCTION IF EXISTS update_last_modified_from_pattern_template;