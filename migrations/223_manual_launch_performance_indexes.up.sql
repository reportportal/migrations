CREATE INDEX IF NOT EXISTS idx_tms_test_folder_test_item_launch_folder ON tms_test_folder_test_item (launch_id, test_folder_id);
CREATE INDEX IF NOT EXISTS idx_launch_test_plan_id ON launch (test_plan_id) WHERE test_plan_id IS NOT NULL;
