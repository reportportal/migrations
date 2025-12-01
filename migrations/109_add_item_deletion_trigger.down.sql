DROP TRIGGER IF EXISTS test_item_delete_trigger ON test_item;
DROP FUNCTION IF EXISTS track_test_item_deletes() CASCADE;
DROP TABLE IF EXISTS test_item_deleted CASCADE;