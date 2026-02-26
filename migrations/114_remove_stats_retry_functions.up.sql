DROP FUNCTION IF EXISTS update_executions_statistics();
DROP FUNCTION IF EXISTS increment_defect_statistics();
DROP FUNCTION IF EXISTS update_defect_statistics();
DROP FUNCTION IF EXISTS update_last_modified_on_retry();
DROP FUNCTION IF EXISTS retries_statistics();
DROP FUNCTION IF EXISTS handle_retry();
DROP FUNCTION IF EXISTS handle_retries();
DROP FUNCTION IF EXISTS delete_item_statistics();
DROP FUNCTION IF EXISTS delete_defect_statistics();
DROP FUNCTION IF EXISTS decrease_statistics();

DROP TRIGGER IF EXISTS after_issue_insert ON issue;
DROP TRIGGER IF EXISTS after_issue_update ON issue;
DROP TRIGGER IF EXISTS before_issue_delete ON issue;

DROP TRIGGER IF EXISTS after_test_results_update ON test_item_results;
DROP TRIGGER IF EXISTS before_item_delete ON test_item_results;